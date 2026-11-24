# frozen_string_literal: true

module CRM
  module Repositories
    class ActivityRepository < BaseRepository
      TABLE = :activities
      MODEL = Models::Activity

      def for_contact(contact_id)
        newest_first(where(contact_id: contact_id))
      end

      def for_deal(deal_id)
        newest_first(where(deal_id: deal_id))
      end

      def recent(limit = 10)
        newest_first(all).first(limit)
      end

      private

      def newest_first(activities)
        activities.sort_by(&:occurred_at).reverse
      end
    end
  end
end
