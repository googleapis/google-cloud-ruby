# Ruby Client for Google Cloud Vision API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))

[Google Cloud Vision API][Product Documentation]:
Integrates Google Vision features, including image labeling, face, logo, and
landmark detection, optical character recognition (OCR), and detection of
explicit content, into applications.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the Google Cloud Vision API.](https://console.cloud.google.com/apis/api/vision)
4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)

### Installation
```
$ gem install google-cloud-vision
```

### Preview
#### ImageAnnotatorClient
```rb
require "google/cloud/vision"

image_annotator_client = Google::Cloud::Vision.new
landmarks = image_annotator_client.landmark_detection("path/to/landmark.jpg")
```

### Next Steps
- Read the [Client Library Documentation][] for Google Cloud Vision API
  to see other available methods on the client.
- Read the [Google Cloud Vision API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-vision/latest/google/cloud/vision/v1
[Product Documentation]: https://cloud.google.com/vision
