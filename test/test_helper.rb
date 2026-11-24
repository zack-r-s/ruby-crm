# frozen_string_literal: true

ENV["APP_ENV"] = "test"
ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "date"
require_relative "../lib/crm"
require_relative "../db/seeds"

module CRM
  class TestCase < Minitest::Test
    TODAY = Date.new(2026, 3, 16)

    def setup
      @store = Store.new
    end

    attr_reader :store

    def contacts
      @contacts ||= Repositories::ContactRepository.new(store)
    end

    def companies
      @companies ||= Repositories::CompanyRepository.new(store)
    end

    def deals
      @deals ||= Repositories::DealRepository.new(store)
    end

    def tasks
      @tasks ||= Repositories::TaskRepository.new(store)
    end

    def build_contact(overrides = {})
      Models::Contact.new({ first_name: "Avery", last_name: "Lin", email: "avery.lin@acme.example" }.merge(overrides))
    end

    def build_company(overrides = {})
      Models::Company.new({ name: "Acme Widgets", domain: "acme.example", industry: "manufacturing" }.merge(overrides))
    end

    def build_deal(overrides = {})
      Models::Deal.new({ title: "Pilot", company_id: 1, amount_cents: 100_000 }.merge(overrides))
    end

    def build_task(overrides = {})
      Models::Task.new({ title: "Follow up", assignee: "Dana", due_on: TODAY }.merge(overrides))
    end
  end
end
