# frozen_string_literal: true

require_relative "../test_helper"

class ContactTest < CRM::TestCase
  def test_valid_contact
    assert build_contact.valid?
  end

  def test_requires_names_and_email
    errors = CRM::Models::Contact.new.errors
    assert_includes errors, "first_name can't be blank"
    assert_includes errors, "last_name can't be blank"
    assert_includes errors, "email can't be blank"
  end

  def test_rejects_malformed_email
    assert_includes build_contact(email: "not-an-email").errors, "email is invalid"
  end

  def test_rejects_unknown_status
    assert(build_contact(status: "vip").errors.any? { |error| error.start_with?("status must be one of") })
  end

  def test_full_name
    assert_equal "Avery Lin", build_contact.full_name
  end

  def test_tag_normalizes_and_skips_duplicates_and_blanks
    contact = build_contact
    contact.tag(" VIP ").tag("vip").tag("")
    assert_equal ["vip"], contact.tags
  end

  def test_untag
    contact = build_contact(tags: ["vip", "renewal"])
    contact.untag("VIP")
    assert_equal ["renewal"], contact.tags
  end

  def test_default_tags_are_not_shared
    build_contact.tag("vip")
    assert_empty build_contact.tags
  end

  def test_unknown_attribute_raises
    assert_raises(ArgumentError) { CRM::Models::Contact.new(nickname: "Ave") }
  end

  def test_validate_raises_with_messages
    error = assert_raises(CRM::ValidationError) { build_contact(email: "").validate! }
    assert_includes error.errors, "email can't be blank"
  end
end
