# frozen_string_literal: true

require_relative "../test_helper"

class TaskTest < CRM::TestCase
  def test_requires_title_and_assignee
    errors = CRM::Models::Task.new.errors
    assert_includes errors, "title can't be blank"
    assert_includes errors, "assignee can't be blank"
  end

  def test_due_on_must_be_a_date
    assert_includes build_task(due_on: "tomorrow").errors, "due_on must be a date"
  end

  def test_complete_keeps_first_completion_time
    first = Time.at(1_000)
    task = build_task.complete!(first).complete!(Time.at(2_000))
    assert task.completed?
    assert_equal first, task.completed_at
  end

  def test_overdue
    assert build_task(due_on: TODAY - 1).overdue?(TODAY)
    refute build_task(due_on: TODAY).overdue?(TODAY)
    refute build_task(due_on: TODAY - 1).complete!.overdue?(TODAY)
  end

  def test_due_within
    assert build_task(due_on: TODAY + 3).due_within?(3, TODAY)
    refute build_task(due_on: TODAY + 4).due_within?(3, TODAY)
    refute build_task(due_on: TODAY - 1).due_within?(3, TODAY)
  end
end
