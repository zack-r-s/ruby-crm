# frozen_string_literal: true

module CRM
  # Declarative validations. Each rule returns an error message, or nil when the record passes.
  module Validation
    def self.included(base)
      base.extend(ClassMethods)
    end

    def self.blank?(value)
      value.nil? || value.to_s.strip.empty?
    end

    module ClassMethods
      def validations
        @validations ||= []
      end

      def validate(&rule)
        validations << rule
      end

      def validates_presence_of(*names)
        names.each do |name|
          validate { |record| "#{name} can't be blank" if Validation.blank?(record.public_send(name)) }
        end
      end

      def validates_format_of(name, with:, allow_blank: false)
        validate do |record|
          value = record.public_send(name)
          next if allow_blank && Validation.blank?(value)

          "#{name} is invalid" unless with.match?(value.to_s)
        end
      end

      def validates_inclusion_of(name, within:, allow_blank: false)
        validate do |record|
          value = record.public_send(name)
          next if allow_blank && Validation.blank?(value)

          "#{name} must be one of: #{within.join(', ')}" unless within.include?(value)
        end
      end

      def validates_number_of(name, minimum: nil, only_integer: false, allow_blank: false)
        validate do |record|
          value = record.public_send(name)
          next if allow_blank && Validation.blank?(value)

          numeric = only_integer ? value.is_a?(Integer) : value.is_a?(Numeric)
          next "#{name} must be #{only_integer ? 'a whole number' : 'a number'}" unless numeric

          "#{name} must be at least #{minimum}" if minimum && value < minimum
        end
      end
    end

    def errors
      self.class.validations.map { |rule| rule.call(self) }.compact
    end

    def valid?
      errors.empty?
    end

    def validate!
      problems = errors
      raise ValidationError, problems unless problems.empty?

      self
    end
  end
end
