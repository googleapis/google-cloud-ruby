# Error Reporting

Error Reporting counts, analyzes and aggregates the crashes in your
running cloud services. The Error Reporting Instrumentation client
provides a simple way to report errors from your application.

For general information about Error Reporting, read [Error Reporting Documentation](https://cloud.google.com/error-reporting/docs/).

The goal of google-cloud is to provide an API that is comfortable to Rubyists.
Your authentication credentials are detected automatically in Google Cloud
Platform (GCP), including Google Compute Engine (GCE), Google Kubernetes Engine
(GKE), Google App Engine (GAE), Google Cloud Functions (GCF) and Cloud Run. In
other environments you can configure authentication easily, either directly in
your code or via environment variables. Read more about the options for
connecting in the [Authentication Guide](AUTHENTICATION.md).

## How to report errors

You can easily report exceptions from your applications to Error
Reporting service:

```ruby
require "google/cloud/error_reporting"

# Configure Error Reporting instrumentation
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

See the [Instrumentation Guide](INSTRUMENTATION.md) for more examples.

## Additional information

Error Reporting can be configured to use gRPC's logging. To learn more, see the[Logging guide](LOGGING.md).
