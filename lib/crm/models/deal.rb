# frozen_string_literal: true

require "date"

module CRM
  module Models
    class Deal < Base
      CURRENCIES = %w[USD EUR GBP].freeze

      attribute :title
      attribute :company_id
      attribute :contact_id
      attribute :amount_cents, default: 0
      attribute :currency, default: "USD"
      attribute :stage, default: "qualification"
      attribute :expected_close_on
      attribute :closed_on
      attribute :owner

      validates_presence_of :title, :company_id
      validates_number_of :amount_cents, minimum: 0, only_integer: true
      validates_inclusion_of :currency, within: CURRENCIES
      validates_inclusion_of :stage, within: PipelineStage.keys

      def pipeline_stage
        PipelineStage.find(stage)
      end

      def open?
        !pipeline_stage.closed?
      end

      def won?
        stage == "won"
      end

      def lost?
        stage == "lost"
      end

      def weighted_amount_cents
        (amount_cents * pipeline_stage.probability).round
      end

      def move_to(new_stage, on: Date.today, reopen: false)
        target = PipelineStage.find(new_stage)
        raise ArgumentError, "deal is closed; pass reopen: true to move it" if !open? && !reopen

        self.stage = target.key
        self.closed_on = target.closed? ? on : nil
        self
      end

      def overdue?(today = Date.today)
        open? && !expected_close_on.nil? && expected_close_on < today
      end
    end
  end
end
