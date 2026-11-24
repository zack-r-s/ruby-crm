# frozen_string_literal: true

module CRM
  module Services
    # Deal counts and amounts per pipeline stage. Amounts are summed as-is: mixed currencies are not
    # converted.
    class PipelineReport
      Row = Struct.new(:stage, :count, :amount_cents, :weighted_cents, keyword_init: true)

      def initialize(deals)
        @deals = deals
      end

      def rows
        Models::PipelineStage.all.map do |stage|
          in_stage = @deals.select { |deal| deal.stage == stage.key }
          Row.new(
            stage: stage,
            count: in_stage.size,
            amount_cents: in_stage.sum(&:amount_cents),
            weighted_cents: in_stage.sum(&:weighted_amount_cents)
          )
        end
      end

      def open_pipeline_cents
        open_deals.sum(&:amount_cents)
      end

      def weighted_pipeline_cents
        open_deals.sum(&:weighted_amount_cents)
      end

      # Share of closed deals that were won, or nil when no deal has closed yet.
      def win_rate
        closed = @deals.reject(&:open?)
        return nil if closed.empty?

        (closed.count(&:won?).to_f / closed.size).round(3)
      end

      def to_text
        header = format("%-14s %5s %14s %14s", "Stage", "Deals", "Amount", "Weighted")
        lines = rows.map do |row|
          format(
            "%-14s %5d %14s %14s",
            row.stage.label, row.count, Money.format(row.amount_cents), Money.format(row.weighted_cents)
          )
        end
        ([header] + lines).join("\n")
      end

      private

      def open_deals
        @deals.select(&:open?)
      end
    end
  end
end
