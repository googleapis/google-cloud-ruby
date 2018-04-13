# Ruby Client for Stackdriver Monitoring API ([Beta](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))

[Stackdriver Monitoring API][Product Documentation]:
Manages your Stackdriver Monitoring data and configurations. Most projects
must be associated with a Stackdriver account, with a few exceptions as
noted on the individual method pages.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the Stackdriver Monitoring API.](https://console.cloud.google.com/apis/api/monitoring)
4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)

### Installation
```
$ gem install google-cloud-monitoring
```

### Preview
#### MetricServiceClient
```rb
require "google/cloud/monitoring"

metric_service_client = Google::Cloud::Monitoring::Metric.new
formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path(project_id)

# Iterate over all results.
metric_service_client.list_monitored_resource_descriptors(formatted_name).each do |element|
  # Process element.
end

# Or iterate over results one page at a time.
metric_service_client.list_monitored_resource_descriptors(formatted_name).each_page do |page|
  # Process each page at a time.
  page.each do |element|
    # Process element.
  end
end
```

### Supported Ruby Versions

This library is supported on Ruby 2.0+.

However, Ruby 2.3 or later is strongly recommended, as earlier releases have
reached or are nearing end-of-life. After June 1, 2018, Google will provide
official support only for Ruby versions that are considered current and
supported by Ruby Core (that is, Ruby versions that are either in normal
maintenance or in security maintenance).
See https://www.ruby-lang.org/en/downloads/branches/ for further details.

### Next Steps
- Read the [Client Library Documentation][] for Stackdriver Monitoring API
  to see other available methods on the client.
- Read the [Stackdriver Monitoring API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-monitoring/latest/google/monitoring/v3
[Product Documentation]: https://cloud.google.com/monitoring
