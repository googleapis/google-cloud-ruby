# Ruby Client for Cloud Video Intelligence API ([GA](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))

[Cloud Video Intelligence API][Product Documentation]:
Cloud Video Intelligence API.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the Cloud Video Intelligence API.](https://console.cloud.google.com/apis/api/video-intelligence)
4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)

### Installation
```
$ gem install google-cloud-video_intelligence
```

### Preview
#### VideoIntelligenceServiceClient
```rb
require "google/cloud/video_intelligence"

video_intelligence_service_client = Google::Cloud::VideoIntelligence.new
input_uri = "gs://demomaker/cat.mp4"
features_element = :LABEL_DETECTION
features = [features_element]

# Register a callback during the method call.
operation = video_intelligence_service_client.annotate_video(input_uri: input_uri, features: features) do |op|
  raise op.results.message if op.error?
  op_results = op.results
  # Process the results.

  metadata = op.metadata
  # Process the metadata.
end

# Or use the return value to register a callback.
operation.on_done do |op|
  raise op.results.message if op.error?
  op_results = op.results
  # Process the results.

  metadata = op.metadata
  # Process the metadata.
end

# Manually reload the operation.
operation.reload!

# Or block until the operation completes, triggering callbacks on
# completion.
operation.wait_until_done!
```

### Next Steps
- Read the [Client Library Documentation][] for Cloud Video Intelligence API
  to see other available methods on the client.
- Read the [Cloud Video Intelligence API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-video_intelligence/latest/google/cloud/videointelligence/v1
[Product Documentation]: https://cloud.google.com/video-intelligence
