<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Text-to-Speech API Ruby Samples

This directory contains samples for Google Cloud Text-to-Speech API. The
[Google Cloud Text-to-Speech API][tts_docs] enables you to generate and
customize synthesized speech from text or SSML.

[tts_docs]: https://cloud.google.com/text-to-speech/docs/

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

       gcloud auth application-default login

1. When running on App Engine or Compute Engine, credentials are already set-up.
However, you may need to configure your Compute Engine instance with
[additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)
. This file can be used to authenticate to Google Cloud Platform services from
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

### Quickstart

    Usage: ruby quickstart.rb

### List Voices

    Usage: ruby list_voices.rb

### Synthesize Text

    Usage: ruby synthesize_text.rb (text TEXT | ssml SSML)

    Example:
    ruby synthesize_text.rb text "hello"
    ruby synthesize_text.rb ssml "<speak>Hello there.</speak>"

### Synthesize File

    Usage: ruby synthesize_file.rb (text FILEPATH | ssml FILEPATH)

    Example usage:
        ruby synthesize_file.rb text resources/hello.txt
        ruby synthesize_file.rb ssml resources/hello.ssml

## Run tests

Run the acceptance tests for these samples:

    bundle exec rake test
