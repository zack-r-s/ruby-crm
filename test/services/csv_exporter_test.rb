# frozen_string_literal: true

require "csv"
require_relative "../test_helper"

class CsvExporterTest < CRM::TestCase
  def export(contact_list)
    CSV.parse(CRM::Services::CsvExporter.new(companies: companies.all).call(contact_list))
  end

  def test_header_and_row
    acme = companies.create(name: "Acme Widgets", domain: "acme.example")
    contact = contacts.create(first_name: "Avery", last_name: "Lin", email: "avery.lin@acme.example",
                              company_id: acme.id, tags: ["vip", "renewal"])

    rows = export([contact])
    assert_equal CRM::Services::CsvExporter::HEADERS, rows.first
    assert_equal ["1", "Avery", "Lin", "avery.lin@acme.example", nil, nil, "Acme Widgets", "lead", "vip; renewal"],
                 rows.last
  end

  def test_formula_cells_are_neutralized
    contact = contacts.create(first_name: "=HYPERLINK(\"http://example.invalid\")", last_name: "+cmd",
                              email: "formula@acme.example", title: "@SUM(A1)")
    row = export([contact]).last
    assert_equal "'=HYPERLINK(\"http://example.invalid\")", row[1]
    assert_equal "'+cmd", row[2]
    assert_equal "'@SUM(A1)", row[5]
  end

  def test_empty_export_has_only_headers
    assert_equal [CRM::Services::CsvExporter::HEADERS], export([])
  end
end
