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


require "gcloud/vision/location"
require "stringio"
require "base64"

module Gcloud
  module Vision
    ##
    # # Image
    #
    # Represents an image for the Vision service.
    #
    # See {Project#image}.
    #
    # The Cloud Vision API supports a variety of image file formats, including
    # JPEG, PNG8, PNG24, Animated GIF (first frame only), and RAW. See [Best
    # Practices - Image Types](https://cloud.google.com/vision/docs/image-best-practices#image_types)
    # for the list of formats. Be aware that Cloud Vision sets upper limits on
    # file size as well as the total combined size of all images in a request.
    # Reducing your file size can significantly improve throughput; however, be
    # careful not to reduce image quality in the process. See [Best Practices -
    # Image Sizing](https://cloud.google.com/vision/docs/image-best-practices#image_sizing)
    # for current file size limits.
    #
    # @see https://cloud.google.com/vision/docs/image-best-practices Best
    #   Practices
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   vision = gcloud.vision
    #
    #   image = vision.image "path/to/text.png"
    #
    #   image.context.languages = ["en"]
    #
    #   text = image.text
    #   text.words.count #=> 28
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
      # @see {#url?}
      #
      def content?
        !@io.nil?
      end

      ##
      # @private Whether the Image is a URL.
      #
      # @see {#content?}
      #
      def url?
        !@url.nil?
      end

      ##
      # @private The contents of the image, encoded via Base64.
      #
      # @return [String]
      #
      def content
        @content ||= Base64.encode64 @io.read
      end

      ##
      # @private The URL of the image.
      #
      # @return [String]
      #
      def url
        @url
      end

      ##
      # Performs the `FACE_DETECTION` feature on the image.
      #
      # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
      #
      # @param [Integer] max_results The maximum number of results. The default
      #   is {Gcloud::Vision.default_max_faces}. Optional.
      #
      # @return [Array<Annotation::Face>] The results of face detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   image = vision.image "path/to/face.jpg"
      #
      #   faces = image.faces
      #
      #   face = faces.first
      #   face.bounds.face.count #=> 4
      #   face.bounds.face.first #=> #<Vertex (x: 153, y: 34)>
      #
      def faces max_results = Gcloud::Vision.default_max_faces
        ensure_vision!
        annotation = @vision.mark self, faces: max_results
        annotation.faces
      end

      ##
      # Performs the `FACE_DETECTION` feature on the image and returns only the
      # first result.
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
      # @param [Integer] max_results The maximum number of results. The default
      #   is {Gcloud::Vision.default_max_landmarks}. Optional.
      #
      # @return [Array<Annotation::Entity>] The results of landmark detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   image = vision.image "path/to/landmark.jpg"
      #
      #   landmarks = image.landmarks
      #
      #   landmark = landmarks.first
      #   landmark.score #=> 0.91912264
      #   landmark.description #=> "Mount Rushmore"
      #   landmark.mid #=> "/m/019dvv"
      #
      def landmarks max_results = Gcloud::Vision.default_max_landmarks
        ensure_vision!
        annotation = @vision.mark self, landmarks: max_results
        annotation.landmarks
      end

      ##
      # Performs the `LANDMARK_DETECTION` feature on the image and returns only
      # the first result.
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
      # @param [Integer] max_results The maximum number of results. The default
      #   is {Gcloud::Vision.default_max_logos}. Optional.
      #
      # @return [Array<Annotation::Entity>] The results of logo detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   image = vision.image "path/to/logo.jpg"
      #
      #   logos = image.logos
      #
      #   logo = logos.first
      #   logo.score #=> 0.70057315
      #   logo.description #=> "Google"
      #   logo.mid #=> "/m/0b34hf"
      #
      def logos max_results = Gcloud::Vision.default_max_logos
        ensure_vision!
        annotation = @vision.mark self, logos: max_results
        annotation.logos
      end

      ##
      # Performs the `LOGO_DETECTION` feature on the image and returns only the
      # first result.
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
      # @param [Integer] max_results The maximum number of results. The default
      #   is {Gcloud::Vision.default_max_labels}. Optional.
      #
      # @return [Array<Annotation::Entity>] The results of label detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   image = vision.image "path/to/face.jpg"
      #
      #   labels = image.labels
      #
      #   labels.count #=> 4
      #   label = labels.first
      #   label.score #=> 0.9481349
      #   label.description #=> "person"
      #   label.mid #=> "/m/01g317"
      #
      def labels max_results = Gcloud::Vision.default_max_labels
        ensure_vision!
        annotation = @vision.mark self, labels: max_results
        annotation.labels
      end

      ##
      # Performs the `LABEL_DETECTION` feature on the image and returns only the
      # first result.
      #
      # @return [Annotation::Entity] The first result of label detection.
      #
      def label
        labels(1).first
      end

      ##
      # Performs the `TEXT_DETECTION` (OCR) feature on the image.
      #
      # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
      #
      # @return [Annotation::Text] The results of text (OCR) detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   image = vision.image "path/to/text.png"
      #
      #   text = image.text
      #
      #   text = image.text
      #   text.locale #=> "en"
      #   text.words.count #=> 28
      #   text.text
      #   #=> "Google Cloud Client Library for Ruby an idiomatic, intuitive... "
      #
      def text
        ensure_vision!
        annotation = @vision.mark self, text: true
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
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   image = vision.image "path/to/face.jpg"
      #
      #   safe_search = image.safe_search
      #
      #   safe_search.spoof? #=> false
      #   safe_search.spoof #=> "VERY_UNLIKELY"
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
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
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

      # @private
      def to_s
        return "(io)" if content?
        "(url: #{url})"
      end

      # @private
      def inspect
        "#<#{self.class.name} #{self}>"
      end

      ##
      # @private The Google API Client object for the Image.
      def to_gapi
        if content?
          { content: content }
        elsif url?
          { source: { gcsImageUri: @url } }
        else
          fail ArgumentError, "Unable to use Image with Vision service."
        end
      end

      ##
      # @private New Image from a source object.
      def self.from_source source, vision = nil
        if source.is_a?(IO) || source.is_a?(StringIO)
          return from_io(source, vision)
        end
        # Convert Storage::File objects to the URL
        source = source.to_gs_url if source.respond_to? :to_gs_url
        # Everything should be a string from now on
        source = String source
        # Create an Image from the Google Storage URL
        return from_url(source, vision) if source.start_with? "gs://"
        # Create an image from a file on the filesystem
        if File.file? source
          unless File.readable? source
            fail ArgumentError, "Cannot read #{source}"
          end
          return from_io(File.open(source, "rb"), vision)
        end
        fail ArgumentError, "Unable to convert #{source} to an Image"
      end

      ##
      # @private New Image from an IO object.
      def self.from_io io, vision
        if !io.is_a?(IO) && !io.is_a?(StringIO)
          puts io.inspect
          fail ArgumentError, "Cannot create an Image without an IO object"
        end
        new.tap do |i|
          i.instance_variable_set :@io, io
          i.instance_variable_set :@vision, vision
        end
      end

      ##
      # @private New Image from an IO object.
      def self.from_url url, vision
        url = String url
        unless url.start_with? "gs://"
          fail ArgumentError, "Cannot create an Image without a Storage URL"
        end
        new.tap do |i|
          i.instance_variable_set :@url, url
          i.instance_variable_set :@vision, vision
        end
      end

      protected

      ##
      # Raise an error unless an active vision project object is available.
      def ensure_vision!
        fail "Must have active connection" unless @vision
      end
    end

    class Image
      ##
      # # Image::Context
      #
      # Represents an image context.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #
      #   image = vision.image "path/to/landmark.jpg"
      #   image.context.area.min = { longitude: -122.0862462,
      #                              latitude: 37.4220041 }
      #   image.context.area.max = { longitude: -122.0762462,
      #                              latitude: 37.4320041 }
      #
      class Context
        # Returns a lat/long rectangle that specifies the location of the image.
        # @return [Area] The lat/long pairs for `latLongRect`.
        attr_reader :area

        # @!attribute languages
        #   @return [Array<String>] The [ISO
        #     639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
        #     language codes for `languageHints`.
        attr_accessor :languages

        ##
        # @private Creates a new Context instance.
        def initialize
          @area = Area.new
          @languages = []
        end

        ##
        # Returns `true` if either `min` or `max` are not populated.
        #
        # @return [Boolean]
        #
        def empty?
          area.empty? && languages.empty?
        end

        ##
        # @private
        def to_gapi
          return nil if empty?
          gapi = {}
          gapi[:latLongRect] = area.to_hash unless area.empty?
          gapi[:languageHints] = languages unless languages.empty?
          gapi
        end

        ##
        # # Image::Context::Area
        #
        # A Lat/long rectangle that specifies the location of the image.
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   vision = gcloud.vision
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
          #   `:latitude` and `:longitude` with corresponding values conforming
          #   to the [WGS84
          #   standard](http://www.unoosa.org/pdf/icg/2012/template/WGS_84.pdf).
          def min= location
            if location.respond_to?(:to_hash) &&
               location.to_hash.keys.sort == [:latitude, :longitude]
              return @min = Location.new(location.to_hash[:latitude],
                                         location.to_hash[:longitude])
            end
            fail ArgumentError, "Must pass a proper location value."
          end

          ##
          # Sets the max lat/long pair for the area.
          #
          # @param [Hash(Symbol => Float)] location A Hash containing the keys
          #   `:latitude` and `:longitude` with corresponding values conforming
          #   to the [WGS84
          #   standard](http://www.unoosa.org/pdf/icg/2012/template/WGS_84.pdf).
          def max= location
            if location.respond_to?(:to_hash) &&
               location.to_hash.keys.sort == [:latitude, :longitude]
              return @max = Location.new(location.to_hash[:latitude],
                                         location.to_hash[:longitude])
            end
            fail ArgumentError, "Must pass a proper location value."
          end

          ##
          # Returns `true` if either `min` or `max` are not populated.
          #
          # @return [Boolean]
          #
          def empty?
            min.to_hash.values.reject(&:nil?).empty? ||
              max.to_hash.values.reject(&:nil?).empty?
          end

          ##
          # Deeply converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_h
            to_hash
          end

          ##
          # Deeply converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_hash
            { minLatLng: min.to_hash, maxLatLng: max.to_hash }
          end

          def to_gapi
            return nil if empty?
            to_hash
          end
        end
      end
    end
  end
end
