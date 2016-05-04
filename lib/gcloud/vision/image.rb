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
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   vision = gcloud.vision
    #   image = vision.image filepath
    class Image
      attr_reader :context

      ##
      # @private Creates a new Image instance.
      def initialize
        @io = nil
        @url = nil
        @vision = nil
        @context = Context.new
      end

      # Determines if the Image has content.
      #
      # @see {#url?}
      #
      def content?
        !@io.nil?
      end

      # Determines if the Image is a URL.
      #
      # @see {#content?}
      #
      def url?
        !@url.nil?
      end

      ##
      # The contents of the image, encoded via Base64.
      def content
        @content ||= Base64.encode64 @io.read
      end

      ##
      # The URL of the image
      def url
        @url
      end

      def faces count = 10
        ensure_vision!
        analysis = @vision.mark self, faces: count
        analysis.faces
      end

      def face
        faces(1).first
      end

      def landmarks count = 10
        ensure_vision!
        analysis = @vision.mark self, landmarks: count
        analysis.landmarks
      end

      def landmark
        landmarks(1).first
      end

      def logos count = 10
        ensure_vision!
        analysis = @vision.mark self, logos: count
        analysis.logos
      end

      def logo
        logos(1).first
      end

      def labels count = 10
        ensure_vision!
        analysis = @vision.mark self, labels: count
        analysis.labels
      end

      def label
        labels(1).first
      end

      def text
        ensure_vision!
        analysis = @vision.mark self, text: true
        analysis.text
      end

      def safe_search
        ensure_vision!
        analysis = @vision.mark self, safe_search: true
        analysis.safe_search
      end

      def properties
        ensure_vision!
        analysis = @vision.mark self, properties: true
        analysis.properties
      end

      def to_s
        return "(io)" if content?
        "(url: #{url})"
      end

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
      # Represents an image context for the Vision service.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   image = vision.image filepath
      #   image.context.location = { longitude: -122.0862462,
      #                              latitude: 37.4220041 }
      class Context
        attr_reader :location
        attr_accessor :languages

        def initialize
          @location = Location.new nil, nil
          @languages = []
        end

        def location= location
          if location.respond_to?(:to_hash) &&
             location.to_hash.keys.sort == [:latitude, :longitude]
            return @location = Location.new(location.to_hash[:latitude],
                                            location.to_hash[:longitude])
          end
          fail ArgumentError, "Must pass a proper location value."
        end

        def empty?
          location.to_hash.values.reject(&:nil?).empty? && languages.empty?
        end

        def to_gapi
          return nil if empty?
          gapi = {}
          unless location.to_hash.values.reject(&:nil?).empty?
            gapi["latLongRect"] = location.to_hash
          end
          gapi["languageHints"] = languages unless languages.empty?
          gapi
        end
      end
    end
  end
end
