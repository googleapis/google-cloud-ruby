# Stackdriver Logging Instrumentation

Then google-cloud-logging gem provides a Rack Middleware class that can easily 
integrate with Rack based application frameworks, such as Rails and Sinatra. 
When enabled, it sets an instance of Google::Cloud::Logging::Logger as the 
default Rack or Rails logger. Then all consequent log entries will be submitted 
to the Stackdriver Logging service. 

On top of that, the google-cloud-logging also implements a Railtie class that 
automatically enables the Rack Middleware in Rails applications when used.

## Using instrumentation with Ruby on Rails

To install application instrumentation in your Ruby on Rails app, add this
gem, `google-cloud-logging`, to your Gemfile and update your bundle. Then
add the following line to your `config/application.rb` file:
```ruby
require "google/cloud/logging/rails"
```
This will load a Railtie that automatically integrates with the Rails
framework by injecting a Rack middleware. The logging instrumentation can be 
configured with the following Rails configuration:
```ruby
# Sharing authentication parameters
config.google_cloud.project_id = "gcp-project-id"
config.google_cloud.keyfile = "/path/to/gcp/secret.json"
# Or more specificly for Logging
config.google_cloud.logging.project_id = "gcp-project-id"
config.google_cloud.logging.keyfile = "/path/to/gcp/sercret.json"
 
# Explicitly enable or disable Logging
config.google_cloud.use_logging = true
 
# Set Stackdriver Logging log name
config.google_cloud.logging.log_name = "my-app-log"
 
# Override default monitored resource if needed. E.g. used on AWS
config.google_cloud.logging.monitored_resource.type = "aws_ec2_instance"
config.google_cloud.logging.monitored_resource.labels.instance_id = "ec2-instance-id"
config.google_cloud.logging.monitored_resource.labels.aws_account = "AWS account number"
```
## Using instrumentation with Sinatra

To install application instrumentation in your Sinatra app, add this gem,
`google-cloud-logging`, to your Gemfile and update your bundle. Then add
the following lines to your main application Ruby file:

```ruby
require "google/cloud/logging"
use Google::Cloud::Logging::Middleware
```

This will install the logging middleware in your application.

You may customize the logging instrumention by providing your own
Google::Cloud::Logging::Logger:
```ruby
require "google/cloud/logging"
 
logging = Google::Cloud::Logging.new
resource = Google::Cloud::Logging::Middleware.build_monitored_resource
logger = logging.logger "my-log-name",
                        resource
use Google::Cloud::Logging::Middleware, logger: logger
```
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
