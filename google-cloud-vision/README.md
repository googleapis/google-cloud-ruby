# Ruby Client for Cloud Vision API ([Alpha](https://github.com/googleapis/google-cloud-ruby#versioning))

[Cloud Vision API][Product Documentation]:
Integrates Google Vision features, including image labeling, face, logo, and
landmark detection, optical character recognition (OCR), and detection of
explicit content, into applications.
- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the Cloud Vision API.](https://console.cloud.google.com/apis/library/vision.googleapis.com)
4. [Setup Authentication.](https://googleapis.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)

### Installation
```
$ gem install google-cloud-vision
```

### Migration Guide

The 0.32.0 release introduced breaking changes relative to the previous release,
0.31.0. For more details and instructions to migrate your code, please visit the
[migration
guide](https://cloud.google.com/vision/docs/ruby-client-migration).

### Preview
#### ImageAnnotatorClient
```rb
require "google/cloud/vision"

image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new
gcs_image_uri = "gs://gapic-toolkit/President_Barack_Obama.jpg"
source = { gcs_image_uri: gcs_image_uri }
image = { source: source }
type = :FACE_DETECTION
features_element = { type: type }
features = [features_element]
requests_element = { image: image, features: features }
requests = [requests_element]
response = image_annotator_client.batch_annotate_images(requests)
```

### Next Steps
- Read the [Client Library Documentation][] for Cloud Vision API
  to see other available methods on the client.
- Read the [Cloud Vision API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/googleapis/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googleapis.github.io/google-cloud-ruby/#/docs/google-cloud-vision/latest/google/cloud/vision/v1
[Product Documentation]: https://cloud.google.com/vision

## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library.
The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as shown below,
or a [`Google::Cloud::Logging::Logger`](https://googleapis.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest/google/cloud/logging/logger)
that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb)
and the gRPC [spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb) for additional information.

Configuring a Ruby stdlib logger:

```ruby
require "logger"

module MyLogger
  LOGGER = Logger.new $stderr, level: Logger::WARN
  def logger
    LOGGER
  end
end

# Define a gRPC module-level logger method before grpc/logconfig.rb loads.
module GRPC
  extend MyLogger
end
```

## Supported Ruby Versions

This library is supported on Ruby 2.3+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Currently, this means Ruby 2.3
and later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.
