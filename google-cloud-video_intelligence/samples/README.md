<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Video Intelligence Ruby Samples

The [Google Cloud Video Intelligence API](https://cloud.google.com/video-intelligence/)
enables easy integration of Google speech recognition technologies into
developer applications.

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

    `gcloud auth application-default login`

1. When running on App Engine or Compute Engine, credentials are already set-up.
However, you may need to configure your Compute Engine instance with
[additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)
. This file can be used to authenticate to Google Cloud Platform services from
any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
environment variable to the path to the key file, for example:

    `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json`

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

    `bundle install`

## Run Quickstart

    bundle exec ruby quickstart.rb

## Run Samples

    Usage: bundle exec ruby video_samples.rb [command] [arguments]

    Commands:
      analyze_labels           <gcs_path>   Detects labels given a GCS path.
      analyze_labels_local     <local_path> Detects labels given file path.
      analyze_shots            <gcs_path>   Detects camera shot changes given a GCS path.
      analyze_explicit_content <gcs_path>   Detects explicit content given a GCS path.
      speech_transcription     <gcs_path>   Transcribes speech given a GCS path.
      detect_text_gcs          <gcs_path>   Detects text given a GCS path.
      detect_text_local        <local_path> Detects text given file path.
      track_objects_gcs        <gcs_path>   Track objects given a GCS path.
      track_objects_local      <local_path> Track objects given file path.
