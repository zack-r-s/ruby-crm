# frozen_string_literal: true

module CRM
  # Amounts are stored as integer cents to avoid floating point rounding.
  module Money
    SYMBOLS = { "USD" => "$", "EUR" => "€", "GBP" => "£" }.freeze
    AMOUNT = /\A\d+(?:\.\d{1,2})?\z/.freeze

    module_function

    def format(cents, currency = "USD")
      whole, fraction = cents.abs.divmod(100)
      grouped = whole.to_s.reverse.scan(/\d{1,3}/).join(",").reverse
      sign = cents.negative? ? "-" : ""
      "#{sign}#{SYMBOLS.fetch(currency, '')}#{grouped}.#{fraction.to_s.rjust(2, '0')}"
    end

    def parse(text)
      cleaned = text.to_s.strip.delete(",").sub(/\A[$€£]/, "")
      raise ArgumentError, "invalid amount: #{text.inspect}" unless AMOUNT.match?(cleaned)

      whole, fraction = cleaned.split(".")
      (whole.to_i * 100) + fraction.to_s.ljust(2, "0").to_i
    end
  end
end
