# frozen_string_literal: true

module CRM
  module Models
    class Contact < Base
      EMAIL_FORMAT = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/.freeze
      STATUSES = %w[lead prospect customer churned].freeze

      attribute :first_name
      attribute :last_name
      attribute :email
      attribute :phone
      attribute :title
      attribute :company_id
      attribute :status, default: "lead"
      attribute :tags, default: -> { [] }

      validates_presence_of :first_name, :last_name, :email
      validates_format_of :email, with: EMAIL_FORMAT
      validates_inclusion_of :status, within: STATUSES

      def full_name
        [first_name, last_name].compact.join(" ")
      end

      def customer?
        status == "customer"
      end

      def tag(name)
        normalized = name.to_s.strip.downcase
        tags << normalized unless normalized.empty? || tags.include?(normalized)
        self
      end

      def untag(name)
        tags.delete(name.to_s.strip.downcase)
        self
      end
    end
  end
end
