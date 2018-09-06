# Error Reporting

Stackdriver Error Reporting counts, analyzes and aggregates the crashes in your
running cloud services. The Stackdriver Error Reporting Instrumentation client
provides a simple way to report errors from your application.

For general information about Stackdriver Error Reporting, read [Stackdriver
Error Reporting Documentation](https://cloud.google.com/error-reporting/docs/).

The goal of google-cloud is to provide an API that is comfortable to Rubyists.
Your authentication credentials are detected automatically in Google Cloud
Platform environments such as Google Compute Engine, Google App Engine and
Google Kubernetes Engine. In other environments you can configure authentication
easily, either directly in your code or via environment variables. Read more
about the options for connecting in the {file:AUTHENTICATION.md Authentication
Guide}.

## How to report errors

You can easily report exceptions from your applications to Stackdriver Error
Reporting service:

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

See the {file:INSTRUMENTATION.md Instrumentation Guide} for more examples.

## Additional information

Stackdriver Error Reporting can be configured to use gRPC's logging. To learn more, see the
{file:LOGGING.md Logging guide}.
