# frozen_string_literal: true

module CRM
  module Repositories
    class CompanyRepository < BaseRepository
      TABLE = :companies
      MODEL = Models::Company

      def find_by_domain(domain)
        needle = domain.to_s.strip.downcase
        return nil if needle.empty?

        all.find { |company| company.domain == needle }
      end

      def in_industry(industry)
        where(industry: industry)
      end

      private

      def before_save(company)
        company.domain = company.domain.strip.downcase if company.domain.is_a?(String)
        company.domain = nil if company.domain == ""
        existing = find_by_domain(company.domain)
        return if existing.nil? || existing.id == company.id

        raise ValidationError, ["domain has already been taken"]
      end
    end
  end
end
