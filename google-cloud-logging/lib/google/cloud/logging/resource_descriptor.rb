# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/logging/resource_descriptor/list"

module Google
  module Cloud
    module Logging
      ##
      # # ResourceDescriptor
      #
      # Describes a type of monitored resource supported by Stackdriver Logging.
      # Each ResourceDescriptor has a type name, such as `cloudsql_database`,
      # `gae_app`, or `gce_instance`. It also specifies a set of labels that
      # must all be given values in a {Resource} instance to represent an actual
      # instance of the type.
      #
      # ResourceDescriptor instances are read-only. You cannot create your own
      # instances, but you can list them with {Project#resource_descriptors}.
      #
      # @example
      #   require "google/cloud/logging"
      #
      #   logging = Google::Cloud::Logging.new
      #   resource_descriptor = logging.resource_descriptors.first
      #   resource_descriptor.type #=> "cloudsql_database"
      #   resource_descriptor.name #=> "Cloud SQL Database"
      #   resource_descriptor.labels.map &:key #=> ["database_id", "zone"]
      #
      class ResourceDescriptor
        ##
        # @private New ResourceDescriptor from a Google API Client object.
        def initialize
          @labels = []
        end

        ##
        # The monitored resource type. For example, `cloudsql_database`.
        attr_reader :type

        ##
        # A display name for the monitored resource type. For example,
        # `Cloud SQL Database`.
        attr_reader :name

        ##
        # A detailed description of the monitored resource type, which is used
        # in documentation.
        attr_reader :description

        ##
        # A set of definitions of the labels that can be used to describe
        # instances of this monitored resource type. For example, Cloud SQL
        # databases must be labeled with their `database_id` and their `region`.
        #
        # @return [Array<LabelDescriptor>]
        #
        attr_reader :labels

        ##
        # @private New ResourceDescriptor from a
        # Google::Api::MonitoredResourceDescriptor object.
        def self.from_grpc grpc
          labels = Array(grpc.labels).map do |g|
            LabelDescriptor.from_grpc g
          end
          new.tap do |r|
            r.instance_variable_set :@type,        grpc.type
            r.instance_variable_set :@name,        grpc.display_name
            r.instance_variable_set :@description, grpc.description
            r.instance_variable_set :@labels,      labels
          end
        end

        ##
        # # LabelDescriptor
        #
        # A definition of a label that can be used to describe instances of a
        # {Resource}. For example, Cloud SQL databases must be labeled with
        # their `database_id`. See {ResourceDescriptor#labels}.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
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
            new.tap do |l|
              l.instance_variable_set :@key,         grpc.key
              l.instance_variable_set :@type,        type_sym
              l.instance_variable_set :@description, grpc.description
            ebd
          end
        end
      end
    end
  end
end
