# google-cloud-logging

[Stackdriver Logging](https://cloud.google.com/logging/) ([docs](https://cloud.google.com/logging/docs/)) allows you to store, search, analyze, monitor, and alert on log data and events from Google Cloud Platform and Amazon Web Services (AWS). It supports ingestion of any custom log data from any source. Stackdriver Logging is a fully-managed service that performs at scale and can ingest application and system log data from thousands of VMs. Even better, you can analyze all that log data in real-time.

- [google-cloud-logging API documentation](http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-logging/master/google/cloud/logging)
- [google-cloud-logging on RubyGems](https://rubygems.org/gems/google-cloud-logging)
- [Stackdriver Logging documentation](https://cloud.google.com/logging/docs/)

## Quick Start

```sh
$ gem install google-cloud-logging
```

## Authentication

This library uses Service Account credentials to connect to Google Cloud services. When running on Compute Engine the credentials will be discovered automatically. When running on other environments the Service Account credentials can be specified by providing the path to the JSON file, or the JSON itself, in environment variables.

Instructions and configuration options are covered in the [Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-logging/guides/authentication).

## Example

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

## Rails Integration

This library also provides a built in Railtie for Ruby on Rails integration. When enabled, it sets an instance of Google::Cloud::Logging::Logger as the default Rails logger. Then all consequent log entries will be submitted to the Stackdriver Logging service. 

To do this, simply add this line to config/application.rb:
```ruby
require "google/cloud/logging/rails"
```
Then the library can be configured through this set of Rails parameters in config/environments/*.rb:
```ruby
# Sharing authentication parameters
config.google_cloud.project_id = "gcp-project-id"
config.google_cloud.keyfile = "/path/to/gcp/secret.json"
# Or more specificly for Logging
config.google_cloud.logging.project_id = "gcp-project-id"
config.google_cloud.logging.keyfile = "/path/to/gcp/sercret.json"
 
# Explicitly enable or disable Logging
config.google_cloud.use_logging = true
 
# Set Stackdriver Logging log name
config.google_cloud.logging.log_name = "my-app-log"
 
# Override default monitored resource if needed. E.g. used on AWS
config.google_cloud.logging.monitored_resource.type = "aws_ec2_instance"
config.google_cloud.logging.monitored_resource.labels.instance_id = "ec2-instance-id"
config.google_cloud.logging.monitored_resource.labels.aws_account = "AWS account number"
```
Alternatively, check out [stackdriver](../stackdriver) gem, which includes this Railtie by default.

## Rack Integration

Other Rack base framework can also directly leverage the built-in Middleware.
```ruby
require "google/cloud/logging"

logging = Google::Cloud::Logging.new
resource = Google::Cloud::Logging::Middleware.build_monitored_resource
logger = logging.logger "my-log-name",
                        resource
use Google::Cloud::Logging::Middleware, logger: logger
```

## Supported Ruby Versions

This library is supported on Ruby 2.0+.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

It is currently in major version zero (0.y.z), which means that anything may change at any time and the public API should not be considered stable.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/contributing) for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](../CODE_OF_CONDUCT.md) for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE).

## Support

Please [report bugs at the project on Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues).
Don't hesitate to [ask questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby) about the client or APIs on [StackOverflow](http://stackoverflow.com).
