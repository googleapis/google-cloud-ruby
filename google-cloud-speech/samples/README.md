<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Speech API Ruby Samples

The [Google Cloud Speech API](https://cloud.google.com/speech/) enables easy
integration of Google speech recognition technologies into developer applications.

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/):

       gcloud auth application-default login

1. When running on App Engine or Compute Engine, credentials are already set-up.
However, you may need to configure your Compute Engine instance with
[additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts).
This file can be used to authenticate to Google Cloud Platform services from
any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
environment variable to the path to the key file, for example:

       export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json

### Set Project ID

Next, set the `GOOGLE_CLOUD_PROJECT` environment variable to the project name
set in the
[Google Cloud Platform Developer Console](https://console.cloud.google.com):

    export GOOGLE_CLOUD_PROJECT="YOUR-PROJECT-ID"

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

       bundle install

## Run samples

Run the sample:

    bundle exec ruby speech_samples.rb

Usage: ruby speech_samples.rb <command> [arguments]

    Commands:
      recognize                 <filename> Detects speech in a local audio file.
      recognize_words           <filename> Detects speech in a local audio file with word offsets.
      recognize_gcs             <gcsUri>   Detects speech in an audio file located in a Google Cloud Storage bucket.
      async_recognize           <filename> Creates a job to detect speech in a local audio file, and waits for the job to complete.
      async_recognize_gcs       <gcsUri>   Creates a job to detect speech in an audio file located in a Google Cloud Storage bucket, and waits for the job to complete.
      async_recognize_gcs_words <gcsUri>   Creates a job to detect speech with wordsoffsets in an audio file located in a Google Cloud Storage bucket, and waits for the job to complete.
      stream_recognize          <filename> Detects speech in a local audio file by streaming it to the Speech API.
      auto_punctuation          <filename> Detects speech in a local audio file, including automatic punctuation in the transcript.
      enhanced_model            <filename> Detects speech in a local audio file, using a model enhanced for phone call audio.
      model_selection           <filename> Detects speech in a local file, using a specific model.

Examples:

    $ bundle exec ruby speech_samples.rb recognize resources/audio.raw
    Text: how old is the Brooklyn Bridge

## Run tests

Run the acceptance tests for these samples:

    bundle exec rake test
