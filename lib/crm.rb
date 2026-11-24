# frozen_string_literal: true

require_relative "crm/version"
require_relative "crm/errors"
require_relative "crm/money"
require_relative "crm/validation"
require_relative "crm/store"

require_relative "crm/models/base"
require_relative "crm/models/pipeline_stage"
require_relative "crm/models/company"
require_relative "crm/models/contact"
require_relative "crm/models/deal"
require_relative "crm/models/activity"
require_relative "crm/models/task"

require_relative "crm/repositories/base_repository"
require_relative "crm/repositories/company_repository"
require_relative "crm/repositories/contact_repository"
require_relative "crm/repositories/deal_repository"
require_relative "crm/repositories/activity_repository"
require_relative "crm/repositories/task_repository"

require_relative "crm/services/contact_search"
require_relative "crm/services/csv_exporter"
require_relative "crm/services/pipeline_report"
require_relative "crm/services/deal_forecast"
require_relative "crm/services/task_reminder"

module CRM
  def self.store
    @store ||= Store.new
  end

  def self.reset!
    @store = Store.new
  end
end
