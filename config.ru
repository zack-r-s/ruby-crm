# frozen_string_literal: true

require_relative "lib/crm"
require_relative "lib/crm/web/app"

if ENV["CRM_SEED"] == "1"
  require_relative "db/seeds"
  CRM::Seeds.load!
end

run CRM::Web::App
