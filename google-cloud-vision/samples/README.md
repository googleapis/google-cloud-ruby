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

### Set Project ID

Next, set the *GOOGLE_CLOUD_PROJECT* environment variable to the project name
set in the
[Google Cloud Platform Developer Console](https://console.cloud.google.com):

    `export GOOGLE_CLOUD_PROJECT="YOUR-PROJECT-ID"`

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

    `bundle install`

## Run samples

### Detect Crop Hints

    Usage: ruby detect_crop_hints.rb [image file path]

    Example:
      ruby detect_crop_hints.rb image.png
      ruby detect_crop_hints.rb https://public-url/image.png
      ruby detect_crop_hints.rb gs://my-bucket/image.png

### Detect Document Text

    Usage: ruby detect_document_text.rb [image file path]

    Example:
      ruby detect_document_text.rb image.png
      ruby detect_document_text.rb https://public-url/image.png
      ruby detect_document_text.rb gs://my-bucket/image.png

### Detect Faces

    Usage: ruby detect_faces.rb [image file path]

    Example:
      ruby detect_faces.rb image.png
      ruby detect_faces.rb https://public-url/image.png
      ruby detect_faces.rb gs://my-bucket/image.png

### Detect Image Properties

    Usage: ruby detect_image_properties.rb [image file path]

    Example:
      ruby detect_image_properties.rb image.png
      ruby detect_image_properties.rb https://public-url/image.png
      ruby detect_image_properties.rb gs://my-bucket/image.png

### Detect Labels

    Usage: ruby detect_labels.rb [image file path]

    Example:
      ruby detect_labels.rb image.png
      ruby detect_labels.rb https://public-url/image.png
      ruby detect_labels.rb gs://my-bucket/image.png

### Detect Landmarks

    Usage: ruby detect_landmarks.rb [image file path]

    Example:
      ruby detect_landmarks.rb image.png
      ruby detect_landmarks.rb https://public-url/image.png
      ruby detect_landmarks.rb gs://my-bucket/image.png

### Detect Logos

    Usage: ruby detect_logos.rb [image file path]

    Example:
      ruby detect_logos.rb image.png
      ruby detect_logos.rb https://public-url/image.png
      ruby detect_logos.rb gs://my-bucket/image.png

### Detect Safe Search Properties

    Usage: ruby detect_safe_search.rb [image file path]

    Example:
      ruby detect_safe_search.rb image.png
      ruby detect_safe_search.rb https://public-url/image.png
      ruby detect_safe_search.rb gs://my-bucket/image.png

### Detect Text

    Usage: ruby detect_text.rb [image file path]

    Example:
      ruby detect_text.rb image.png
      ruby detect_text.rb https://public-url/image.png
      ruby detect_text.rb gs://my-bucket/image.png

### Detect Web Entities and Pages

    Usage: ruby detect_web.rb [image file path]

    Example:
      ruby detect_web.rb image.png
      ruby detect_web.rb https://public-url/image.png
      ruby detect_web.rb gs://my-bucket/image.png

### Face Detection Tutorial

    Usage: ruby draw_box_around_faces.rb [input-file] [output-file]

    Example:
      ruby draw_box_around_faces.rb images/face_no_surprise.png output-image.png

### Object Localization Tutorial

    Usage: ruby localize_objects.rb [image file path]

    Example:
      ruby localize_objects.rb image.png
      ruby localize_objects.rb https://public-url/image.png
      ruby localize_objects.rb gs://my-bucket/image.png
