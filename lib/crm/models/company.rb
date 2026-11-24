# frozen_string_literal: true

module CRM
  module Models
    class Company < Base
      DOMAIN_FORMAT = /\A(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z]{2,}\z/i.freeze
      INDUSTRIES = %w[manufacturing logistics software healthcare retail finance education other].freeze

      attribute :name
      attribute :domain
      attribute :industry, default: "other"
      attribute :employee_count

      validates_presence_of :name
      validates_format_of :domain, with: DOMAIN_FORMAT, allow_blank: true
      validates_inclusion_of :industry, within: INDUSTRIES
      validates_number_of :employee_count, minimum: 0, only_integer: true, allow_blank: true

      def size_band
        case employee_count
        when nil then "unknown"
        when 0..49 then "small"
        when 50..999 then "mid-market"
        else "enterprise"
        end
      end
    end
  end
end
