# Stackdriver Trace

The Stackdriver Trace service collects and stores latency data from your
application and displays it in the Google Cloud Platform Console, giving
you detailed near-real-time insight into application performance.

The Stackdriver Trace Ruby library, `google-cloud-trace`, provides:

*   Easy-to-use trace instrumentation that collects and collates latency
    data for your Ruby application. If you just want latency trace data
    for your application to appear on the Google Cloud Platform Console,
    see the section on [instrumenting your app](#instrumenting-your-app).
*   An idiomatic Ruby API for querying, analyzing, and manipulating trace
    data in your Ruby application. For an introduction to the Trace API,
    see the section on the [Trace API](#stackdriver-trace-api).

## Instrumenting Your App

This library integrates with Rack-based web frameworks such as Ruby On
Rails to provide latency trace reports for your application.
Specifcally, it:

*   Provides a Rack middleware that automatically reports latency traces
    for http requests handled by your application, and measures the
    latency of each request as a whole.
*   Integrates with `ActiveSupport::Notifications` to add important
    latency-affecting events such as ActiveRecord queries to the trace.
*   Provides a simple API for your application code to define and
    measure latency-affecting processes specific to your application.

When this library is installed and configured in your running
application, you can view your application's latency traces in real time
by opening the Google Cloud Console in your web browser and navigating
to the "Trace" section. It also integrates with Google App Engine
Flexible and Google Container Engine to provide additional information
for applications hosted in those environments.

Note that not all requests will have traces. By default, the library will
sample about one trace every ten seconds per Ruby process, to prevent
heavily used applications from reporting too much data. It will also
omit certain requests used by Google App Engine for health checking. See
{Google::Cloud::Trace::TimeSampler} for more details.

### Using instrumentation with Ruby on Rails

To install application instrumentation in your Ruby on Rails app, add
this gem, `google-cloud-trace`, to your Gemfile and update your bundle.
Then add the following line to your `config/application.rb` file:

```ruby
require "google/cloud/trace/rails"
```

This will install a Railtie that automatically integrates with the
Rails framework, installing the middleware and the ActiveSupport
integration for you. Your application traces, including basic request
tracing, ActiveRecord query measurements, and view render measurements,
should then start appearing in the Cloud Console.

See the {Google::Cloud::Trace::Railtie} class for more information,
including how to customize your application traces.

### Using instrumentation with Sinatra

To install application instrumentation in your Sinatra app, add this gem,
`google-cloud-trace`, to your Gemfile and update your bundle. Then add
the following lines to your main application Ruby file:

```ruby
require "google/cloud/trace"
use Google::Cloud::Trace::Middleware
```

This will install the trace middleware in your application, providing
basic request tracing for your application. You may measure additional
processes such as database queries or calls to external services using
other classes in this library. See the {Google::Cloud::Trace::Middleware}
documentation for more information.

### Using instrumentation with other Rack-based frameworks

To install application instrumentation in an app using another Rack-based
web framework, add this gem, `google-cloud-trace`, to your Gemfile and
update your bundle. Then add install the trace middleware in your
middleware stack. In most cases, this means adding these lines to your
`config.ru` Rack configuration file:

```ruby
require "google/cloud/trace"
use Google::Cloud::Trace::Middleware
```

Some web frameworks have an alternate mechanism for modifying the
middleware stack. Consult your web framework's documentation for more
information.

### The Stackdriver diagnostics suite

The trace library is part of the Stackdriver diagnostics suite, which
also includes error reporting and log analysis. If you include the
`stackdriver` gem in your Gemfile, this trace library will be included
automatically. In addition, if you include the `stackdriver` gem in an
application using Ruby On Rails, the Railtie will be installed
automatically; you will not need to write any code to view latency
traces for your appl. See the documentation for the "stackdriver" gem
for more details.

## Stackdriver Trace API

This library also includes an easy to use Ruby client for the
Stackdriver Trace API. This API provides calls to report and modify
application traces, as well as to query and analyze existing traces.

For further information on the trace API, see
{Project}.

### Querying traces using the API

Using the Stackdriver Trace API, your application can query and analyze
its own traces and traces of other projects. Here is an example query
for all traces in the past hour.

```ruby
require "google/cloud/trace"
trace_client = Google::Cloud::Trace.new

traces = trace_client.list_traces Time.now - 3600, Time.now
traces.each do |trace|
  puts "Retrieved trace ID: #{trace.trace_id}"
end
```

Each trace is an object of type {Google::Cloud::Trace::TraceRecord},
which provides methods for analyzing tasks that took place during the
request trace. See https://cloud.google.com/trace for more information
on the kind of data you can capture in a trace.

### Reporting traces using the API

Usually it is easiest to use this library's trace instrumentation
features to collect and record application trace information. However,
you may also use the trace API to update this data. Here is an example:

```ruby
require "google/cloud/trace"

trace_client = Google::Cloud::Trace.new

trace = Google::Cloud::Trace.new
trace.in_span "root_span" do
  # Do stuff...
end

trace_client.patch_traces trace
```

## Additional information

Stackdriver Trace can be configured to be used in Rack applications or to use
gRPC's logging. To learn more, see the {file:INSTRUMENTATION.md Instrumentation
Guide} and {file:LOGGING.md Logging guide}.
