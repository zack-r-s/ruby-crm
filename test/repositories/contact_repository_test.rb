# frozen_string_literal: true

require_relative "../test_helper"

class ContactRepositoryTest < CRM::TestCase
  def valid_attrs(overrides = {})
    { first_name: "Avery", last_name: "Lin", email: "avery.lin@acme.example" }.merge(overrides)
  end

  def test_create_assigns_id_and_timestamps
    contact = contacts.create(valid_attrs)
    assert_equal 1, contact.id
    refute_nil contact.created_at
    refute_nil contact.updated_at
  end

  def test_create_normalizes_email
    contact = contacts.create(valid_attrs(email: "  Avery.Lin@ACME.example "))
    assert_equal "avery.lin@acme.example", contact.email
  end

  def test_create_rejects_duplicate_email_case_insensitively
    contacts.create(valid_attrs)
    error = assert_raises(CRM::ValidationError) { contacts.create(valid_attrs(email: "AVERY.LIN@acme.example")) }
    assert_includes error.errors, "email has already been taken"
  end

  def test_create_ignores_protected_attributes
    contact = contacts.create(valid_attrs(id: 99, created_at: Time.at(0)))
    assert_equal 1, contact.id
    refute_equal Time.at(0), contact.created_at
  end

  def test_create_accepts_string_keys
    contact = contacts.create("first_name" => "Sam", "last_name" => "Okafor", "email" => "sam@globex.example")
    assert_equal "Sam Okafor", contact.full_name
  end

  def test_failed_update_leaves_record_unchanged
    contact = contacts.create(valid_attrs)
    assert_raises(CRM::ValidationError) { contacts.update(contact.id, email: "broken") }
    assert_equal "avery.lin@acme.example", contacts.find(contact.id).email
  end

  def test_update_keeps_own_email
    contact = contacts.create(valid_attrs)
    updated = contacts.update(contact.id, title: "COO", email: "avery.lin@acme.example")
    assert_equal "COO", updated.title
  end

  def test_update_rejects_unknown_attributes
    contact = contacts.create(valid_attrs)
    assert_raises(ArgumentError) { contacts.update(contact.id, nickname: "Ave") }
  end

  def test_find_missing_raises_and_find_by_id_returns_nil
    assert_raises(CRM::RecordNotFound) { contacts.find(404) }
    assert_nil contacts.find_by_id("not-a-number")
  end

  def test_delete
    contact = contacts.create(valid_attrs)
    contacts.delete(contact.id)
    assert_equal 0, contacts.count
  end

  def test_queries
    contacts.create(valid_attrs(company_id: 1, tags: ["vip"], status: "customer"))
    contacts.create(valid_attrs(first_name: "Riley", email: "riley@globex.example", company_id: 2))

    assert_equal ["Avery"], contacts.for_company(1).map(&:first_name)
    assert_equal ["Avery"], contacts.with_tag("VIP").map(&:first_name)
    assert_equal ["Riley"], contacts.by_status("lead").map(&:first_name)
    assert_equal "Riley", contacts.find_by_email("RILEY@globex.example").first_name
  end
end
