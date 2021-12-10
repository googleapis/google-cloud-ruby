# google-cloud-spanner

[Google Cloud Spanner API](https://cloud.google.com/spanner/) ([docs](https://cloud.google.com/spanner/docs)) provides a fully managed, mission-critical, relational database service that offers transactional consistency at global scale, schemas, SQL (ANSI 2011 with extensions), and automatic, synchronous replication for high availability.

- [google-cloud-spanner API
  documentation](https://googleapis.dev/ruby/google-cloud-spanner/latest)
- [google-cloud-spanner on
  RubyGems](https://rubygems.org/gems/google-cloud-spanner)
- [Google Cloud Spanner API
  documentation](https://cloud.google.com/spanner/docs)

## NOTICE: Freezing development of `Database`, `Instance` and `Backup` classes.

From `google-cloud-spanner/v2.11.0` onwards, **new features for mananging
databases, instances and backups will only be available through the
[google-cloud-spanner-admin-instance-v1](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-spanner-admin-instance-v1)
and
[google-cloud-spanner-admin-database-v1](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-spanner-admin-database-v1)
packages**. The
[`Database`](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud-spanner/lib/google/cloud/spanner/database.rb),

[`Instance`](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud-spanner/lib/google/cloud/spanner/instance.rb) and
[`Backup`](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud-spanner/lib/google/cloud/spanner/backup.rb)
classes in
[google-cloud-spanner](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-spanner)
and methods related to database and instance management in the
[`Project`](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud-spanner/lib/google/cloud/spanner/project.rb)
class,
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

## FAQ for freezing development of `Database`, `Instance` and `Backup` classes

### Can I keep using the frozen classes and methods?

Yes, these classes and methods can continue to be used for the forseeable
future, even in production applications. P0/P1 bug fixes and security patches
for up to 1 year will be provided after `google-cloud-spanner/v2.11.0` is released.

### When should I use the `google-cloud-spanner-admin-instance-v1` and `google-cloud-spanner-admin-database-v1` packages?

Only when your application needs to use Cloud Spanner features for managing
databases and instances that are released after `google-cloud-spanner/v2.11.0`.
You may continue to use the existing `Database`, `Instance` and `Backup` classes
from `google-cloud-spanner`, and the methods from the `Project` class for all
existing usages in your code for managing databases, instances and backups.

### Which classes and methods are subject to the freeze?

#### `Backup`
* `Google::Cloud::Spanner::Backup`
* `Google::Cloud::Spanner::Backup::Job`
* `Google::Cloud::Spanner::Backup::Job::List`
* `Google::Cloud::Spanner::Backup::List`
* `Google::Cloud::Spanner::Backup::Restore::Job`

#### `Database`
* `Google::Cloud::Spanner::Database`
* `Google::Cloud::Spanner::Database::BackupInfo`
* `Google::Cloud::Spanner::Database::Config`
* `Google::Cloud::Spanner::Database::Job`
* `Google::Cloud::Spanner::Database::Job::List`
* `Google::Cloud::Spanner::Database::List`
* `Google::Cloud::Spanner::Database::RestoreInfo`

#### `Instance`
* `Google::Cloud::Spanner::Instance`
* `Google::Cloud::Spanner::Instance::Config`
* `Google::Cloud::Spanner::Instance::Job`
* `Google::Cloud::Spanner::Instance::Job::List`
* `Google::Cloud::Spanner::Instance::List`

#### `Project`
* `Google::Cloud::Spanner::Project#create_database`
* `Google::Cloud::Spanner::Project#create_instance`
* `Google::Cloud::Spanner::Project#database`
* `Google::Cloud::Spanner::Project#databases`
* `Google::Cloud::Spanner::Project#database_path`
* `Google::Cloud::Spanner::Project#instance`
* `Google::Cloud::Spanner::Project#instances`
* `Google::Cloud::Spanner::Project#instance_config`
* `Google::Cloud::Spanner::Project#instance_configs`

### Where can I find code samples?
The code samples for all new features that relate to managing databases and
instances will include code samples on how to use the feature through
`google-cloud-spanner-admin-instance-v1` or
`google-cloud-spanner-admin-database-v1` in the documentation.

Code samples on how to manage instances and databases can also be found in
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
