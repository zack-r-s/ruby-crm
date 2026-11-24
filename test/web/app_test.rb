# frozen_string_literal: true

require_relative "../test_helper"

begin
  require "rack/test"
  require_relative "../../lib/crm/web/app"
  WEB_AVAILABLE = true
rescue LoadError
  WEB_AVAILABLE = false
end

class AppTest < CRM::TestCase
  include Rack::Test::Methods if WEB_AVAILABLE

  def setup
    super
    skip "sinatra and rack-test are not installed" unless WEB_AVAILABLE

    CRM::Web::App.set :store, store
    CRM::Seeds.load!(store)
  end

  def app
    CRM::Web::App
  end

  def test_health
    get "/health"
    assert_equal 200, last_response.status
    assert_equal '{"status":"ok"}', last_response.body
  end

  def test_dashboard
    get "/"
    assert last_response.ok?
    assert_includes last_response.body, "Pipeline"
    assert_includes last_response.body, "Recent activity"
  end

  def test_contact_search
    get "/contacts", q: "avery"
    assert last_response.ok?
    assert_includes last_response.body, "Avery Lin"
    refute_includes last_response.body, "Jordan Patel"
  end

  def test_create_contact_escapes_html
    post "/contacts", contact: { first_name: "<script>alert(1)</script>", last_name: "Doe", email: "doe@acme.example" }
    assert last_response.redirect?

    follow_redirect!
    refute_includes last_response.body, "<script>alert(1)</script>"
    assert_includes last_response.body, "&lt;script&gt;"
  end

  def test_invalid_contact_returns_422_with_errors
    post "/contacts", contact: { first_name: "", last_name: "", email: "bad" }
    assert_equal 422, last_response.status
    assert_includes last_response.body, "email is invalid"
  end

  def test_missing_contact_is_404
    get "/contacts/9999"
    assert_equal 404, last_response.status
    get "/contacts/not-a-number"
    assert_equal 404, last_response.status
  end

  def test_delete_contact
    id = CRM::Repositories::ContactRepository.new(store).find_by_email("riley.chen@globex.example").id
    post "/contacts/#{id}/delete"
    assert last_response.redirect?
    assert_nil CRM::Repositories::ContactRepository.new(store).find_by_id(id)
  end

  def test_csv_export
    get "/contacts.csv"
    assert last_response.ok?
    assert_equal "text/csv", last_response.media_type
    assert_includes last_response.headers["Content-Disposition"], "contacts.csv"
    assert_includes last_response.body, "avery.lin@acme.example"
  end

  def test_deals_filter_by_stage
    get "/deals", stage: "won"
    assert last_response.ok?
    assert_includes last_response.body, "Acme support renewal"
    refute_includes last_response.body, "Globex fleet pilot"
  end
end
