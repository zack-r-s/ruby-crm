# frozen_string_literal: true

require_relative "../test_helper"

class DealForecastTest < CRM::TestCase
  def forecast(deal_list)
    CRM::Services::DealForecast.new(deal_list, today: TODAY)
  end

  def test_buckets_include_empty_months
    result = forecast([]).by_month(months: 3)
    assert_equal({ "2026-03" => 0, "2026-04" => 0, "2026-05" => 0 }, result)
  end

  def test_weights_open_deals_by_close_month
    deal_list = [
      build_deal(stage: "proposal", amount_cents: 100_000, expected_close_on: Date.new(2026, 3, 30)),
      build_deal(stage: "negotiation", amount_cents: 100_000, expected_close_on: Date.new(2026, 4, 2)),
      build_deal(stage: "won", amount_cents: 100_000, expected_close_on: Date.new(2026, 4, 3)),
      build_deal(stage: "proposal", amount_cents: 100_000, expected_close_on: Date.new(2026, 9, 1)),
      build_deal(stage: "proposal", amount_cents: 100_000, expected_close_on: nil)
    ]
    result = forecast(deal_list).by_month(months: 3)
    assert_equal({ "2026-03" => 50_000, "2026-04" => 75_000, "2026-05" => 0 }, result)
    assert_equal 125_000, forecast(deal_list).total(months: 3)
  end

  def test_slipped_deals
    late = build_deal(title: "Late", stage: "proposal", expected_close_on: TODAY - 7)
    later = build_deal(title: "Later", stage: "discovery", expected_close_on: TODAY - 2)
    on_time = build_deal(title: "On time", stage: "proposal", expected_close_on: TODAY + 1)
    closed = build_deal(title: "Closed", stage: "lost", expected_close_on: TODAY - 9)

    assert_equal ["Late", "Later"], forecast([later, on_time, closed, late]).slipped.map(&:title)
  end
end
