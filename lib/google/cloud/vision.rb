# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud"
require "google/cloud/vision/project"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Vision service.
    # Each call creates a new connection.
    #
    # @param [String] project Project identifier for the Vision service you are
    #   connecting to.
    # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If
    #   file path the file must be readable.
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/cloud-platform`
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Vision::Project]
    #
    # @example
    #   require "google/cloud/vision"
    #
    #   gcloud = Google::Cloud.new
    #   vision = gcloud.vision
    #
    #   image = vision.image "path/to/landmark.jpg"
    #
    #   landmark = image.landmark
    #   landmark.description #=> "Mount Rushmore"
    #
    def self.vision project = nil, keyfile = nil, scope: nil, retries: nil,
                    timeout: nil
      project ||= Google::Cloud::Vision::Project.default_project
      project = project.to_s # Always cast to a string
      fail ArgumentError, "project is missing" if project.empty?

      if keyfile.nil?
        credentials = Google::Cloud::Vision::Credentials.default scope: scope
      else
        credentials = Google::Cloud::Vision::Credentials.new \
          keyfile, scope: scope
      end

      Google::Cloud::Vision::Project.new(
        Google::Cloud::Vision::Service.new(
          project, credentials, retries: retries, timeout: timeout))
    end

    ##
    # # Google Cloud Vision
    #
    # Google Cloud Vision allows easy integration of vision detection features
    # developer applications, including image labeling, face and landmark
    # detection, optical character recognition (OCR), and tagging of explicit
    # content.
    #
    # For more information about Cloud Vision, read the [Google Cloud Vision API
    # Documentation](https://cloud.google.com/vision/docs/).
    #
    # The goal of google-cloud is to provide an API that is comfortable to
    # Rubyists. Authentication is handled by {Google::Cloud#vision}. You can
    # provide the project and credential information to connect to the Cloud
    # Vision service, or if you are running on Google Compute Engine this
    # configuration is taken care of for you. You can read more about the
    # options for connecting in the [Authentication
    # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
    #
    # ## Creating images
    #
    # The Cloud Vision API supports a variety of image file formats, including
    # JPEG, PNG8, PNG24, Animated GIF (first frame only), and RAW. See [Best
    # Practices - Image
    # Types](https://cloud.google.com/vision/docs/image-best-practices#image_types)
    # for the complete list of formats. Be aware that Cloud Vision sets upper
    # limits on file size as well as on the total combined size of all images in
    # a request. Reducing your file size can significantly improve throughput;
    # however, be careful not to reduce image quality in the process. See [Best
    # Practices - Image
    # Sizing](https://cloud.google.com/vision/docs/image-best-practices#image_sizing)
    # for current file size limits.
    #
    # Use {Vision::Project#image} to create images for the Cloud Vision service.
    # You can provide a file path:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # vision = gcloud.vision
    #
    # image = vision.image "path/to/landmark.jpg"
    # ```
    #
    # Or, you can initialize the image with a Google Cloud Storage URI:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # vision = gcloud.vision
    #
    # image = vision.image "gs://bucket-name/path_to_image_object"
    # ```
    #
    # Creating an Image instance does not perform an API request.
    #
    # ## Annotating images
    #
    # The instance methods on {Vision::Image} invoke Cloud Vision's detection
    # features individually. Each method call makes an API request. (If you want
    # to run multiple features in a single request, see the examples for
    # {Vision::Project#annotate}, below.)
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # vision = gcloud.vision
    #
    # image = vision.image "path/to/face.jpg"
    #
    # face = image.face
    #
    # face.features.to_h.count #=> 9
    # face.features.eyes.left.pupil
    # #=> #<Landmark (x: 190.41544, y: 84.4557, z: -1.3682901)>
    # face.features.chin.center
    # #=> #<Landmark (x: 233.21977, y: 189.47475, z: 19.487228)>
    # ```
    #
    # To run multiple features on an image in a single request, pass the image
    # (or a string file path or Storage URI) to {Vision::Project#annotate}:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # vision = gcloud.vision
    #
    # image = vision.image "path/to/face.jpg"
    #
    # annotation = vision.annotate image, faces: true, labels: true
    # annotation.faces.count #=> 1
    # annotation.labels.count #=> 4
    # ```
    #
    # You can also perform detection tasks on multiple images in a single
    # request:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # vision = gcloud.vision
    #
    # face_image = vision.image "path/to/face.jpg"
    # landmark_image = vision.image "path/to/landmark.jpg"
    #
    # annotations = vision.annotate face_image,
    #                               landmark_image,
    #                               faces: true,
    #                               landmarks: true,
    #                               labels: true
    #
    # annotations[0].faces.count #=> 1
    # annotations[0].landmarks.count #=> 0
    # annotations[0].labels.count #=> 4
    # annotations[1].faces.count #=> 1
    # annotations[1].landmarks.count #=> 1
    # annotations[1].labels.count #=> 6
    # ```
    #
    # It is even possible to configure different features for multiple images in
    # a single call using a block. The following example results in a single
    # request to the Cloud Vision API:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # vision = gcloud.vision
    #
    # face_image = vision.image "path/to/face.jpg"
    # landmark_image = vision.image "path/to/landmark.jpg"
    # text_image = vision.image "path/to/text.png"
    #
    # annotations = vision.annotate do |annotate|
    #    annotate.annotate face_image, faces: true, labels: true
    #    annotate.annotate landmark_image, landmarks: true
    #    annotate.annotate text_image, text: true
    # end
    #
    # annotations[0].faces.count #=> 1
    # annotations[0].labels.count #=> 4
    # annotations[1].landmarks.count #=> 1
    # annotations[2].text.words.count #=> 28
    # ```
    #
    # The maximum number of results returned when performing face, landmark,
    # logo, and label detection are defined by
    # {Google::Cloud::Vision.default_max_faces},
    # {Google::Cloud::Vision.default_max_landmarks},
    # {Google::Cloud::Vision.default_max_logos}, and
    # {Google::Cloud::Vision.default_max_labels}, respectively. To change the
    # global defaults, you can update the configuration:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # vision = gcloud.vision
    #
    # Google::Cloud::Vision.default_max_faces = 1
    #
    # annotation = vision.annotate "path/to/face.jpg", faces: true
    # annotation.faces.count #=> 1
    # ```
    #
    # Or, to override a default for a single method call, simply pass an
    # integer instead of a flag:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # vision = gcloud.vision
    #
    # image = vision.image "path/to/face.jpg"
    #
    # # Return just one face.
    # annotation = vision.annotate image, faces: 1
    # # Return up to 5 faces.
    # annotation = vision.annotate image, faces: 5
    # ```
    #
    # ## Configuring retries and timeout
    #
    # You can configure how many times API requests may be automatically
    # retried. When an API request fails, the response will be inspected to see
    # if the request meets criteria indicating that it may succeed on retry,
    # such as `500` and `503` status codes or a specific internal error code
    # such as `rateLimitExceeded`. If it meets the criteria, the request will be
    # retried after a delay. If another error occurs, the delay will be
    # increased before a subsequent attempt, until the `retries` limit is
    # reached.
    #
    # You can also set the request `timeout` value in seconds.
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # vision = gcloud.vision retries: 10, timeout: 120
    # ```
    #
    module Vision
      class << self
        ##
        # The default max results to return for facial detection requests. This
        # is used on {Project#annotate} as well as {Image#faces}.
        #
        # The default value is `100`.
        #
        # @example Using the default setting on {Project#annotate}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   Google::Cloud::Vision.default_max_faces #=> 100
        #
        #   annotation = vision.annotate "path/to/faces.jpg", faces: true
        #   # This is the same as calling
        #   # annotation = vision.annotate "path/to/faces.jpg", faces: 100
        #
        # @example Updating the default setting on {Project#annotate}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_faces = 5
        #
        #   annotation = vision.annotate "path/to/faces.jpg", faces: true
        #   # This is the same as calling
        #   # annotation = vision.annotate "path/to/faces.jpg", faces: 5
        #
        #
        # @example Using the default setting on {Image#faces}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   Google::Cloud::Vision.default_max_faces #=> 100
        #
        #   faces = vision.image("path/to/faces.jpg").faces
        #   # This is the same as calling
        #   # faces = vision.image("path/to/faces.jpg").faces 100
        #
        # @example Updating the default setting on {Image#faces}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_faces = 5
        #
        #   faces = vision.image("path/to/faces.jpg").faces
        #   # This is the same as calling
        #   # faces = vision.image("path/to/faces.jpg").faces 5
        #
        attr_accessor :default_max_faces

        ##
        # The default max results to return for landmark detection requests.
        # This is used on {Project#annotate} as well as {Image#landmarks}.
        #
        # The default value is 100.
        #
        # @example Using the default setting on {Project#annotate}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   Google::Cloud::Vision.default_max_landmarks #=> 100
        #
        #   img = "path/to/landmarks.jpg"
        #   annotation = vision.annotate img, landmarks: true
        #   # This is the same as calling
        #   # annotation = vision.annotate img, landmarks: 100
        #
        # @example Updating the default setting on {Project#annotate}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_landmarks = 5
        #
        #   img = "path/to/landmarks.jpg"
        #   annotation = vision.annotate img, landmarks: true
        #   # This is the same as calling
        #   # annotation = vision.annotate img, landmarks: 5
        #
        #
        # @example Using the default setting on {Image#landmarks}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   Google::Cloud::Vision.default_max_landmarks #=> 100
        #
        #   landmarks = vision.image("path/to/landmarks.jpg").landmarks
        #   # This is the same as calling
        #   # landmarks = vision.image("path/to/landmarks.jpg").landmarks 100
        #
        # @example Updating the default setting on {Image#landmarks}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_landmarks = 5
        #
        #   landmarks = vision.image("path/to/landmarks.jpg").landmarks
        #   # This is the same as calling
        #   # landmarks = vision.image("path/to/landmarks.jpg").landmarks 5
        #
        attr_accessor :default_max_landmarks

        ##
        # The default max results to return for logo detection requests. This is
        # used on {Project#annotate} as well as {Image#logos}.
        #
        # The default value is 100.
        #
        # @example Using the default setting on {Project#annotate}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   Google::Cloud::Vision.default_max_logos #=> 100
        #
        #   annotation = vision.annotate "path/to/logos.jpg", logos: true
        #   # This is the same as calling
        #   # annotation = vision.annotate "path/to/logos.jpg", logos: 100
        #
        # @example Updating the default setting on {Project#annotate}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_logos = 5
        #
        #   annotation = vision.annotate "path/to/logos.jpg", logos: true
        #   # This is the same as calling
        #   # annotation = vision.annotate "path/to/logos.jpg", logos: 5
        #
        #
        # @example Using the default setting on {Image#logos}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   Google::Cloud::Vision.default_max_logos #=> 100
        #
        #   logos = vision.image("path/to/logos.jpg").logos
        #   # This is the same as calling
        #   # logos = vision.image("path/to/logos.jpg").logos 100
        #
        # @example Updating the default setting on {Image#logos}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_logos = 5
        #
        #   logos = vision.image("path/to/logos.jpg").logos
        #   # This is the same as calling
        #   # logos = vision.image("path/to/logos.jpg").logos 5
        #
        attr_accessor :default_max_logos

        ##
        # The default max results to return for label detection requests. This
        # is used on {Project#annotate} as well as {Image#labels}.
        #
        # The default value is 100.
        #
        # @example Using the default setting on {Project#annotate}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   Google::Cloud::Vision.default_max_labels #=> 100
        #
        #   annotation = vision.annotate "path/to/labels.jpg", labels: true
        #   # This is the same as calling
        #   # annotation = vision.annotate "path/to/labels.jpg", labels: 100
        #
        # @example Updating the default setting on {Project#annotate}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_labels = 5
        #
        #   annotation = vision.annotate "path/to/labels.jpg", labels: true
        #   # This is the same as calling
        #   # annotation = vision.annotate "path/to/labels.jpg", labels: 5
        #
        #
        # @example Using the default setting on {Image#labels}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   Google::Cloud::Vision.default_max_labels #=> 100
        #
        #   labels = vision.image("path/to/labels.jpg").labels
        #   # This is the same as calling
        #   # labels = vision.image("path/to/labels.jpg").labels 100
        #
        # @example Updating the default setting on {Image#labels}:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_labels = 5
        #
        #   labels = vision.image("path/to/labels.jpg").labels
        #   # This is the same as calling
        #   # labels = vision.image("path/to/labels.jpg").labels 5
        #
        attr_accessor :default_max_labels
      end

      # Set the default values.
      # Update the comments documentation when these change.
      self.default_max_faces     = 100
      self.default_max_landmarks = 100
      self.default_max_logos     = 100
      self.default_max_labels    = 100
    end
  end
end
