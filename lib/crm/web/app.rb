# frozen_string_literal: true

require "securerandom"
require "sinatra/base"
require_relative "../../crm"
require_relative "helpers"

module CRM
  module Web
    class App < Sinatra::Base
      set :root, File.expand_path("../../..", __dir__)
      set :store, CRM.store
      set :sessions, key: "crm.session", httponly: true, same_site: :lax
      set :session_secret, ENV.fetch("SESSION_SECRET") { SecureRandom.hex(64) }

      configure :development, :production do
        use Rack::Protection::AuthenticityToken
      end

      helpers Helpers

      get "/health" do
        content_type :json
        '{"status":"ok"}'
      end

      get "/" do
        all_deals = deals.all
        @report = Services::PipelineReport.new(all_deals)
        @forecast = Services::DealForecast.new(all_deals).by_month(months: 3)
        @reminders = Services::TaskReminder.new(tasks.all).reminders
        @recent = activities.recent(5)
        erb :dashboard
      end

      get "/contacts" do
        @query = params["q"].to_s.strip
        @contacts =
          if @query.empty?
            contacts.all
          else
            Services::ContactSearch.new(contacts: contacts.all, companies: companies.all).call(@query)
          end
        erb :"contacts/index"
      end

      get "/contacts.csv" do
        content_type "text/csv"
        attachment "contacts.csv"
        Services::CsvExporter.new(companies: companies.all).call(contacts.all)
      end

      get "/contacts/new" do
        @contact = Models::Contact.new
        render_contact_form([])
      end

      post "/contacts" do
        contact = contacts.create(contact_params)
        redirect to("/contacts/#{contact.id}")
      rescue ValidationError => e
        @contact = Models::Contact.new(contact_params)
        status 422
        render_contact_form(e.errors)
      end

      get "/contacts/:id" do
        @contact = find_or_404(contacts, params["id"])
        @company = @contact.company_id && companies.find_by_id(@contact.company_id)
        @activities = activities.for_contact(@contact.id)
        @deals = deals.all.select { |deal| deal.contact_id == @contact.id }
        erb :"contacts/show"
      end

      post "/contacts/:id/delete" do
        contact = find_or_404(contacts, params["id"])
        contacts.delete(contact.id)
        redirect to("/contacts")
      end

      get "/companies" do
        @companies = companies.all.sort_by { |company| company.name.downcase }
        @contact_counts = contacts.all.group_by(&:company_id).transform_values(&:size)
        erb :"companies/index"
      end

      get "/deals" do
        @stage = params["stage"].to_s
        @deals = @stage.empty? ? deals.all : deals.by_stage(@stage)
        @companies_by_id = companies.all.each_with_object({}) { |company, index| index[company.id] = company }
        erb :"deals/index"
      end

      not_found do
        erb :not_found
      end

      private

      def contacts
        Repositories::ContactRepository.new(settings.store)
      end

      def companies
        Repositories::CompanyRepository.new(settings.store)
      end

      def deals
        Repositories::DealRepository.new(settings.store)
      end

      def tasks
        Repositories::TaskRepository.new(settings.store)
      end

      def activities
        Repositories::ActivityRepository.new(settings.store)
      end

      def find_or_404(repository, id)
        repository.find_by_id(id) || halt(404, erb(:not_found))
      end

      def render_contact_form(errors)
        @errors = errors
        @companies = companies.all.sort_by(&:name)
        erb :"contacts/form"
      end

      def contact_params
        source = params.fetch("contact", {})
        {
          first_name: source["first_name"].to_s.strip,
          last_name: source["last_name"].to_s.strip,
          email: source["email"].to_s.strip,
          phone: presence(source["phone"]),
          title: presence(source["title"]),
          company_id: presence(source["company_id"]) && source["company_id"].to_i,
          status: presence(source["status"]) || "lead",
          tags: source["tags"].to_s.split(",").map { |tag| tag.strip.downcase }.reject(&:empty?).uniq
        }
      end

      def presence(value)
        text = value.to_s.strip
        text.empty? ? nil : text
      end
    end
  end
end
