# Stackdriver Debugger

Stackdriver Debugger is a feature of the Google Cloud Platform that lets you
inspect the state of an application at any code location without using logging
statements and without stopping or slowing down your applications. Your users
are not impacted during debugging. Using the production debugger you can capture
the local variables and call stack and link it back to a specific line location
in your source code. You can use this to analyze the production state of your
application and understand the behavior of your code in production.

For general information about Stackdriver Debugger, read [Stackdriver Debugger
Documentation](https://cloud.google.com/debugger/docs/).

The Stackdriver Debugger Ruby library, `google-cloud-debugger`, provides:

* Easy-to-use debugger instrumentation that reports state data, such as value of
  program variables and the call stack, to Stackdriver Debugger when the code at
  a breakpoint location is executed in your Ruby application. See the
  [instrumenting your app](#instrumenting-your-app) section for how to debug
  your application, in both development and production.
* An idiomatic Ruby API for registerying debuggee application, and querying or
  manipulating breakpoints in registered Ruby debuggee application. See
  [Debugger API](#stackdriver-debugger-api) section for an introduction to
  Stackdriver Debugger API.

## Instrumenting Your App

This instrumentation library provides the following features to help you debug
your applications in production:

* Automatic application registration. It facilitates multiple running instances
  of same version of application when hosted in production.
* A background debugger agent that runs side-by-side with your application that
  automatically collects state data when code is executed at breakpoint
  locations.
* A Rack middleware and Railtie that automatically manages the debugger agent
  for Ruby on Rails and other Rack-based Ruby applications.

When this library is configured in your running application, and the source code
and breakpoints are setup through the Google Cloud Console, You'll be able to
[interact](https://cloud.google.com/debugger/docs/debugging) with your
application in real time through the [Stackdriver Debugger
UI](https://console.cloud.google.com/debug?_ga=1.84295834.280814654.1476313407).
This library also integrates with Google App Engine Flexible to make debuggee
application configuration more seemless.

Note that when no breakpoints are created, the debugger agent consumes very
little resource and has no interference with the running application. Once
breakpoints are created and depends on where the breakpoints are located, the
debugger agent may add a little latency onto each request. The application
performance will be back to normal after all breakpoints are finished being
evaluated. Be aware the more breakpoints are created, or the harder to reach the
breakpoints, the more resource the debugger agent would need to consume.

### Using instrumentation with Ruby on Rails

To install application instrumentation in your Ruby on Rails app, add this gem,
`google-cloud-debugger`, to your Gemfile and update your bundle. Then add the
following line to your `config/application.rb` file:

```ruby
require "google/cloud/debugger/rails"
```

This will load a Railtie that automatically integrates with the Rails framework
by injecting a Rack middleware. The Railtie also takes in the following Rails
configuration as parameter of the debugger agent initialization:

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
# Stackdriver Debugger Agent service name identifier
config.google_cloud.debugger.service_name = "my-ruby-app"
# Stackdriver Debugger Agent service version identifier
config.google_cloud.debugger.service_version = "v1"
```

See the {Google::Cloud::Debugger::Railtie} class for more information.

### Using instrumentation with Sinatra

To install application instrumentation in your Sinatra app, add this gem,
`google-cloud-debugger`, to your Gemfile and update your bundle. Then add the
following lines to your main application Ruby file:

```ruby
require "google/cloud/debugger"
use Google::Cloud::Debugger::Middleware
```

This will install the debugger middleware in your application.

Configuration parameters may also be passed in as arguments to Middleware.

```ruby
require "google/cloud/debugger"
use Google::Cloud::Debugger::Middleware project: "debugger-project-id",
                                        keyfile: "/path/to/keyfile.json",
                                        service_name: "my-ruby-app",
                                        service_version: "v1"
```

### Using instrumentation with other Rack-based frameworks

To install application instrumentation in an app using another Rack-based web
framework, add this gem, `google-cloud-debugger`, to your Gemfile and update
your bundle. Then add install the debugger middleware in your middleware stack.
In most cases, this means adding these lines to your `config.ru` Rack
configuration file:

```ruby
require "google/cloud/debugger"
use Google::Cloud::Debugger::Middleware
```

Some web frameworks have an alternate mechanism for modifying the middleware
stack. Consult your web framework's documentation for more information.

### The Stackdriver diagnostics suite

The debugger library is part of the Stackdriver diagnostics suite, which also
includes error reporting, log analysis, and tracing analysis. If you include the
`stackdriver` gem in your Gemfile, this debugger library will be included
automatically. In addition, if you include the `stackdriver` gem in an
application using Ruby On Rails, the Railties will be installed automatically.
See the documentation for the "stackdriver" gem for more details.

## Stackdriver Debugger API

This library also includes an easy to use Ruby client for the Stackdriver
Debugger API. This API provides calls to register debuggee application, as well
as creating or modifying breakpoints.

For further information on the Debugger API, see
{Google::Cloud::Debugger::Project}

### Registering debuggee application

```ruby
require "google/cloud/debugger/v2"

Controller2Client = Google::Cloud::Debugger::V2::Controller2Client
Debuggee = Google::Devtools::Clouddebugger::V2::Debuggee

controller2_client = Controller2Client.new
debuggee = Debuggee.new
response = controller2_client.register_debuggee(debuggee)
debuggee_id = response.debuggee.id
```
See [Stackdriver Debugger Debuggee
doc](https://cloud.google.com/debugger/api/reference/rpc/google.devtools.clouddebugger.v2#google.devtools.clouddebugger.v2.Debuggee)
on fields necessary for registerying a debuggee.

Upon successful registration, the response debuggee object will contain a
debuggee_id that's later needed to interact with the other Stackdriver Debugger
API.

See {Google::Cloud::Debugger::V2::Controller2Client} for details.

### List Active Breakpoints

```ruby
require "google/cloud/debugger/v2"

Controller2Client = Google::Cloud::Debugger::V2::Controller2Client
controller2_client = Controller2Client.new

debuggee_id = ''
response = controller2_client.list_active_breakpoints(debuggee_id)
breakpoints = response.breakpoints
```

See {Google::Cloud::Debugger::V2::Controller2Client} for details.

### Update Active Breakpoint

Users can send custom snapshots for active breakpoints using this API.

```ruby
require "google/cloud/debugger/v2"

Breakpoint = Google::Devtools::Clouddebugger::V2::Breakpoint
Controller2Client = Google::Cloud::Debugger::V2::Controller2Client

controller2_client = Controller2Client.new
debuggee_id = ''
breakpoint = Breakpoint.new
response =
  controller2_client.update_active_breakpoint(debuggee_id, breakpoint)
```

See [Stackdriver Debugger Breakpoint
doc](https://cloud.google.com/debugger/api/reference/rpc/google.devtools.clouddebugger.v2#google.devtools.clouddebugger.v2.Breakpoint)
for all available fields for breakpoint.

See {Google::Cloud::Debugger::V2::Controller2Client} for details.

### Set Breakpoint

```ruby
require "google/cloud/debugger/v2"

Breakpoint = Google::Devtools::Clouddebugger::V2::Breakpoint
Debugger2Client = Google::Cloud::Debugger::V2::Debugger2Client

debugger2_client = Debugger2Client.new
debuggee_id = ''
breakpoint = Breakpoint.new
client_version = ''
response = debugger2_client.set_breakpoint(
             debuggee_id, breakpoint, client_version)
```

See [Stackdriver Debugger Breakpoint
doc](https://cloud.google.com/debugger/api/reference/rpc/google.devtools.clouddebugger.v2#google.devtools.clouddebugger.v2.Breakpoint)
for fields needed to specify breakpoint location.

See {Google::Cloud::Debugger::V2::Debugger2Client} for details.

### Get Breakpoint

```ruby
require "google/cloud/debugger/v2"

Debugger2Client = Google::Cloud::Debugger::V2::Debugger2Client

debugger2_client = Debugger2Client.new
debuggee_id = ''
breakpoint_id = ''
client_version = ''
response = debugger2_client.get_breakpoint(
             debuggee_id, breakpoint_id, client_version)
```

See {Google::Cloud::Debugger::V2::Debugger2Client} for details.

### Delete Breakpoint

```ruby
require "google/cloud/debugger/v2"

Debugger2Client = Google::Cloud::Debugger::V2::Debugger2Client

debugger2_client = Debugger2Client.new
debuggee_id = ''
breakpoint_id = ''
client_version = ''
debugger2_client.delete_breakpoint(
  debuggee_id, breakpoint_id, client_version)
```

See {Google::Cloud::Debugger::V2::Debugger2Client} for details.

### List Breakpoints

```ruby
require "google/cloud/debugger/v2"

Debugger2Client = Google::Cloud::Debugger::V2::Debugger2Client

Debugger2Client = Google::Cloud::Debugger::V2::Debugger2Client

debugger2_client = Debugger2Client.new
debuggee_id = ''
client_version = ''
response = debugger2_client.list_breakpoints(debuggee_id, client_version)
```

See {Google::Cloud::Debugger::V2::Debugger2Client} for details.

### List Debuggees

```ruby
require "google/cloud/debugger/v2"

Debugger2Client = Google::Cloud::Debugger::V2::Debugger2Client

debugger2_client = Debugger2Client.new
project = ''
client_version = ''
response = debugger2_client.list_debuggees(project, client_version)
```

See {Google::Cloud::Debugger::V2::Debugger2Client} for details.

## Additional information

Stackdriver Debugger can be configured to use gRPC's logging. To learn more, see
the {file:LOGGING.md Logging guide}.
