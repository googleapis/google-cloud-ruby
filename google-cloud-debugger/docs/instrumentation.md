# Stackdriver Debugger Instrumentation

Stackdriver Debugger is a feature of the Google Cloud Platform that lets
you inspect the state of an application at any code location without using
logging statements and without stopping or slowing down your applications.
Your users are not impacted during debugging. Using the production
debugger you can capture the local variables and call stack and link it
back to a specific line location in your source code. You can use this to
analyze the production state of your application and understand the
behavior of your code in production.

For general information about Stackdriver Debugger, read [Stackdriver
Debugger Documentation](https://cloud.google.com/debugger/docs/).

The Stackdriver Debugger Ruby library, `google-cloud-debugger`, provides an
easy-to-use debugger instrumentation that reports state data, such as
value of program variables and the call stack, to Stackdriver Debugger
when the code at a breakpoint location is executed in your Ruby
application. See the [instrumenting your app](#instrumenting-your-app)
section for how to debug your application, in both development and production.

## Instrumenting Your App

This instrumentation library provides the following features to help you
debug your applications in production:

*   Automatic application registration. It facilitates multiple running
    instances of same version of application when hosted in production.
*   A background debugger agent that runs side-by-side with your
    application that automatically collects state data when code is
    executed at breakpoint locations.
*   A Rack middleware and Railtie that automatically manages the debugger
    agent for Ruby on Rails and other Rack-based Ruby applications.

When this library is configured in your running application, and the
source code and breakpoints are setup through the Google Cloud Console,
You'll be able to
[interact](https://cloud.google.com/debugger/docs/debugging) with your
application in real time through the [Stackdriver Debugger 
UI](https://console.cloud.google.com/debug?_ga=1.84295834.280814654.1476313407).
This library also integrates with Google App Engine Flexible to make debuggee
application configuration more seemless.

Note that when no breakpoints are created, the debugger agent consumes
very little resource and has no interference with the running application.
Once breakpoints are created and depends on where the breakpoints are
located, the debugger agent may add a little latency onto each request.
The application performance will be back to normal after all breakpoints
are finished being evaluated. Be aware the more breakpoints are created,
or the harder to reach the breakpoints, the more resource the debugger
agent would need to consume.

### Configuration

The default configuration enables Stackdriver instrumentation features to run on
Google Cloud Platform. You can easily configure the instrumentation library if 
you want to run on a non Google Cloud environment or you want to customize 
the default behavior.

See the
[Configuration Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver/guides/instrumentation_configuration)
for full configuration parameters.

### Using instrumentation with Ruby on Rails

To install application instrumentation in your Ruby on Rails app, add this
gem, `google-cloud-debugger`, to your Gemfile and update your bundle. Then
add the following line to your `config/application.rb` file:

```ruby
require "google/cloud/debugger/rails"
```

This will load a Railtie that automatically integrates with the Rails
framework by injecting a Rack middleware. 

### Using instrumentation with Sinatra

To install application instrumentation in your Sinatra app, add this gem,
`google-cloud-debugger`, to your Gemfile and update your bundle. Then add
the following lines to your main application Ruby file:

```ruby
require "google/cloud/debugger"
use Google::Cloud::Debugger::Middleware
```

This will install the debugger middleware in your application.

### Using instrumentation with other Rack-based frameworks

To install application instrumentation in an app using another Rack-based
web framework, add this gem, `google-cloud-debugger`, to your Gemfile and
update your bundle. Then add install the debugger middleware in your
middleware stack. In most cases, this means adding these lines to your
`config.ru` Rack configuration file:

```ruby
require "google/cloud/debugger"
use Google::Cloud::Debugger::Middleware
```

Some web frameworks have an alternate mechanism for modifying the
middleware stack. Consult your web framework's documentation for more
information.

### The Stackdriver diagnostics suite

The debugger library is part of the Stackdriver diagnostics suite, which
also includes error reporting, log analysis, and tracing analysis. If you
include the `stackdriver` gem in your Gemfile, this debugger library will
be included automatically. In addition, if you include the `stackdriver`
gem in an application using Ruby On Rails, the Railties will be installed
automatically. See the documentation for the "stackdriver" gem
for more details.
