# Stackdriver Trace Instrumentation

Then google-cloud-trace gem provides a Rack Middleware class that integrates with Rack-based application frameworks, such as Rails and Sinatra. When installed, the middleware collects performance traces of requests and, subject to sampling constraints, submits them to the Stackdriver Trace service.

Additionally, the google-cloud-trace gem provides a Railtie class that automatically enables the Rack Middleware in Rails applications when used.

## Configuration
The default configuration enables Stackdriver instrumentation features to run
on Google Cloud Platform. You can easily configure the instrumentation library 
if you want to run on a non Google Cloud environment or you want to customize 
the default behavior.

See the 
[Configuration Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver/guides/instrumentation_configuration)
for full configuration parameters.

## Rails Integration

To use the Stackdriver Logging Railtie for Ruby on Rails applications, simply add this line to config/application.rb:
```ruby
require "google/cloud/trace/rails"
```

Alternatively, check out the [stackdriver](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver) gem, which enables this Railtie by default.

## Rack Integration

Other Rack base frameworks can also directly leverage the built-in Middleware.
```ruby
require "google/cloud/trace"
use Google::Cloud::Trace::Middleware
```
