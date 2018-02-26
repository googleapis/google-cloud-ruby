# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google-cloud-vision"
require "google/cloud/vision/project"
require "google/cloud/config"
require "google/cloud/env"

module Google
  module Cloud
    ##
    # # Google Cloud Vision
    #
    # Google Cloud Vision allows developers to easily integrate vision
    # detection features within applications, including image labeling, face
    # and landmark detection, optical character recognition (OCR), and tagging
    # of explicit content.
    #
    # For more information about Cloud Vision, read the [Google Cloud Vision API
    # Documentation](https://cloud.google.com/vision/docs/).
    #
    # The goal of google-cloud is to provide an API that is comfortable to
    # Rubyists. Your authentication credentials are detected automatically in
    # Google Cloud Platform environments such as Google Compute Engine, Google
    # App Engine and Google Kubernetes Engine. In other environments you can
    # configure authentication easily, either directly in your code or via
    # environment variables. Read more about the options for connecting in the
    # [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # ## Creating images
    #
    # The Cloud Vision API supports UTF-8, UTF-16, and UTF-32 text encodings.
    # (Ruby uses UTF-8 natively, which is the default sent to the API, so unless
    # you're working with text processed in different platform, you should not
    # need to set the encoding type.)
    # a ). Be aware that Cloud Vision sets upper
    # limits on file size as well as on the total combined size of all images in
    # a request. Reducing your file size can significantly improve throughput;
    # however, be careful not to reduce image quality in the process. See [Best
    # Practices - Image
    # Sizing](https://cloud.google.com/vision/docs/best-practices#image_sizing)
    # for current file size limits.
    #
    # Use {Vision::Project#image} to create images for the Cloud Vision service.
    # You can provide a file path:
    #
    # ```ruby
    # require "google/cloud/vision"
    #
    # vision = Google::Cloud::Vision.new
    #
    # image = vision.image "path/to/landmark.jpg"
    # ```
    #
    # Or any publicly-accessible image HTTP/HTTPS URL:
    #
    # ```ruby
    # require "google/cloud/vision"
    #
    # vision = Google::Cloud::Vision.new
    #
    # image = vision.image "https://www.example.com/images/landmark.jpg"
    # ```
    #
    # Or, you can initialize the image with a Google Cloud Storage URI:
    #
    # ```ruby
    # require "google/cloud/vision"
    #
    # vision = Google::Cloud::Vision.new
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
    # require "google/cloud/vision"
    #
    # vision = Google::Cloud::Vision.new
    #
    # image = vision.image "path/to/face.jpg"
    #
    # face = image.face
    #
    # face.features.to_h.count #=> 9
    # face.features.eyes.left.pupil
    # #<Landmark (x: 190.41544, y: 84.4557, z: -1.3682901)>
    # face.features.chin.center
    # #<Landmark (x: 233.21977, y: 189.47475, z: 19.487228)>
    # ```
    #
    # To run multiple features on an image in a single request, pass the image
    # (or a string file path, publicly-accessible image HTTP/HTTPS URL, or
    # Storage URI) to {Vision::Project#annotate}:
    #
    # ```ruby
    # require "google/cloud/vision"
    #
    # vision = Google::Cloud::Vision.new
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
    # require "google/cloud/vision"
    #
    # vision = Google::Cloud::Vision.new
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
    # require "google/cloud/vision"
    #
    # vision = Google::Cloud::Vision.new
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
    # annotations[2].text.pages.count #=> 1
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
    # require "google/cloud/vision"
    #
    # vision = Google::Cloud::Vision.new
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
    # require "google/cloud/vision"
    #
    # vision = Google::Cloud::Vision.new
    #
    # image = vision.image "path/to/face.jpg"
    #
    # # Return just one face.
    # annotation = vision.annotate image, faces: 1
    # # Return up to 5 faces.
    # annotation = vision.annotate image, faces: 5
    # ```
    #
    # ## Configuring timeout
    #
    # You can configure the request `timeout` value in seconds.
    #
    # ```ruby
    # require "google/cloud/vision"
    #
    # vision = Google::Cloud::Vision.new timeout: 120
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
        # This is also available on the configuration as
        # `Google::Cloud::Vision.configure.default_max_faces`
        #
        # @example Using the default setting on {Project#annotate}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   Google::Cloud::Vision.default_max_faces #=> 100
        #
        #   annotation = vision.annotate "path/to/faces.jpg", faces: true
        #   # This is the same as calling
        #   # annotation = vision.annotate "path/to/faces.jpg", faces: 100
        #
        # @example Updating the default setting on {Project#annotate}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
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
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   Google::Cloud::Vision.default_max_faces #=> 100
        #
        #   faces = vision.image("path/to/faces.jpg").faces
        #   # This is the same as calling
        #   # faces = vision.image("path/to/faces.jpg").faces 100
        #
        # @example Updating the default setting on {Image#faces}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_faces = 5
        #
        #   faces = vision.image("path/to/faces.jpg").faces
        #   # This is the same as calling
        #   # faces = vision.image("path/to/faces.jpg").faces 5
        #
        def default_max_faces= value
          configure.default_max_faces = value
        end

        ##
        # The default max results to return for face detection requests.
        #
        def default_max_faces
          configure.default_max_faces
        end

        ##
        # The default max results to return for landmark detection requests.
        # This is used on {Project#annotate} as well as {Image#landmarks}.
        #
        # The default value is 100.
        #
        # This is also available on the configuration as
        # `Google::Cloud::Vision.configure.default_max_landmarks`
        #
        # @example Using the default setting on {Project#annotate}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   Google::Cloud::Vision.default_max_landmarks #=> 100
        #
        #   img = "path/to/landmarks.jpg"
        #   annotation = vision.annotate img, landmarks: true
        #   # This is the same as calling
        #   # annotation = vision.annotate img, landmarks: 100
        #
        # @example Updating the default setting on {Project#annotate}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
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
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   Google::Cloud::Vision.default_max_landmarks #=> 100
        #
        #   landmarks = vision.image("path/to/landmarks.jpg").landmarks
        #   # This is the same as calling
        #   # landmarks = vision.image("path/to/landmarks.jpg").landmarks 100
        #
        # @example Updating the default setting on {Image#landmarks}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_landmarks = 5
        #
        #   landmarks = vision.image("path/to/landmarks.jpg").landmarks
        #   # This is the same as calling
        #   # landmarks = vision.image("path/to/landmarks.jpg").landmarks 5
        #
        def default_max_landmarks= value
          configure.default_max_landmarks = value
        end

        ##
        # The default max results to return for landmark detection requests.
        #
        def default_max_landmarks
          configure.default_max_landmarks
        end

        ##
        # The default max results to return for logo detection requests. This is
        # used on {Project#annotate} as well as {Image#logos}.
        #
        # The default value is 100.
        #
        # This is also available on the configuration as
        # `Google::Cloud::Vision.configure.default_max_logos`
        #
        # @example Using the default setting on {Project#annotate}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   Google::Cloud::Vision.default_max_logos #=> 100
        #
        #   annotation = vision.annotate "path/to/logos.jpg", logos: true
        #   # This is the same as calling
        #   # annotation = vision.annotate "path/to/logos.jpg", logos: 100
        #
        # @example Updating the default setting on {Project#annotate}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
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
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   Google::Cloud::Vision.default_max_logos #=> 100
        #
        #   logos = vision.image("path/to/logos.jpg").logos
        #   # This is the same as calling
        #   # logos = vision.image("path/to/logos.jpg").logos 100
        #
        # @example Updating the default setting on {Image#logos}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_logos = 5
        #
        #   logos = vision.image("path/to/logos.jpg").logos
        #   # This is the same as calling
        #   # logos = vision.image("path/to/logos.jpg").logos 5
        #
        def default_max_logos= value
          configure.default_max_logos = value
        end

        ##
        # The default max results to return for logo detection requests.
        #
        def default_max_logos
          configure.default_max_logos
        end

        ##
        # The default max results to return for label detection requests. This
        # is used on {Project#annotate} as well as {Image#labels}.
        #
        # The default value is 100.
        #
        # This is also available on the configuration as
        # `Google::Cloud::Vision.configure.default_max_labels`
        #
        # @example Using the default setting on {Project#annotate}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   Google::Cloud::Vision.default_max_labels #=> 100
        #
        #   annotation = vision.annotate "path/to/labels.jpg", labels: true
        #   # This is the same as calling
        #   # annotation = vision.annotate "path/to/labels.jpg", labels: 100
        #
        # @example Updating the default setting on {Project#annotate}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
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
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   Google::Cloud::Vision.default_max_labels #=> 100
        #
        #   labels = vision.image("path/to/labels.jpg").labels
        #   # This is the same as calling
        #   # labels = vision.image("path/to/labels.jpg").labels 100
        #
        # @example Updating the default setting on {Image#labels}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_labels = 5
        #
        #   labels = vision.image("path/to/labels.jpg").labels
        #   # This is the same as calling
        #   # labels = vision.image("path/to/labels.jpg").labels 5
        #
        def default_max_labels= value
          configure.default_max_labels = value
        end

        ##
        # The default max results to return for label detection requests.
        #
        def default_max_labels
          configure.default_max_labels
        end

        ##
        # The default max results to return for crop hints detection requests.
        # This is used on {Project#annotate} as well as {Image#crop_hints}.
        #
        # The default value is 100.
        #
        # This is also available on the configuration as
        # `Google::Cloud::Vision.configure.default_max_crop_hints`
        #
        # @example Using the default setting on {Project#annotate}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   Google::Cloud::Vision.default_max_crop_hints #=> 100
        #
        #   img = "path/to/landmarks.jpg"
        #   annotation = vision.annotate img, crop_hints: true
        #   # This is the same as calling
        #   # annotation = vision.annotate img, crop_hints: 100
        #
        # @example Updating the default setting on {Project#annotate}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_crop_hints = 5
        #
        #   img = "path/to/landmarks.jpg"
        #   annotation = vision.annotate img, crop_hints: true
        #   # This is the same as calling
        #   # annotation = vision.annotate img, crop_hints: 5
        #
        #
        # @example Using the default setting on {Image#crop_hints}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   Google::Cloud::Vision.default_max_crop_hints #=> 100
        #
        #   crop_hints = vision.image("path/to/landmarks.jpg").crop_hints
        #   # This is the same as calling
        #   # crop_hints = vision.image("path/to/landmarks.jpg").crop_hints 100
        #
        # @example Updating the default setting on {Image#crop_hints}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_crop_hints = 5
        #
        #   crop_hints = vision.image("path/to/landmarks.jpg").crop_hints
        #   # This is the same as calling
        #   # crop_hints = vision.image("path/to/landmarks.jpg").crop_hints 5
        #
        def default_max_crop_hints= value
          configure.default_max_crop_hints = value
        end

        ##
        # The default max results to return for crop hints detection requests.
        #
        def default_max_crop_hints
          configure.default_max_crop_hints
        end

        ##
        # The default max results to return for web detection requests.
        # This is used on {Project#annotate} as well as {Image#web}.
        #
        # The default value is 100.
        #
        # This is also available on the configuration as
        # `Google::Cloud::Vision.configure.default_max_web`
        #
        # @example Using the default setting on {Project#annotate}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   Google::Cloud::Vision.default_max_web #=> 100
        #
        #   img = "path/to/landmarks.jpg"
        #   annotation = vision.annotate img, web: true
        #   # This is the same as calling
        #   # annotation = vision.annotate img, web: 100
        #
        # @example Updating the default setting on {Project#annotate}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_web = 5
        #
        #   img = "path/to/landmarks.jpg"
        #   annotation = vision.annotate img, web: true
        #   # This is the same as calling
        #   # annotation = vision.annotate img, web: 5
        #
        #
        # @example Using the default setting on {Image#web}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   Google::Cloud::Vision.default_max_web #=> 100
        #
        #   web = vision.image("path/to/landmarks.jpg").web
        #   # This is the same as calling
        #   # web = vision.image("path/to/landmarks.jpg").web 100
        #
        # @example Updating the default setting on {Image#web}:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   # Set a new default
        #   Google::Cloud::Vision.default_max_web = 5
        #
        #   web = vision.image("path/to/landmarks.jpg").web
        #   # This is the same as calling
        #   # web = vision.image("path/to/landmarks.jpg").web 5
        #
        def default_max_web= value
          configure.default_max_web = value
        end

        ##
        # The default max results to return for web detection requests.
        #
        def default_max_web
          configure.default_max_web
        end
      end

      ##
      # Creates a new object for connecting to the Vision service.
      # Each call creates a new connection.
      #
      # @param [String] project_id Project identifier for the Vision service you
      #   are connecting to. If not present, the default project for the
      #   credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Vision::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/cloud-platform`
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [Hash] client_config A hash of values to override the default
      #   behavior of the API client. Optional.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Vision::Project]
      #
      # @example
      #   require "google/cloud/vision"
      #
      #   vision = Google::Cloud::Vision.new
      #
      #   image = vision.image "path/to/landmark.jpg"
      #
      #   landmark = image.landmark
      #   landmark.description #=> "Mount Rushmore"
      #
      def self.new project_id: nil, credentials: nil, scope: nil, timeout: nil,
                   client_config: nil, project: nil, keyfile: nil
        project_id ||= (project || default_project_id)
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        scope ||= configure.scope
        timeout ||= configure.timeout
        client_config ||= configure.client_config
        credentials ||= (keyfile || default_credentials(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Vision::Credentials.new credentials, scope: scope
        end

        Vision::Project.new(
          Vision::Service.new(
            project_id, credentials, timeout: timeout,
                                     client_config: client_config
          )
        )
      end

      ##
      # Configure the Google Cloud Vision library.
      #
      # The following Vision configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a Vision project. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Vision::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `client_config` - (Hash) A hash of values to override the default
      #   behavior of the API client.
      # * `default_max_faces` - (Integer) The default max results to return for
      #   facial detection requests. See {Vision.default_max_faces=}.
      # * `default_max_landmarks` - (Integer) The default max results to return
      #   for landmark detection requests. See {Vision.default_max_landmarks=}.
      # * `default_max_logos` - (Integer) The default max results to return for
      #   logo detection requests. See {Vision.default_max_logos=}.
      # * `default_max_labels` - (Integer) The default max results to return for
      #   label detection requests. See {Vision.default_max_labels=}.
      # * `default_max_crop_hints` - (Integer) The default max results to return
      #   for crop hints detection requests. See
      #   {Vision.default_max_crop_hints=}.
      # * `default_max_web` - (Integer) The default max results to return for
      #   web detection requests. See {Vision.default_max_faces=}.
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Vision library uses.
      #
      def self.configure
        yield Google::Cloud.configure.vision if block_given?

        Google::Cloud.configure.vision
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.vision.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.vision.credentials ||
          Google::Cloud.configure.credentials ||
          Vision::Credentials.default(scope: scope)
      end
    end
  end
end
