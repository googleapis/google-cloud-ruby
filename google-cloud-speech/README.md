# Ruby Client for Cloud Speech API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))

[Cloud Speech API][Product Documentation]:
Converts audio to text by applying powerful neural network models.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the Cloud Speech API.](https://console.cloud.google.com/apis/api/speech)
4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)

### Installation
```
$ gem install google-cloud-speech
```

### Preview
#### SpeechClient
```rb
require "google/cloud/speech"

speech_client = Google::Cloud::Speech::V1p1beta1.new
language_code = "en-US"
sample_rate_hertz = 44100
encoding = :FLAC
config = {
  language_code: language_code,
  sample_rate_hertz: sample_rate_hertz,
  encoding: encoding
}
uri = "gs://gapic-toolkit/hello.flac"
audio = { uri: uri }
response = speech_client.recognize(config, audio)
```

### Next Steps
- Read the [Client Library Documentation][] for Cloud Speech API
  to see other available methods on the client.
- Read the [Cloud Speech API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-speech/latest/google/cloud/speech/v1p1beta1
[Product Documentation]: https://cloud.google.com/speech
