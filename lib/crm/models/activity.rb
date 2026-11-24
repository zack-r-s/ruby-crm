# frozen_string_literal: true

module CRM
  module Models
    # A logged interaction: a call, email, meeting or free-form note.
    class Activity < Base
      KINDS = %w[call email meeting note].freeze

      attribute :kind, default: "note"
      attribute :summary
      attribute :contact_id
      attribute :deal_id
      attribute :author
      attribute :occurred_at, default: -> { Time.now }

      validates_presence_of :summary
      validates_inclusion_of :kind, within: KINDS
      validate { |activity| "contact_id or deal_id is required" if activity.contact_id.nil? && activity.deal_id.nil? }
    end
  end
end
