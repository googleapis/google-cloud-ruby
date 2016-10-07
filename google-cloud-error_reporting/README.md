# google-cloud-error_reporting

[Stackdriver Error Reporting](https://cloud.google.com/error-reporting/) ([docs](https://cloud.google.com/error-reporting/docs/))  counts, analyzes and aggregates the crashes in your running cloud services. A centralized error management interface displays the results with sorting and filtering capabilities. A dedicated view shows the error details: time chart, occurrences, affected user count, first and last seen dates and a cleaned exception stack trace. Opt-in to receive email and mobile alerts on new errors.

- [google-cloud-error_reporting API documentation](http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-error_reporting/master/)
- [google-cloud-error_reporting on RubyGems](https://rubygems.org/gems/google-cloud-error_reporting)
- [Stackdriver Error Reporting documentation](https://cloud.google.com/error-reporting/docs)

## Quick Start

```sh
$ gem install google-cloud-error_reporting
```

## Authentication

This library uses Service Account credentials to connect to Google Cloud services. When running on Compute Engine the credentials will be discovered automatically. When running on other environments the Google Cloud project ID and Service Account credentials can be specified by providing in environment variables.

Instructions and configuration options are covered in the [Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-error_reporting/guides/authentication).

## Example

```ruby
require "google/cloud/error_reporting"
 
error_reporting = Google::Cloud::ErrorReporting.new
 
# Report an error event
error_event = error_reporting.error_event "Error Message with Backtrace",
                                          service_name: "my_app_name",
                                          service_version: "v8",
                                          timestamp: Time.now,
                                          user: ENV["USER"],
                                          http_method: "GET",
                                          http_url: "http://mysite.com/index.html",
                                          http_status: 500,
                                          http_remote_ip: "127.0.0.1",
                                          file_path: "app/controllers/MyController.rb",
                                          line_number: 123,
                                          function_name: "index"
error_reporting.report error_event
```

google-cloud-error_reporting can also extract some context information from Ruby Exception objects and report the event to Stackdriver Error Reporting service:
```ruby
require "google/cloud/error_reporting"
 
error_reporting = Google::Cloud::ErrorReporting.new
 
begin
  raise "Boom!"
rescue StandardError => exception
  error_reporting.report_exception(
    exception, 
    service_name: "my_app_name",
    service_version: "v9"
  ) do |error_event|
    # Add more context to ErrorEvent object before submission
    error_event.error_context.http_request_context.status = 500
  end
end
````

## Service Context Configuration
The Stackdriver Error Reporting API requires a Google Cloud service name and an optional service version. When running on Google App Engine, the service name and service version will be automatically discovered. While outside App Engine, the stackdriver-error_reporting library defaults the service name to simply "ruby" and leave service version blank. Users are also able to override default service name and version by providing them as parameters in code, or define the **ERROR_REPORTING_SERVICE** and **ERROR_REPORTING_VERSION** environment variables respectively.

The service name and version can also be supplied as Rails application configuration when used in Rails. See [Rails Integration](#rails-integration) for detail.

## Rails Integration

This library also provides a built in Railtie for Ruby on Rails integration. To do this, simply add this line to config/application.rb:
```ruby
require "google/cloud/error_reporting/rails"
```
Then the library can be configured through this set of Rails parameters in config/environments/*.rb:
```ruby
# Sharing authentication parameters
config.google_cloud.project_id = "gcp-project-id"
config.google_cloud.keyfile = "/path/to/gcp/secret.json"
# Or more specifically for ErrorReporting
config.google_cloud.error_reporting.project_id = "gcp-project-id"
config.google_cloud.error_reporting.keyfile = "/path/to/gcp/sercret.json"
 
# Explicitly enable or disable ErrorReporting
config.google_cloud.use_error_reporting = true
 
# Set ErrorReporting service context info
config.google_cloud.error_reporting.service_name = "my-rails-app"
config.google_cloud.error_reporting.service_version = "5.0.0"
```

Alternatively, check out [stackdriver](../stackdriver) gem, which includes this Railtie by default.

## Rack Integration

Other Rack base framework, such as Sinatra, can directly leverage the built-in Middleware class.
```ruby
require "google/cloud/error_reporting"

# Optional parameters
error_reporting = Google::Cloud::ErrorReporting.new "my-todo-project-id",
                                                   "/path/to/keyfile.json"
 
use Google::Cloud::ErrorReporting::Middleware, error_reporting: error_reporting,
                                               service_name: "sinatra-app",
                                               service_version: "v10"
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

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](../LICENSE).

## Support

Please [report bugs at the project on Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues).
Don't hesitate to [ask questions](http://stackoverflow.com/questions/tagged/google-cloud-ruby) about the client or APIs on [StackOverflow](http://stackoverflow.com).
