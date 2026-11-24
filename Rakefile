# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "lib" << "test"
  t.pattern = "test/**/*_test.rb"
  t.warning = false
end

task default: :test

desc "Load the sample data and print the pipeline report"
task :report do
  require_relative "lib/crm"
  require_relative "db/seeds"

  CRM::Seeds.load!
  deals = CRM::Repositories::DealRepository.new.all
  report = CRM::Services::PipelineReport.new(deals)

  puts report.to_text
  puts
  puts "Open pipeline:     #{CRM::Money.format(report.open_pipeline_cents)}"
  puts "Weighted pipeline: #{CRM::Money.format(report.weighted_pipeline_cents)}"
  puts "Win rate:          #{report.win_rate ? format('%.1f%%', report.win_rate * 100) : 'n/a'}"
end
