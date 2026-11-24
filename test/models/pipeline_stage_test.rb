# frozen_string_literal: true

require_relative "../test_helper"

class PipelineStageTest < CRM::TestCase
  Stage = CRM::Models::PipelineStage

  def test_find_by_string_or_symbol
    assert_equal "Proposal", Stage.find("proposal").label
    assert_equal "Proposal", Stage.find(:proposal).label
  end

  def test_unknown_stage_raises
    assert_raises(ArgumentError) { Stage.find("someday") }
  end

  def test_closed_stages
    assert_equal %w[won lost], Stage.all.select(&:closed?).map(&:key)
    assert_equal 4, Stage.open_stages.size
  end

  def test_open_stage_probabilities_increase
    probabilities = Stage.open_stages.sort.map(&:probability)
    assert_equal probabilities.sort, probabilities
    assert(probabilities.all? { |p| p > 0 && p < 1 })
  end

  def test_stages_are_frozen
    assert Stage.find("won").frozen?
  end
end
