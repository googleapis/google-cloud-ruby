# Generated protos live here
$LOAD_PATH << File.join(__dir__, "proto")

require "grpc"
require "google/cloud/bigtable"
require "logger"

require "google/bigtable/testproxy/test_proxy_services_pb"

LOGGER = Logger.new $stderr, level: Logger::DEBUG

# Injected into GRPC to enable additional logging
module ProxyLogger
  def logger
    LOGGER
  end
end

# Define a gRPC module-level logger method before grpc/logconfig.rb loads.
module GRPC
  extend ProxyLogger
end

# Helper method to provide feedback for future devs trying to maintain this file.
# Generally we can't rely on the type system to fail fast when arguments are invalid
# so we'll add some simple assertions to help out.
def assert condition, what
  return if condition
  abort "DEBUG ASSERTION FAILED: #{what}"
end

# Implements a proxy per https://github.com/googleapis/cloud-bigtable-clients-test/blob/main/docs/test_proxy.md#
# for client conformance testing.
class TestProxyServer < Google::Bigtable::Testproxy::CloudBigtableV2TestProxy::Service
  # Client provides class-level get, create and remove methods for managing client
  # connections in a thread-safe manner, per
  # https://github.com/googleapis/cloud-bigtable-clients-test/blob/main/docs/test_proxy.md#additional-notes
  class Client
    @clients = {}
    @clients_lock = Mutex.new

    def self.get id
      @clients.fetch id
    end

    def self.create req
      id = req.client_id
      @clients_lock.synchronize do
        # No tests should intentionally hit this, if we do it's our bug.
        assert(!@clients.key?(id), "Client #{id} already exists in Client#create")
        @clients[id] = new(**req.to_h)
      end
    end

    def self.remove id
      @clients_lock.synchronize do
        assert(@clients.key?(id), "Client #{id} didn't exist in Client#remove()")
        @clients.delete id
      end
    end

    def close
      # no-op?
      # There appears to be no way to tell Bigtable to close whatever underlying connections it has
    end

    def table name
      assert(
        name[%r{\Aprojects/[a-z]+/instances/[a-z]+/tables/[a-z]+\z}],
        "The `name` argument to Client#table should be in the form \"projects/X/instances/Y/tables/Z\""
      )

      @bigtable.table instance_id, name.split("/").last, app_profile_id: app_profile_id
    end

    attr_reader :timeout

    private

    attr_accessor :instance_id
    attr_accessor :app_profile_id

    def initialize client_id:, data_target:, project_id:, instance_id:,
                   app_profile_id: nil,
                   per_operation_timeout: nil,
                   optional_feature_config: :OPTIONAL_FEATURE_CONFIG_DEFAULT

      LOGGER.debug "Building client #{client_id}"

      # Every test uses these values
      assert project_id == "project", "Unxpected value for `project`"
      assert instance_id == "instance", "Unexpected value for `instance`"

      # Used later in Client#table
      self.instance_id = instance_id
      self.app_profile_id = app_profile_id

      @timeout = per_operation_timeout[:seconds].to_i if per_operation_timeout

      # At time of writing, the only value ever supplied here OPTIONAL_FEATURE_CONFIG_DEFAULT
      assert optional_feature_config == :OPTIONAL_FEATURE_CONFIG_DEFAULT,
             "optional_feature_config was set to an unexpected value"

      @bigtable = connect project_id, data_target
    end

    def connect project_id, data_target
      args = {
        project_id: project_id,
        timeout: @timeout
      }.compact

      if data_target == "emulator"
        args[:emulator_host] = ENV.fetch("BIGTABLE_EMULATOR_HOST")
      else
        args[:endpoint] = data_target
        args[:credentials] = GRPC::Core::Channel.new data_target, nil, :this_channel_is_insecure
      end

      Google::Cloud::Bigtable.new(**args)
    end
  end

  # Creates a client in the proxy.
  # Each client has its own dedicated channel(s), and can be used concurrently
  # and independently with other clients.
  def create_client req, _call
    LOGGER.info "CreateClient(#{req.to_h})"
    Client.create req
    Google::Bigtable::Testproxy::CreateClientResponse.new
  end

  # Closes a client in the proxy, making it not accept new requests.
  def close_client req, _call
    LOGGER.info "CloseClient(#{req.to_h})"
    Client.get(req.client_id).close
    Google::Bigtable::Testproxy::CloseClientResponse.new
  end

  # Removes a client in the proxy, making it inaccessible. Client closing
  # should be done by CloseClient() separately.
  def remove_client req, _call
    LOGGER.info "RemoveClient(#{req.to_h})"
    Client.remove req.client_id
    Google::Bigtable::Testproxy::RemoveClientResponse.new
  end

  # Reads a row with the client instance.
  # The result row may not be present in the response.
  # Callers should check for it (e.g. calling has_row() in C++).
  # rpc ReadRow(ReadRowRequest) returns (RowResult) {}
  def read_row req, _call
    LOGGER.info "ReadRow(#{req.to_h})"

    result = Client.get(req.client_id)
                   .table(req.table_name)
                   .read_row(req.row_key)

    Google::Bigtable::Testproxy::RowResult.new(
      status: ok_status,
      row: result.nil? ? Google::Cloud::Bigtable::V2::Row.new(key: req.row_key) : row_to_v2_row(result)
    )
  rescue Google::Cloud::Error => e
    LOGGER.info "ReadRow failed: Caught #{e}"
    abort "Unexpected codepath reached, populate the error handler for ReadRow"
  end

  # Reads rows with the client instance.
  # rpc ReadRow(ReadRowRequest) returns (RowResult) {}
  # rubocop:disable Metrics/AbcSize
  def read_rows req, _call
    LOGGER.info "ReadRows(#{req.to_h})"

    # At the time of writing, no tests set this field; rather than guess at an implementation,
    # this is a note for future maintainers to implement this if the field becomes set in the test suite
    assert req.request.app_profile_id == "", "An app profile ID was specified when non was expected"

    # TODO: req.request.reverse is not supported by the client library; when it is, fix this
    table = Client.get(req.client_id)
                   .table(req.request.table_name)


    options = {
      keys: req.request&.rows&.row_keys&.to_a,
      limit: req.request.rows_limit
    }

    if req.request.rows&.row_ranges&.any?
      options[:ranges] = req.request.rows.row_ranges.map do |r|
        range = table.new_row_range
        if r.start_key_closed
          range = range.from(r.start_key_closed, inclusive: true)
        elsif r.start_key_open
          range = range.from(r.start_key_open, inclusive: false)
        end

        if r.end_key_closed
          range = range.to(r.end_key_closed, inclusive: true)
        elsif r.end_key_open
          range = range.to(r.end_key_open, inclusive: false)
        end

        range
      end
    end

    result = table.read_rows(**options)

    result = result.to_a

    if result.any?
      Google::Bigtable::Testproxy::RowsResult.new(
        # The status is not available from the Ruby client library, so just assumed "ok"
        status: ok_status,
        rows: result.map { |row| row_to_v2_row(row) }
      )
    else
      # TODO(meagar): Is this the right response?
      #   It seems to allow the tests to pass...
      Google::Bigtable::Testproxy::RowsResult.new(
        status: not_found_status
      )
    end
  rescue Google::Cloud::Error => e
    LOGGER.info "ReadRows failed: Caught #{e}"
    Google::Bigtable::Testproxy::RowsResult.new(
      status: make_status(e.code, e.message)
    )
  end
  # rubocop:enable Metrics/AbcSize

  # Writes a row with the client instance.
  # rpc MutateRow(MutateRowRequest) returns (MutateRowResult) {}
  def mutate_row req, _call
    LOGGER.info "MutateRow(#{req.to_h})"

    table = Client.get(req.client_id)
                  .table(req.request.table_name)

    entry = entry_to_v2_entry table, req.request.row_key, req.request.mutations

    table.mutate_row entry

    Google::Bigtable::Testproxy::MutateRowResult.new(
      status: ok_status
    )
  rescue Google::Cloud::Error => e
    LOGGER.info "MutateRow failed: Caught #{e}"
    # At the time of writing, no tests executed this code path. Rather than guess at an implementation,
    # this is a note for future maintainers that you should populate this error handler.
    abort "Unexpected codepath reached, populate the error handler for MutateRow"
  end

  # Writes multiple rows with the client instance.
  # rpc BulkMutateRows(MutateRowsRequest) returns (MutateRowsResult) {}
  # rubocop:disable Metrics/AbcSize
  def bulk_mutate_rows req, _call
    LOGGER.info "BulkMutateRows(#{req.to_h}"

    table = Client.get(req.client_id)
                  .table(req.request.table_name)

    entries = req.request.entries.map do |entry|
      entry_to_v2_entry table, entry.row_key, entry.mutations
    end

    results = table.mutate_rows entries

    Google::Bigtable::Testproxy::MutateRowsResult.new(
      status: ok_status,
      # Entries should include only the failed rows, where status != 0 (OK)
      entries: results.reject { |r| r.status.code.zero? }.map do |result|
        Google::Cloud::Bigtable::V2::MutateRowsResponse::Entry.new(
          index: result.index,
          status: Google::Rpc::Status.new(
            code: result.status.code,
            message: result.status.message
          )
        )
      end
    )
  rescue Google::Cloud::Error => e
    LOGGER.info "BulkMutateRows failed: Caught #{e}"
    # At the time of writing, no tests executed this code path. Rather than guess at an implementation,
    # this is a note for future maintainers that you should populate this error handler.
    abort "Unexpected codepath reached, populate the error handler for BulkMutateRows"
  end
  # rubocop:enable Metrics/AbcSize

  # Performs a check-and-mutate-row operation with the client instance.
  # rpc CheckAndMutateRow(CheckAndMutateRowRequest) returns (CheckAndMutateRowResult) {}
  # rubocop:disable Metrics/AbcSize
  def check_and_mutate_row req, _call
    LOGGER.info "CheckAndMutateRow(#{req.to_h})"

    table = Client.get(req.client_id).table(req.request.table_name)

    result = table.check_and_mutate_row(
      req.request.row_key,
      build_predicate_filter(req.request),
      on_match: entry_to_v2_entry(table, req.request.row_key, req.request.true_mutations),
      otherwise: entry_to_v2_entry(table, req.request.row_key, req.request.false_mutations)
    )

    Google::Bigtable::Testproxy::CheckAndMutateRowResult.new(
      status: ok_status,
      result: Google::Cloud::Bigtable::V2::CheckAndMutateRowResponse.new(
        predicate_matched: result
      )
    )
  rescue Google::Cloud::Error => e
    LOGGER.info "CheckAndMutateRow failed: Caught #{e}"
    Google::Bigtable::Testproxy::CheckAndMutateRowResult.new(
      status: make_status(e.code)
    )
  end
  # rubocop:enable Metrics/AbcSize

  def build_predicate_filter request
    return unless request.predicate_filter

    # At the time of writing, no tests seem to actually supply complex predicates,
    # if they stat to do so, update this
    # Google::Cloud::Bigtable::RowFilter.chain
    #   .family(column_family)
    #   .qualifier(qualifer)
    #   .value(value)

    Google::Cloud::Bigtable::RowFilter.pass
  end

  # Obtains a row key sampling with the client instance.
  # rpc SampleRowKeys(SampleRowKeysRequest) returns (SampleRowKeysResult) {}
  def sample_row_keys req, _call
    LOGGER.info "SampleRowKeys(#{req.to_h})"

    table = Client.get(req.client_id).table(req.request.table_name)
    result = table.sample_row_keys

    Google::Bigtable::Testproxy::SampleRowKeysResult.new(
      status: ok_status,
      samples: result.map do |sample|
        Google::Cloud::Bigtable::V2::SampleRowKeysResponse.new(
          row_key: sample.key,
          offset_bytes: sample.offset
        )
      end
    )
  rescue Google::Cloud::Error => e
    LOGGER.info "SampleRowKeys failed: Caught #{e}"
    # At the time of writing, no tests executed this code path. Rather than guess at an implementation,
    # this is a note for future maintainers that you should populate this error handler.
    abort "Unexpected codepath reached, populate the error handler for SampleRowKeys"
  end

  # Performs a read-modify-write operation with the client.
  # rpc ReadModifyWriteRow(ReadModifyWriteRowRequest) returns (RowResult) {}
  # rubocop:disable Metrics/AbcSize
  def read_modify_write_row req, _call
    LOGGER.info "ReadModifyWriteRow(#{req.to_h})"

    table = Client.get(req.client_id).table(req.request.table_name)

    result = table.read_modify_write_row(req.request.row_key, req.request.rules.map do |r|
      rule = Google::Cloud::Bigtable::ReadModifyWriteRule.new r.family_name, r.column_qualifier
      rule.append r.append_value if r.append_value && r.append_value != ""
      rule.increment r.increment_amount if r.increment_amount&.positive?
      rule
    end)

    Google::Bigtable::Testproxy::RowResult.new(
      # The status is not available from the Ruby client library
      status: ok_status,
      row: row_to_v2_row(result)
    )
  rescue Google::Cloud::Error => e
    Google::Bigtable::Testproxy::RowResult.new(
      status: make_status(e.code)
    )
  end
  # rubocop:enable Metrics/AbcSize

  # Executes a query with the client.
  # rpc ExecuteQuery(ExecuteQueryRequest) returns (ExecuteQueryResult) {}
  def execute_query req, _call
    LOGGER.info "ExecuteQuery(#{req.to_h})"
    # The handwritten client appears not to implement queries. We'll reflect
    # that for now.
    Google::Bigtable::Testproxy::ExecuteQueryResult.new status: unimplemented_status
  end

  private

  def row_to_v2_row row
    families = row.cells.map do |family_name, cells|
      Google::Cloud::Bigtable::V2::Family.new(
        name: family_name,
        columns: cells.map do |cell|
          Google::Cloud::Bigtable::V2::Column.new(
            qualifier: cell.qualifier,
            cells: [Google::Cloud::Bigtable::V2::Cell.new(
              # labels: cell.labels,
              timestamp_micros: cell.timestamp,
              value: cell.value
            )]
          )
        end
      )
    end

    Google::Cloud::Bigtable::V2::Row.new key: row.key, families: families
  end

  def entry_to_v2_entry table, row_key, mutations
    entry = table.new_mutation_entry row_key

    mutations.each do |m|
      if m.set_cell
        entry = entry.set_cell(
          m.set_cell.family_name,
          m.set_cell.column_qualifier,
          m.set_cell.value,
          timestamp: m.set_cell.timestamp_micros
        )
      end

      # At the time of writing, no tests set any of these fields. Rather than guessing at an
      # implementation, this is a note for future maintainers to implement logic for these fields,
      # should any test start to set them.
      assert m.add_to_cell.nil?, "No test sets add_to_cell, if this changes, fix entry_to_v2_entry"
      assert m.delete_from_column.nil?, "No test sets delete_from_column, if this changes, fix entry_to_v2_entry"
      assert m.delete_from_family.nil?, "No test sets delete_from_family, if this changes, fix entry_to_v2_entry"
      assert m.delete_from_row.nil?, "No test sets delete_from_row, if this changes, fix entry_to_v2_entry"
    end

    entry
  end

  def make_status code, message = ""
    Google::Rpc::Status.new code: code, message: message
  end

  def ok_status message = ""
    make_status Google::Rpc::Code::OK, message
  end

  def not_found_status message = ""
    make_status Google::Rpc::Code::NOT_FOUND, message
  end

  def unimplemented_status message = ""
    make_status Google::Rpc::Code::UNIMPLEMENTED, message
  end
end

port = ENV.fetch "PORT", "9999"
addr = "0.0.0.0:#{port}"

puts "Starting server on #{addr}"
server = GRPC::RpcServer.new
server.add_http2_port addr, :this_port_is_insecure
server.handle TestProxyServer
puts "SERVER STARTED"
server.run_till_terminated_or_interrupted [1, "int", "SIGTERM"]
puts "SERVER STOPPED"
