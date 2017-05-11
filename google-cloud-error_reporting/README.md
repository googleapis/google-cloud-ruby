# google-cloud-error_reporting

[Stackdriver Error Reporting](https://cloud.google.com/error-reporting/) counts,
analyzes and aggregates errors raised in your running cloud services. A
centralized error management interface displays the results with sorting 
and filtering capabilities. A dedicated view shows the error details: time 
chart, occurrences, affected user count, first and last seen dates and a 
cleaned exception stack trace. Opt-in to receive email and mobile alerts on 
new errors.

- [google-cloud-error_reporting API documentation](http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-error_reporting/latest)
- [google-cloud-error_reporting instrumentation documentation](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-error_reporting/guides/instrumentation)
- [google-cloud-error_reporting on RubyGems](https://rubygems.org/gems/google-cloud-error_reporting)
- [Stackdriver ErrorReporting documentation](https://cloud.google.com/error-reporting/docs/)

google-cloud-error_reporting provides an instrumentation API that makes it easy 
to report exceptions to the Stackdriver Error Reporting service. It also 
contains a full API client library for the 
[Stackdriver Error Reporting API](https://developers.google.com/apis-explorer/#p/clouderrorreporting/v1beta1/) 
(v1beta1).

## Quick Start
```sh
$ gem install google-cloud-error_reporting
```

## Authentication

The Instrumentation client and API use Service Account credentials to connect 
to Google Cloud services. When running on Google Cloud Platform environments, 
the credentials will be discovered automatically. When running on other 
environments the Service Account credentials can be specified by providing the 
path to the JSON file, or the JSON itself, in environment variables or 
configuration code.

Instructions and configuration options are covered in the 
[Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-error_reporting/guides/authentication).

## Instrumentation Example
```ruby
require "google/cloud/error_reporting"
 
# Configure Stackdriver ErrorReporting instrumentation
Google::Cloud::ErrorReporting.configure do |config|
  config.project_id = "my-project"
  config.keyfile = "/path/to/keyfile.json"
end
 
# Insert a Rack Middleware to report unhanded exceptions 
use Google::Cloud::ErrorReporting::Middleware
 
# Or explicitly submit exceptions
begin
  fail "Boom!"
rescue => exception
  Google::Cloud::ErrorReporting.report exception
end
```

## Rails and Rack Integration

This library also provides a built-in Railtie for Ruby on Rails integration. To
 do this, simply add this line to config/application.rb:
```ruby
require "google/cloud/error_reporting/rails"
```

Alternatively, check out [stackdriver](../stackdriver) gem, which includes this 
library and enables the Railtie by default.

For Rack integration and more examples, see 
[Instrumentation Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-error_reporting/guides/instrumentation).

## Supported Ruby Versions

This library is supported on Ruby 2.0+.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

It is currently in major version zero (0.y.z), which means that anything may 
change at any time and the public API should not be considered stable.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the 
[Contributing Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/contributing) 
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See 
[Code of Conduct](../CODE_OF_CONDUCT.md) for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
 [LICENSE](LICENSE).

## Support

Please 
[report bugs at the project on Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues).
Don't hesitate to 
[ask questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby) 
about the client or APIs on [StackOverflow](http://stackoverflow.com).

