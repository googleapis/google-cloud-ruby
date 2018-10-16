# google-cloud-debugger

[Stackdriver Debugger](https://cloud.google.com/debugger/) lets you inspect the
state of a running application at any code location in real time, without
stopping or slowing down the application, and without modifying the code to add
logging statements. You can use Stackdriver Debugger with any deployment of
your application, including test, development, and production. The Ruby
debugger adds minimal request latency, typically less than 50ms, and only when
application state is captured. In most cases, this is not noticeable by users.

- [google-cloud-debugger documentation](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-debugger/latest)
- [google-cloud-debugger on RubyGems](https://rubygems.org/gems/google-cloud-debugger)
- [Stackdriver Debugger documentation](https://cloud.google.com/debugger/docs/)

## Quick Start

### Installing the gem

Add the `google-cloud-debugger` gem to your Gemfile:

```ruby
gem "google-cloud-debugger"
```

Alternatively, consider installing the [`stackdriver`](../stackdriver) gem. It
includes the `google-cloud-debugger` gem as a dependency, and automatically
initializes it for some application frameworks.

### Initializing the Debugger

The Stackdriver Debugger library provides a Debugger agent that helps create
breakpoints in your running applications. It then collects application snapshot
data and transmits it to the Stackdriver Debugger service for you to view on
the Google Cloud Console. The library also comes with a Railtie and a Rack
Middleware to help control the Debugger agent in popular Rack based frameworks,
such as Ruby on Rails and Sinatra.

#### Setup with Ruby on Rails

You can load the Railtie that comes with the library into your Ruby
on Rails application by explicitly requiring it during the application startup:

```ruby
# In config/application.rb
require "google/cloud/debugger/rails"
```

If you're using the `stackdriver` gem, it automatically loads the Railtie into
your application when it starts.

#### Setup with other Rack-based frameworks

Other Rack-based frameworks, such as Sinatra, can use the Rack Middleware
provided by the library:

```ruby
require "google/cloud/debugger"
use Google::Cloud::Debugger::Middleware
```

#### Setup without a Rack-based framework

Non-rack-based applications can start the agent explicitly during the
initialization code:

```ruby
require "google/cloud/debugger"
Google::Cloud::Debugger.new.start
```

### Connecting to the Debugger

You can set breakpoints and view snapshots using the Google Cloud Console.
If your app is hosted on Google Cloud (such as on Google App Engine, Google
Kubernetes Engine, or Google Compute Engine), you can use the same project.
Otherwise, if your application is hosted elsewhere, create a new project on
[Google Cloud](https://console.cloud.google.com/).

Make sure the
[Stackdriver Debugger API](https://console.cloud.google.com/apis/library/clouddebugger.googleapis.com)
is enabled on your Google Cloud project.

To connect to the Stackdriver Debugger service, the agent needs to be
authenticated. If your application is hosted on Google Cloud Platform, much of
this is handled for you automatically.

#### Connecting from Google App Engine (GAE)

If your app is running on Google App Engine, the Stackdriver Debugger agent
authenticates automatically by default, and no additional configuration is
required.

#### Connecting from Google Kubernetes Engine (GKE)

If your app is running on Google Kubernetes Engine, you must explicitly add the
`cloud_debugger` OAuth scope when creating the cluster:

```sh
$ gcloud container clusters create example-cluster-name --scopes https://www.googleapis.com/auth/cloud_debugger
```

You can also do this through the Google Cloud Platform Console. Select
**Enabled** in the Cloud Platform section of **Create a container cluster**.

After the OAuth scope is enabled, the Stackdriver Debugger agent authenticates
automatically by default, and no additional configuration is required.

#### Connecting from Google Compute Engine (GCE)

If your app is running on Google Compute Engine, its VM instances should have
one of the following access scopes. These are only relevant when you use
Compute Engine's default service account:

* `https://www.googleapis.com/auth/cloud-platform`
* `https://www.googleapis.com/auth/cloud_debugger`

The `cloud-platform` access scope can be supplied when creating a new instance
through the Google Cloud Platform Console. Select **Allow full access to all
Cloud APIs** in the **Identity and API access** section of **Create an
instance**.

The `cloud_debugger` access scope can be supplied manually using the SDK's
`gcloud compute instances create` command or the `gcloud compute instances
set-service-account` command.

After the OAuth scope is enabled, the Stackdriver Debugger agent authenticates
automatically by default using the VM's service account, and no additional
configuration is required.

#### Connecting from other hosting environments

To run the Stackdriver Debugger agent outside of Google Cloud Platform, you must
supply your GCP project ID and appropriate service account credentials directly
to the Stackdriver Debugger agent. This applies to running the agent on your own
workstation, on your datacenter's computers, or on the VM instances of another
cloud provider.

The best way to provide authentication information if you're using Ruby on Rails
is through the Rails configuration interface:

```ruby
# in config/environments/*.rb
Rails.application.configure do |config|
  # Shared parameters
  config.google_cloud.project_id = "your-project-id"
  config.google_cloud.credentials = "/path/to/key.json"
  # Or Stackdriver Debugger agent specific parameters
  config.google_cloud.debugger.project_id = "your-project-id"
  config.google_cloud.debugger.credentials = "/path/to/key.json"
end
```

Other Rack-based applications that are loading the Rack Middleware directly can
use the configration interface:

```ruby
require "google/cloud/debugger"
Google::Cloud.configure do |config|
  # Shared parameters
  config.project_id = "your-project-id"
  config.credentials = "/path/to/key.json"
  # Or Stackdriver Debugger agent specific parameters
  config.debugger.project_id = "your-project-id"
  config.debugger.credentials = "/path/to/key.json"
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
in the [Authentication Guide](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-debugger/latest/file.AUTHENTICATION).

### Using the Debugger

When you set a breakpoint in the Stackdriver Debugger console, the agent takes
a snapshot of application data when the breakpoint is hit. The application then
continues running with minimal slowdown, and you can view the snapshot offline
in the console.

By default, the snapshot includes the local variables from the current and four
most recent stack frames. You may include additional data in the snapshot by
providing a list of _expressions_ when you create the breakpoint. Expressions
may be instance variables, global variables, or the result of calling Ruby
methods, or indeed, any Ruby expression.

For more information on using the debugger features, see the
[Stackdriver Debugger Documentation](https://cloud.google.com/debugger/docs/).

#### Working with Mutation Protection

To reduce the risk of corrupting your application data or changing your
application's behavior, the debugger agent checks all expressions you provide
for possible side effects before it runs them. If an expression calls any code
that could modify the program state, by changing an instance variable for
example, it is not evaluated.

This check is rather conservative, so if you are receiving mutation errors on
an expression you know to be safe, you may disable the check by wrapping your
expression in a call to `Google::Cloud::Debugger.allow_mutating_methods!`. For
example:

```ruby
Google::Cloud::Debugger.allow_mutating_methods! { my_expression() }
```

You may disable side effect checks globally by setting the
`allow_mutating_methods` configuration. See the next section on configuring the
agent.

#### Configuring the agent

You can customize the behavior of the Stackdriver Debugger agent. This includes
setting the Google Cloud project and authentication, and customizing the
behavior of the debugger itself, such as side effect protection and data
size limits. See [agent configuration](../stackdriver/INSTRUMENTATION_CONFIGURATION.md)
for a list of possible configuration options.

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

This library follows [Semantic Versioning](http://semver.org/). It is currently
in major version zero (0.y.z), which means that anything may change at any time
and the public API should not be considered stable.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing
Guide](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-debugger/latest/file.CONTRIBUTING)
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See [Code of
Conduct](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-debugger/latest/file.CODE_OF_CONDUCT)
for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-debugger/latest/file.LICENSE).

## Support

Please [report bugs at the project on
Github](https://github.com/googleapis/google-cloud-ruby/issues). Don't
hesitate to [ask
questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby)
about the client or APIs on [StackOverflow](http://stackoverflow.com).
