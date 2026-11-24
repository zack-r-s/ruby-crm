# frozen_string_literal: true

module CRM
  module Models
    class Base
      include Validation

      class << self
        def attribute(name, default: nil)
          own_attributes[name.to_sym] = default
          attr_accessor name
        end

        # Attribute names and defaults, including those declared on parent classes.
        def attributes
          inherited = superclass.respond_to?(:attributes) ? superclass.attributes : {}
          inherited.merge(own_attributes)
        end

        private

        def own_attributes
          @own_attributes ||= {}
        end
      end

      attribute :id
      attribute :created_at
      attribute :updated_at

      def initialize(attrs = {})
        attrs = symbolize(attrs)
        unknown = attrs.keys - self.class.attributes.keys
        raise ArgumentError, "unknown attribute(s): #{unknown.join(', ')}" unless unknown.empty?

        self.class.attributes.each do |name, default|
          value = attrs.fetch(name) { default.is_a?(Proc) ? default.call : default }
          public_send("#{name}=", value)
        end
      end

      def assign(attrs)
        symbolize(attrs).each do |name, value|
          raise ArgumentError, "unknown attribute: #{name}" unless self.class.attributes.key?(name)

          public_send("#{name}=", value)
        end
        self
      end

      def to_h
        self.class.attributes.keys.each_with_object({}) { |name, out| out[name] = public_send(name) }
      end

      def persisted?
        !id.nil?
      end

      def ==(other)
        other.instance_of?(self.class) && persisted? && other.id == id
      end
      alias eql? ==

      def hash
        [self.class, id].hash
      end

      private

      def symbolize(attrs)
        attrs.each_with_object({}) { |(key, value), out| out[key.to_sym] = value }
      end
    end
  end
end
