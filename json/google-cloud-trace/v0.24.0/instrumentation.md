# Stackdriver Trace Instrumentation

Then google-cloud-trace gem provides a Rack Middleware class that integrates with Rack-based application frameworks, such as Rails and Sinatra. When installed, the middleware collects performance traces of requests and, subject to sampling constraints, submits them to the Stackdriver Trace service.

Additionally, the google-cloud-trace gem provides a Railtie class that automatically enables the Rack Middleware in Rails applications when used.

## Rails Integration

To use the Stackdriver Logging Railtie for Ruby on Rails applications, simply add this line to config/application.rb:
```ruby
require "google/cloud/trace/rails"
```

Then the library can be configured through this set of Rails parameters in config/environments/*.rb:
```ruby
# Sharing authentication parameters
config.google_cloud.project_id = "gcp-project-id"
config.google_cloud.keyfile = "/path/to/gcp/secret.json"
# Or more specificly for Logging
config.google_cloud.logging.project_id = "gcp-project-id"
config.google_cloud.logging.keyfile = "/path/to/gcp/sercret.json"

# Explicitly enable or disable Trace
config.google_cloud.use_trace = true

# Choose ActiveRecord notifications to trace
config.google_cloud.trace.notifications =
  Google::Cloud::Trace::Railtie::DEFAULT_NOTIFICATIONS +
  ["render_partial.action_view"]

# Specify whether to capture call stacks
config.google_cloud.trace.capture_stack = true
```

Alternatively, check out the [stackdriver](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver) gem, which enables this Railtie by default.

## Rack Integration

Other Rack base frameworks can also directly leverage the built-in Middleware.
```ruby
require "google/cloud/trace"
use Google::Cloud::Trace::Middleware
```
