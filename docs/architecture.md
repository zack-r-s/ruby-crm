# Architecture

The app has four layers. Each one only calls the layer below it.

1. **Web** (`lib/crm/web`): a Sinatra app. Routes read params, call repositories and services, and
   render ERB views. All user-supplied text is escaped with the `h` helper.
2. **Services** (`lib/crm/services`): plain Ruby objects that take records and return results:
   contact search, CSV export, the pipeline report, the deal forecast and task reminders. They
   never touch the store directly, so they are easy to test with hand-built records.
3. **Repositories** (`lib/crm/repositories`): create, find, update, delete and query one kind of
   record. They validate before saving and enforce uniqueness (contact email, company domain).
4. **Store** (`lib/crm/store.rb`): a thread-safe in-memory table per record type that assigns IDs
   and timestamps.

## Models

Models inherit from `CRM::Models::Base`, which provides declared attributes with defaults,
`to_h`, and the validation rules from `CRM::Validation`. Unknown attributes raise `ArgumentError`
instead of being silently ignored.

Deals move through the fixed stages in `CRM::Models::PipelineStage`. Each stage has a win
probability, and the forecast weights each open deal's amount by it.

## Security notes

- Forms carry an authenticity token (`Rack::Protection::AuthenticityToken`) outside the test
  environment.
- The session secret comes from `SESSION_SECRET`, or a random value per process when unset.
- CSV export prefixes cells that start with `=`, `+`, `-`, `@`, tab or carriage return with a
  single quote, so spreadsheets don't evaluate them as formulas.
- Repositories ignore attempts to set `id`, `created_at` or `updated_at` from input.
