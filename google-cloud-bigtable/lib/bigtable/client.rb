# frozen_string_literal: true

require "google/cloud/bigtable/v2"

module Bigtable
  class ClientError < StandardError; end

  class Client
    ##
    # Bigtable client for data oprations like read rows, mutate rows,
    # read and modify rows etc.
    #
    # @example
    #   Bigtable::Client.new(
    #     "project-id-xyz",
    #     "instance-id-abc"
    #     credentials: "keyfile.json"
    #   )
    #
    #  # Or if google project default credentials set on server
    #
    #  Bigtable::Client.new("project-id-xyz", "instance-id-abc")
    #

    attr_reader :options, :project_id, :instance_id

    # @param project_id [String]
    # @param instance_id [String]
    # @param options [Hash]
    def initialize project_id, instance_id, options = {}
      @project_id = project_id
      @instance_id = instance_id
      @options = options
    end

    # Read rows
    #
    # @param table_id [String]
    #   Existing table id
    # @param rows [Google::Bigtable::V2::RowSet | Hash]
    #   The row keys and/or ranges to read.
    #   If not specified, reads from all rows.
    #   A hash of the same form as `Google::Bigtable::V2::RowSet`
    #   can also be provided.
    # @param filter [Google::Bigtable::V2::RowFilter | Hash]
    #   The filter to apply to the contents of the specified row(s). If unset,
    #   reads the entirety of each row.
    #   A hash of the same form as `Google::Bigtable::V2::RowFilter`
    #   can also be provided.
    # @param rows_limit [Integer]
    #   The read will terminate after committing to N rows' worth of results.
    #   The default (zero) is to return all results.
    # @param options [Google::Gax::CallOptions]
    #   Overrides the default settings for this call, e.g, timeout,
    #   retries, etc.
    # @example
    #   TODO
    def read_rows \
      table_id,
      app_profile_id: nil,
      rows: nil,
      filter: nil,
      rows_limit: nil
      rows = client.read_rows(
        table_path(table_id),
        app_profile_id: app_profile_id,
        rows: rows,
        filter: filter,
        rows_limit: rows_limit
      )

      # TODO: Read as per read state machine
      rows
    end

    private

    # Create or return existing data client object
    # @return [Google::Cloud::Bigtable::V2::BigtableClient]
    def client
      @client ||= Google::Cloud::Bigtable.new(options)
    end

    # Created formatted table path
    # @param table_id [String]
    # @return [String]
    #   Formatted table path
    #   +projects/<project>/instances/<instance>/tables/<table>+
    def table_path table_id
      Google::Cloud::Bigtable::V2::Bigtable.table_path(
        project_id,
        instance_id,
        table_id
      )
    end
  end
end
