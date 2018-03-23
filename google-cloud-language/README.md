# Ruby Client for Google Cloud Natural Language API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))

[Google Cloud Natural Language API][Product Documentation]:
Google Cloud Natural Language API provides natural language understanding
technologies to developers. Examples include sentiment analysis, entity
recognition, and text annotations.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the Google Cloud Natural Language API.](https://console.cloud.google.com/apis/api/language)
4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)

### Installation
```
$ gem install google-cloud-language
```

### Preview
#### LanguageServiceClient
```rb
require "google/cloud/language"

language_service_client = Google::Cloud::Language.new
content = "Hello, world!"
type = :PLAIN_TEXT
document = { content: content, type: type }
response = language_service_client.analyze_sentiment(document)
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
- Read the [Client Library Documentation][] for Google Cloud Natural Language API
  to see other available methods on the client.
- Read the [Google Cloud Natural Language API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-language/latest/google/cloud/language/v1
[Product Documentation]: https://cloud.google.com/natural-language
