# Stackdriver Error Reporting Instrumentation

Then google-cloud-error_reporting gem provides a Rack Middleware class that can easily integrate with Rack based application frameworks, such as Rails and Sinatra. When enabled, it automatically gathers application exceptions from requests and submit the information to the Stackdriver Error Reporting service.  

On top of that, the google-cloud-error_reporting also implements a Railtie class that automatically enables the Rack Middleware in Rails applications when used.

## Rails Integration

To use the Stackdriver Error Reporting Railtie for Ruby on Rails applications, simply add this line to config/application.rb:
```ruby
require "google/cloud/error_reporting/rails"
```
Then the library can be configured through this set of Rails parameters in config/environments/*.rb:
```ruby
# Sharing authentication parameters
config.google_cloud.project_id = "gcp-project-id"
config.google_cloud.keyfile = "/path/to/gcp/secret.json"
# Or more specificly for ErrorReporting
config.google_cloud.error_reporting.project_id = "gcp-project-id"
config.google_cloud.error_reporting.keyfile = "/path/to/gcp/sercret.json"
 
# Explicitly enable or disable ErrorReporting
config.google_cloud.use_error_reporting = true
 
# Set Stackdriver Error Reporting service context
config.google_cloud.error_reporting.service_name = "my-app-name"
config.google_cloud.error_reporting.service_version = "my-app-version"
```

Alternatively, check out [stackdriver](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver) gem, which enables this Railtie by default.

## Rack Integration

Other Rack base framework can also directly leverage the built-in Middleware:
```ruby
require "google/cloud/error_reporting/v1beta1"
 
use Google::Cloud::ErrorReporting::Middleware
```
