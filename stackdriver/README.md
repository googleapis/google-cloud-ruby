# stackdriver

This gem instruments a Ruby web application for Stackdriver diagnostics. When
loaded, it integrates with Rails, Sinatra, or other Rack-based web frameworks
to collect application diagnostic and monitoring information for your
application.

Specifically, this gem is a convenience package that loads and automatically
activates the instrumentation features of the following gems:

*   [google-cloud-debugger](../google-cloud-debugger) which enables remote
    debugging using [Stackdriver Debugger](https://cloud.google.com/debugger/)
*   [google-cloud-error_reporting](../google-cloud-error_reporting) which
    reports unhandled exceptions and other errors to
    [Stackdriver Error Reporting](https://cloud.google.com/error-reporting/)
*   [google-cloud-logging](../google-cloud-logging) which collects application
    logs in [Stackdriver logging](https://cloud.google.com/logging/)
*   [google-cloud-trace](../google-cloud-trace) which reports distributed
    latency traces to [Stackdriver Trace](https://cloud.google.com/trace/)

## Quick Start

### Install the gem

Add the `stackdriver` gem to your Gemfile:

```ruby
gem "stackdriver"
```

### Instrument your code

#### Using Ruby on Rails

If you are running Ruby on Rails, the `stackdriver` gem will automatically
install Railties that will instrument your application for basic diagnostics.
In most applications, the gem will initialize itself, and you will not need to
write any additional code.

If your Rails application has removed the `Bundler.require` line in the
`application.rb` initialization file, then you might need to require the gem
explicitly with:

```ruby
# In application.rb
require "stackdriver"
```

#### Other Rack-based frameworks

If you are running another Rack-based framework, such as Sinatra, you should
install the Rack Middleware provided by each library you want to use:

```ruby
# In your Rack middleware configuration code.
require "stackdriver"
use Google::Cloud::Logging::Middleware
use Google::Cloud::ErrorReporting::Middleware
use Google::Cloud::Trace::Middleware
use Google::Cloud::Debugger::Middleware
```

#### Advanced instrumentation

See the individual gem documentation for each gem for information on how to
customize the instrumentation, e.g. how to manually report errors or add custom
spans to latency traces.

### Viewing diagnostic reports

Logs, errors, traces, and other reports can be viewed on the Google Cloud
Console. If your app is hosted on Google Cloud (such as on Google App Engine,
Google Kubernetes Engine, or Google Compute Engine), you can use the same
project. Otherwise, if your application is hosted elsewhere, create a new
project on [Google Cloud](https://console.cloud.google.com/).

Make sure the [Stackdriver Error Reporting
API](https://console.cloud.google.com/apis/library/clouderrorreporting.googleapis.com)
is enabled on your Google Cloud project. (The other service APIs---debugging,
logging, and tracing---are enabled by default on all new projects.)

#### Authentication

Your app also needs to authenticate with the Stackdriver services in order to
send data.

*   If you are running on **Google App Engine**, authentication happens
    automatically. You do not need to do anything.
*   If you are running on **Google Kubernetes Engine**, you must explicitly add
    `https://www.googleapis.com/auth/cloud-platform` to the API access scopes
    when creating the cluster. Authentication will then happen automatically.
*   If you are running on **Google Compute Engine**, you must explicitly add
    `https://www.googleapis.com/auth/cloud-platform` to the API access scopes
    when creating the VM. Authentication will then happen automatically.
*   If you are not running on a Google Cloud hosting environment, you must set
    up a service account, and provide the Stackdriver library with the ID of
    your Google Cloud project, and the service account credentials.

    ```ruby
    # In your app initialization code
    Google::Cloud.configure do |config|
      config.project_id = "your-project-id"
      config.credentials = "/path/to/servce-account-keyfile.json"
    end
    ```

See the gem documentation for each individual gem for more information.

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
Guide](https://googleapis.github.io/google-cloud-ruby/docs/stackdriver/latest/file.CONTRIBUTING)
for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. See [Code of
Conduct](https://googleapis.github.io/google-cloud-ruby/docs/stackdriver/latest/file.CODE_OF_CONDUCT)
for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](LICENSE).

## Support

Please [report bugs at the project on
Github](https://github.com/googleapis/google-cloud-ruby/issues). Don't
hesitate to [ask
questions](http://stackoverflow.com/questions/tagged/google-cloud-ruby) about
the client or APIs on [StackOverflow](http://stackoverflow.com).
