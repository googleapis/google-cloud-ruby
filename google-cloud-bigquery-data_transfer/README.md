# Ruby Client for BigQuery Data Transfer API ([Beta](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))

[BigQuery Data Transfer API][Product Documentation]:
Transfers data from partner SaaS applications to Google BigQuery on a
scheduled, managed basis.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the BigQuery Data Transfer API.](https://console.cloud.google.com/apis/api/bigquerydatatransfer)
4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)

### Installation
```
$ gem install google-cloud-bigquery-data_transfer
```

### Preview
#### DataTransferServiceClient
```rb
require "google/cloud/bigquery/data_transfer"

data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer.new
formatted_parent = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_path(project_id)

# Iterate over all results.
data_transfer_service_client.list_data_sources(formatted_parent).each do |element|
  # Process element.
end

# Or iterate over results one page at a time.
data_transfer_service_client.list_data_sources(formatted_parent).each_page do |page|
  # Process each page at a time.
  page.each do |element|
    # Process element.
  end
end
```

### Next Steps
- Read the [Client Library Documentation][] for BigQuery Data Transfer API
  to see other available methods on the client.
- Read the [BigQuery Data Transfer API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library. The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as shown below, or a [`Google::Cloud::Logging::Logger`](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest/google/cloud/logging/logger) that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb) and the gRPC [spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb) for additional information.

Configuring a Ruby stdlib logger:

```ruby
require "logger"

module MyLogger
  LOGGER = Logger.new $stderr, level: Logger::WARN
  def logger
    LOGGER
  end
end

# Define a gRPC module-level logger method before grpc/logconfig.rb loads.
module GRPC
  extend MyLogger
end
```

## Supported Ruby Versions

This library is supported on Ruby 2.3+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Currently, this means Ruby 2.3
and later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.

[Client Library Documentation]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-bigquery-data_transfer/latest/google/cloud/bigquery/datatransfer/v1
[Product Documentation]: https://cloud.google.com/bigquerydatatransfer
