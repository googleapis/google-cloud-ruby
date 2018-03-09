# frozen_string_literal: true

require "google/cloud/bigtable"
require "google/cloud/bigtable/v2"
require "google/cloud/bigtable/table_data_operations"

module Google
  module Cloud
    module Bigtable
      class DataClient
        # Bigtable client for data oprations.

        attr_reader :options, :project_id, :instance_id

        # @param project_id [String]
        # @param instance_id [String]
        # @param options [Hash]

        def initialize project_id, instance_id, options = {}
          @project_id = project_id
          @instance_id = instance_id
          @options = options
        end

        # Get table data operations client
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   client = Google::Cloud::Bigtable.new(instance_id: "instance-id")
        #
        #   client.table("table-name")
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
