# Ruby Client for Cloud Bigtable API

[Cloud Bigtable API][Product Documentation]:
API for reading and writing the contents of Bigtables associated with a
cloud project.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the Cloud Bigtable API.](https://console.cloud.google.com/apis/library/bigtable.googleapis.com)
4. [Setup Authentication.](https://googleapis.dev/ruby/google-cloud-bigtable/latest/file.AUTHENTICATION.html)

### Installation
```
$ gem install google-cloud-bigtable
```

### Next Steps
- Read the [Client Library Documentation][] for Cloud Bigtable API
  to see other available methods on the client.
- Read the [Cloud Bigtable API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/googleapis/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

## Authentication

This library uses Service Account credentials to connect to Google Cloud services. When running on Google Cloud Platform (GCP), including Google Compute Engine (GCE), Google Kubernetes Engine (GKE), Google App Engine (GAE), Google Cloud Functions (GCF) and Cloud Run, the credentials will be discovered automatically. When running on other environments the Service Account credentials can be specified by providing the path to the JSON file, or the JSON itself, in environment variables.

Instructions and configuration options are covered in the [Authentication Guide](https://googleapis.dev/ruby/google-cloud-bigtable/latest/file.AUTHENTICATION.html).

## Example

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new

table = bigtable.table("my-instance", "my-table")

entry = table.new_mutation_entry("user-1")
entry.set_cell(
  "cf1",
  "field1",
  "XYZ",
  timestamp: Time.now.to_i * 1000 # Time stamp in milliseconds.
).delete_cells("cf2", "field02")

table.mutate_row(entry)
```

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

## Supported Ruby Versions

This library is supported on Ruby 3.0+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Older versions of Ruby _may_
still work, but are unsupported and not recommended. See
https://www.ruby-lang.org/en/downloads/branches/ for details about the Ruby
support schedule.

[Client Library Documentation]: https://googleapis.dev/ruby/google-cloud-bigtable/latest
[Product Documentation]: https://cloud.google.com/bigtable
