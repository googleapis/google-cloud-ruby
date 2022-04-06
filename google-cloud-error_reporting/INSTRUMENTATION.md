# Error Reporting Instrumentation

The google-cloud-error_reporting gem provides framework instrumentation features
to make it easy to report exceptions from your application.

## Quick Start

```ruby
require "google/cloud/error_reporting"

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

The default configuration enables Google Cloud Error Reporting instrumentation features to run on
Google Cloud Platform. You can easily configure the instrumentation library  if
you want to run on a non Google Cloud environment or you want to customize  the
default behavior.

See the [Configuration
Guide](https://googleapis.dev/ruby/stackdriver/latest/file.INSTRUMENTATION_CONFIGURATION.html)
for full configuration parameters.

## Rack Middleware and Railtie

The google-cloud-error_reporting gem provides a Rack Middleware class that can
easily integrate with Rack based application frameworks, such as Rails and
Sinatra. When enabled, it automatically gathers application exceptions from
requests and submits the information to the Error Reporting service.
On top of that, the google-cloud-error_reporting also implements a Railtie class
that automatically enables the Rack Middleware in Rails applications when used.

### Rails Integration

To use the Error Reporting Railtie for Ruby on Rails applications,
simply add this line to `config/application.rb`:

```ruby
require "google/cloud/error_reporting/rails"
```

Alternatively, check out the
[stackdriver](https://googleapis.dev/ruby/stackdriver/latest
gem, which enables this Railtie by default.

### Rack Integration

Other Rack-based framework can also directly leverage the Middleware directly:

```ruby
require "google/cloud/error_reporting"

use Google::Cloud::ErrorReporting::Middleware
```

## Report Captured Exceptions

Captured Ruby exceptions can be reported directly to Error Reporting
by using {Google::Cloud::ErrorReporting.report}:

```ruby
begin
  fail "Boom!"
rescue => exception
  Google::Cloud::ErrorReporting.report exception
end
```

The reported error event can also be customized:

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

See {Google::Cloud::ErrorReporting::ErrorEvent} class for all options.
