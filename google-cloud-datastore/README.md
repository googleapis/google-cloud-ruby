# google-cloud-datastore

[Google Cloud Datastore](https://cloud.google.com/datastore/) ([docs](https://cloud.google.com/datastore/docs)) is a fully managed, schemaless database for storing non-relational data. Cloud Datastore automatically scales with your users and supports ACID transactions, high availability of reads and writes, strong consistency for reads and ancestor queries, and eventual consistency for all other queries.

Follow the [activation instructions](https://cloud.google.com/datastore/docs/activate) to use the Google Cloud Datastore API with your project.

- [google-cloud-datastore API documentation](http://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-datastore/latest)
- [google-cloud-datastore on RubyGems](https://rubygems.org/gems/google-cloud-datastore)
- [Google Cloud Datastore documentation](https://cloud.google.com/datastore/docs)

## Quick Start

```sh
$ gem install google-cloud-datastore
```

## Authentication

This library uses Service Account credentials to connect to Google Cloud services. When running on Compute Engine the credentials will be discovered automatically. When running on other environments the Service Account credentials can be specified by providing the path to the JSON file, or the JSON itself, in environment variables.

Instructions and configuration options are covered in the [Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-datastore/latest/file.AUTHENTICATION).

## Example

```ruby
require "google/cloud/datastore"

datastore = Google::Cloud::Datastore.new(
  project_id: "my-todo-project",
  credentials: "/path/to/keyfile.json"
)

# Create a new task to demo datastore
task = datastore.entity "Task", "sampleTask" do |t|
  t["type"] = "Personal"
  t["done"] = false
  t["priority"] = 4
  t["description"] = "Learn Cloud Datastore"
end

# Save the new task
datastore.save task

# Run a query for all completed tasks
query = datastore.query("Task").
  where("done", "=", false)
tasks = datastore.run query
```

## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library. The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as shown below, or a [`Google::Cloud::Logging::Logger`](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-logging/latest/Google/Cloud/Logging/Logger) that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb) and the gRPC [spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb) for additional information.

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

## Supported Ruby Versions

This library is supported on Ruby 2.3+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or in
security maintenance, and not end of life. Currently, this means Ruby 2.3 and
later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing
Guide](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-datastore/latest/file.CONTRIBUTING)
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See [Code of
Conduct](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-datastore/latest/file.CODE_OF_CONDUCT)
for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](https://googlecloudplatform.github.io/google-cloud-ruby/docs/google-cloud-datastore/latest/file.LICENSE).

## Support

Please [report bugs at the project on
Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues). Don't
hesitate to [ask
questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby)
about the client or APIs on [StackOverflow](http://stackoverflow.com).
