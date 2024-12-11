# Ruby Client for the Google Cloud Compute V1 API

API Client library for the Google Cloud Compute V1 API

google-cloud-compute-v1 is the official client library for the Google Cloud Compute V1 API.

https://github.com/googleapis/google-cloud-ruby

## Installation

```
$ gem install google-cloud-compute-v1
```

## Before You Begin

In order to use this library, you first need to go through the following steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
1. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
1. [Enable the API.](https://console.cloud.google.com/apis/library/compute.googleapis.com)
1. [Set up authentication.](AUTHENTICATION.md)

## Quick Start

```ruby
require "google/cloud/compute/v1"

client = ::Google::Cloud::Compute::V1::AcceleratorTypes::Rest::Client.new
request = ::Google::Cloud::Compute::V1::AggregatedListAcceleratorTypesRequest.new # (request fields as keyword arguments...)
response = client.aggregated_list request
```

View the [Client Library Documentation](https://cloud.google.com/ruby/docs/reference/google-cloud-compute-v1/latest)
for class and method documentation.

See also the [Product Documentation](https://cloud.google.com/compute/)
for general usage information.

## Debug Logging

This library comes with opt-in Debug Logging that can help you troubleshoot
your application's integration with the API. When logging is activated, key
events such as requests and responses, along with data payloads and metadata
such as headers and client configuration, are logged to the standard error
stream.

**WARNING:** Client Library Debug Logging includes your data payloads in
plaintext, which could include sensitive data such as PII for yourself or your
customers, private keys, or other security data that could be compromising if
leaked. Always practice good data hygiene with your application logs, and follow
the principle of least access. Google also recommends that Client Library Debug
Logging be enabled only temporarily during active debugging, and not used
permanently in production.

To enable logging, set the environment variable `GOOGLE_SDK_RUBY_LOGGING_GEMS`
to the value `all`. Alternatively, you can set the value to a comma-delimited
list of client library gem names. This will select the default logging behavior,
which writes logs to the standard error stream. On a local workstation, this may
result in logs appearing on the console. When running on a Google Cloud hosting
service such as [Google Cloud Run](https://cloud.google.com/run), this generally
results in logs appearing alongside your application logs in the
[Google Cloud Logging](https://cloud.google.com/logging/) service.

You can customize logging by modifying the `logger` configuration when
constructing a client object. For example:

```ruby
require "google/cloud/compute/v1"
require "logger"

client = ::Google::Cloud::Compute::V1::AcceleratorTypes::Rest::Client.new do |config|
  config.logger = Logger.new "my-app.log"
end
```

## Google Cloud Samples

To browse ready to use code samples check [Google Cloud Samples](https://cloud.google.com/docs/samples).

## Supported Ruby Versions

This library is supported on Ruby 2.7+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Older versions of Ruby _may_
still work, but are unsupported and not recommended. See
https://www.ruby-lang.org/en/downloads/branches/ for details about the Ruby
support schedule.
