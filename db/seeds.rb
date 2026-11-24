# frozen_string_literal: true

require "date"
require_relative "../lib/crm"

module CRM
  # Fictional sample data. Email domains use the reserved .example TLD and phone numbers use the
  # 555-01xx range, so nothing here belongs to a real person or company.
  module Seeds
    COMPANIES = [
      { name: "Acme Widgets", domain: "acme.example", industry: "manufacturing", employee_count: 120 },
      { name: "Globex Logistics", domain: "globex.example", industry: "logistics", employee_count: 860 },
      { name: "Initech Software", domain: "initech.example", industry: "software", employee_count: 45 },
      { name: "Northwind Clinics", domain: "northwind.example", industry: "healthcare", employee_count: 2300 }
    ].freeze

    CONTACTS = [
      ["Avery", "Lin", "acme.example", "Head of Operations", "customer", %w[vip renewal]],
      ["Jordan", "Patel", "acme.example", "Plant Manager", "customer", %w[champion]],
      ["Sam", "Okafor", "globex.example", "VP Supply Chain", "prospect", %w[vip]],
      ["Riley", "Chen", "globex.example", "IT Director", "lead", []],
      ["Morgan", "Diaz", "initech.example", "CTO", "prospect", %w[technical]],
      ["Casey", "Novak", "initech.example", "Office Manager", "churned", []],
      ["Taylor", "Brooks", "northwind.example", "Chief Medical Officer", "lead", %w[executive]],
      ["Jamie", "Rivera", "northwind.example", "Procurement Lead", "prospect", %w[procurement]]
    ].freeze

    module_function

    def load!(store = CRM.store, today: Date.today)
      companies = Repositories::CompanyRepository.new(store)
      contacts = Repositories::ContactRepository.new(store)
      deals = Repositories::DealRepository.new(store)
      activities = Repositories::ActivityRepository.new(store)
      tasks = Repositories::TaskRepository.new(store)

      company_ids = COMPANIES.each_with_object({}) do |attrs, ids|
        ids[attrs[:domain]] = companies.create(attrs).id
      end

      contact_ids = CONTACTS.each_with_index.map do |(first, last, domain, title, status, tags), index|
        contacts.create(
          first_name: first,
          last_name: last,
          email: "#{first}.#{last}@#{domain}".downcase,
          phone: format("(555) 010-%04d", 100 + index),
          title: title,
          company_id: company_ids.fetch(domain),
          status: status,
          tags: tags.dup
        ).id
      end

      deal_specs = [
        ["Acme line expansion", "acme.example", 0, 4_800_000, "negotiation", 12, "Dana"],
        ["Acme support renewal", "acme.example", 1, 1_250_000, "won", -20, "Dana"],
        ["Globex fleet pilot", "globex.example", 2, 2_200_000, "proposal", 30, "Lee"],
        ["Globex warehouse rollout", "globex.example", 3, 9_500_000, "discovery", 75, "Lee"],
        ["Initech seat upgrade", "initech.example", 4, 600_000, "qualification", 45, "Dana"],
        ["Initech add-on", "initech.example", 5, 300_000, "lost", -40, "Lee"],
        ["Northwind clinic network", "northwind.example", 6, 15_000_000, "discovery", 90, "Dana"],
        ["Northwind scheduling module", "northwind.example", 7, 1_800_000, "proposal", -5, "Lee"]
      ]
      deal_ids = deal_specs.map do |title, domain, contact_index, cents, stage, close_in_days, owner|
        closed = %w[won lost].include?(stage)
        deals.create(
          title: title,
          company_id: company_ids.fetch(domain),
          contact_id: contact_ids[contact_index],
          amount_cents: cents,
          stage: stage,
          expected_close_on: today + close_in_days,
          closed_on: closed ? today + close_in_days : nil,
          owner: owner
        ).id
      end

      [
        ["call", "Walked through expansion pricing", 0, 0, 2],
        ["meeting", "Quarterly business review", 1, 1, 9],
        ["email", "Sent pilot scope and timeline", 2, 2, 1],
        ["note", "Prefers a phased rollout", 3, 3, 4],
        ["call", "Technical deep dive on integrations", 4, 4, 6],
        ["meeting", "Intro with clinical leadership", 6, 6, 3]
      ].each do |kind, summary, contact_index, deal_index, days_ago|
        activities.create(
          kind: kind,
          summary: summary,
          contact_id: contact_ids[contact_index],
          deal_id: deal_ids[deal_index],
          author: "Dana",
          occurred_at: Time.now - (days_ago * 86_400)
        )
      end

      [
        ["Send revised expansion quote", "Dana", -2, 0],
        ["Book pilot kickoff", "Lee", 1, 2],
        ["Confirm procurement contact", "Lee", 3, 7],
        ["Prepare clinic network proposal", "Dana", 6, 6],
        ["Follow up on seat upgrade", "Dana", -1, 4]
      ].each do |title, assignee, due_in_days, deal_index|
        tasks.create(
          title: title,
          assignee: assignee,
          due_on: today + due_in_days,
          deal_id: deal_ids[deal_index]
        )
      end

      {
        companies: companies.count,
        contacts: contacts.count,
        deals: deals.count,
        activities: activities.count,
        tasks: tasks.count
      }
    end
  end
end
