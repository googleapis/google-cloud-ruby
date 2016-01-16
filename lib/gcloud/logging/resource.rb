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
      # Create an empty Resource object.
      def initialize
        @labels = []
      end

      ##
      # The monitored resource type.
      attr_accessor :type

      ##
      # A concise name for the monitored resource type, which is displayed in
      # user interfaces.
      attr_accessor :name

      ##
      # A detailed description of the monitored resource type, which is used in
      # documentation.
      attr_accessor :description

      ##
      # A set of labels that can be used to describe instances of this monitored
      # resource type.
      attr_accessor :labels

      ##
      # @private Exports the Resource to a Google API Client object.
      def to_gapi
        ret = {
          "type" => type,
          "displayName" => name,
          "description" => description,
          "labels" => labels
        }.delete_if { |_, v| v.nil? }
        ret.delete "labels" if labels.empty?
        ret
      end

      ##
      # @private Determines if the Resource has any data.
      def empty?
        to_gapi.empty?
      end

      ##
      # @private New Resource from a Google API Client object.
      def self.from_gapi gapi
        gapi ||= {}
        gapi = gapi.to_hash if gapi.respond_to? :to_hash
        new.tap do |r|
          r.type        = gapi["type"]
          r.name        = gapi["displayName"]
          r.description = gapi["description"]
          r.labels      = Array(gapi["labels"])
        end
      end
    end
  end
end
