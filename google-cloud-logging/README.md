# google-cloud-logging

[Stackdriver Logging](https://cloud.google.com/logging/) ([docs](https://cloud.google.com/logging/docs/)) allows you to store, search, analyze, monitor, and alert on log data and events from Google Cloud Platform and Amazon Web Services (AWS). It supports ingestion of any custom log data from any source. Stackdriver Logging is a fully-managed service that performs at scale and can ingest application and system log data from thousands of VMs. Even better, you can analyze all that log data in real-time.

- [google-cloud-logging API documentation](http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest)
- [google-cloud-logging on RubyGems](https://rubygems.org/gems/google-cloud-logging)
- [Stackdriver Logging documentation](https://cloud.google.com/logging/docs/)

## Quick Start

Install the gem directly:

```sh
$ gem install google-cloud-logging
```

Or install through Bundler:

1. Add the `google-cloud-logging` gem to your Gemfile:

```ruby
gem "google-cloud-logging"
```

2. Use Bundler to install the gem:

```sh
$ bundle install
```

Alternatively, check out the [`stackdriver`](../stackdriver) gem that includes 
the `google-cloud-logging` gem.

## Logging using client library

You can directly read or write log entries through the client library:

```ruby
require "google/cloud/logging"

logging = Google::Cloud::Logging.new

# List all log entries
logging.entries.each do |e|
  puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
end

# List only entries from a single log
entries = logging.entries filter: "log:syslog"

# Write a log entry
entry = logging.entry
entry.payload = "Job started."
entry.log_name = "my_app_log"
entry.resource.type = "gae_app"
entry.resource.labels[:module_id] = "1"
entry.resource.labels[:version_id] = "20150925t173233"

logging.write_entries entry
```

## Using Stackdriver Logging in frameworks

The `google-cloud-logging` library provides framework integration for popular 
Rack-based frameworks, such as Ruby on Rails and Sinatra, which sets the default 
Rack logger to an instance of Stackdriver Logging logger.

### With Ruby on Rails

You can load the Railtie that comes with the library into your Ruby 
on Rails application by explicitly require it in the application startup path:

```ruby
# In config/application.rb
require "google/cloud/logging/rails"
```

If you're using the `stackdriver` gem, it automatically loads the Railtie into 
your application when it starts.

You'll be able to use Stackdriver logger through the standard Rails logger:

```ruby
Rails.logger.info "Hello World"
# Or just...
logger.warn "Hola Mundo"
```

### With other Rack-based frameworks

Other Rack-based applications can use the Rack Middleware to replace the Rack 
logger with the Stackdriver Logging logger:

```ruby
require "google/cloud/logging"
use Google::Cloud::Logging::Middleware
```

Once the Rack logger is set, some Rack-based frameworks, such as Ruby on Rails 
and Sinatra, automatically initialize the default application logger to use the 
Rack logger:

```ruby
logger.info "Hello World"
logger.warn "Hola Mundo"
logger.error "Bonjour Monde"
```

For other frameworks, consult the documentations on how to utilize the Rack 
logger.

### Configuring the framework integration

You can customize the behavior of the Stackdriver Logging framework integration 
for Ruby. See the [configuration guide](../stackdriver/configuration.md) for a 
list of possible configuration options.

## Authentication

This library uses Service Account credentials to connect to Google Cloud 
services. When running on Compute Engine the credentials will be discovered 
automatically. When running on other environments the Service Account 
credentials can be specified by providing in several ways.

If you're using Ruby on Rails and the library's Rails integration feature, you 
can provide the authentication parameters through the Rails configuration 
interface:
 
```ruby
# Add this to config/environments/*.rb
Rails.application.configure do |config|
  # Shared parameters
  config.google_cloud.project_id = "your-project-id"
  config.google_cloud.keyfile = "/path/to/key.json"
  # Stackdriver Logging specific parameters
  config.google_cloud.logging.project_id = "your-project-id"
  config.google_cloud.logging.keyfile    = "/path/to/key.json"
end
```
Other Rack-based applications that are loading the Rack Middleware directly can 
use the configration interface:

```ruby
require "google/cloud/logging"
Google::Cloud.configure do |config|
  # Shared parameters
  config.project_id = "your-project-id"
  config.keyfile = "/path/to/key.json"
  # Or Stackdriver logging specific parameters
  config.logging.project_id = "your-project-id"
  config.logging.keyfile = "/path/to/key.json"
end
```

See the [Authentication 
Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-logging/guides/authentication).
for more ways to authenticate the client library.

## Supported Ruby Versions

This library is supported on Ruby 2.0+.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/contributing) for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](../CODE_OF_CONDUCT.md) for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE).

## Support

Please [report bugs at the project on Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues).
Don't hesitate to [ask questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby) about the client or APIs on [StackOverflow](http://stackoverflow.com).
