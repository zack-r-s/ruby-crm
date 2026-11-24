# frozen_string_literal: true

require "rack/utils"

module CRM
  module Web
    module Helpers
      def h(value)
        Rack::Utils.escape_html(value.to_s)
      end

      def money(cents, currency = "USD")
        Money.format(cents.to_i, currency)
      end

      def date(value)
        value ? value.strftime("%b %-d, %Y") : "—"
      end

      def stage_label(key)
        Models::PipelineStage.find(key).label
      rescue ArgumentError
        key.to_s
      end

      def status_badge(status)
        %(<span class="badge badge-#{h(status)}">#{h(status)}</span>)
      end

      def csrf_tag
        token = Rack::Protection::AuthenticityToken.token(session)
        %(<input type="hidden" name="authenticity_token" value="#{h(token)}">)
      end

      def selected(current, value)
        current.to_s == value.to_s ? " selected" : ""
      end
    end
  end
end
