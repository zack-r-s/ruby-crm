# frozen_string_literal: true

require_relative "../test_helper"

class CompanyTest < CRM::TestCase
  def test_valid_company
    assert build_company.valid?
  end

  def test_requires_name
    assert_includes build_company(name: " ").errors, "name can't be blank"
  end

  def test_domain_is_optional
    assert build_company(domain: nil).valid?
  end

  def test_rejects_malformed_domain
    assert_includes build_company(domain: "not a domain").errors, "domain is invalid"
  end

  def test_rejects_negative_employee_count
    assert_includes build_company(employee_count: -1).errors, "employee_count must be at least 0"
  end

  def test_rejects_fractional_employee_count
    assert_includes build_company(employee_count: 10.5).errors, "employee_count must be a whole number"
  end

  def test_size_bands
    assert_equal "unknown", build_company.size_band
    assert_equal "small", build_company(employee_count: 12).size_band
    assert_equal "mid-market", build_company(employee_count: 400).size_band
    assert_equal "enterprise", build_company(employee_count: 5000).size_band
  end
end
