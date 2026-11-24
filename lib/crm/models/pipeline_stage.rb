# frozen_string_literal: true

module CRM
  module Models
    # The fixed sales pipeline. A stage's probability weights open deals in the forecast.
    class PipelineStage
      include Comparable

      attr_reader :key, :label, :probability, :position

      def initialize(key, label, probability, position)
        @key = key
        @label = label
        @probability = probability
        @position = position
        freeze
      end

      def closed?
        %w[won lost].include?(key)
      end

      def <=>(other)
        return nil unless other.is_a?(PipelineStage)

        position <=> other.position
      end

      def to_s
        label
      end

      ALL = [
        new("qualification", "Qualification", 0.1, 1),
        new("discovery", "Discovery", 0.25, 2),
        new("proposal", "Proposal", 0.5, 3),
        new("negotiation", "Negotiation", 0.75, 4),
        new("won", "Closed won", 1.0, 5),
        new("lost", "Closed lost", 0.0, 6)
      ].freeze

      def self.all
        ALL
      end

      def self.keys
        ALL.map(&:key)
      end

      def self.open_stages
        ALL.reject(&:closed?)
      end

      def self.find(key)
        ALL.find { |stage| stage.key == key.to_s } || raise(ArgumentError, "unknown pipeline stage: #{key}")
      end
    end
  end
end
