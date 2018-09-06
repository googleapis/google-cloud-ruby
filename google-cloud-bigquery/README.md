# google-cloud-bigquery

[Google BigQuery](https://cloud.google.com/bigquery/) ([docs](https://cloud.google.com/bigquery/docs)) enables super-fast, SQL-like queries against append-only tables, using the processing power of Google's infrastructure. Simply move your data into BigQuery and let it handle the hard work. You can control access to both the project and your data based on your business needs, such as giving others the ability to view or query your data.

- [google-cloud-bigquery API documentation](http://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-bigquery/latest)
- [google-cloud-bigquery on RubyGems](https://rubygems.org/gems/google-cloud-bigquery)
- [Google BigQuery documentation](https://cloud.google.com/bigquery/docs)

## Quick Start

```sh
$ gem install google-cloud-bigquery
```

## Authentication

This library uses Service Account credentials to connect to Google Cloud services. When running on Compute Engine the credentials will be discovered automatically. When running on other environments the Service Account credentials can be specified by providing the path to the JSON file, or the JSON itself, in environment variables.

Instructions and configuration options are covered in the [Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-bigquery/latest/file.AUTHENTICATION).

## Example

```ruby
require "google/cloud/bigquery"

bigquery = Google::Cloud::Bigquery.new
dataset = bigquery.create_dataset "my_dataset"

table = dataset.create_table "my_table" do |t|
  t.name = "My Table",
  t.description = "A description of my table."
  t.schema do |s|
    s.string "first_name", mode: :required
    s.string "last_name", mode: :required
    s.integer "age", mode: :required
  end
end

# Load data into the table from Google Cloud Storage
table.load "gs://my-bucket/file-name.csv"

# Run a query
data = dataset.query "SELECT first_name FROM my_table"

data.each do |row|
  puts row[:first_name]
end
```

## Enabling Logging

To enable logging for this library, set the logger for the underlying [Google API Client](https://github.com/google/google-api-ruby-client/blob/master/README.md#logging) library. The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html) as shown below, or a [`Google::Cloud::Logging::Logger`](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-logging/latest/Google/Cloud/Logging/Logger) that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/).

If you do not set the logger explicitly and your application is running in a Rails environment, it will default to `Rails.logger`. Otherwise, if you do not set the logger and you are not using Rails, logging is disabled by default.

Configuring a Ruby stdlib logger:

```ruby
require "logger"

my_logger = Logger.new $stderr
my_logger.level = Logger::WARN

# Set the Google API Client logger
Google::Apis.logger = my_logger
```

## Supported Ruby Versions

This library is supported on Ruby 2.3+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Currently, this means Ruby 2.3
and later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

It is currently in major version zero (0.y.z), which means that anything may change at any time and the public API should not be considered stable.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing Guide](../CONTRIBUTING.md) for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-bigquery/latest/file.CODE_OF_CONDUCT) for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE).

## Support

Please [report bugs at the project on Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues).
Don't hesitate to [ask questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby) about the client or APIs on [StackOverflow](http://stackoverflow.com). For more see the [Troubleshooting guide](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-bigquery/latest/file.TROUBLESHOOTING)
