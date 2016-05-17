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


require "gcloud/gce"
require "gcloud/vision/connection"
require "gcloud/vision/credentials"
require "gcloud/vision/image"
require "gcloud/vision/annotation"
require "gcloud/vision/errors"

module Gcloud
  module Vision
    ##
    # # Location
    #
    # A latitude/longitude pair with values conforming to the [WGS84
    # standard](http://www.unoosa.org/pdf/icg/2012/template/WGS_84.pdf).
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   vision = gcloud.vision
    #
    #   image = vision.image "path/to/landmark.jpg"
    #   entity = image.landmark
    #
    #   location = entity.locations.first
    #
    #   location.latitude #=> 43.878264
    #   location.longitude #=> -103.45700740814209
    #
    class Location
      # @!attribute latitude
      #   @return [Float] The degrees latitude conforming to the [WGS84
      #     standard](http://www.unoosa.org/pdf/icg/2012/template/WGS_84.pdf).
      # @!attribute longitude
      #   @return [Float] The degrees longitude conforming to the [WGS84
      #     standard](http://www.unoosa.org/pdf/icg/2012/template/WGS_84.pdf).
      attr_accessor :latitude, :longitude

      ##
      # @private Creates a new Location instance.
      def initialize latitude, longitude
        @latitude  = latitude
        @longitude = longitude
      end

      ##
      # Returns the object's property values as an array.
      #
      # @return [Array]
      #
      def to_a
        to_ary
      end

      ##
      # Returns the object's property values as an array.
      #
      # @return [Array]
      #
      def to_ary
        [latitude, longitude]
      end

      ##
      # Converts object to a hash. All keys will be symbolized.
      #
      # @return [Hash]
      #
      def to_h
        to_hash
      end

      ##
      # Converts object to a hash. All keys will be symbolized.
      #
      # @return [Hash]
      #
      def to_hash
        { latitude: latitude, longitude: longitude }
      end

      # @private
      def to_s
        "(latitude: #{latitude.inspect}, longitude: #{longitude.inspect})"
      end

      # @private
      def inspect
        "#<#{self.class.name} #{self}>"
      end

      ##
      # @private New Google API Client LatLng object.
      def to_gapi
        to_hash
      end

      ##
      # @private New Location from a Google API Client LatLng object.
      def self.from_gapi gapi
        new gapi["latitude"], gapi["longitude"]
      end
    end
  end
end
