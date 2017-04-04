# Stackdriver Logging Instrumentation

Then google-cloud-logging gem provides a Rack Middleware class that can easily integrate with Rack based application frameworks, such as Rails and Sinatra. When enabled, it sets an instance of Google::Cloud::Logging::Logger as the default Rack or Rails logger. Then all consequent log entries will be submitted to the Stackdriver Logging service. 

On top of that, the google-cloud-logging also implements a Railtie class that automatically enables the Rack Middleware in Rails applications when used.

## Rails Integration

To use the Stackdriver Logging Railtie for Ruby on Rails applications, simply add this line to config/application.rb:
```ruby
require "google/cloud/logging/rails"
```
Then the library can be configured through this set of Rails parameters in config/environments/*.rb:
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
Alternatively, check out [stackdriver](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver) gem, which enables this Railtie by default.

## Rack Integration

Other Rack base framework can also directly leverage the built-in Middleware.
```ruby
require "google/cloud/logging"
 
logging = Google::Cloud::Logging.new
resource = Google::Cloud::Logging::Middleware.build_monitored_resource
logger = logging.logger "my-log-name",
                        resource
use Google::Cloud::Logging::Middleware, logger: logger
```