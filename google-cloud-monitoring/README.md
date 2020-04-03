# Ruby Client for Cloud Monitoring API

[Cloud Monitoring API][Product Documentation]:
Manages your Cloud Monitoring data and configurations. Most projects must
be associated with a Workspace, with a few exceptions as noted on the
individual method pages. The table entries below are presented in
alphabetical order, not in order of common use. For explanations of the
concepts found in the table entries, read the [Cloud Monitoring
documentation](https://cloud.google.com/monitoring/docs).
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the Cloud Monitoring API.](https://console.cloud.google.com/apis/library/monitoring.googleapis.com)
4. [Setup Authentication.](https://googleapis.dev/ruby/google-cloud-monitoring/latest/file.AUTHENTICATION.html)

### Installation
```
$ gem install google-cloud-monitoring
```

### Preview
#### MetricServiceClient
```rb
require "google/cloud/monitoring"

metric_client = Google::Cloud::Monitoring::Metric.new
formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path(project_id)

# Iterate over all results.
metric_client.list_monitored_resource_descriptors(formatted_name).each do |element|
  # Process element.
end

# Or iterate over results one page at a time.
metric_client.list_monitored_resource_descriptors(formatted_name).each_page do |page|
  # Process each page at a time.
  page.each do |element|
    # Process element.
  end
end
```

### Next Steps
- Read the [Client Library Documentation][] for Cloud Monitoring API
  to see other available methods on the client.
- Read the [Cloud Monitoring API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/googleapis/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googleapis.dev/ruby/google-cloud-monitoring/latest
[Product Documentation]: https://cloud.google.com/monitoring

## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library.
The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as shown below,
or a [`Google::Cloud::Logging::Logger`](https://googleapis.dev/ruby/google-cloud-logging/latest)
that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb)
and the gRPC [spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb) for additional information.

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

This library is supported on Ruby 2.4+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Currently, this means Ruby 2.4
and later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.
