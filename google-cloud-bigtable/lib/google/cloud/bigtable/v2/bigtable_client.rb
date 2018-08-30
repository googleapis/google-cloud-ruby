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
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/bigtable/v2/bigtable.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/bigtable/v2/bigtable_pb"
require "google/cloud/bigtable/v2/credentials"

module Google
  module Cloud
    module Bigtable
      module V2
        # Service for reading from and writing to existing Bigtable tables.
        #
        # @!attribute [r] bigtable_stub
        #   @return [Google::Bigtable::V2::Bigtable::Stub]
        class BigtableClient
          # @private
          attr_reader :bigtable_stub

          # The default address of the service.
          SERVICE_ADDRESS = "bigtable.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/bigtable.data",
            "https://www.googleapis.com/auth/bigtable.data.readonly",
            "https://www.googleapis.com/auth/cloud-bigtable.data",
            "https://www.googleapis.com/auth/cloud-bigtable.data.readonly",
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/cloud-platform.read-only"
          ].freeze


          TABLE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/instances/{instance}/tables/{table}"
          )

          private_constant :TABLE_PATH_TEMPLATE

          # Returns a fully-qualified table resource name string.
          # @param project [String]
          # @param instance [String]
          # @param table [String]
          # @return [String]
          def self.table_path project, instance, table
            TABLE_PATH_TEMPLATE.render(
              :"project" => project,
              :"instance" => instance,
              :"table" => table
            )
          end

          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/bigtable/v2/bigtable_services_pb"

            credentials ||= Google::Cloud::Bigtable::V2::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Bigtable::V2::Credentials.new(credentials).updater_proc
            end
            if credentials.is_a?(GRPC::Core::Channel)
              channel = credentials
            end
            if credentials.is_a?(GRPC::Core::ChannelCredentials)
              chan_creds = credentials
            end
            if credentials.is_a?(Proc)
              updater_proc = credentials
            end
            if credentials.is_a?(Google::Auth::Credentials)
              updater_proc = credentials.updater_proc
            end

            package_version = Gem.loaded_specs['google-cloud-bigtable'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "bigtable_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.bigtable.v2.Bigtable",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @bigtable_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Bigtable::V2::Bigtable::Stub.method(:new)
            )

            @read_rows = Google::Gax.create_api_call(
              @bigtable_stub.method(:read_rows),
              defaults["read_rows"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'table_name' => request.table_name}
              end
            )
            @sample_row_keys = Google::Gax.create_api_call(
              @bigtable_stub.method(:sample_row_keys),
              defaults["sample_row_keys"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'table_name' => request.table_name}
              end
            )
            @mutate_row = Google::Gax.create_api_call(
              @bigtable_stub.method(:mutate_row),
              defaults["mutate_row"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'table_name' => request.table_name}
              end
            )
            @mutate_rows = Google::Gax.create_api_call(
              @bigtable_stub.method(:mutate_rows),
              defaults["mutate_rows"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'table_name' => request.table_name}
              end
            )
            @check_and_mutate_row = Google::Gax.create_api_call(
              @bigtable_stub.method(:check_and_mutate_row),
              defaults["check_and_mutate_row"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'table_name' => request.table_name}
              end
            )
            @read_modify_write_row = Google::Gax.create_api_call(
              @bigtable_stub.method(:read_modify_write_row),
              defaults["read_modify_write_row"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'table_name' => request.table_name}
              end
            )
          end

          # Service calls

          # Streams back the contents of all requested rows in key order, optionally
          # applying the same Reader filter to each. Depending on their size,
          # rows and cells may be broken up across multiple responses, but
          # atomicity of each row will still be preserved. See the
          # ReadRowsResponse documentation for details.
          #
          # @param table_name [String]
          #   The unique name of the table from which to read.
          #   Values are of the form
          #   +projects/<project>/instances/<instance>/tables/<table>+.
          # @param app_profile_id [String]
          #   This value specifies routing for replication. If not specified, the
          #   "default" application profile will be used.
          # @param rows [Google::Bigtable::V2::RowSet | Hash]
          #   The row keys and/or ranges to read. If not specified, reads from all rows.
          #   A hash of the same form as `Google::Bigtable::V2::RowSet`
          #   can also be provided.
          # @param filter [Google::Bigtable::V2::RowFilter | Hash]
          #   The filter to apply to the contents of the specified row(s). If unset,
          #   reads the entirety of each row.
          #   A hash of the same form as `Google::Bigtable::V2::RowFilter`
          #   can also be provided.
          # @param rows_limit [Integer]
          #   The read will terminate after committing to N rows' worth of results. The
          #   default (zero) is to return all results.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Bigtable::V2::ReadRowsResponse>]
          #   An enumerable of Google::Bigtable::V2::ReadRowsResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/bigtable/v2"
          #
          #   bigtable_client = Google::Cloud::Bigtable::V2.new
          #   formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
          #   bigtable_client.read_rows(formatted_table_name).each do |element|
          #     # Process element.
          #   end

          def read_rows \
              table_name,
              app_profile_id: nil,
              rows: nil,
              filter: nil,
              rows_limit: nil,
              options: nil
            req = {
              table_name: table_name,
              app_profile_id: app_profile_id,
              rows: rows,
              filter: filter,
              rows_limit: rows_limit
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Bigtable::V2::ReadRowsRequest)
            @read_rows.call(req, options)
          end

          # Returns a sample of row keys in the table. The returned row keys will
          # delimit contiguous sections of the table of approximately equal size,
          # which can be used to break up the data for distributed tasks like
          # mapreduces.
          #
          # @param table_name [String]
          #   The unique name of the table from which to sample row keys.
          #   Values are of the form
          #   +projects/<project>/instances/<instance>/tables/<table>+.
          # @param app_profile_id [String]
          #   This value specifies routing for replication. If not specified, the
          #   "default" application profile will be used.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Bigtable::V2::SampleRowKeysResponse>]
          #   An enumerable of Google::Bigtable::V2::SampleRowKeysResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/bigtable/v2"
          #
          #   bigtable_client = Google::Cloud::Bigtable::V2.new
          #   formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
          #   bigtable_client.sample_row_keys(formatted_table_name).each do |element|
          #     # Process element.
          #   end

          def sample_row_keys \
              table_name,
              app_profile_id: nil,
              options: nil
            req = {
              table_name: table_name,
              app_profile_id: app_profile_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Bigtable::V2::SampleRowKeysRequest)
            @sample_row_keys.call(req, options)
          end

          # Mutates a row atomically. Cells already present in the row are left
          # unchanged unless explicitly changed by +mutation+.
          #
          # @param table_name [String]
          #   The unique name of the table to which the mutation should be applied.
          #   Values are of the form
          #   +projects/<project>/instances/<instance>/tables/<table>+.
          # @param row_key [String]
          #   The key of the row to which the mutation should be applied.
          # @param mutations [Array<Google::Bigtable::V2::Mutation | Hash>]
          #   Changes to be atomically applied to the specified row. Entries are applied
          #   in order, meaning that earlier mutations can be masked by later ones.
          #   Must contain at least one entry and at most 100000.
          #   A hash of the same form as `Google::Bigtable::V2::Mutation`
          #   can also be provided.
          # @param app_profile_id [String]
          #   This value specifies routing for replication. If not specified, the
          #   "default" application profile will be used.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Bigtable::V2::MutateRowResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Bigtable::V2::MutateRowResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/bigtable/v2"
          #
          #   bigtable_client = Google::Cloud::Bigtable::V2.new
          #   formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
          #
          #   # TODO: Initialize +row_key+:
          #   row_key = ''
          #
          #   # TODO: Initialize +mutations+:
          #   mutations = []
          #   response = bigtable_client.mutate_row(formatted_table_name, row_key, mutations)

          def mutate_row \
              table_name,
              row_key,
              mutations,
              app_profile_id: nil,
              options: nil,
              &block
            req = {
              table_name: table_name,
              row_key: row_key,
              mutations: mutations,
              app_profile_id: app_profile_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Bigtable::V2::MutateRowRequest)
            @mutate_row.call(req, options, &block)
          end

          # Mutates multiple rows in a batch. Each individual row is mutated
          # atomically as in MutateRow, but the entire batch is not executed
          # atomically.
          #
          # @param table_name [String]
          #   The unique name of the table to which the mutations should be applied.
          # @param entries [Array<Google::Bigtable::V2::MutateRowsRequest::Entry | Hash>]
          #   The row keys and corresponding mutations to be applied in bulk.
          #   Each entry is applied as an atomic mutation, but the entries may be
          #   applied in arbitrary order (even between entries for the same row).
          #   At least one entry must be specified, and in total the entries can
          #   contain at most 100000 mutations.
          #   A hash of the same form as `Google::Bigtable::V2::MutateRowsRequest::Entry`
          #   can also be provided.
          # @param app_profile_id [String]
          #   This value specifies routing for replication. If not specified, the
          #   "default" application profile will be used.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Enumerable<Google::Bigtable::V2::MutateRowsResponse>]
          #   An enumerable of Google::Bigtable::V2::MutateRowsResponse instances.
          #
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/bigtable/v2"
          #
          #   bigtable_client = Google::Cloud::Bigtable::V2.new
          #   formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
          #
          #   # TODO: Initialize +entries+:
          #   entries = []
          #   bigtable_client.mutate_rows(formatted_table_name, entries).each do |element|
          #     # Process element.
          #   end

          def mutate_rows \
              table_name,
              entries,
              app_profile_id: nil,
              options: nil
            req = {
              table_name: table_name,
              entries: entries,
              app_profile_id: app_profile_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Bigtable::V2::MutateRowsRequest)
            @mutate_rows.call(req, options)
          end

          # Mutates a row atomically based on the output of a predicate Reader filter.
          #
          # @param table_name [String]
          #   The unique name of the table to which the conditional mutation should be
          #   applied.
          #   Values are of the form
          #   +projects/<project>/instances/<instance>/tables/<table>+.
          # @param row_key [String]
          #   The key of the row to which the conditional mutation should be applied.
          # @param app_profile_id [String]
          #   This value specifies routing for replication. If not specified, the
          #   "default" application profile will be used.
          # @param predicate_filter [Google::Bigtable::V2::RowFilter | Hash]
          #   The filter to be applied to the contents of the specified row. Depending
          #   on whether or not any results are yielded, either +true_mutations+ or
          #   +false_mutations+ will be executed. If unset, checks that the row contains
          #   any values at all.
          #   A hash of the same form as `Google::Bigtable::V2::RowFilter`
          #   can also be provided.
          # @param true_mutations [Array<Google::Bigtable::V2::Mutation | Hash>]
          #   Changes to be atomically applied to the specified row if +predicate_filter+
          #   yields at least one cell when applied to +row_key+. Entries are applied in
          #   order, meaning that earlier mutations can be masked by later ones.
          #   Must contain at least one entry if +false_mutations+ is empty, and at most
          #   100000.
          #   A hash of the same form as `Google::Bigtable::V2::Mutation`
          #   can also be provided.
          # @param false_mutations [Array<Google::Bigtable::V2::Mutation | Hash>]
          #   Changes to be atomically applied to the specified row if +predicate_filter+
          #   does not yield any cells when applied to +row_key+. Entries are applied in
          #   order, meaning that earlier mutations can be masked by later ones.
          #   Must contain at least one entry if +true_mutations+ is empty, and at most
          #   100000.
          #   A hash of the same form as `Google::Bigtable::V2::Mutation`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Bigtable::V2::CheckAndMutateRowResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Bigtable::V2::CheckAndMutateRowResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/bigtable/v2"
          #
          #   bigtable_client = Google::Cloud::Bigtable::V2.new
          #   formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
          #
          #   # TODO: Initialize +row_key+:
          #   row_key = ''
          #   response = bigtable_client.check_and_mutate_row(formatted_table_name, row_key)

          def check_and_mutate_row \
              table_name,
              row_key,
              app_profile_id: nil,
              predicate_filter: nil,
              true_mutations: nil,
              false_mutations: nil,
              options: nil,
              &block
            req = {
              table_name: table_name,
              row_key: row_key,
              app_profile_id: app_profile_id,
              predicate_filter: predicate_filter,
              true_mutations: true_mutations,
              false_mutations: false_mutations
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Bigtable::V2::CheckAndMutateRowRequest)
            @check_and_mutate_row.call(req, options, &block)
          end

          # Modifies a row atomically on the server. The method reads the latest
          # existing timestamp and value from the specified columns and writes a new
          # entry based on pre-defined read/modify/write rules. The new value for the
          # timestamp is the greater of the existing timestamp or the current server
          # time. The method returns the new contents of all modified cells.
          #
          # @param table_name [String]
          #   The unique name of the table to which the read/modify/write rules should be
          #   applied.
          #   Values are of the form
          #   +projects/<project>/instances/<instance>/tables/<table>+.
          # @param row_key [String]
          #   The key of the row to which the read/modify/write rules should be applied.
          # @param rules [Array<Google::Bigtable::V2::ReadModifyWriteRule | Hash>]
          #   Rules specifying how the specified row's contents are to be transformed
          #   into writes. Entries are applied in order, meaning that earlier rules will
          #   affect the results of later ones.
          #   A hash of the same form as `Google::Bigtable::V2::ReadModifyWriteRule`
          #   can also be provided.
          # @param app_profile_id [String]
          #   This value specifies routing for replication. If not specified, the
          #   "default" application profile will be used.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Bigtable::V2::ReadModifyWriteRowResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Bigtable::V2::ReadModifyWriteRowResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/bigtable/v2"
          #
          #   bigtable_client = Google::Cloud::Bigtable::V2.new
          #   formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
          #
          #   # TODO: Initialize +row_key+:
          #   row_key = ''
          #
          #   # TODO: Initialize +rules+:
          #   rules = []
          #   response = bigtable_client.read_modify_write_row(formatted_table_name, row_key, rules)

          def read_modify_write_row \
              table_name,
              row_key,
              rules,
              app_profile_id: nil,
              options: nil,
              &block
            req = {
              table_name: table_name,
              row_key: row_key,
              rules: rules,
              app_profile_id: app_profile_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Bigtable::V2::ReadModifyWriteRowRequest)
            @read_modify_write_row.call(req, options, &block)
          end
        end
      end
    end
  end
end
