# frozen_string_literal: true

require "date"

module CRM
  module Repositories
    class TaskRepository < BaseRepository
      TABLE = :tasks
      MODEL = Models::Task

      def open
        all.reject(&:completed?)
      end

      def overdue(today = Date.today)
        all.select { |task| task.overdue?(today) }
      end

      def due_within(days, today = Date.today)
        all.select { |task| task.due_within?(days, today) }
      end

      def for_assignee(assignee)
        where(assignee: assignee)
      end

      def complete(id, at = Time.now)
        task = find(id).dup
        task.complete!(at)
        store.update(TABLE, task)
      end
    end
  end
end
