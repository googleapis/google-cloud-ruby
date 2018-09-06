# Google Cloud Vision

Google Cloud Vision allows developers to easily integrate vision
detection features within applications, including image labeling, face
and landmark detection, optical character recognition (OCR), and tagging
of explicit content.

For more information about Cloud Vision, read the [Google Cloud Vision API
Documentation](https://cloud.google.com/vision/docs/).

The goal of google-cloud is to provide an API that is comfortable to
Rubyists. Your authentication credentials are detected automatically in
Google Cloud Platform environments such as Google Compute Engine, Google
App Engine and Google Kubernetes Engine. In other environments you can
configure authentication easily, either directly in your code or via
environment variables. Read more about the options for connecting in the
{file:AUTHENTICATION.md Authentication Guide}.

## Creating images

The Cloud Vision API supports UTF-8, UTF-16, and UTF-32 text encodings.
(Ruby uses UTF-8 natively, which is the default sent to the API, so unless
you're working with text processed in different platform, you should not
need to set the encoding type.)
a ). Be aware that Cloud Vision sets upper
limits on file size as well as on the total combined size of all images in
a request. Reducing your file size can significantly improve throughput;
however, be careful not to reduce image quality in the process. See [Best
Practices - Image
Sizing](https://cloud.google.com/vision/docs/best-practices#image_sizing)
for current file size limits.

Use {Vision::Project#image} to create images for the Cloud Vision service.
You can provide a file path:

```ruby
require "google/cloud/vision"

vision = Google::Cloud::Vision.new

image = vision.image "path/to/landmark.jpg"
```

Or any publicly-accessible image HTTP/HTTPS URL:

```ruby
require "google/cloud/vision"

vision = Google::Cloud::Vision.new

image = vision.image "https://www.example.com/images/landmark.jpg"
```

Or, you can initialize the image with a Google Cloud Storage URI:

```ruby
require "google/cloud/vision"

vision = Google::Cloud::Vision.new

image = vision.image "gs://bucket-name/path_to_image_object"
```

Creating an Image instance does not perform an API request.

## Annotating images

The instance methods on {Vision::Image} invoke Cloud Vision's detection
features individually. Each method call makes an API request. (If you want
to run multiple features in a single request, see the examples for
{Vision::Project#annotate}, below.)

```ruby
require "google/cloud/vision"

vision = Google::Cloud::Vision.new

image = vision.image "path/to/face.jpg"

face = image.face

face.features.to_h.count #=> 9
face.features.eyes.left.pupil
#<Landmark (x: 190.41544, y: 84.4557, z: -1.3682901)>
face.features.chin.center
#<Landmark (x: 233.21977, y: 189.47475, z: 19.487228)>
```

To run multiple features on an image in a single request, pass the image
(or a string file path, publicly-accessible image HTTP/HTTPS URL, or
Storage URI) to {Vision::Project#annotate}:

```ruby
require "google/cloud/vision"

vision = Google::Cloud::Vision.new

image = vision.image "path/to/face.jpg"

annotation = vision.annotate image, faces: true, labels: true
annotation.faces.count #=> 1
annotation.labels.count #=> 4
```

You can also perform detection tasks on multiple images in a single
request:

```ruby
require "google/cloud/vision"

vision = Google::Cloud::Vision.new

face_image = vision.image "path/to/face.jpg"
landmark_image = vision.image "path/to/landmark.jpg"

annotations = vision.annotate face_image,
                              landmark_image,
                              faces: true,
                              landmarks: true,
                              labels: true

annotations[0].faces.count #=> 1
annotations[0].landmarks.count #=> 0
annotations[0].labels.count #=> 4
annotations[1].faces.count #=> 1
annotations[1].landmarks.count #=> 1
annotations[1].labels.count #=> 6
```

It is even possible to configure different features for multiple images in
a single call using a block. The following example results in a single
request to the Cloud Vision API:

```ruby
require "google/cloud/vision"

vision = Google::Cloud::Vision.new

face_image = vision.image "path/to/face.jpg"
landmark_image = vision.image "path/to/landmark.jpg"
text_image = vision.image "path/to/text.png"

annotations = vision.annotate do |annotate|
   annotate.annotate face_image, faces: true, labels: true
   annotate.annotate landmark_image, landmarks: true
   annotate.annotate text_image, text: true
end

annotations[0].faces.count #=> 1
annotations[0].labels.count #=> 4
annotations[1].landmarks.count #=> 1
annotations[2].text.pages.count #=> 1
```

The maximum number of results returned when performing face, landmark,
logo, and label detection are defined by
{Google::Cloud::Vision.default_max_faces},
{Google::Cloud::Vision.default_max_landmarks},
{Google::Cloud::Vision.default_max_logos}, and
{Google::Cloud::Vision.default_max_labels}, respectively. To change the
global defaults, you can update the configuration:

```ruby
require "google/cloud/vision"

vision = Google::Cloud::Vision.new

Google::Cloud::Vision.default_max_faces = 1

annotation = vision.annotate "path/to/face.jpg", faces: true
annotation.faces.count #=> 1
```

Or, to override a default for a single method call, simply pass an
integer instead of a flag:

```ruby
require "google/cloud/vision"

vision = Google::Cloud::Vision.new

image = vision.image "path/to/face.jpg"

# Return just one face.
annotation = vision.annotate image, faces: 1
# Return up to 5 faces.
annotation = vision.annotate image, faces: 5
```

## Configuring timeout

You can configure the request `timeout` value in seconds.

```ruby
require "google/cloud/vision"

vision = Google::Cloud::Vision.new timeout: 120
```
## Additional information

Google Cloud Vision can be configured to use gRPC's logging. To learn more, see
the {file:LOGGING.md Logging guide}.
