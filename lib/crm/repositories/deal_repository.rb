# frozen_string_literal: true

module CRM
  module Repositories
    class DealRepository < BaseRepository
      TABLE = :deals
      MODEL = Models::Deal

      def open
        all.select(&:open?)
      end

      def won
        where(stage: "won")
      end

      def by_stage(stage)
        where(stage: stage.to_s)
      end

      def for_company(company_id)
        where(company_id: company_id)
      end

      def closing_between(from, to)
        open.select do |deal|
          deal.expected_close_on && deal.expected_close_on >= from && deal.expected_close_on <= to
        end
      end
    end
  end
end
