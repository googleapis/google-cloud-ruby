# google-cloud-debugger

[Stackdriver Debugger](https://cloud.google.com/debugger/) lets you inspect the state of a running application at any code location in real time, without stopping or slowing down the application, and without modifying the code to add logging statements. You can use Stackdriver Debugger with any deployment of your application, including test, development, and production. The Ruby debugger adds minimal request latency, typically less than 50ms, and only when the application state is captured. In most cases, this is not noticeable by users.

- [google-cloud-debugger documentation](http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-debugger/master/google/cloud/debugger)
- [google-cloud-debugger on RubyGems](https://rubygems.org/gems/google-cloud-debugger)
- [Stackdriver Debugger documentation](https://cloud.google.com/debugger/docs/)

## Quick Start

Install the gem directly:

```sh
$ gem install google-cloud-debugger
```

Or install through Bundler:

1. Add the `google-cloud-debugger` gem to your Gemfile:

```ruby
gem "google-cloud-debugger"
```

2. Use Bundler to install the gem:

```sh
$ bundle install
```

Alternatively, check out the [`stackdriver`](../stackdriver) gem that includes
the `google-cloud-debugger` gem.

## Enable Stackdriver Debugger API

The Stackdriver Debugger agent needs the [Stackdriver Debugger
API](https://console.cloud.google.com/apis/library/clouddebugger.googleapis.com)
to be enabled on your Google Cloud project. Make sure it's enabled if not
already.

## Enabling the Debugger agent

The Stackdriver Debugger library provides a Debugger agent that helps instrument
breakpoints in your running applications. The library also comes with a Railtie
and a Rack Middleware to help control the Debugger agent in popular Rack based
frameworks, such as Ruby on Rails and Sinatra.

### With Ruby on Rails

You can load the Railtie that comes with the library into your Ruby
on Rails application by explicitly requiring it during the application startup:

```ruby
# In config/application.rb
require "google/cloud/debugger/rails"
```

If you're using the `stackdriver` gem, it automatically loads the Railtie into
your application when it starts.

### With other Rack-based frameworks

Other Rack-based frameworks, such as Sinatra, can use the Rack Middleware
provided by the library:

```ruby
require "google/cloud/debugger"
use Google::Cloud::Debugger::Middleware
```

### Without Rack-based framework

Non-rack-based applications can start the agent explicitly at the entry point of
your application:

```ruby
require "google/cloud/debugger"
Google::Cloud::Debugger.new.start
```

### Configuring the agent

You can customize the behavior of the Stackdriver Debugger agent. See the
[agent configuration](../stackdriver/docs/configuration.md) for a list of
possible configuration options.

## Running on Google Cloud Platform

The Stackdriver Debugger agent should work without you manually providing
authentication credentials for instances running on Google Cloud Platform, as
long as the Stackdriver Debugger API access scope is enabled on that instance.

### App Engine

On Google App Engine, the Stackdriver Debugger API access scope is enabled by
default, and the Stackdriver Debugger agent can be used without providing
credentials or a project ID.

### Container Engine

On Google Container Engine, you must explicitly add the `cloud_debugger` OAuth
scope when creating the cluster:

```sh
$ gcloud container clusters create example-cluster-name --scopes https://www.googleapis.com/auth/cloud_debugger
```

You can also do this through the Google Cloud Platform Console. Select
**Enabled** in the Cloud Platform section of **Create a container cluster**.

### Compute Engine

To use Stackdriver Debugger, Compute Engine VM instances should have one of the
following access scopes. These are only relevant when you use Compute Engine's
default service account:

* `https://www.googleapis.com/auth/cloud-platform`
* `https://www.googleapis.com/auth/cloud_debugger`

The `cloud-platform` access scope can be supplied when creating a new instance
through the Google Cloud Platform Console. Select **Allow full access to all
Cloud APIs** in the **Identity and API access** section of **Create an
instance**.

The `cloud_debugger` access scope must be supplied manually using the SDK's
`gcloud compute instances create` command or the `gcloud compute instances
set-service-account` command.

## Running locally and elsewhere

To run the Stackdriver Debugger agent outside of Google Cloud Platform, you must
supply your GCP project ID and appropriate service account credentials directly
to the Stackdriver Debugger agent. This applies to running the agent on your own
workstation, on your datacenter's computers, or on the VM instances of another
cloud provider. See the [Authentication section](#authentication) for
instructions on how to do so.

## Authentication

This library uses Service Account credentials to connect to Google Cloud
services. When running on Compute Engine the credentials will be discovered
automatically. When running on other environments the Service Account
credentials can be specified by providing in several ways.

The best way to provide authentication information if you're using Ruby on Rails
is through the Rails configuration interface:

```ruby
# in config/environments/*.rb
Rails.application.configure do |config|
  # Shared parameters
  config.google_cloud.project_id = "your-project-id"
  config.google_cloud.keyfile = "/path/to/key.json"
  # Or Stackdriver Debugger agent specific parameters
  config.google_cloud.debugger.project_id = "your-project-id"
  config.google_cloud.debugger.keyfile = "/path/to/key.json"
end
```

Other Rack-based applications that are loading the Rack Middleware directly can use
the configration interface:

```ruby
require "google/cloud/debugger"
Google::Cloud.configure do |config|
  # Shared parameters
  config.project_id = "your-project-id"
  config.keyfile = "/path/to/key.json"
  # Or Stackdriver Debugger agent specific parameters
  config.debugger.project_id = "your-project-id"
  config.debugger.keyfile = "/path/to/key.json"
end
```

Or provide the parameters to the Stackdriver Debugger agent when it starts:

```ruby
require "google/cloud/debugger"
Google::Cloud::Debugger.new(project_id: "your-project-id",
                            credentials: "/path/to/key.json").start
```

This library also supports the other authentication methods provided by the
`google-cloud-ruby` suite. Instructions and configuration options are covered
in the [Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-debugger/guides/authentication).

## Supported Ruby Versions

This library is supported on Ruby 2.2+.

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
