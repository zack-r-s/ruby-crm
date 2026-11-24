# frozen_string_literal: true

require "monitor"

module CRM
  # In-memory tables keyed by record ID. Safe to share between request threads.
  class Store
    def initialize
      @tables = Hash.new { |hash, table| hash[table] = {} }
      @sequences = Hash.new(0)
      @monitor = Monitor.new
    end

    def insert(table, record)
      synchronize do
        @sequences[table] += 1
        now = Time.now
        record.id = @sequences[table]
        record.created_at ||= now
        record.updated_at = now
        @tables[table][record.id] = record
      end
    end

    def update(table, record)
      synchronize do
        raise RecordNotFound, "#{table} #{record.id} not found" unless @tables[table].key?(record.id)

        record.updated_at = Time.now
        @tables[table][record.id] = record
      end
    end

    def find(table, id)
      key = normalize_id(id)
      synchronize { @tables[table][key] }
    end

    def all(table)
      synchronize { @tables[table].values.sort_by(&:id) }
    end

    def delete(table, id)
      key = normalize_id(id)
      synchronize { @tables[table].delete(key) }
    end

    def count(table)
      synchronize { @tables[table].size }
    end

    def clear!
      synchronize do
        @tables.clear
        @sequences.clear
      end
    end

    private

    def synchronize(&block)
      @monitor.synchronize(&block)
    end

    def normalize_id(id)
      return id if id.is_a?(Integer)

      Integer(id.to_s, 10)
    rescue ArgumentError
      nil
    end
  end
end
