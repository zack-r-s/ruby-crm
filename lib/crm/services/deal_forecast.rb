# frozen_string_literal: true

require "date"

module CRM
  module Services
    # Weighted revenue forecast for open deals, bucketed by expected close month.
    class DealForecast
      def initialize(deals, today: Date.today)
        @deals = deals
        @today = today
      end

      # Returns { "YYYY-MM" => weighted cents } for this month and the following months, including
      # months with nothing expected to close.
      def by_month(months: 3)
        buckets = month_keys(months).each_with_object({}) { |key, out| out[key] = 0 }
        @deals.each do |deal|
          next unless deal.open? && deal.expected_close_on

          key = deal.expected_close_on.strftime("%Y-%m")
          buckets[key] += deal.weighted_amount_cents if buckets.key?(key)
        end
        buckets
      end

      def total(months: 3)
        by_month(months: months).values.sum
      end

      # Open deals whose expected close date has passed.
      def slipped
        @deals.select { |deal| deal.overdue?(@today) }.sort_by(&:expected_close_on)
      end

      private

      def month_keys(months)
        first_of_month = Date.new(@today.year, @today.month, 1)
        (0...months).map { |offset| (first_of_month >> offset).strftime("%Y-%m") }
      end
    end
  end
end
