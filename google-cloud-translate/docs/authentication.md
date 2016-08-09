## With `gcloud-ruby`

With `gcloud-ruby` it's incredibly easy to get authenticated and start using Google's APIs. You can set your credentials on a global basis as well as on a per-API basis.

### The API access key

Unlike other Cloud Platform services, which authenticate using a project ID and OAuth 2.0 credentials, Google Translate API requires a public API access key. (This may change in future releases of Google Translate API.)

Follow the general instructions at [Identifying your application to Google](https://cloud.google.com/translate/v2/using_rest#auth), and the specific instructions for [Server keys](https://cloud.google.com/translate/v2/using_rest#creating-server-api-keys).