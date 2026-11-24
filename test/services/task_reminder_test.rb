# frozen_string_literal: true

require_relative "../test_helper"

class TaskReminderTest < CRM::TestCase
  def reminder_service(task_list)
    CRM::Services::TaskReminder.new(task_list, today: TODAY, window_days: 3)
  end

  def sample_tasks
    [
      build_task(title: "Send quote", assignee: "Dana", due_on: TODAY - 2),
      build_task(title: "Book kickoff", assignee: "Lee", due_on: TODAY + 1),
      build_task(title: "Prepare proposal", assignee: "Dana", due_on: TODAY + 2),
      build_task(title: "Next quarter", assignee: "Lee", due_on: TODAY + 30),
      build_task(title: "Already done", assignee: "Kim", due_on: TODAY - 1).complete!
    ]
  end

  def test_groups_by_assignee_and_skips_completed_or_distant_tasks
    reminders = reminder_service(sample_tasks).reminders
    assert_equal ["Dana", "Lee"], reminders.map(&:assignee)

    dana = reminders.first
    assert_equal ["Send quote"], dana.overdue.map(&:title)
    assert_equal ["Prepare proposal"], dana.upcoming.map(&:title)

    lee = reminders.last
    assert_empty lee.overdue
    assert_equal ["Book kickoff"], lee.upcoming.map(&:title)
  end

  def test_message
    service = reminder_service(sample_tasks)
    message = service.message_for(service.reminders.first)
    assert_equal <<~TEXT.chomp, message
      Hi Dana,

      Overdue:
        - Send quote (due 2026-03-14)

      Due in the next 3 days:
        - Prepare proposal (due 2026-03-18)
    TEXT
  end
end
