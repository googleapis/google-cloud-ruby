# Stackdriver Logging Instrumentation

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

Other Stackdriver Debugger service features not covered by this
application instrumentation:

*   Source code context generation. The Stackdriver Debugger service
    console is able to display your application source code from a source
    of your choice if a source context JSON file exists. See
    [Debugger Doc](https://cloud.google.com/debugger/docs/source-context)
    on how to select source code on Stackdriver Debugger UI.
*   Breakpoints creation and manipulation. See the [Debugger
    Doc](https://cloud.google.com/debugger/docs/debugging) on how to
    manage breakpoints on Cloud Console.

When this library is installed and configured in your running application,
you can view your applications breakpoint snapshots in real time by
opening the Google Cloud Console in your web browser and navigating to the
"Debug" section. It also integrates with Google App Engine Flexible to
make application registration more seemless, and helps Stackdriver
Debugger Console to select correct version of source code from Cloud
Source Repository.

Note that when no breakpoints are created, the debugger agent consumes
very little resource and has no interference with the running application.
Once breakpoints are created and depends on where the breakpoints are
located, the debugger agent may add a little latency onto each request.
The application performance will be back to normal after all breakpoints
are finished being evaluated. Be aware the more breakpoints are created,
or the harder to reach the breakpoints, the more resource the debugger
agent would need to consume.

### Using instrumentation with Ruby on Rails

To install application instrumentation in your Ruby on Rails app, add this
gem, `google-cloud-debugger`, to your Gemfile and update your bundle. Then
add the following line to your `config/application.rb` file:

```ruby
require "google/cloud/debugger/rails"
```

This will load a Railtie that automatically integrates with the Rails
framework by injecting a Rack middleware. The Railtie also takes in the
following Rails configuration as parameter of the debugger agent
initialization:

```ruby
# Explicitly enable or disable Stackdriver Debugger Agent
config.google_cloud.use_debugger = true
# Shared Google Cloud Platform project identifier
config.google_cloud.project_id = "gcloud-project"
# Google Cloud Platform project identifier for Stackdriver Debugger only
config.google_cloud.debugger.project_id = "debugger-project"
# Shared Google Cloud authentication json file
config.google_cloud.keyfile = "/path/to/keyfile.json"
# Google Cloud authentication json file for Stackdriver Debugger only
config.google_cloud.debugger.keyfile = "/path/to/debugger/keyfile.json"
# Stackdriver Debugger Agent module name identifier
config.google_cloud.debugger.module_name = "my-ruby-app"
# Stackdriver Debugger Agent module version identifier
config.google_cloud.debugger.module_version = "v1"
```

See the Google::Cloud::Debugger::Railtie class for more information.

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
