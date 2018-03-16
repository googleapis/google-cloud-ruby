# Ruby Client for DLP API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))

[DLP API][Product Documentation]:
The Google Data Loss Prevention API provides methods for detection of
privacy-sensitive fragments in text, images, and Google Cloud Platform
storage repositories.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the DLP API.](https://console.cloud.google.com/apis/api/dlp)
4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)

### Installation
```
$ gem install google-cloud-dlp
```

### Supported Ruby Versions

This library is supported on Ruby 2.0+.

However, Ruby 2.3 or later is strongly recommended, as earlier releases have
reached or are nearing end-of-life. After June 1, 2018, Google will provide
official support only for Ruby versions that are considered current and
supported by Ruby Core (that is, Ruby versions that are either in normal
maintenance or in security maintenance).
See https://www.ruby-lang.org/en/downloads/branches/ for further details.

### Preview
#### DlpServiceClient
```rb
require "google/cloud/dlp"

dlp = Google::Cloud::Dlp.new

inspect_config = { 
  info_types: [{ name: "PHONE_NUMBER" }], 
  min_likelihood: :POSSIBLE
}
item = { value: "my phone number is 215-512-1212" }
parent = "projects/#{ENV["DLP_TEST_PROJECT"]}"

response = dlp.inspect_content parent, 
  inspect_config: inspect_config, 
  item: item
```

### Next Steps
- Read the [Client Library Documentation][] for DLP API
  to see other available methods on the client.
- Read the [DLP API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-dlp/latest/google/privacy/dlp/v2
[Product Documentation]: https://cloud.google.com/dlp
