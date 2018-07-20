# frozen_string_literal: true

# Copyright 2018 Google LLC
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


require "google/cloud/bigtable/client/table"

module Google
  module Cloud
    module Bigtable
      # # Client
      #
      # A client is used to create table data client instance with or without app profile id to
      # read and/or modify data in a Cloud Bigtable table.
      #
      # # See {Google::Cloud::Bigtable::Project#client}.
      #
      # @example
      #   require "google/cloud"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   client = bigtable.client("my-instance")
      #
      #   table = client.table("my-table")
      #   entry = table.new_mutation_entry("user-1")
      #   entry.set_cell(
      #     "cf-1",
      #     "field-1",
      #     "XYZ"
      #     timestamp: Time.now.to_i * 1000 # Time stamp in milli seconds.
      #   ).delete_from_column("cf2", "field02")
      #
      #   table.mutate_row(entry)
      #
      class Client
        # @return [String] The unique identifier for the instance.
        attr_reader :instance_id

        # @private
        #
        # Creates a new Bigtable Data Client instance.
        #
        # @param service [Google::Cloud::Bigtable::Service]
        # @param instance_id [String]
        #
        def initialize service, instance_id
          @service = service
          @instance_id = instance_id
        end

        # The unique identifier for the project.
        # @return [String]
        def project_id
          @service.project_id
        end

        # Get table instance to perform read/write data operations.
        # @param table_id [String] The unique identifier for the table. Required.
        # @param app_profile_id [String] The unique identifier for the app profile. Optional.
        #  This value specifies routing for replication. If not specified, the
        #  "default" application profile will be used.
        # @return [Google::Cloud::Bigtable::Client::Table]
        #
        # @example
        #   require "google/cloud"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   client = bigtable.client "my-instance"
        #
        #   table = client.table("my-table")
        #
        # @example With app profile
        #   require "google/cloud"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   client = bigtable.client "my-instance"
        #
        #   table = client.table("my-table", app_profile_id: "my-app-profile")
        #
        #
        def table table_id, app_profile_id: nil
          ensure_service!
          Client::Table.new(
            @service.client,
            table_path(table_id),
            app_profile_id: app_profile_id
          )
        end

        # Create formatted table path
        #
        # @param table_id [String]
        # @return [String]
        #   Formatted table path
        #   +projects/<project>/instances/<instance>/tables/<table>+
        #
        def table_path table_id
          V2::BigtableClient.table_path(
            project_id,
            instance_id,
            table_id
          )
        end

        # @private
        # Inspect table instance
        # @return [String]

        def inspect
          "#{self.class}(#{project_id}#{@instance_id})"
        end

        private

        # @private
        #
        # Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless @service
        end
      end
    end
  end
end
