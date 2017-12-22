# Ruby Client for Google Cloud Dataproc API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))

[Google Cloud Dataproc API][Product Documentation]:
Manages Hadoop-based clusters and jobs on Google Cloud Platform.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the Google Cloud Dataproc API.](https://console.cloud.google.com/apis/api/dataproc)
4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)

### Installation
```
$ gem install google-cloud-dataproc
```

### Preview
#### ClusterControllerClient
```rb
require "google/cloud/dataproc"

cluster_controller_client = Google::Cloud::Dataproc::ClusterController.new
project_id_2 = project_id
region = "global"

# Iterate over all results.
cluster_controller_client.list_clusters(project_id_2, region).each do |element|
  # Process element.
end

# Or iterate over results one page at a time.
cluster_controller_client.list_clusters(project_id_2, region).each_page do |page|
  # Process each page at a time.
  page.each do |element|
    # Process element.
  end
end
```

### Next Steps
- Read the [Client Library Documentation][] for Google Cloud Dataproc API
  to see other available methods on the client.
- Read the [Google Cloud Dataproc API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-dataproc/latest/google/cloud/dataproc/v1
[Product Documentation]: https://cloud.google.com/dataproc
