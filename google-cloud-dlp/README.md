# Ruby Client for DLP API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))

[DLP API][Product Documentation]:
The Google Data Loss Prevention API provides methods for detection of
privacy-sensitive fragments in text, images, and Google Cloud Platform storage
repositories.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable the DLP API.](https://console.cloud.google.com/apis/api/dlp)
3. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)

### Installation
```
$ gem install google-cloud-dlp
```

### Preview
#### DlpServiceClient
```rb
require "google/cloud/dlp"

dlp_service_client = Google::Cloud::Dlp.new
min_likelihood = :POSSIBLE
inspect_config = { min_likelihood: min_likelihood }
type = "text/plain"
value = "my phone number is 215-512-1212"
items_element = { type: type, value: value }
items = [items_element]
response = dlp_service_client.inspect_content(inspect_config, items)
```

### Next Steps
- Read the [Client Library Documentation][] for DLP API
  to see other available methods on the client.
- Read the [DLP API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-dlp/latest/google/privacy/dlp/v2beta1
[Product Documentation]: https://cloud.google.com/dlp