# frozen_string_literal: true

module CRM
  module Services
    # Free-text contact search with optional filters, for example "status:customer tag:vip lin".
    # Plain terms must all appear in the contact's name, email, title, company or tags.
    class ContactSearch
      FILTER = /\A(tag|status|company):(.+)\z/.freeze

      def initialize(contacts:, companies: [])
        @contacts = contacts
        @companies_by_id = companies.each_with_object({}) { |company, index| index[company.id] = company }
      end

      def call(query)
        terms, filters = parse(query)
        @contacts.select do |contact|
          matches_filters?(contact, filters) && terms.all? { |term| haystack(contact).include?(term) }
        end
      end

      private

      def parse(query)
        terms = []
        filters = Hash.new { |hash, name| hash[name] = [] }
        query.to_s.downcase.split.each do |token|
          match = FILTER.match(token)
          if match
            filters[match[1]] << match[2]
          else
            terms << token
          end
        end
        [terms, filters]
      end

      def matches_filters?(contact, filters)
        filters.all? do |name, values|
          case name
          when "tag" then values.all? { |value| contact.tags.include?(value) }
          when "status" then values.include?(contact.status)
          when "company" then values.any? { |value| company_name(contact).include?(value) }
          else false
          end
        end
      end

      def haystack(contact)
        [contact.full_name, contact.email, contact.title, company_name(contact), contact.tags.join(" ")]
          .compact.join(" ").downcase
      end

      def company_name(contact)
        company = @companies_by_id[contact.company_id]
        company ? company.name.downcase : ""
      end
    end
  end
end
