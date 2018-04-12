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


require "google/cloud/bigtable"
require "google/cloud/bigtable/v2"
require "google/cloud/bigtable/table_data_operations"

module Google
  module Cloud
    module Bigtable
      # DataClient
      #
      # A Bigtable client for data oprations.
      #
      # Read, wirite, update and delete of table data
      class DataClient
        attr_reader :project_id, :instance_id

        # @private
        attr_reader :options

        # @private
        #
        # Create data client object to perform operations on tables data.
        # @param project_id [String]
        # @param instance_id [String]
        # @param options [Hash]

        def initialize project_id, instance_id, options = {}
          @project_id = project_id
          @instance_id = instance_id
          @options = options
        end

        # Get table data operations client for read, write and delete rows
        #
        # See {Google::Cloud::Bigtable::TableDataOperations} for list of
        # operations
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(instance_id: "instance-id")
        #
        #   table = client.table("table-name")
        #
        #   table.read_rows(rows_limit: 10) do |row|
        #     p row
        #   end
        #
        # @param table_id [String]
        #   Existing table id.
        # @param app_profile_id [String]
        #   This value specifies routing for replication. If not specified, the
        #   "default" application profile will be used.
        # @return [Bigtable::TableDataOperations]

        def table table_id, app_profile_id = nil
          TableDataOperations.new(
            client,
            table_path(table_id),
            app_profile_id
          )
        end

        private

        # Create or return existing data client object
        #
        # @return [Google::Cloud::Bigtable::V2::BigtableClient]

        def client
          @client ||= Google::Cloud::Bigtable::V2.new(options)
        end

        # Created formatted table path
        #
        # @param table_id [String]
        # @return [String]
        #   Formatted table path
        #   +projects/<project>/instances/<instance>/tables/<table>+

        def table_path table_id
          client.class.table_path(project_id, instance_id, table_id)
        end
      end
    end
  end
end
