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
    #   image = vision.image "./acceptance/data/text.png"
    #
    #   image.context.languages = ["en"]
    #
    #   text = image.text
    #   text.words.count #=> 28
    #
    class Image
      # Returns the image context for the image
      # @return [Context]
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
      # Whether the Image has content.
      #
      # @see {#url?}
      #
      def content?
        !@io.nil?
      end

      ##
      # Whether the Image is a URL.
      #
      # @see {#content?}
      #
      def url?
        !@url.nil?
      end

      ##
      # The contents of the image, encoded via Base64.
      #
      # @return [String]
      #
      def content
        @content ||= Base64.encode64 @io.read
      end

      ##
      # The URL of the image.
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
      # @param [Integer] count The maximum number of results.
      #
      # @return [Array<Analysis::Face>] The results of face detection.
      #
      def faces count = 10
        ensure_vision!
        analysis = @vision.mark self, faces: count
        analysis.faces
      end

      ##
      # Performs the `FACE_DETECTION` feature on the image and returns only the
      # first result.
      #
      # @return [Analysis::Face] The first result of face detection.
      #
      def face
        faces(1).first
      end

      ##
      # Performs the `LANDMARK_DETECTION` feature on the image.
      #
      # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
      #
      # @param [Integer] count The maximum number of results.
      #
      # @return [Array<Analysis::Entity>] The results of landmark detection.
      #
      def landmarks count = 10
        ensure_vision!
        analysis = @vision.mark self, landmarks: count
        analysis.landmarks
      end

      ##
      # Performs the `LANDMARK_DETECTION` feature on the image and returns only
      # the first result.
      #
      # @return [Analysis::Entity] The first result of landmark detection.
      #
      def landmark
        landmarks(1).first
      end

      ##
      # Performs the `LOGO_DETECTION` feature on the image.
      #
      # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
      #
      # @param [Integer] count The maximum number of results.
      #
      # @return [Array<Analysis::Entity>] The results of logo detection.
      #
      def logos count = 10
        ensure_vision!
        analysis = @vision.mark self, logos: count
        analysis.logos
      end

      ##
      # Performs the `LOGO_DETECTION` feature on the image and returns only the
      # first result.
      #
      # @return [Analysis::Entity] The first result of logo detection.
      #
      def logo
        logos(1).first
      end

      ##
      # Performs the `LABEL_DETECTION` feature on the image.
      #
      # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
      #
      # @param [Integer] count The maximum number of results.
      #
      # @return [Array<Analysis::Entity>] The results of label detection.
      #
      def labels count = 10
        ensure_vision!
        analysis = @vision.mark self, labels: count
        analysis.labels
      end

      ##
      # Performs the `LABEL_DETECTION` feature on the image and returns only the
      # first result.
      #
      # @return [Analysis::Entity] The first result of label detection.
      #
      def label
        labels(1).first
      end

      ##
      # Performs the `TEXT_DETECTION` (OCR) feature on the image.
      #
      # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
      #
      # @return [Analysis::Text] The results of text (OCR) detection.
      #
      def text
        ensure_vision!
        analysis = @vision.mark self, text: true
        analysis.text
      end

      ##
      # Performs the `SAFE_SEARCH_DETECTION` feature on the image.
      #
      # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
      #
      # @return [Analysis::SafeSearch] The results of safe search detection.
      #
      def safe_search
        ensure_vision!
        analysis = @vision.mark self, safe_search: true
        analysis.safe_search
      end

      ##
      # Performs the `IMAGE_PROPERTIES` feature on the image.
      #
      # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
      #
      # @return [Analysis::Properties] The results of image properties
      #   detection.
      #
      def properties
        ensure_vision!
        analysis = @vision.mark self, properties: true
        analysis.properties
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
      #   image = vision.image "./acceptance/data/landmark.jpg"
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
        #   image = vision.image "./acceptance/data/landmark.jpg"
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
