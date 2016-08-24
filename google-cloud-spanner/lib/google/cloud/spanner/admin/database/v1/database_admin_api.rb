# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
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
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"
require "google/spanner/admin/database/v1/spanner_database_admin_services_pb"

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
            # @!attribute [r] stub
            #   @return [Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub]
            class DatabaseAdminApi
              attr_reader :stub

              # The default address of the service.
              SERVICE_ADDRESS = "wrenchworks.googleapis.com".freeze

              # The default port of the service.
              DEFAULT_SERVICE_PORT = 443

              CODE_GEN_NAME_VERSION = "gapic/0.1.0".freeze

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

              # Parses the project from a instance resource.
              # @param instance_name [String]
              # @return [String]
              def self.match_project_from_instance_name instance_name
                INSTANCE_PATH_TEMPLATE.match(instance_name)["project"]
              end

              # Parses the instance from a instance resource.
              # @param instance_name [String]
              # @return [String]
              def self.match_instance_from_instance_name instance_name
                INSTANCE_PATH_TEMPLATE.match(instance_name)["instance"]
              end

              # Parses the project from a database resource.
              # @param database_name [String]
              # @return [String]
              def self.match_project_from_database_name database_name
                DATABASE_PATH_TEMPLATE.match(database_name)["project"]
              end

              # Parses the instance from a database resource.
              # @param database_name [String]
              # @return [String]
              def self.match_instance_from_database_name database_name
                DATABASE_PATH_TEMPLATE.match(database_name)["instance"]
              end

              # Parses the database from a database resource.
              # @param database_name [String]
              # @return [String]
              def self.match_database_from_database_name database_name
                DATABASE_PATH_TEMPLATE.match(database_name)["database"]
              end

              # @param service_path [String]
              #   The domain name of the API remote host.
              # @param port [Integer]
              #   The port on which to connect to the remote host.
              # @param channel [Channel]
              #   A Channel object through which to make calls.
              # @param chan_creds [Grpc::ChannelCredentials]
              #   A ChannelCredentials for the setting up the RPC client.
              # @param client_config[Hash]
              #   A Hash for call options for each method. See
              #   Google::Gax#construct_settings for the structure of
              #   this data. Falls back to the default config if not specified
              #   or the specified config is missing data points.
              # @param timeout [Numeric]
              #   The default timeout, in seconds, for calls made through this client.
              # @param app_name [String]
              #   The codename of the calling service.
              # @param app_version [String]
              #   The version of the calling service.
              def initialize \
                  service_path: SERVICE_ADDRESS,
                  port: DEFAULT_SERVICE_PORT,
                  channel: nil,
                  chan_creds: nil,
                  scopes: ALL_SCOPES,
                  client_config: {},
                  timeout: DEFAULT_TIMEOUT,
                  app_name: "gax",
                  app_version: Google::Gax::VERSION
                google_api_client = "#{app_name}/#{app_version} " \
                  "#{CODE_GEN_NAME_VERSION} ruby/#{RUBY_VERSION}".freeze
                headers = { :"x-goog-api-client" => google_api_client }
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
                    kwargs: headers
                  )
                end
                @stub = Google::Gax::Grpc.create_stub(
                  service_path,
                  port,
                  chan_creds: chan_creds,
                  channel: channel,
                  scopes: scopes,
                  &Google::Spanner::Admin::Database::V1::DatabaseAdmin::Stub.method(:new)
                )

                @list_databases = Google::Gax.create_api_call(
                  @stub.method(:list_databases),
                  defaults["list_databases"]
                )
                @create_database = Google::Gax.create_api_call(
                  @stub.method(:create_database),
                  defaults["create_database"]
                )
                @update_database = Google::Gax.create_api_call(
                  @stub.method(:update_database),
                  defaults["update_database"]
                )
                @drop_database = Google::Gax.create_api_call(
                  @stub.method(:drop_database),
                  defaults["drop_database"]
                )
                @get_database_ddl = Google::Gax.create_api_call(
                  @stub.method(:get_database_ddl),
                  defaults["get_database_d_d_l"]
                )
              end

              # Service calls

              # Lists Cloud Spanner databases.
              #
              # @param name [String]
              #   The project whose databases should be listed. Required.
              #   Values are of the form +projects/<project>/instances/<instance>+.
              # @param page_size [Integer]
              #   The maximum number of resources contained in the underlying API
              #   response. If page streaming is performed per-resource, this
              #   parameter does not affect the return value. If page streaming is
              #   performed per-page, this determines the maximum number of
              #   resources in a page.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Gax::PagedEnumerable<Google::Spanner::Admin::Database::V1::Database>]
              #   An enumerable of Google::Spanner::Admin::Database::V1::Database instances.
              #   See Google::Gax::PagedEnumerable documentation for other
              #   operations such as per-page iteration or access to the response
              #   object.
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              def list_databases \
                  name,
                  page_size: nil,
                  options: nil
                req = Google::Spanner::Admin::Database::V1::ListDatabasesRequest.new(
                  name: name
                )
                req.page_size = page_size unless page_size.nil?
                @list_databases.call(req, options)
              end

              # Creates a new Cloud Spanner database.
              #
              # @param name [String]
              #   The name of the instance that will serve the new database.
              #   Values are of the form +projects/<project>/instances/<instance>+.
              # @param create_statement [String]
              #   A +CREATE DATABASE+ statement, which specifies the name of the
              #   new database.
              # @param extra_statements [Array<String>]
              #   An optional list of DDL statements to run inside the newly created
              #   database. Statements can create tables, indexes, etc. These
              #   statements execute atomically with the creation of the database:
              #   if there is an error in any statement, the database is not created.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Spanner::Admin::Database::V1::Database]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              def create_database \
                  name,
                  create_statement,
                  extra_statements,
                  options: nil
                req = Google::Spanner::Admin::Database::V1::CreateDatabaseRequest.new(
                  name: name,
                  create_statement: create_statement,
                  extra_statements: extra_statements
                )
                @create_database.call(req, options)
              end

              # Updates the schema of a Cloud Spanner database by
              # creating/altering/dropping tables, columns, indexes, etc.  The
              # UpdateDatabaseMetadata message is used for operation
              # metadata; The operation has no response.
              #
              # @param database [String]
              #   The database to update.
              # @param statements [Array<String>]
              #   DDL statements to be applied to the database.
              # @param operation_id [String]
              #   If empty, the new update request is assigned an
              #   automatically-generated operation ID. Otherwise, +operation_id+
              #   is used to construct the name of the resulting
              #   Operation.
              #
              #   Specifying an explicit operation ID simplifies determining
              #   whether the statements were executed in the event that the
              #   UpdateDatabase call is replayed,
              #   or the return value is otherwise lost: the Database and
              #   +operation_id+ fields can be combined to form the
              #   Name of the resulting
              #   Longrunning::Operation: +<database>/operations/<operation_id>+.
              #
              #   +operation_id+ should be unique within the database, and must be
              #   a valid identifier: +A-zA-Z*+. Note that
              #   automatically-generated operation IDs always begin with an
              #   underscore. If the named operation already exists,
              #   UpdateDatabase returns
              #   +ALREADY_EXISTS+.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Longrunning::Operation]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              def update_database \
                  database,
                  statements,
                  operation_id,
                  options: nil
                req = Google::Spanner::Admin::Database::V1::UpdateDatabaseRequest.new(
                  database: database,
                  statements: statements,
                  operation_id: operation_id
                )
                @update_database.call(req, options)
              end

              # Drops (aka deletes) a Cloud Spanner database.
              #
              # @param database [String]
              #   The database to be dropped.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              def drop_database \
                  database,
                  options: nil
                req = Google::Spanner::Admin::Database::V1::DropDatabaseRequest.new(
                  database: database
                )
                @drop_database.call(req, options)
              end

              # Returns the schema of a Cloud Spanner database as a list of formatted
              # DDL statements. This method does not show pending schema updates, those may
              # be queried using the Operations API.
              #
              # @param database [String]
              #   The database whose schema we wish to get.
              # @param options [Google::Gax::CallOptions]
              #   Overrides the default settings for this call, e.g, timeout,
              #   retries, etc.
              # @return [Google::Spanner::Admin::Database::V1::GetDatabaseDDLResponse]
              # @raise [Google::Gax::GaxError] if the RPC is aborted.
              def get_database_ddl \
                  database,
                  options: nil
                req = Google::Spanner::Admin::Database::V1::GetDatabaseDDLRequest.new(
                  database: database
                )
                @get_database_ddl.call(req, options)
              end
            end
          end
        end
      end
    end
  end
end
