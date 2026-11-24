# frozen_string_literal: true

module CRM
  module Repositories
    # Subclasses set TABLE and MODEL, and may override before_save for normalization or uniqueness.
    class BaseRepository
      PROTECTED_ATTRIBUTES = %i[id created_at updated_at].freeze

      def initialize(store = CRM.store)
        @store = store
      end

      def all
        store.all(table)
      end

      def find(id)
        find_by_id(id) || raise(RecordNotFound, "#{model_name} #{id} not found")
      end

      def find_by_id(id)
        store.find(table, id)
      end

      def where(conditions)
        all.select do |record|
          conditions.all? { |name, value| record.public_send(name) == value }
        end
      end

      def count
        store.count(table)
      end

      def create(attrs)
        record = model.new(permitted(attrs))
        before_save(record)
        record.validate!
        store.insert(table, record)
      end

      # Validates a copy, so a failed update leaves the stored record unchanged.
      def update(id, attrs)
        record = find(id).dup
        record.assign(permitted(attrs))
        before_save(record)
        record.validate!
        store.update(table, record)
      end

      def delete(id)
        record = find(id)
        store.delete(table, record.id)
      end

      private

      attr_reader :store

      def table
        self.class::TABLE
      end

      def model
        self.class::MODEL
      end

      def model_name
        model.name.split("::").last
      end

      def permitted(attrs)
        attrs.each_with_object({}) do |(key, value), out|
          name = key.to_sym
          out[name] = value unless PROTECTED_ATTRIBUTES.include?(name)
        end
      end

      def before_save(_record); end
    end
  end
end
