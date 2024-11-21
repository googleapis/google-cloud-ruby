# google-cloud-storage

[Google Cloud Storage](https://cloud.google.com/storage/) ([docs](https://cloud.google.com/storage/docs/json_api/)) allows you to store data on Google infrastructure with very high reliability, performance and availability, and can be used to distribute large data objects to users via direct download.

- [google-cloud-storage API documentation](https://googleapis.dev/ruby/google-cloud-storage/latest)
- [google-cloud-storage on RubyGems](https://rubygems.org/gems/google-cloud-storage)
- [Google Cloud Storage documentation](https://cloud.google.com/storage/docs)

## Quick Start

```sh
$ gem install google-cloud-storage
```

## Authentication

This library uses Service Account credentials to connect to Google Cloud services. When running on Google Cloud Platform (GCP), including Google Compute Engine (GCE), Google Kubernetes Engine (GKE), Google App Engine (GAE), Google Cloud Functions (GCF) and Cloud Run, the credentials will be discovered automatically. When running on other environments the Service Account credentials can be specified by providing the path to the JSON file, or the JSON itself, in environment variables.

Instructions and configuration options are covered in the [Authentication Guide](https://googleapis.dev/ruby/google-cloud-storage/latest/file.AUTHENTICATION.html).

## Example

```ruby
require "google/cloud/storage"

storage = Google::Cloud::Storage.new(
  project_id: "my-project",
  credentials: "/path/to/keyfile.json"
)

bucket = storage.bucket "task-attachments"

file = bucket.file "path/to/my-file.ext"

# Download the file to the local file system
file.download "/tasks/attachments/#{file.name}"

# Copy the file to a backup bucket
backup = storage.bucket "task-attachment-backups"
file.copy backup, file.name
```

## Enabling Logging

To enable logging for this library, set the logger for the underlying [Google API Client](https://github.com/google/google-api-ruby-client/blob/master/README.md#logging) library. The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as shown below, or a [`Google::Cloud::Logging::Logger`](https://googleapis.dev/ruby/google-cloud-logging/latest) that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/).

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

This library is supported on Ruby 3.0.0+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or in
security maintenance, and not end of life. Currently, this means Ruby 3.0.0 and
later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing
Guide](https://googleapis.dev/ruby/google-cloud-storage/latest/file.CONTRIBUTING.html)
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See [Code of
Conduct](https://googleapis.dev/ruby/google-cloud-storage/latest/file.CODE_OF_CONDUCT.html)
for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](https://googleapis.dev/ruby/google-cloud-storage/latest/file.LICENSE.html).

## Support

Please [report bugs at the project on
Github](https://github.com/googleapis/google-cloud-ruby/issues). Don't
hesitate to [ask
questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby)
about the client or APIs on [StackOverflow](http://stackoverflow.com).
