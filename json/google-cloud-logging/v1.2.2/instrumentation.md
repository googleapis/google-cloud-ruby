# Stackdriver Logging Instrumentation

Then google-cloud-logging gem provides a Rack Middleware class that can easily 
integrate with Rack based application frameworks, such as Rails and Sinatra. 
When enabled, it sets an instance of Google::Cloud::Logging::Logger as the 
default Rack or Rails logger. Then all consequent log entries will be submitted 
to the Stackdriver Logging service. 

On top of that, the google-cloud-logging also implements a Railtie class that 
automatically enables the Rack Middleware in Rails applications when used.

## Configuration
The default configuration enables Stackdriver instrumentation features to run
on Google Cloud Platform. You can easily configure the instrumentation library 
if you want to run on a non Google Cloud environment or you want to customize 
the default behavior.

See the 
[Configuration Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver/guides/instrumentation_configuration)
for full configuration parameters.

## Using instrumentation with Ruby on Rails

To install application instrumentation in your Ruby on Rails app, add this
gem, `google-cloud-logging`, to your Gemfile and update your bundle. Then
add the following line to your `config/application.rb` file:
```ruby
require "google/cloud/logging/rails"
```
This will load a Railtie that automatically integrates with the Rails
framework by injecting a Rack middleware.

## Using instrumentation with Sinatra

To install application instrumentation in your Sinatra app, add this gem,
`google-cloud-logging`, to your Gemfile and update your bundle. Then add
the following lines to your main application Ruby file:

```ruby
require "google/cloud/logging"
use Google::Cloud::Logging::Middleware
```

This will install the logging middleware in your application.

### Using instrumentation with other Rack-based frameworks

To install application instrumentation in an app using another Rack-based
web framework, add this gem, `google-cloud-logging`, to your Gemfile and
update your bundle. Then add install the logging middleware in your
middleware stack. In most cases, this means adding these lines to your
`config.ru` Rack configuration file:

```ruby
require "google/cloud/logging"
use Google::Cloud::Logging::Middleware
```

Some web frameworks have an alternate mechanism for modifying the
middleware stack. Consult your web framework's documentation for more
information.

### The Stackdriver diagnostics suite

The google-cloud-logging library is part of the Stackdriver diagnostics suite, 
which also includes error reporting, tracing analysis, and real-time debugger. 
If you include the `stackdriver` gem in your Gemfile, this logging library will
be included automatically. In addition, if you include the `stackdriver`
gem in an application using Ruby On Rails, the Railties will be installed
automatically. See the documentation for the "stackdriver" gem
for more details.
