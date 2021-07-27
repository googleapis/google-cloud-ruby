# google-cloud-spanner

[Google Cloud Spanner API](https://cloud.google.com/spanner/) ([docs](https://cloud.google.com/spanner/docs)) provides a fully managed, mission-critical, relational database service that offers transactional consistency at global scale, schemas, SQL (ANSI 2011 with extensions), and automatic, synchronous replication for high availability.

- [google-cloud-spanner API
  documentation](https://googleapis.dev/ruby/google-cloud-spanner/latest)
- [google-cloud-spanner on
  RubyGems](https://rubygems.org/gems/google-cloud-spanner)
- [Google Cloud Spanner API
  documentation](https://cloud.google.com/spanner/docs)

## NOTICE: Freezing development of `database` and `instance` classes.

From `google-cloud-spanner/v3.0` onwards, **new features for mananging databases
and instances will only be available through the
[google-cloud-spanner-admin-instance-v1](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-spanner-admin-instance-v1)
and
[google-cloud-spanner-admin-database-v1](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-spanner-admin-database-v1)
packages**. The `database` and `instance` classes in
[google-cloud-spanner](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-spanner)
will no longer be updated to support new features. Please refer to the [FAQ](#faq-for-freezing-development-of-database-and-instance-classes)
for further details.

## Quick Start

```sh
$ gem install google-cloud-spanner
```

## Authentication

This library uses Service Account credentials to connect to Google Cloud services. When running on Google Cloud Platform (GCP), including Google Compute Engine (GCE), Google Kubernetes Engine (GKE), Google App Engine (GAE), Google Cloud Functions (GCF) and Cloud Run, the credentials will be discovered automatically. When running on other environments the Service Account credentials can be specified by providing the path to the JSON file, or the JSON itself, in environment variables.

Instructions and configuration options are covered in the [Authentication Guide](https://googleapis.dev/ruby/google-cloud-spanner/latest/file.AUTHENTICATION.html).

## Example

```ruby
require "google/cloud/spanner"

spanner = Google::Cloud::Spanner.new

db = spanner.client "my-instance", "my-database"

db.transaction do |tx|
  results = tx.execute_query "SELECT * FROM users"

  results.rows.each do |row|
    puts "User #{row[:id]} is #{row[:name]}"
  end
end
```

## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library. The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html) as shown below, or a [`Google::Cloud::Logging::Logger`](https://googleapis.dev/ruby/google-cloud-logging/latest) that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb) and the gRPC [spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb) for additional information.

Configuring a Ruby stdlib logger:

```ruby
require "logger"

module MyLogger
  LOGGER = Logger.new $stderr, level: Logger::WARN
  def logger
    LOGGER
  end
end

# Define a gRPC module-level logger method before grpc/logconfig.rb loads.
module GRPC
  extend MyLogger
end
```

## FAQ for freezing development of `database` and `instance` classes

### Can I keep using the `database` and `instance` classes?

Yes, these classes can continue to be used for the forseeable future, even in
production applications. P0/P1 bug fixes and security patches for up to 1 year
will be provided after `google-cloud-spanner/v3.0` is released.

### When should I use the `google-cloud-spanner-admin-instance-v1` and `google-cloud-spanner-admin-database-v1` packages?

Only when your application needs to use Cloud Spanner features for managing
databases and instances that are released after `google-cloud-spanner/v3.0`. You
may continue to use the existing `database` and `instance` classes from
`google-cloud-spanner` for all existing usages in your code for managing
databases and instances.

### Where can I find code samples?
The code samples for all new features that relate to managing databases and
instances will include code samples on how to use the feature through
`google-cloud-spanner-admin-instance-v1` or
`google-cloud-spanner-admin-database-v1` in the documentation.

Some code samples that use `google-cloud-spanner-admin-instance-v1` and
`google-cloud-spanner-admin-database-v1` to manage instances and databases can
also be found in
[OVERVIEW](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud-spanner/OVERVIEW.md).

## Supported Ruby Versions

This library is supported on Ruby 2.5+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or in
security maintenance, and not end of life. Currently, this means Ruby 2.5 and
later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing
Guide](https://googleapis.dev/ruby/google-cloud-spanner/latest/file.CONTRIBUTING.html)
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See [Code of
Conduct](https://googleapis.dev/ruby/google-cloud-spanner/latest/file.CODE_OF_CONDUCT.html)
for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](https://googleapis.dev/ruby/google-cloud-spanner/latest/file.LICENSE.html).

## Support

Please [report bugs at the project on
Github](https://github.com/googleapis/google-cloud-ruby/issues). Don't
hesitate to [ask
questions](http://stackoverflow.com/questions/tagged/google-cloud-ruby) about
the client or APIs on [StackOverflow](http://stackoverflow.com).
