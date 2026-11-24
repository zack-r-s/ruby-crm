# frozen_string_literal: true

require_relative "../test_helper"

class DealTest < CRM::TestCase
  def test_defaults
    deal = build_deal
    assert_equal "qualification", deal.stage
    assert_equal "USD", deal.currency
    assert deal.open?
  end

  def test_rejects_unknown_stage_and_currency
    errors = build_deal(stage: "maybe", currency: "XYZ").errors
    assert(errors.any? { |error| error.start_with?("stage must be one of") })
    assert(errors.any? { |error| error.start_with?("currency must be one of") })
  end

  def test_rejects_float_amounts
    assert_includes build_deal(amount_cents: 10.5).errors, "amount_cents must be a whole number"
  end

  def test_weighted_amount_uses_stage_probability
    assert_equal 50_000, build_deal(stage: "proposal").weighted_amount_cents
    assert_equal 0, build_deal(stage: "lost").weighted_amount_cents
  end

  def test_move_to_won_sets_closed_on
    deal = build_deal.move_to("won", on: TODAY)
    assert deal.won?
    refute deal.open?
    assert_equal TODAY, deal.closed_on
  end

  def test_closed_deal_needs_reopen
    deal = build_deal(stage: "lost", closed_on: TODAY)
    assert_raises(ArgumentError) { deal.move_to("proposal") }

    deal.move_to("proposal", reopen: true)
    assert_equal "proposal", deal.stage
    assert_nil deal.closed_on
  end

  def test_move_to_unknown_stage_raises
    assert_raises(ArgumentError) { build_deal.move_to("someday") }
  end

  def test_overdue
    assert build_deal(expected_close_on: TODAY - 1).overdue?(TODAY)
    refute build_deal(expected_close_on: TODAY).overdue?(TODAY)
    refute build_deal(stage: "won", expected_close_on: TODAY - 1).overdue?(TODAY)
  end
end
