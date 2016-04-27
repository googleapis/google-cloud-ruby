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
require "gcloud/vision/analysis"
require "gcloud/vision/errors"

module Gcloud
  module Vision
    ##
    # # Location
    #
    # TODO: info here...
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   vision = gcloud.vision
    #   # TODO: example here...
    #
    class Location
      attr_accessor :latitude, :longitude

      def initialize latitude, longitude
        @latitude  = latitude
        @longitude = longitude
      end

      def to_a
        to_ary
      end

      def to_ary
        [latitude, longitude]
      end

      def to_h
        to_hash
      end

      def to_hash
        { latitude: latitude, longitude: longitude }
      end

      def to_s
        "(latitude: #{latitude.inspect}, longitude: #{longitude.inspect})"
      end

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
