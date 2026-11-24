# frozen_string_literal: true

require_relative "../test_helper"

class PipelineReportTest < CRM::TestCase
  def report(deals)
    CRM::Services::PipelineReport.new(deals)
  end

  def sample_deals
    [
      build_deal(stage: "proposal", amount_cents: 100_000),
      build_deal(stage: "proposal", amount_cents: 50_000),
      build_deal(stage: "negotiation", amount_cents: 200_000),
      build_deal(stage: "won", amount_cents: 80_000),
      build_deal(stage: "lost", amount_cents: 40_000)
    ]
  end

  def test_rows_cover_every_stage
    rows = report(sample_deals).rows
    assert_equal CRM::Models::PipelineStage.keys, rows.map { |row| row.stage.key }

    proposal = rows.find { |row| row.stage.key == "proposal" }
    assert_equal 2, proposal.count
    assert_equal 150_000, proposal.amount_cents
    assert_equal 75_000, proposal.weighted_cents
  end

  def test_pipeline_totals_exclude_closed_deals
    assert_equal 350_000, report(sample_deals).open_pipeline_cents
    assert_equal 225_000, report(sample_deals).weighted_pipeline_cents
  end

  def test_win_rate
    assert_equal 0.5, report(sample_deals).win_rate
    assert_nil report([build_deal]).win_rate
  end

  def test_to_text
    text = report(sample_deals).to_text
    assert_match(/^Stage\s+Deals/, text)
    assert_match(/^Proposal\s+2\s+\$1,500\.00\s+\$750\.00$/, text)
  end
end
