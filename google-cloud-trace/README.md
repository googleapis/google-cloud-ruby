# google-cloud-trace

[Stackdriver Trace](https://cloud.google.com/trace/) is a distributed tracing
system that collects latency data from your applications and displays it in the
Google Cloud Platform Console. You can track how requests propagate through your
application and receive detailed near real-time performance insights.
Stackdriver Trace automatically analyzes all of your application's traces to
generate in-depth latency reports to surface performance degradations, and can
capture traces from all of your VMs, containers, or Google App Engine projects.

- [google-cloud-trace API documentation](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-trace/latest)
- [google-cloud-trace instrumentation documentation](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-trace/latest/file.INSTRUMENTATION)
- [google-cloud-trace on RubyGems](https://rubygems.org/gems/google-cloud-trace)
- [Stackdriver Trace documentation](https://cloud.google.com/trace/docs/)

## Quick Start

Install the gem directly:

```sh
$ gem install google-cloud-trace
```

Or install through Bundler:

1. Add the `google-cloud-trace` gem to your Gemfile:

```ruby
gem "google-cloud-trace"
```

2. Use Bundler to install the gem:

```sh
$ bundle install
```

Alternatively, check out the [`stackdriver`](../stackdriver) gem that includes
the `google-cloud-trace` gem.

## Enable Stackdriver Trace API

The Stackdriver Trace library needs the [Stackdriver Trace
API](https://console.cloud.google.com/apis/library/cloudtrace.googleapis.com)
to be enabled on your Google Cloud project. Make sure it's enabled if not
already.

## Tracing on Rack-based frameworks

The Stackdriver Trace library for Ruby makes it easy to integrate Stackdriver
Trace into popular Rack-based Ruby web frameworks such as Ruby on Rails and
Sinatra. When the library integration is enabled, it automatically traces
incoming requests in the application.

### With Ruby on Rails

You can load the Railtie that comes with the library into your Ruby
on Rails application by explicitly requiring it during the application startup:

```ruby
# In config/application.rb
require "google/cloud/trace/rails"
```

If you're using the `stackdriver` gem, it automatically loads the Railtie into
your application when it starts.

### With other Rack-based frameworks

Other Rack-based frameworks, such as Sinatra, can use the Rack Middleware
provided by the library:

```ruby
require "google/cloud/trace"
use Google::Cloud::Trace::Middleware
```

### Adding Custom Trace Spans

The Stackdriver Trace Rack Middleware automatically creates a trace record for
incoming requests. You can add additional custom trace spans within each
request:

```ruby
Google::Cloud::Trace.in_span "my_task" do |span|
  # Do stuff...

  Google::Cloud::Trace.in_span "my_subtask" do |subspan|
    # Do other stuff
  end
end
```

### Configuring the library

You can customize the behavior of the Stackdriver Trace library for Ruby. See
the [configuration guide](../stackdriver/INSTRUMENTATION_CONFIGURATION.md) for a list of
possible configuration options.

## Running on Google Cloud Platform

The Stackdriver Trace library for Ruby should work without you manually
providing authentication credentials for instances running on Google Cloud
Platform, as long as the Stackdriver Trace API access scope is enabled on that
instance.

### App Engine

On Google App Engine, the Stackdriver Trace API access scope is enabled by
default, and the Stackdriver Trace library for Ruby can be used without
providing credentials or a project ID

### Container Engine

On Google Container Engine, you must explicitly add the `trace.append` OAuth
scope when creating the cluster:

```sh
$ gcloud container clusters create example-cluster-name --scopes https://www.googleapis.com/auth/trace.append
```

### Compute Engine

For Google Compute Engine instances, you need to explicitly enable the
`trace.append` Stackdriver Trace API access scope for each instance. When
creating a new instance through the Google Cloud Platform Console, you can do
this under Identity and API access: Use the Compute Engine default service
account and select "Allow full access to all Cloud APIs" under Access scopes.

To use something other than the Compute Engine default service account see the
docs for Creating and Enabling Service Accounts for Instances and the Running
elsewhere section below. The important thing is that the service account you use
has the Cloud Trace Agent role.

## Running locally and elsewhere

To run the Stackdriver Trace outside of Google Cloud Platform, you must supply
your GCP project ID and appropriate service account credentials directly to the
Stackdriver Trace. This applies to running the library on your own workstation,
on your datacenter's computers, or on the VM instances of another cloud
provider. See the [Authentication section](#authentication) for instructions on
how to do so.

## Authentication

The Instrumentation client and API use Service Account credentials to connect
to Google Cloud services. When running on Google Cloud Platform environments,
the credentials will be discovered automatically. When running on other
environments the Service Account credentials can be specified by providing in
several ways.

The best way to provide authentication information if you're using Ruby on Rails
is through the Rails configuration interface:

```ruby
# in config/environments/*.rb
Rails.application.configure do |config|
  # Shared parameters
  config.google_cloud.project_id = "your-project-id"
  config.google_cloud.keyfile = "/path/to/key.json"
  # Or Stackdriver Trace specific parameters
  config.google_cloud.trace.project_id = "your-project-id"
  config.google_cloud.trace.keyfile = "/path/to/key.json"
end
```

Other Rack-based applications that are loading the Rack Middleware directly can use
the configration interface:

```ruby
require "google/cloud/trace"
Google::Cloud.configure do |config|
  # Shared parameters
  config.project_id = "your-project-id"
  config.keyfile = "/path/to/key.json"
  # Or Stackdriver Trace specific parameters
  config.trace.project_id = "your-project-id"
  config.trace.keyfile = "/path/to/key.json"
end
```

This library also supports the other authentication methods provided by the
`google-cloud-ruby` suite. Instructions and configuration options are covered
in the [Authentication Guide](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-trace/latest/file.AUTHENTICATION).

## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library. The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as shown below, or a [`Google::Cloud::Logging::Logger`](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-logging/latest/Google/Cloud/Logging/Logger) that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb) and the gRPC [spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb) for additional information.

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

It is currently in major version zero (0.y.z), which means that anything may
change at any time and the public API should not be considered stable.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing
Guide](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-trace/latest/file.CONTRIBUTING)
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See [Code of
Conduct](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-trace/latest/file.CODE_OF_CONDUCT)
for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-trace/latest/file.LICENSE).

## Support

Please [report bugs at the project on
Github](https://github.com/googleapis/google-cloud-ruby/issues). Don't
hesitate to [ask
questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby)
about the client or APIs on [StackOverflow](http://stackoverflow.com).
