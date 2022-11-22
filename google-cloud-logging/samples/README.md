# Stackdriver Logging Sample

This sample provides example code for
[cloud.google.com/logging/docs](https://cloud.google.com/logging/docs).

## Setup

Before you can run or test the sample, you will need to enable the Stackdriver Logging API in the [Google Developers Console](https://console.developers.google.com/projectselector/apis/api/datastore/overview).

## Testing

The tests for the sample are integration tests that run against the Logging
service and require authentication.

### Authenticating

Set one of the following environment variables to your Google Cloud Platform
project ID:

* `GCLOUD_PROJECT`
* `GOOGLE_CLOUD_PROJECT`

For more information, see
[Authentication](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).

### Running the tests

```bash
$ bundle exec rake test
```
