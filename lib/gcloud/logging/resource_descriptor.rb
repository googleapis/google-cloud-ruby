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


require "gcloud/logging/resource_descriptor/list"

module Gcloud
  module Logging
    ##
    # # ResourceDescriptor
    #
    # A type of monitored resource that is used by Cloud Logging. Read-only.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   logging = gcloud.logging
    #   resource_descriptor = logging.resource_descriptors.first
    #
    class ResourceDescriptor
      ##
      # @private New ResourceDescriptor from a Google API Client object.
      def initialize
        @labels = []
      end

      ##
      # The monitored resource type.
      attr_reader :type

      ##
      # A concise name for the monitored resource type, which is displayed in
      # user interfaces.
      attr_reader :name

      ##
      # A detailed description of the monitored resource type, which is used in
      # documentation.
      attr_reader :description

      ##
      # A set of labels that can be used to describe instances of this monitored
      # resource type.
      attr_reader :labels

      ##
      # @private New ResourceDescriptor from a Google API Client object.
      def self.from_gapi gapi
        gapi ||= {}
        gapi = gapi.to_hash if gapi.respond_to? :to_hash
        r = new
        r.instance_eval do
          @type        = gapi["type"]
          @name        = gapi["displayName"]
          @description = gapi["description"]
          @labels      = Array(gapi["labels"]) # TODO: Array<LabelDescriptor>
        end
        r
      end
    end
  end
end
