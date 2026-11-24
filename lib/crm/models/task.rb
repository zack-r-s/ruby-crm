# frozen_string_literal: true

require "date"

module CRM
  module Models
    class Task < Base
      attribute :title
      attribute :assignee
      attribute :due_on
      attribute :contact_id
      attribute :deal_id
      attribute :completed_at

      validates_presence_of :title, :assignee
      validate { |task| "due_on must be a date" unless task.due_on.nil? || task.due_on.is_a?(Date) }

      def completed?
        !completed_at.nil?
      end

      def complete!(at = Time.now)
        self.completed_at ||= at
        self
      end

      def overdue?(today = Date.today)
        !completed? && !due_on.nil? && due_on < today
      end

      def due_within?(days, today = Date.today)
        !completed? && !due_on.nil? && due_on >= today && due_on <= today + days
      end
    end
  end
end
