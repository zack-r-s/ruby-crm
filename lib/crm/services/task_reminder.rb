# frozen_string_literal: true

require "date"

module CRM
  module Services
    # Groups each assignee's overdue and upcoming tasks and renders a plain-text reminder.
    class TaskReminder
      Reminder = Struct.new(:assignee, :overdue, :upcoming, keyword_init: true) do
        def empty?
          overdue.empty? && upcoming.empty?
        end
      end

      def initialize(tasks, today: Date.today, window_days: 3)
        @tasks = tasks
        @today = today
        @window_days = window_days
      end

      def reminders
        @tasks.reject(&:completed?).group_by(&:assignee).sort_by(&:first).map do |assignee, tasks|
          Reminder.new(
            assignee: assignee,
            overdue: tasks.select { |task| task.overdue?(@today) }.sort_by(&:due_on),
            upcoming: tasks.select { |task| task.due_within?(@window_days, @today) }.sort_by(&:due_on)
          )
        end.reject(&:empty?)
      end

      def message_for(reminder)
        lines = ["Hi #{reminder.assignee},"]
        append_section(lines, "Overdue:", reminder.overdue)
        append_section(lines, "Due in the next #{@window_days} days:", reminder.upcoming)
        lines.join("\n")
      end

      private

      def append_section(lines, heading, tasks)
        return if tasks.empty?

        lines << "" << heading
        tasks.each { |task| lines << "  - #{task.title} (due #{task.due_on.iso8601})" }
      end
    end
  end
end
