# frozen_string_literal: true

module CRM
  module Repositories
    class ContactRepository < BaseRepository
      TABLE = :contacts
      MODEL = Models::Contact

      def find_by_email(email)
        needle = email.to_s.strip.downcase
        return nil if needle.empty?

        all.find { |contact| contact.email == needle }
      end

      def for_company(company_id)
        where(company_id: company_id)
      end

      def with_tag(tag)
        needle = tag.to_s.strip.downcase
        all.select { |contact| contact.tags.include?(needle) }
      end

      def by_status(status)
        where(status: status)
      end

      private

      def before_save(contact)
        contact.email = contact.email.strip.downcase if contact.email.is_a?(String)
        existing = find_by_email(contact.email)
        return if existing.nil? || existing.id == contact.id

        raise ValidationError, ["email has already been taken"]
      end
    end
  end
end
