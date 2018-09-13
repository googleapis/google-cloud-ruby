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
# https://github.com/googleapis/googleapis/blob/master/google/spanner/admin/database/v1/spanner_database_admin.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/spanner/admin/database/v1/spanner_database_admin_pb"
require "google/cloud/spanner/admin/database/v1/credentials"

module Google
  module Cloud
    module Spanner
      module Admin
        module Database
          module V1
            # Cloud Spanner Database Admin API
            #
            # The Cloud Spanner Database Admin API can be used to create, drop, and
            # list databases. It also enables updating the schema of pre-existing
            # databases.
            #
            # @!attribute [r] database_admin_stub
            #   @return [Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub]
            class DatabaseAdminClient
              # @private
              attr_reader :database_admin_stub

              # The default address of the service.
              SERVICE_ADDRESS = "spanner.googleapis.com".freeze

              # The default port of the service.
              DEFAULT_SERVICE_PORT = 443

              # The default set of gRPC interceptors.
              GRPC_INTERCEPTORS = []

              DEFAULT_TIMEOUT = 30

              PAGE_DESCRIPTORS = {
                "list_databases" => Google::Gax::PageDescriptor.new(
                  "page_token",
                  "next_page_token",
                  "databases")
              }.freeze

              private_constant :PAGE_DESCRIPTORS

              # The scopes needed to make gRPC calls to all of the methods defined in
              # this service.
              ALL_SCOPES = [
                "https://www.googleapis.com/auth/cloud-platform",
                "https://www.googleapis.com/auth/spanner.admin"
              ].freeze

              # @private
              class OperationsClient < Google::Longrunning::OperationsClient
                self::SERVICE_ADDRESS = DatabaseAdminClient::SERVICE_ADDRESS
                self::GRPC_INTERCEPTORS = DatabaseAdminClient::GRPC_INTERCEPTORS
              end

              INSTANCE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
                "projects/{project}/instances/{instance}"
              )

              private_constant :INSTANCE_PATH_TEMPLATE

              DATABASE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
                "projects/{project}/instances/{instance}/databases/{database}"
              )

              private_constant :DATABASE_PATH_TEMPLATE

              # Returns a fully-qualified instance resource name string.
              # @param project [String]
              # @param instance [String]
              # @return [String]
              def self.instance_path project, instance
                INSTANCE_PATH_TEMPLATE.render(
                  :"project" => project,
                  :"instance" => instance
                )
              end

              # Returns a fully-qualified database resource name string.
              # @param project [String]
              # @param instance [String]
              # @param database [String]
              # @return [String]
              def self.database_path project, instance, database
                DATABASE_PATH_TEMPLATE.render(
                  :"project" => project,
                  :"instance" => instance,
                  :"database" => database
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
                require "google/spanner/admin/database/v1/spanner_database_admin_services_pb"

                credentials ||= Google::Cloud::Spanner::Admin::Database::V1::Credentials.default

                @operations_client = OperationsClient.new(
                  credentials: credentials,
                  scopes: scopes,
                  client_config: client_config,
                  timeout: timeout,
                  lib_name: lib_name,
                  lib_version: lib_version,
                )

                if credentials.is_a?(String) || credentials.is_a?(Hash)
                  updater_proc = Google::Cloud::Spanner::Admin::Database::V1::Credentials.new(credentials).updater_proc
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

                package_version = Gem.loaded_specs['google-cloud-spanner'].version.version

                google_api_client = "gl-ruby/#{RUBY_VERSION}"
                google_api_client << " #{lib_name}/#{lib_version}" if lib_name
                google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
                google_api_client << " grpc/#{GRPC::VERSION}"
                google_api_client.freeze

                headers = { :"x-goog-api-client" => google_api_client }
                headers.merge!(metadata) unless metadata.nil?
                client_config_file = Pathname.new(__dir__).join(
                  "database_admin_client_config.json"
                )
                defaults = client_config_file.open do |f|
                  Google::Gax.construct_settings(
                    "google.spanner.admin.database.v1.DatabaseAdmin",
                    JSON.parse(f.read),
                    client_config,
                    Google::Gax::Grpc::STATUS_CODE_NAMES,
                    timeout,
                    page_descriptors: PAGE_DESCRIPTORS,
                    errors: Google::Gax::Grpc::API_ERRORS,
                    metadata: headers
                  )
                end

                # Allow overriding the service path/port in subclasses.
                service_path = self.class::SERVICE_ADDRESS
                port = self.class::DEFAULT_SERVICE_PORT
                interceptors = self.class::GRPC_INTERCEPTORS
                @database_admin_stub = Google::Gax::Grpc.create_stub(
                  service_path,
                  port,
                  chan_creds: chan_creds,
                  channel: channel,
                  updater_proc: updater_proc,
                  scopes: scopes,
                  interceptors: interceptors,
                  &Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.method(:new)
                )

                @list_databases = Google::Gax.create_api_call(
                  @database_admin_stub.method(:list_databases),
                  defaults["list_databases"],
                  exception_transformer: exception_transformer
                )
                @create_database = Google::Gax.create_api_call(
                  @database_admin_stub.method(:create_database),
                  defaults["create_database"],
                  exception_transformer: exception_transformer
                )
                @get_database = Google::Gax.create_api_call(
                  @database_admin_stub.method(:get_database),
                  defaults["get_database"],
                  exception_transformer: exception_transformer
                )
                @update_database_ddl = Google::Gax.create_api_call(
                  @database_admin_stub.method(:update_database_ddl),
                  defaults["update_database_ddl"],
                  exception_transformer: exception_transformer
                )
                @drop_database = Google::Gax.create_api_call(
                  @database_admin_stub.method(:drop_database),
                  defaults["drop_database"],
                  exception_transformer: exception_transformer
                )
                @get_database_ddl = Google::Gax.create_api_call(
                  @database_admin_stub.method(:get_database_ddl),
                  defaults["get_database_ddl"],
                  exception_transformer: exception_transformer
                )
                @set_iam_policy = Google::Gax.create_api_call(
                  @database_admin_stub.method(:set_iam_policy),
                  defaults["set_iam_policy"],
                  exception_transformer: exception_transformer
                )
                @get_iam_policy = Google::Gax.create_api_call(
                  @database_admin_stub.method(:get_iam_policy),
                  defaults["get_iam_policy"],
                  exception_transformer: exception_transformer
                )
                @test_iam_permissions = Google::Gax.create_api_call(
                  @database_admin_stub.method(:test_iam_permissions),
                  defaults["test_iam_permissions"],
                  exception_transformer: exception_transformer
                )
              end

              # Service calls

              # Lists Cloud Spanner databases.
              #
              # @param parent [String]
              #   Required. The instance whose databases should be listed.
              #   Values are of the form `projects/<project>/instances/<instance>`.
              # @param page_size [Integer]
              #   The maximum number of resources contained in the underlying API
              #   response. If page streaming is performed per-resource, this
              #   parameter does not affect the return value. If page streaming is
              #   performed per-page, this determines the maximum number of
              #   resources in a page.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @yield [result, operation] Access the result along with the RPC operation
              # @yieldparam result [Google::Gax::PagedEnumerable<Google::Spanner::Admin::Database::V1::Database>]
              # @yieldparam operation [GRPC::ActiveCall::Operation]
              # @return [Google::Gax::PagedEnumerable<Google::Spanner::Admin::Database::V1::Database>]
              #   An enumerable of Google::Spanner::Admin::Database::V1::Database instances.
              #   See Google::Gax::PagedEnumerable documentation for other
              #   operations such as per-page iteration or access to the response
              #   object.
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/database"
              #
              #   database_admin_client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)
              #   formatted_parent = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
              #
              #   # Iterate over all results.
              #   database_admin_client.list_databases(formatted_parent).each do |element|
              #     # Process element.
              #   end
              #
              #   # Or iterate over results one page at a time.
              #   database_admin_client.list_databases(formatted_parent).each_page do |page|
              #     # Process each page at a time.
              #     page.each do |element|
              #       # Process element.
              #     end
              #   end

              def list_databases \
                  parent,
                  page_size: nil,
                  options: nil,
                  &block
                req = {
                  parent: parent,
                  page_size: page_size
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Database::V1::ListDatabasesRequest)
                @list_databases.call(req, options, &block)
              end

              # Creates a new Cloud Spanner database and starts to prepare it for serving.
              # The returned {Google::Longrunning::Operation long-running operation} will
              # have a name of the format `<database_name>/operations/<operation_id>` and
              # can be used to track preparation of the database. The
              # {Google::Longrunning::Operation#metadata metadata} field type is
              # {Google::Spanner::Admin::Database::V1::CreateDatabaseMetadata CreateDatabaseMetadata}. The
              # {Google::Longrunning::Operation#response response} field type is
              # {Google::Spanner::Admin::Database::V1::Database Database}, if successful.
              #
              # @param parent [String]
              #   Required. The name of the instance that will serve the new database.
              #   Values are of the form `projects/<project>/instances/<instance>`.
              # @param create_statement [String]
              #   Required. A `CREATE DATABASE` statement, which specifies the ID of the
              #   new database.  The database ID must conform to the regular expression
              #   `[a-z][a-z0-9_\-]*[a-z0-9]` and be between 2 and 30 characters in length.
              #   If the database ID is a reserved word or if it contains a hyphen, the
              #   database ID must be enclosed in backticks (`` ` ``).
              # @param extra_statements [Array<String>]
              #   An optional list of DDL statements to run inside the newly created
              #   database. Statements can create tables, indexes, etc. These
              #   statements execute atomically with the creation of the database:
              #   if there is an error in any statement, the database is not created.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Gax::Operation]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/database"
              #
              #   database_admin_client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)
              #   formatted_parent = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
              #
              #   # TODO: Initialize `create_statement`:
              #   create_statement = ''
              #
              #   # Register a callback during the method call.
              #   operation = database_admin_client.create_database(formatted_parent, create_statement) do |op|
              #     raise op.results.message if op.error?
              #     op_results = op.results
              #     # Process the results.
              #
              #     metadata = op.metadata
              #     # Process the metadata.
              #   end
              #
              #   # Or use the return value to register a callback.
              #   operation.on_done do |op|
              #     raise op.results.message if op.error?
              #     op_results = op.results
              #     # Process the results.
              #
              #     metadata = op.metadata
              #     # Process the metadata.
              #   end
              #
              #   # Manually reload the operation.
              #   operation.reload!
              #
              #   # Or block until the operation completes, triggering callbacks on
              #   # completion.
              #   operation.wait_until_done!

              def create_database \
                  parent,
                  create_statement,
                  extra_statements: nil,
                  options: nil
                req = {
                  parent: parent,
                  create_statement: create_statement,
                  extra_statements: extra_statements
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Database::V1::CreateDatabaseRequest)
                operation = Google::Gax::Operation.new(
                  @create_database.call(req, options),
                  @operations_client,
                  Google::Spanner::Admin::Database::V1::Database,
                  Google::Spanner::Admin::Database::V1::CreateDatabaseMetadata,
                  call_options: options
                )
                operation.on_done { |operation| yield(operation) } if block_given?
                operation
              end

              # Gets the state of a Cloud Spanner database.
              #
              # @param name [String]
              #   Required. The name of the requested database. Values are of the form
              #   `projects/<project>/instances/<instance>/databases/<database>`.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @yield [result, operation] Access the result along with the RPC operation
              # @yieldparam result [Google::Spanner::Admin::Database::V1::Database]
              # @yieldparam operation [GRPC::ActiveCall::Operation]
              # @return [Google::Spanner::Admin::Database::V1::Database]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/database"
              #
              #   database_admin_client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)
              #   formatted_name = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
              #   response = database_admin_client.get_database(formatted_name)

              def get_database \
                  name,
                  options: nil,
                  &block
                req = {
                  name: name
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Database::V1::GetDatabaseRequest)
                @get_database.call(req, options, &block)
              end

              # Updates the schema of a Cloud Spanner database by
              # creating/altering/dropping tables, columns, indexes, etc. The returned
              # {Google::Longrunning::Operation long-running operation} will have a name of
              # the format `<database_name>/operations/<operation_id>` and can be used to
              # track execution of the schema change(s). The
              # {Google::Longrunning::Operation#metadata metadata} field type is
              # {Google::Spanner::Admin::Database::V1::UpdateDatabaseDdlMetadata UpdateDatabaseDdlMetadata}.  The operation has no response.
              #
              # @param database [String]
              #   Required. The database to update.
              # @param statements [Array<String>]
              #   DDL statements to be applied to the database.
              # @param operation_id [String]
              #   If empty, the new update request is assigned an
              #   automatically-generated operation ID. Otherwise, `operation_id`
              #   is used to construct the name of the resulting
              #   {Google::Longrunning::Operation Operation}.
              #
              #   Specifying an explicit operation ID simplifies determining
              #   whether the statements were executed in the event that the
              #   {Google::Spanner::Admin::Database::V1::DatabaseAdmin::UpdateDatabaseDdl UpdateDatabaseDdl} call is replayed,
              #   or the return value is otherwise lost: the {Google::Spanner::Admin::Database::V1::UpdateDatabaseDdlRequest#database database} and
              #   `operation_id` fields can be combined to form the
              #   {Google::Longrunning::Operation#name name} of the resulting
              #   {Google::Longrunning::Operation longrunning::Operation}: `<database>/operations/<operation_id>`.
              #
              #   `operation_id` should be unique within the database, and must be
              #   a valid identifier: `[a-z][a-z0-9_]*`. Note that
              #   automatically-generated operation IDs always begin with an
              #   underscore. If the named operation already exists,
              #   {Google::Spanner::Admin::Database::V1::DatabaseAdmin::UpdateDatabaseDdl UpdateDatabaseDdl} returns
              #   `ALREADY_EXISTS`.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Gax::Operation]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/database"
              #
              #   database_admin_client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)
              #   formatted_database = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
              #
              #   # TODO: Initialize `statements`:
              #   statements = []
              #
              #   # Register a callback during the method call.
              #   operation = database_admin_client.update_database_ddl(formatted_database, statements) do |op|
              #     raise op.results.message if op.error?
              #     op_results = op.results
              #     # Process the results.
              #
              #     metadata = op.metadata
              #     # Process the metadata.
              #   end
              #
              #   # Or use the return value to register a callback.
              #   operation.on_done do |op|
              #     raise op.results.message if op.error?
              #     op_results = op.results
              #     # Process the results.
              #
              #     metadata = op.metadata
              #     # Process the metadata.
              #   end
              #
              #   # Manually reload the operation.
              #   operation.reload!
              #
              #   # Or block until the operation completes, triggering callbacks on
              #   # completion.
              #   operation.wait_until_done!

              def update_database_ddl \
                  database,
                  statements,
                  operation_id: nil,
                  options: nil
                req = {
                  database: database,
                  statements: statements,
                  operation_id: operation_id
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Database::V1::UpdateDatabaseDdlRequest)
                operation = Google::Gax::Operation.new(
                  @update_database_ddl.call(req, options),
                  @operations_client,
                  Google::Protobuf::Empty,
                  Google::Spanner::Admin::Database::V1::UpdateDatabaseDdlMetadata,
                  call_options: options
                )
                operation.on_done { |operation| yield(operation) } if block_given?
                operation
              end

              # Drops (aka deletes) a Cloud Spanner database.
              #
              # @param database [String]
              #   Required. The database to be dropped.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @yield [result, operation] Access the result along with the RPC operation
              # @yieldparam result []
              # @yieldparam operation [GRPC::ActiveCall::Operation]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/database"
              #
              #   database_admin_client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)
              #   formatted_database = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
              #   database_admin_client.drop_database(formatted_database)

              def drop_database \
                  database,
                  options: nil,
                  &block
                req = {
                  database: database
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Database::V1::DropDatabaseRequest)
                @drop_database.call(req, options, &block)
                nil
              end

              # Returns the schema of a Cloud Spanner database as a list of formatted
              # DDL statements. This method does not show pending schema updates, those may
              # be queried using the {Google::Longrunning::Operations Operations} API.
              #
              # @param database [String]
              #   Required. The database whose schema we wish to get.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @yield [result, operation] Access the result along with the RPC operation
              # @yieldparam result [Google::Spanner::Admin::Database::V1::GetDatabaseDdlResponse]
              # @yieldparam operation [GRPC::ActiveCall::Operation]
              # @return [Google::Spanner::Admin::Database::V1::GetDatabaseDdlResponse]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/database"
              #
              #   database_admin_client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)
              #   formatted_database = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
              #   response = database_admin_client.get_database_ddl(formatted_database)

              def get_database_ddl \
                  database,
                  options: nil,
                  &block
                req = {
                  database: database
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Spanner::Admin::Database::V1::GetDatabaseDdlRequest)
                @get_database_ddl.call(req, options, &block)
              end

              # Sets the access control policy on a database resource. Replaces any
              # existing policy.
              #
              # Authorization requires `spanner.databases.setIamPolicy` permission on
              # {Google::Iam::V1::SetIamPolicyRequest#resource resource}.
              #
              # @param resource [String]
              #   REQUIRED: The resource for which the policy is being specified.
              #   `resource` is usually specified as a path. For example, a Project
              #   resource is specified as `projects/{project}`.
              # @param policy [Google::Iam::V1::Policy | Hash]
              #   REQUIRED: The complete policy to be applied to the `resource`. The size of
              #   the policy is limited to a few 10s of KB. An empty policy is a
              #   valid policy but certain Cloud Platform services (such as Projects)
              #   might reject them.
              #   A hash of the same form as `Google::Iam::V1::Policy`
              #   can also be provided.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @yield [result, operation] Access the result along with the RPC operation
              # @yieldparam result [Google::Iam::V1::Policy]
              # @yieldparam operation [GRPC::ActiveCall::Operation]
              # @return [Google::Iam::V1::Policy]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/database"
              #
              #   database_admin_client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)
              #   formatted_resource = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
              #
              #   # TODO: Initialize `policy`:
              #   policy = {}
              #   response = database_admin_client.set_iam_policy(formatted_resource, policy)

              def set_iam_policy \
                  resource,
                  policy,
                  options: nil,
                  &block
                req = {
                  resource: resource,
                  policy: policy
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Iam::V1::SetIamPolicyRequest)
                @set_iam_policy.call(req, options, &block)
              end

              # Gets the access control policy for a database resource. Returns an empty
              # policy if a database exists but does not have a policy set.
              #
              # Authorization requires `spanner.databases.getIamPolicy` permission on
              # {Google::Iam::V1::GetIamPolicyRequest#resource resource}.
              #
              # @param resource [String]
              #   REQUIRED: The resource for which the policy is being requested.
              #   `resource` is usually specified as a path. For example, a Project
              #   resource is specified as `projects/{project}`.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @yield [result, operation] Access the result along with the RPC operation
              # @yieldparam result [Google::Iam::V1::Policy]
              # @yieldparam operation [GRPC::ActiveCall::Operation]
              # @return [Google::Iam::V1::Policy]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/database"
              #
              #   database_admin_client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)
              #   formatted_resource = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
              #   response = database_admin_client.get_iam_policy(formatted_resource)

              def get_iam_policy \
                  resource,
                  options: nil,
                  &block
                req = {
                  resource: resource
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Iam::V1::GetIamPolicyRequest)
                @get_iam_policy.call(req, options, &block)
              end

              # Returns permissions that the caller has on the specified database resource.
              #
              # Attempting this RPC on a non-existent Cloud Spanner database will result in
              # a NOT_FOUND error if the user has `spanner.databases.list` permission on
              # the containing Cloud Spanner instance. Otherwise returns an empty set of
              # permissions.
              #
              # @param resource [String]
              #   REQUIRED: The resource for which the policy detail is being requested.
              #   `resource` is usually specified as a path. For example, a Project
              #   resource is specified as `projects/{project}`.
              # @param permissions [Array<String>]
              #   The set of permissions to check for the `resource`. Permissions with
              #   wildcards (such as '*' or 'storage.*') are not allowed. For more
              #   information see
              #   [IAM Overview](https://cloud.google.com/iam/docs/overview#permissions).
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @yield [result, operation] Access the result along with the RPC operation
              # @yieldparam result [Google::Iam::V1::TestIamPermissionsResponse]
              # @yieldparam operation [GRPC::ActiveCall::Operation]
              # @return [Google::Iam::V1::TestIamPermissionsResponse]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              # @example
              #   require "google/cloud/spanner/admin/database"
              #
              #   database_admin_client = Google::Cloud::Spanner::Admin::Database.new(version: :v1)
              #   formatted_resource = Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdminClient.database_path("[PROJECT]", "[INSTANCE]", "[DATABASE]")
              #
              #   # TODO: Initialize `permissions`:
              #   permissions = []
              #   response = database_admin_client.test_iam_permissions(formatted_resource, permissions)

              def test_iam_permissions \
                  resource,
                  permissions,
                  options: nil,
                  &block
                req = {
                  resource: resource,
                  permissions: permissions
                }.delete_if { |_, v| v.nil? }
                req = Google::Gax::to_proto(req, Google::Iam::V1::TestIamPermissionsRequest)
                @test_iam_permissions.call(req, options, &block)
              end
            end
          end
        end
      end
    end
  end
end
