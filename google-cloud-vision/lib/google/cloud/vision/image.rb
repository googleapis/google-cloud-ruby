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


require "google/cloud/vision/location"
require "stringio"
require "base64"

module Google
  module Cloud
    module Vision
      ##
      # # Image
      #
      # Represents an image for the Vision service.
      #
      # An Image instance can be created from a string file path, publicly-
      # accessible image HTTP/HTTPS URL, or Cloud Storage URI of the form
      # `"gs://bucketname/path/to/image_filename"`; or a File, IO, StringIO, or
      # Tempfile instance; or an instance of Google::Cloud::Storage::File.
      #
      # See {Project#image}.
      #
      # The Cloud Vision API supports a variety of image file formats, including
      # JPEG, PNG8, PNG24, Animated GIF (first frame only), and RAW. See [Best
      # Practices - Image
      # Types](https://cloud.google.com/vision/docs/best-practices#image_types)
      # for the list of formats. Be aware that Cloud Vision sets upper limits on
      # file size as well as the total combined size of all images in a request.
      # Reducing your file size can significantly improve throughput; however,
      # be careful not to reduce image quality in the process. See [Best
      # Practices - Image
      # Sizing](https://cloud.google.com/vision/docs/best-practices#image_sizing)
      # for current file size limits.
      #
      # @see https://cloud.google.com/vision/docs/best-practices Best
      #   Practices
      #
      # @example
      #   require "google/cloud/vision"
      #
      #   vision = Google::Cloud::Vision.new
      #
      #   image = vision.image "path/to/text.png"
      #
      #   image.context.languages = ["en"]
      #
      #   text = image.text
      #   text.pages.count #=> 1
      #
      class Image
        # Returns the image context for the image, which accepts metadata values
        # such as location and language hints.
        # @return [Context] The context instance for the image.
        attr_reader :context

        ##
        # @private Creates a new Image instance.
        def initialize
          @io = nil
          @url = nil
          @vision = nil
          @context = Context.new
        end

        ##
        # @private Whether the Image has content.
        #
        def io?
          !@io.nil?
        end

        ##
        # @private Whether the Image is a URL.
        #
        def url?
          !@url.nil?
        end

        ##
        # Performs the `FACE_DETECTION` feature on the image.
        #
        # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
        #
        # @param [Integer] max_results The maximum number of results. The
        #   default is {Google::Cloud::Vision.default_max_faces}. Optional.
        #
        # @return [Array<Annotation::Face>] The results of face detection.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   faces = image.faces
        #
        #   face = faces.first
        #   face.bounds.face.count #=> 4
        #   vertex = face.bounds.face.first
        #   vertex.x #=> 28
        #   vertex.y #=> 40
        #
        def faces max_results = Vision.default_max_faces
          ensure_vision!
          annotation = @vision.mark self, faces: max_results
          annotation.faces
        end

        ##
        # Performs the `FACE_DETECTION` feature on the image and returns only
        # the first result.
        #
        # @return [Annotation::Face] The first result of face detection.
        #
        def face
          faces(1).first
        end

        ##
        # Performs the `LANDMARK_DETECTION` feature on the image.
        #
        # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
        #
        # @param [Integer] max_results The maximum number of results. The
        #   default is {Google::Cloud::Vision.default_max_landmarks}. Optional.
        #
        # @return [Array<Annotation::Entity>] The results of landmark detection.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/landmark.jpg"
        #
        #   landmarks = image.landmarks
        #
        #   landmark = landmarks.first
        #   landmark.score #=> 0.9191226363182068
        #   landmark.description #=> "Mount Rushmore"
        #   landmark.mid #=> "/m/019dvv"
        #
        def landmarks max_results = Vision.default_max_landmarks
          ensure_vision!
          annotation = @vision.mark self, landmarks: max_results
          annotation.landmarks
        end

        ##
        # Performs the `LANDMARK_DETECTION` feature on the image and returns
        # only the first result.
        #
        # @return [Annotation::Entity] The first result of landmark detection.
        #
        def landmark
          landmarks(1).first
        end

        ##
        # Performs the `LOGO_DETECTION` feature on the image.
        #
        # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
        #
        # @param [Integer] max_results The maximum number of results. The
        #   default is {Google::Cloud::Vision.default_max_logos}. Optional.
        #
        # @return [Array<Annotation::Entity>] The results of logo detection.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/logo.jpg"
        #
        #   logos = image.logos
        #
        #   logo = logos.first
        #   logo.score #=> 0.7005731463432312
        #   logo.description #=> "Google"
        #   logo.mid #=> "/m/0b34hf"
        #
        def logos max_results = Vision.default_max_logos
          ensure_vision!
          annotation = @vision.mark self, logos: max_results
          annotation.logos
        end

        ##
        # Performs the `LOGO_DETECTION` feature on the image and returns only
        # the first result.
        #
        # @return [Annotation::Entity] The first result of logo detection.
        #
        def logo
          logos(1).first
        end

        ##
        # Performs the `LABEL_DETECTION` feature on the image.
        #
        # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
        #
        # @param [Integer] max_results The maximum number of results. The
        #   default is {Google::Cloud::Vision.default_max_labels}. Optional.
        #
        # @return [Array<Annotation::Entity>] The results of label detection.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/landmark.jpg"
        #
        #   labels = image.labels
        #
        #   labels.count #=> 4
        #   label = labels.first
        #   label.score #=> 0.9481348991394043
        #   label.description #=> "stone carving"
        #   label.mid #=> "/m/02wtjj"
        #
        def labels max_results = Vision.default_max_labels
          ensure_vision!
          annotation = @vision.mark self, labels: max_results
          annotation.labels
        end

        ##
        # Performs the `LABEL_DETECTION` feature on the image and returns only
        # the first result.
        #
        # @return [Annotation::Entity] The first result of label detection.
        #
        def label
          labels(1).first
        end

        ##
        # Performs the `TEXT_DETECTION` feature (OCR for shorter documents with
        # sparse text) on the image.
        #
        # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
        #
        # @return [Annotation::Text] The results of text (OCR) detection.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/text.png"
        #
        #   text = image.text
        #
        #   text.text
        #   # "Google Cloud Client for Ruby an idiomatic, intuitive... "
        #
        #   text.locale #=> "en"
        #   text.words.count #=> 28
        #   text.words[0].text #=> "Google"
        #   text.words[0].bounds.count #=> 4
        #   vertex = text.words[0].bounds.first
        #   vertex.x #=> 13
        #   vertex.y #=> 8
        #
        #   # Use `pages` to access a full structural representation
        #   page = text.pages.first
        #   page.blocks[0].paragraphs[0].words[0].symbols[0].text #=> "G"
        #
        #
        def text
          ensure_vision!
          annotation = @vision.mark self, text: true
          annotation.text
        end

        ##
        # Performs the `DOCUMENT_TEXT_DETECTION` feature (OCR for longer
        # documents with dense text) on the image.
        #
        # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
        #
        # @return [Annotation::Text] The results of document text (OCR)
        #   detection.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/text.png"
        #
        #   text = image.document
        #
        #   text.text
        #   # "Google Cloud Client for Ruby an idiomatic, intuitive... "
        #
        #   text.words[0].text #=> "Google"
        #   text.words[0].bounds.count #=> 4
        #   vertex = text.words[0].bounds.first
        #   vertex.x #=> 13
        #   vertex.y #=> 8
        #
        #   # Use `pages` to access a full structural representation
        #   page = text.pages.first
        #   page.blocks[0].paragraphs[0].words[0].symbols[0].text #=> "G"
        #
        def document
          ensure_vision!
          annotation = @vision.mark self, document: true
          annotation.text
        end

        ##
        # Performs the `SAFE_SEARCH_DETECTION` feature on the image.
        #
        # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
        #
        # @return [Annotation::SafeSearch] The results of safe search detection.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   safe_search = image.safe_search
        #
        #   safe_search.spoof? #=> false
        #   safe_search.spoof #=> :VERY_UNLIKELY
        #
        def safe_search
          ensure_vision!
          annotation = @vision.mark self, safe_search: true
          annotation.safe_search
        end

        ##
        # Performs the `IMAGE_PROPERTIES` feature on the image.
        #
        # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
        #
        # @return [Annotation::Properties] The results of image properties
        #   detection.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/logo.jpg"
        #
        #   properties = image.properties
        #
        #   properties.colors.count #=> 10
        #   color = properties.colors.first
        #   color.red #=> 247.0
        #   color.green #=> 236.0
        #   color.blue #=> 20.0
        #
        def properties
          ensure_vision!
          annotation = @vision.mark self, properties: true
          annotation.properties
        end

        ##
        # Performs the `CROP_HINTS` feature on the image.
        #
        # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
        #
        # @return [Array<Annotation::CropHint>] The results of crop hints
        #   detection.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   crop_hints = image.crop_hints
        #   crop_hints.count #=> 1
        #   crop_hint = crop_hints.first
        #
        #   crop_hint.bounds.count #=> 4
        #   crop_hint.confidence #=> 1.0
        #   crop_hint.importance_fraction #=> 1.0399999618530273
        #
        def crop_hints max_results = Vision.default_max_crop_hints
          ensure_vision!
          annotation = @vision.mark self, crop_hints: max_results
          annotation.crop_hints
        end

        ##
        # Performs the `WEB_ANNOTATION` feature on the image.
        #
        # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
        #
        # @return [Annotation::Web] The results of web detection.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   web = image.web
        #
        #   entity = web.entities.first
        #   entity.entity_id #=> "/m/019dvv"
        #   entity.score #=> 107.34591674804688
        #   entity.description #=> "Mount Rushmore National Memorial"
        #
        #   full_matching_image = web.full_matching_images.first
        #   full_matching_image.url #=> "http://example.com/images/123.jpg"
        #   full_matching_image.score #=> 0.10226666927337646
        #
        #   page_with_matching_images = web.pages_with_matching_images.first
        #   page_with_matching_images.url #=> "http://example.com/posts/123"
        #   page_with_matching_images.score #=> 8.114753723144531
        #
        def web max_results = Vision.default_max_web
          ensure_vision!
          annotation = @vision.mark self, web: max_results
          annotation.web
        end

        ##
        # Performs detection of Cloud Vision
        # [features](https://cloud.google.com/vision/reference/rest/v1/images/annotate#Feature)
        # on the image. If no options for features are provided, **all** image
        # detection features will be performed, with a default of `100` results
        # for faces, landmarks, logos, labels, crop_hints, and web. If any
        # feature option is provided, only the specified feature detections will
        # be performed. Please review
        # [Pricing](https://cloud.google.com/vision/docs/pricing) before use, as
        # a separate charge is incurred for each feature performed on an image.
        #
        # @see https://cloud.google.com/vision/docs/requests-and-responses Cloud
        #   Vision API Requests and Responses
        # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#AnnotateImageRequest
        #   AnnotateImageRequest
        # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
        #
        # @param [Boolean, Integer] faces Whether to perform the facial
        #   detection feature. The maximum number of results is configured in
        #   {Google::Cloud::Vision.default_max_faces}, or may be provided here.
        #   Optional.
        # @param [Boolean, Integer] landmarks Whether to perform the landmark
        #   detection feature. The maximum number of results is configured in
        #   {Google::Cloud::Vision.default_max_landmarks}, or may be provided
        #   here. Optional.
        # @param [Boolean, Integer] logos Whether to perform the logo detection
        #   feature. The maximum number of results is configured in
        #   {Google::Cloud::Vision.default_max_logos}, or may be provided here.
        #   Optional.
        # @param [Boolean, Integer] labels Whether to perform the label
        #   detection feature. The maximum number of results is configured in
        #   {Google::Cloud::Vision.default_max_labels}, or may be provided here.
        #   Optional.
        # @param [Boolean] text Whether to perform the text detection feature
        #   (OCR for shorter documents with sparse text). Optional.
        # @param [Boolean] document Whether to perform the document text
        #   detection feature (OCR for longer documents with dense text).
        #   Optional.
        # @param [Boolean] safe_search Whether to perform the safe search
        #   feature. Optional.
        # @param [Boolean] properties Whether to perform the image properties
        #   feature (currently, the image's dominant colors.) Optional.
        # @param [Boolean, Integer] crop_hints Whether to perform the crop hints
        #   feature. Optional.
        # @param [Boolean, Integer] web Whether to perform the web annotation
        #   feature. Optional.
        #
        # @return [Annotation] The results for all image detections, returned as
        #   a single {Annotation} instance.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   image = vision.image "path/to/landmark.jpg"
        #
        #   annotation = image.annotate labels: true, landmarks: true
        #
        #   annotation.labels.map &:description
        #   # ["stone carving", "ancient history", "statue", "sculpture",
        #   #  "monument", "landmark"]
        #   annotation.landmarks.count #=> 1
        #
        # @example Maximum result values can also be provided:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   image = vision.image "path/to/landmark.jpg"
        #
        #   annotation = image.annotate labels: 3, landmarks: 3
        #
        #   annotation.labels.map &:description
        #   # ["stone carving", "ancient history", "statue"]
        #   annotation.landmarks.count #=> 1
        #
        def annotate faces: false, landmarks: false, logos: false,
                     labels: false, text: false, document: false,
                     safe_search: false, properties: false, crop_hints: false,
                     web: false
          @vision.annotate(self, faces: faces, landmarks: landmarks,
                                 logos: logos, labels: labels, text: text,
                                 document: document, safe_search: safe_search,
                                 properties: properties, crop_hints: crop_hints,
                                 web: web)
        end
        alias mark annotate
        alias detect annotate

        # @private
        def to_s
          @to_s ||= begin
            if io?
              @io.rewind
              "(#{@io.read(16)}...)"
            else
              "(#{@url})"
            end
          end
        end

        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end

        ##
        # @private The GRPC object for the Image.
        def to_grpc
          if io?
            @io.rewind
            Google::Cloud::Vision::V1::Image.new content: @io.read
          elsif url?
            Google::Cloud::Vision::V1::Image.new(
              source: Google::Cloud::Vision::V1::ImageSource.new(
                image_uri: @url
              )
            )
          else
            raise ArgumentError, "Unable to use Image with Vision service."
          end
        end

        ##
        # @private New Image from a source object.
        def self.from_source source, vision = nil
          if source.respond_to?(:read) && source.respond_to?(:rewind)
            return from_io(source, vision)
          end
          # Convert Storage::File objects to the URL
          source = source.to_gs_url if source.respond_to? :to_gs_url
          # Everything should be a string from now on
          source = String source
          # Create an Image from a HTTP/HTTPS URL or Google Storage URL.
          return from_url(source, vision) if url? source
          # Create an image from a file on the filesystem
          if File.file? source
            unless File.readable? source
              raise ArgumentError, "Cannot read #{source}"
            end
            return from_io(File.open(source, "rb"), vision)
          end
          raise ArgumentError, "Unable to convert #{source} to an Image"
        end

        ##
        # @private New Image from an IO object.
        def self.from_io io, vision
          if !io.respond_to?(:read) && !io.respond_to?(:rewind)
            raise ArgumentError, "Cannot create an Image without an IO object"
          end
          new.tap do |i|
            i.instance_variable_set :@io, io
            i.instance_variable_set :@vision, vision
          end
        end

        ##
        # @private New Image from a HTTP/HTTPS URL or Google Storage URL.
        def self.from_url url, vision
          url = String url
          unless url? url
            raise ArgumentError, "Cannot create an Image without a URL"
          end
          new.tap do |i|
            i.instance_variable_set :@url, url
            i.instance_variable_set :@vision, vision
          end
        end

        ##
        # @private
        def self.url? url
          regex = %r{\A(http|https|gs):\/\/}
          !regex.match(url).nil?
        end

        protected

        ##
        # Raise an error unless an active vision project object is available.
        def ensure_vision!
          raise "Must have active connection" unless @vision
        end
      end

      class Image
        ##
        # # Image::Context
        #
        # Represents an image context.
        #
        # @attr [Array<String>] languages A list of [ISO 639-1 language
        #   codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
        #   to use for text (OCR) detection. In most cases, an empty value
        #   will yield the best results as it will allow text detection to
        #   automatically detect the text language. For languages based on the
        #   latin alphabet a hint is not needed. In rare cases, when the
        #   language of the text in the image is known in advance, setting
        #   this hint will help get better results (although it will hurt a
        #   great deal if the hint is wrong). For use with {Image#text}.
        # @attr [Array<Float>] aspect_ratios Aspect ratios in floats,
        #   representing the ratio of the width to the height of the image. For
        #   example, if the desired aspect ratio is 4/3, the corresponding float
        #   value should be 1.33333.  If not specified, the best possible crop
        #   is returned. The number of provided aspect ratios is limited to a
        #   maximum of 16; any aspect ratios provided after the 16th are
        #   ignored. For use with {Image#crop_hints}.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   image = vision.image "path/to/landmark.jpg"
        #   image.context.area.min = { longitude: -122.0862462,
        #                              latitude: 37.4220041 }
        #   image.context.area.max = { longitude: -122.0762462,
        #                              latitude: 37.4320041 }
        #
        class Context
          ##
          # Returns a lat/long rectangle that specifies the location of the
          # image.
          # @return [Area] The lat/long pairs for `latLongRect`.
          attr_reader :area

          attr_accessor :languages, :aspect_ratios

          ##
          # @private Creates a new Context instance.
          def initialize
            @area = Area.new
            @languages = []
            @aspect_ratios = []
          end

          ##
          # Returns `true` if either `min` or `max` are not populated.
          #
          # @return [Boolean]
          #
          def empty?
            area.empty? && languages.empty? && aspect_ratios.empty?
          end

          ##
          # @private
          def to_grpc
            return nil if empty?

            args = {}
            args[:lat_long_rect] = area.to_grpc unless area.empty?
            args[:language_hints] = languages unless languages.empty?
            unless aspect_ratios.empty?
              crop_params = Google::Cloud::Vision::V1::CropHintsParams.new(
                aspect_ratios: aspect_ratios
              )
              args[:crop_hints_params] = crop_params
            end
            Google::Cloud::Vision::V1::ImageContext.new args
          end

          ##
          # # Image::Context::Area
          #
          # A Lat/long rectangle that specifies the location of the image.
          #
          # @example
          #   require "google/cloud/vision"
          #
          #   vision = Google::Cloud::Vision.new
          #
          #   image = vision.image "path/to/landmark.jpg"
          #
          #   image.context.area.min = { longitude: -122.0862462,
          #                              latitude: 37.4220041 }
          #   image.context.area.max = { longitude: -122.0762462,
          #                              latitude: 37.4320041 }
          #
          #   entity = image.landmark
          #
          class Area
            # Returns the min lat/long pair.
            # @return [Location]
            attr_reader :min

            # Returns the max lat/long pair.
            # @return [Location]
            attr_reader :max

            ##
            # @private Creates a new Area instance.
            def initialize
              @min = Location.new nil, nil
              @max = Location.new nil, nil
            end

            ##
            # Sets the min lat/long pair for the area.
            #
            # @param [Hash(Symbol => Float)] location A Hash containing the keys
            #   `:latitude` and `:longitude` with corresponding values
            #   conforming to the [WGS84
            #   standard](http://www.unoosa.org/pdf/icg/2012/template/WGS_84.pdf).
            def min= location
              if location.respond_to?(:to_h) &&
                 location.to_h.keys.sort == %i[latitude longitude]
                @min = Location.new(location.to_h[:latitude],
                                    location.to_h[:longitude])
                return
              end
              raise ArgumentError, "Must pass a proper location value."
            end

            ##
            # Sets the max lat/long pair for the area.
            #
            # @param [Hash(Symbol => Float)] location A Hash containing the keys
            #   `:latitude` and `:longitude` with corresponding values
            #   conforming to the [WGS84
            #   standard](http://www.unoosa.org/pdf/icg/2012/template/WGS_84.pdf).
            def max= location
              if location.respond_to?(:to_h) &&
                 location.to_h.keys.sort == %i[latitude longitude]
                @max = Location.new(location.to_h[:latitude],
                                    location.to_h[:longitude])
                return
              end
              raise ArgumentError, "Must pass a proper location value."
            end

            ##
            # Returns `true` if either `min` or `max` are not populated.
            #
            # @return [Boolean]
            #
            def empty?
              min.to_h.values.reject(&:nil?).empty? ||
                max.to_h.values.reject(&:nil?).empty?
            end

            ##
            # Deeply converts object to a hash. All keys will be symbolized.
            #
            # @return [Hash]
            #
            def to_h
              { min_lat_lng: min.to_h, max_lat_lng: max.to_h }
            end

            def to_grpc
              return nil if empty?
              Google::Cloud::Vision::V1::LatLongRect.new(
                min_lat_lng: min.to_grpc,
                max_lat_lng: max.to_grpc
              )
            end
          end
        end
      end
    end
  end
end
