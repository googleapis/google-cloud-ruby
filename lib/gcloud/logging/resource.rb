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


require "gcloud/logging/resource/list"

module Gcloud
  module Logging
    ##
    # # Resource
    #
    # Monitored resource that is used by Cloud Logging.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   logging = gcloud.logging
    #   resource = logging.resources.first
    #
    class Resource
      ##
      # @private The Google API Client object.
      attr_accessor :gapi

      ##
      # @private Create an empty File object.
      def initialize
        @connection = nil
        @gapi = {}
      end

      ##
      # The monitored resource type.
      def type
        @gapi["type"]
      end

      ##
      # A concise name for the monitored resource type, which is displayed in
      # user interfaces.
      def name
        @gapi["displayName"]
      end

      ##
      # A detailed description of the monitored resource type, which is used in
      # documentation.
      def description
        @gapi["description"]
      end

      ##
      # A set of labels that can be used to describe instances of this monitored
      # resource type.
      def labels
        # TODO: Make a proper Label class to represent this structure...
        Array @gapi["labels"]
      end

      ##
      # @private New Resource from a Google API Client object.
      def self.from_gapi gapi
        new.tap do |f|
          f.gapi = gapi
        end
      end
    end
  end
end
