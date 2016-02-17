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
      # A set of definitions of the labels that can be used to describe
      # instances of this monitored resource type.
      #
      # @return [Array<LabelDescriptor>]
      #
      attr_reader :labels

      ##
      # @private New ResourceDescriptor from a
      # Google::Api::MonitoredResourceDescriptor object.
      def self.from_grpc grpc
        r = new
        r.instance_eval do
          @type        = grpc.type
          @name        = grpc.display_name
          @description = grpc.description
          @labels      = Array(grpc.labels).map do |g|
            LabelDescriptor.from_grpc g
          end
        end
        r
      end

      ##
      # # LabelDescriptor
      #
      # A definition of a label that can be used to describe instances of a
      # monitored resource type. For example, Cloud SQL databases can be labeled
      # with their "database_id" and their "zone". See
      # {ResourceDescriptor#labels}.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   resource_descriptor = logging.resource_descriptors.first
      #   label_descriptor = resource_descriptor.labels.first
      #   label_descriptor.key #=> "database_id"
      #   label_descriptor.description #=> "The ID of the database."
      #
      class LabelDescriptor
        ##
        # The key (name) of the label.
        attr_reader :key

        ##
        # The type of data that can be assigned to the label.
        #
        # @return [Symbol, nil] Returns `:string`, `:boolean`, `:integer`, or
        #   `nil` if there is no type.
        #
        attr_reader :type

        ##
        # A human-readable description for the label.
        attr_reader :description

        ##
        # @private New LabelDescriptor from a Google::Api::LabelDescriptor
        # object.
        def self.from_grpc grpc
          type_sym = { STRING: :string,
                       BOOL:   :boolean,
                       INT64:  :integer }[grpc.value_type]
          l = new
          l.instance_eval do
            @key         = grpc.key
            @type        = type_sym
            @description = grpc.description
          end
          l
        end
      end
    end
  end
end
