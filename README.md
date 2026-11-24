# Ruby CRM

A small customer relationship manager written in Ruby: contacts, companies, deals, activities and
tasks, with a Sinatra web UI, CSV export, a pipeline report and a weighted revenue forecast.

This repository is sample code for security testing. Every name, company, email address and phone
number in it is fictional: email domains use the reserved `.example` TLD and phone numbers use the
555-01xx range.

## Running it

```bash
bundle install
CRM_SEED=1 bundle exec rackup    # http://localhost:9292
```

Data lives in memory and is lost on restart. `CRM_SEED=1` loads the sample data from `db/seeds.rb`.

```bash
bundle exec rake report    # pipeline summary for the sample data
bin/console                # IRB with the sample data loaded
```

## Tests

```bash
bundle exec rake test
```

The model, repository and service tests need only Ruby and minitest. The web tests also need
`sinatra` and `rack-test` and are skipped when those gems are missing.

## Layout

| Path | What it holds |
|---|---|
| `lib/crm/models` | Contact, Company, Deal, Activity, Task and the fixed pipeline stages |
| `lib/crm/repositories` | Create, find, update and query records in the in-memory store |
| `lib/crm/services` | Search, CSV export, pipeline report, forecast, task reminders |
| `lib/crm/web` | Sinatra app and view helpers |
| `views`, `public` | ERB templates and CSS |
| `db/seeds.rb` | Fictional sample data |

See `docs/architecture.md` for how the pieces fit together.

## License

MIT
