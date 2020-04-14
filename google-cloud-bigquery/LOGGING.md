# Enabling Logging

The [google-cloud-bigquery](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-bigquery)
library uses the [Google API
Client](https://github.com/google/google-api-ruby-client/blob/master/README.md#logging)
library to perform RPC calls, but also rescues API errors and retries requests itself.
Therefore, it may be necessary to enable logging in both libraries.

# Enabling Logging in Google API Client

To enable general logging for google-cloud-bigquery, set the logger for the underlying [Google
API Client](https://github.com/google/google-api-ruby-client/blob/master/README.md#logging)
library. The logger that you provide may be a Ruby stdlib
[`Logger`](https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html) as
shown below, or a
[`Google::Cloud::Logging::Logger`](https://googleapis.dev/ruby/google-cloud-logging/latest)
that will write logs to [Cloud
Logging](https://cloud.google.com/logging/).

If you do not set the logger explicitly and your application is running in a
Rails environment, it will default to `Rails.logger`. Otherwise, if you do not
set the logger and you are not using Rails, logging is disabled by default.

Configuring a Ruby stdlib logger for Google API Client:

```ruby
require "logger"

my_logger = Logger.new $stderr
my_logger.level = Logger::WARN

# Set the Google API Client logger
Google::Apis.logger = my_logger
```

# Enabling Logging in google-cloud-bigquery

You may also pass the same logger (or a different one) when you call
{Google::Cloud::Bigquery.new} to instantiate a google-cloud-bigquery client.

Logging in the higher-level {Google::Cloud::Bigquery}
library is currently limited to logging errors that result in request retries.

Currently, log entries in google-cloud-bigquery use the following levels:

* `WARN` - Entries contain only the class name of a rescued error, in order
  to protect potentially sensitive user data.
* `DEBUG` - Entries contain all details of the rescued error, in order to
  facilitate debugging. ATTENTION: `DEBUG`-level logging should be used only
  in a carefully-controlled environment due to the possibility of logging
  sensitive user data.

Configuring a Ruby stdlib logger for google-cloud-bigquery:

```ruby
require "logger"

my_logger = Logger.new $stderr
my_logger.level = Logger::WARN

# Set the Google::Cloud::Bigquery logger for logging
# errors that result in request retries.
bigquery = Google::Cloud::Bigquery.new logger: my_logger
```
