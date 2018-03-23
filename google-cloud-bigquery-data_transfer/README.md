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

[Client Library Documentation]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-bigquery-data_transfer/latest/google/cloud/bigquery/datatransfer/v1
[Product Documentation]: https://cloud.google.com/bigquerydatatransfer
