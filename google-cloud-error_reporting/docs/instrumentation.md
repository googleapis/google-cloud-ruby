# Stackdriver Error Reporting Instrumentation

The google-cloud-error_reporting gem provides framework instrumentation features
to make it easy to report exceptions from your application.

## Installation
```
$ gem install google-cloud-error_reporting
```

## Quick Start
```ruby
require "google/cloud/error_reporting"
 
# Configure Stackdriver ErrorReporting instrumentation
Google::Cloud::ErrorReporting.configure do |config|
  config.project_id = "my-project"
  config.keyfile = "/path/to/keyfile.json"
end
 
# Insert a Rack Middleware to report unhanded exceptions 
use Google::Cloud::ErrorReporting::Middleware
 
# Or explicitly submit exceptions
begin
  fail "Boom!"
rescue => exception
  Google::Cloud::ErrorReporting.report exception
end
```

## Configuration
All Stackdriver service instrumentation can be configured through a single interface
```ruby
require "google/cloud/error_reporting"
 
Google::Cloud.configure do |config|
  # Sharing authentication parameters
  config.project_id = "my-project"
  config.keyfile    = "/path/to/keyfile.json"
  # Or more specificly for ErrorReporting
  config.error_reporting.project_id = "my-error_reporting-project"
  config.error_reporting.keyfile    = "/path/error_reporting/keyfile.json"
  
  # Explicitly enable or disable ErrorReporting
  config.use_error_reporting = true
 
  # Set Stackdriver Error Reporting service context
  config.error_reporting.service_name = "my-app-name"
  config.error_reporting.service_version = "my-app-version"
end
```

The Stackdriver ErrorReporting specific configuration parameters can also be
configured through its own interface
```ruby
require "google/cloud/error_reporting"
 
# These two blocks code are functionally identical
Google::Cloud::ErrorReporting do |config|
  config.project_id      = "my-project"
  config.keyfile         = "/path/to/keyfile.json"
  config.service_name    = "my-app-name"
  config.service_version = "my-app-version"
end
 
Google::Cloud.configure do |config|
  config.error_reporting.project_id      = "my-project"
  config.error_reporting.keyfile         = "/path/to/keyfile.json"
  config.error_reporting.service_name    = "my-app-name"
  config.error_reporting.service_version = "my-app-version"
end
```
These configuration parameters will be applied to both of the `Google::Cloud::ErrorReporting::Middleware` and
the `Google::Cloud::ErrorReporting.report` interface

## Rack Middleware and Railtie
The google-cloud-error_reporting gem provides a Rack Middleware class that can easily integrate with Rack based application frameworks, such as Rails and Sinatra. When enabled, it automatically gathers application exceptions from requests and submit the information to the Stackdriver Error Reporting service. On top of that, the google-cloud-error_reporting also implements a Railtie class that automatically enables the Rack Middleware in Rails applications when used.

### Rails Integration

To use the Stackdriver Error Reporting Railtie for Ruby on Rails applications, simply add this line to config/application.rb:
```ruby
require "google/cloud/error_reporting/rails"
```
Then the instrumentation library can also be configured through Rails configuration interface:
```ruby
# In config/environments/*.rb
 
Rails.application.configure do
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
end
```

Alternatively, check out [stackdriver](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver) gem, which enables this Railtie by default.

### Rack Integration

Other Rack base framework can also directly leverage the Middleware directly:
```ruby
require "google/cloud/error_reporting"
 
Google::Cloud::ErrorReporting.configure do |config|
  config.project_id      = "my-project"
  config.keyfile         = "/path/to/keyfile.json"
  config.service_name    = "my-app-name"
  config.service_version = "my-app-version"
end
 
use Google::Cloud::ErrorReporting::Middleware
```

## Report Captured Expcetions
Captured Ruby exceptions can be directly reported to Stackdriver ErrorReporting
by using `Google::Cloud::ErrorReporting.report`
```ruby
begin
  fail "Boom!"
rescue => exception
  Google::Cloud::ErrorReporting.report exception
end
```

The reported error event can also be customized
```ruby
begin
  fail "Boom!"
rescue => exception
  Google::Cloud::ErrorReporting.report exception do |error_event|
    # Directly modify the Google::Cloud::ErrorReporting::ErrorEvent object before submission
    error_event.message     = "Custom error message"
    error_event.user        = "johndoh@example.com"
    error_event.http_status = 502
  end
end
```
See [Google::Cloud::ErrorReporting::ErrorEvent](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-error_reporting/v0.24.0/google/cloud/errorreporting/errorevent) 
class for all options.
