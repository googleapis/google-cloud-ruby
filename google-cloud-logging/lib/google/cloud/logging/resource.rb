# Copyright 2016 Google LLC
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


module Google
  module Cloud
    module Logging
      ##
      # # Resource
      #
      # A monitored resource is an abstraction used to characterize many kinds
      # of objects in your cloud infrastructure, including Google Cloud SQL
      # databases, Google App Engine apps, Google Compute Engine virtual machine
      # instances, and so forth. Each of those kinds of objects is described by
      # an instance of {ResourceDescriptor}.
      #
      # For use with {Google::Cloud::Logging::Entry#resource},
      # {Google::Cloud::Logging::Project#resource}, and
      # {Google::Cloud::Logging::Project#write_entries}.
      #
      # @example
      #   require "google/cloud/logging"
      #
      #   logging = Google::Cloud::Logging.new
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
        # The type of resource, as represented by a {ResourceDescriptor}.
        attr_accessor :type

        ##
        # A set of labels that can be used to describe instances of this
        # monitored resource type.
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
            labels: Hash[labels.map { |k, v| [String(k), String(v)] }]
          )
        end

        ##
        # @private New Resource from a Google::Api::MonitoredResource object.
        def self.from_grpc grpc
          return new if grpc.nil?
          new.tap do |r|
            r.type = grpc.type
            r.labels = Convert.map_to_hash(grpc.labels)
          end
        end
      end
    end
  end
end
