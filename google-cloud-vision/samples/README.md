<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Vision API Ruby Samples

The [Google Cloud Vision API][vision_docs] allows developers to easily integrate vision
detection features within applications, including image labeling, face and
landmark detection, optical character recognition (OCR), and tagging of explicit
content.

[vision_docs]: https://cloud.google.com/vision/docs/

[Vision How-to Guides](https://cloud.google.com/vision/docs/how-to)

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

### Detect Faces

    Usage: ruby detect_faces.rb [image file path]

    Example:
      ruby detect_faces.rb image.png
      ruby detect_faces.rb https://public-url/image.png
      ruby detect_faces.rb gs://my-bucket/image.png

### Face Detection Tutorial

    Usage: ruby draw_box_around_faces.rb [input-file] [output-file]

    Example:
      ruby draw_box_around_faces.rb images/face_no_surprise.png output-image.png

## Run tests

Run the acceptance tests for these samples:

    bundle exec rake test
