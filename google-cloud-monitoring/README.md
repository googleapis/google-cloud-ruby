# Ruby Client for Stackdriver Monitoring API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))

[Stackdriver Monitoring API][Product Documentation]:
Manages your Stackdriver Monitoring data and configurations. Most projects must
be associated with a Stackdriver account, with a few exceptions as noted on the
individual method pages.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable the Stackdriver Monitoring API.](https://console.cloud.google.com/apis/api/monitoring)
3. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)

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

### Next Steps
- Read the [Client Library Documentation][] for Stackdriver Monitoring API
  to see other available methods on the client.
- Read the [Stackdriver Monitoring API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-monitoring/latest/google/monitoring/v3
[Product Documentation]: https://cloud.google.com/monitoring
