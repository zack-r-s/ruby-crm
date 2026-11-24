# frozen_string_literal: true

require_relative "../test_helper"

class DealRepositoryTest < CRM::TestCase
  def setup
    super
    deals.create(title: "Open early", company_id: 1, amount_cents: 1_000, stage: "proposal", expected_close_on: TODAY + 5)
    deals.create(title: "Open late", company_id: 2, amount_cents: 2_000, stage: "discovery", expected_close_on: TODAY + 60)
    deals.create(title: "Won", company_id: 1, amount_cents: 3_000, stage: "won", expected_close_on: TODAY - 3)
  end

  def test_open_and_won
    assert_equal ["Open early", "Open late"], deals.open.map(&:title)
    assert_equal ["Won"], deals.won.map(&:title)
  end

  def test_by_stage_accepts_symbols
    assert_equal ["Open early"], deals.by_stage(:proposal).map(&:title)
  end

  def test_for_company
    assert_equal ["Open early", "Won"], deals.for_company(1).map(&:title)
  end

  def test_closing_between_only_includes_open_deals
    assert_equal ["Open early"], deals.closing_between(TODAY - 10, TODAY + 30).map(&:title)
  end

  def test_create_validates
    assert_raises(CRM::ValidationError) { deals.create(title: "", company_id: nil) }
  end
end
