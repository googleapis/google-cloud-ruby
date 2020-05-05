# Cloud Datastore Sample

This sample provides example code for
[cloud.google.com/datastore/docs](https://cloud.google.com/datastore/docs).

## Setup

Before you can run or test the sample, you will need to enable the Cloud Datastore API in the [Google Cloud Console](https://console.cloud.google.com/apis/library/datastore.googleapis.com).

## Testing

The tests for the sample are integration tests that run against the Datastore
service and require authentication.

### Authenticating

Set one of the following environment variables to your Google Cloud Platform
project ID:

* `DATASTORE_DATASET`
* `DATASTORE_PROJECT`
* `GOOGLE_CLOUD_PROJECT`

Set one of the following environment variables to the path to your Google Cloud
Platform keyfile:

* `DATASTORE_KEYFILE`
* `GOOGLE_CLOUD_KEYFILE`
* `DATASTORE_KEYFILE_JSON`
* `GOOGLE_CLOUD_KEYFILE_JSON`

For more information, see
[Authentication](https://googleapis.dev/ruby/google-cloud-datastore/latest/file.AUTHENTICATION.html).

### Creating the Datastore indexes

Install the [gcloud command-line
tool](https://cloud.google.com/sdk/gcloud) and use it to create the
indexes used in the tests. From the Datastore samples directory:

``` sh
# Set the default project in your env
$ gcloud config set project PROJECT_ID

# Authenticate the gcloud tool with your account
$ gcloud auth login

# Create the indexes
$ gcloud datastore indexes create index.yaml
```

### Running the tests

```bash
$ bundle exec rake test
```

