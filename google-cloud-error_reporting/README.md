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

## Quick Start

Install the gem directly:

```sh
$ gem install google-cloud-error_reporting
```

Or install through Bundler:

1. Add the `google-cloud-error_reporting` gem to your Gemfile:

```ruby
gem "google-cloud-error_reporting"
```

2. Use Bundler to install the gem:

```sh
$ bundle install
```

Alternatively, check out the [`stackdriver`](../stackdriver) gem that includes 
the `google-cloud-error_reporting` gem.

## Enable Stackdriver Error Reporting API

The Stackdriver Error Reporting library would need the [Stackdriver Error
Reporting API](https://console.cloud.google.com/apis/library/clouderrorreporting.googleapis.com) 
to be enabled on your Google Cloud project. Make sure it's enabled if not 
already.

## Reporting errors in Rack-based frameworks

The Stackdriver Error Reporting library for Ruby makes it easy to integrate 
Stackdriver Error Reporting into popular Rack-based Ruby web frameworks such as 
Ruby on Rails and Sinatra. When the library integration is enabled, it 
automatically reports exceptions captured from the application's Rack stack.

If you're using Ruby on Rails and the `stackdriver` gem, they automatically 
loads the library into your application when it starts.

Otherwise, you can load the Railtie that comes with the library into your Ruby 
on Rails application by explicitly require it in the application startup path:

```ruby
# In config/application.rb
require "google/cloud/error_reporting/rails"
```

Other Rack-based frameworks, such as Sinatra, can use the Rack Middleware 
provided by the library:

```ruby
require "google/cloud/error_reporting"
use Google::Cloud::ErrorReporting::Middleware
```

## Reporting errors manually

Manually reporting an error is as easy as calling the report method:

```ruby
require "google/cloud/error_reporting"
begin
  fail "boom!"
rescue => exception
  Google::Cloud::ErrorReporting.report exception
end
```

## Configuring the library

You can customize the behavior of the Stackdriver Error Reporting library for 
Ruby. See the [configuration guide](../stackdriver/configuration.md) for a list 
of possible configuration options.

## Running on Google Cloud Platform

The Stackdriver Error Reporting library for Ruby should work without you 
manually providing authentication credentials for instances running on Google 
Cloud Platform, as long as the Stackdriver Error Reporting API access scope is 
enabled on that instance.

### App Engine

On Google App Engine, the Stackdriver Error Reporting API access scope is 
enabled by default, and the Stackdriver Error Reporting library for Ruby can 
be used without providing credentials or a project ID.

### Container Engine

On Google Container Engine, you must explicitly add the `cloud-platform` OAuth 
scope when creating the cluster:

```sh
$ gcloud container clusters create example-cluster-name --scopes https://www.googleapis.com/auth/cloud-platform
```

You may also do this through the Google Cloud Platform Console. Select 
**Enabled** in the **Cloud Platform** section of **Create a container cluster**.

### Compute Engine

For Google Compute Engine instances, you must explicitly enable the 
`cloud-platform` access scope for each instance. When you create a new instance 
through the Google Cloud Platform Console, you can do this under Identity and 
API access: Use the Compute Engine default service account and select "Allow 
full access to all Cloud APIs" under Access scopes.

## Running locally and elsewhere

To run the Stackdriver Error Reporting outside of Google Cloud Platform, you 
must supply your GCP project ID and appropriate service account credentials 
directly to the Stackdriver Error Reporting. This applies to running the 
library on your own workstation, on your datacenter's computers, or on the VM 
instances of another cloud provider. See the [Authentication 
section](#authentication) for instructions on how to do so.

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
  # Or Stackdriver Error Reporting specific parameters
  config.google_cloud.error_reporting.project_id = "your-project-id"
  config.google_cloud.error_reporting.keyfile = "/path/to/key.json"
end
```

Other Rack-based applications that are loading the Rack Middleware directly can use
the configration interface:
 
```ruby
require "google/cloud/error_reporting"
Google::Cloud.configure do |config|
  # Shared parameters
  config.project_id = "your-project-id"
  config.keyfile = "/path/to/key.json"
  # Or Stackdriver Error Reporting specific parameters
  config.error_reporting.project_id = "your-project-id"
  config.error_reporting.keyfile = "/path/to/key.json"
end
```

This library also supports the other authentication methods provided by the 
`google-cloud-ruby` suite. Instructions and configuration options are covered 
in the [Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-debugger/guides/authentication).

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

