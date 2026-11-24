# frozen_string_literal: true

require "csv"

module CRM
  module Services
    # Exports contacts to CSV. Spreadsheets evaluate cells that start with a formula character, so
    # those cells get a leading single quote.
    class CsvExporter
      HEADERS = ["ID", "First name", "Last name", "Email", "Phone", "Title", "Company", "Status", "Tags"].freeze
      FORMULA_PREFIXES = ["=", "+", "-", "@", "\t", "\r"].freeze

      def initialize(companies: [])
        @companies_by_id = companies.each_with_object({}) { |company, index| index[company.id] = company }
      end

      def call(contacts)
        CSV.generate do |csv|
          csv << HEADERS
          contacts.each { |contact| csv << row(contact).map { |value| sanitize(value) } }
        end
      end

      private

      def row(contact)
        company = @companies_by_id[contact.company_id]
        [
          contact.id,
          contact.first_name,
          contact.last_name,
          contact.email,
          contact.phone,
          contact.title,
          company && company.name,
          contact.status,
          contact.tags.join("; ")
        ]
      end

      def sanitize(value)
        return value unless value.is_a?(String)

        FORMULA_PREFIXES.any? { |prefix| value.start_with?(prefix) } ? "'#{value}" : value
      end
    end
  end
end
