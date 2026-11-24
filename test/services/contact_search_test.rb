# frozen_string_literal: true

require_relative "../test_helper"

class ContactSearchTest < CRM::TestCase
  def setup
    super
    @acme = companies.create(name: "Acme Widgets", domain: "acme.example")
    @globex = companies.create(name: "Globex Logistics", domain: "globex.example")
    contacts.create(first_name: "Avery", last_name: "Lin", email: "avery.lin@acme.example",
                    company_id: @acme.id, status: "customer", tags: ["vip"])
    contacts.create(first_name: "Sam", last_name: "Okafor", email: "sam.okafor@globex.example",
                    company_id: @globex.id, status: "prospect", tags: ["vip"], title: "VP Supply Chain")
    contacts.create(first_name: "Riley", last_name: "Chen", email: "riley.chen@globex.example",
                    company_id: @globex.id)
  end

  def search(query)
    CRM::Services::ContactSearch.new(contacts: contacts.all, companies: companies.all).call(query).map(&:first_name)
  end

  def test_free_text_matches_name_email_title_and_company
    assert_equal ["Avery"], search("lin")
    assert_equal ["Sam"], search("supply")
    assert_equal ["Sam", "Riley"], search("globex")
  end

  def test_all_terms_must_match
    assert_equal ["Sam"], search("globex okafor")
    assert_empty search("globex avery")
  end

  def test_filters
    assert_equal ["Avery", "Sam"], search("tag:vip")
    assert_equal ["Avery"], search("tag:vip status:customer")
    assert_equal ["Sam", "Riley"], search("company:globex")
    assert_equal ["Riley"], search("status:lead company:globex")
  end

  def test_blank_query_returns_everyone
    assert_equal ["Avery", "Sam", "Riley"], search("  ")
  end
end
