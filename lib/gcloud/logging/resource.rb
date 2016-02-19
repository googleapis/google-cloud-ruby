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
    #   resource = logging.resource "gae_app",
    #                               "module_id" => "1",
    #                               "version_id" => "20150925t173233"
    #
    class Resource
      ##
      # Create an empty Resource object.
      def initialize
        @labels = {}
      end

      ##
      # The type of a {ResourceDescriptor}
      #
      attr_accessor :type

      ##
      # A set of labels that can be used to describe instances of this monitored
      # resource type.
      attr_accessor :labels

      ##
      # @private Determines if the Resource has any data.
      def empty?
        type.nil? && (labels.nil? || labels.empty?)
      end

      ##
      # @private Exports the Resource to a Google::Api::MonitoredResource
      # object.
      def to_grpc
        return nil if empty?
        Google::Api::MonitoredResource.new(
          type: type,
          labels: labels
        )
      end

      ##
      # @private New Resource from a Google::Api::MonitoredResource object.
      def self.from_grpc grpc
        return new if grpc.nil?
        new.tap do |r|
          r.type = grpc.type
          r.labels = grpc.labels
          # hashify the labels hash, just in case...
          r.labels = r.labels.to_hash if r.labels.respond_to? :to_hash
          r.labels = r.labels.to_h    if r.labels.respond_to? :to_h
        end
      end
    end
  end
end
