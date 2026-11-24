# frozen_string_literal: true

module CRM
  class Error < StandardError; end

  class RecordNotFound < Error; end

  class ValidationError < Error
    attr_reader :errors

    def initialize(errors)
      @errors = Array(errors)
      super("Validation failed: #{@errors.join(', ')}")
    end
  end
end
