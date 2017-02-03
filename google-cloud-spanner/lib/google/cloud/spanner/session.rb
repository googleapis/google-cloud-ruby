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


require "google/cloud/spanner/results"

module Google
  module Cloud
    module Spanner
      ##
      # # Session
      #
      # ...
      #
      # See {Google::Cloud#spanner}
      #
      # @example
      #   require "google/cloud"
      #
      #   gcloud = Google::Cloud.new
      #   spanner = gcloud.spanner
      #
      #   # ...
      class Session
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        # @private Creates a new Session instance.
        def initialize grpc, service
          @grpc = grpc
          @service = service
        end

        # The unique identifier for the project.
        # @return [String]
        def project_id
          V1::SpannerClient.match_project_from_session_name @grpc.name
        end

        # The unique identifier for the instance.
        # @return [String]
        def instance_id
          V1::SpannerClient.match_instance_from_session_name @grpc.name
        end

        # The unique identifier for the database.
        # @return [String]
        def database_id
          V1::SpannerClient.match_database_from_session_name @grpc.name
        end

        # The unique identifier for the session.
        # @return [String]
        def session_id
          V1::SpannerClient.match_session_from_session_name @grpc.name
        end

        # rubocop:disable LineLength

        ##
        # The full path for the session resource. Values are of the form
        # `projects/<project_id>/instances/<instance_id>/databases/<database_id>/sessions/<session_id>`.
        # @return [String]
        def path
          @grpc.name
        end

        # rubocop:enable LineLength

        ##
        # Reloads the session resource. Useful for determining if the session is
        # still valid on the Spanner API.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.session "my-instance", "my-database"
        #
        #   db.reload! # API call
        #
        def reload!
          ensure_service!
          @grpc = service.get_session path
          self
        end

        ##
        # Permanently deletes the session.
        #
        # @return [Boolean] Returns `true` if the session was deleted.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.session "my-instance", "my-database"
        #
        #   db.delete
        #
        def delete
          ensure_service!
          service.delete_session path
          true
        end

        ##
        # Executes a SQL query.
        #
        # Arguments can be passed using `params`, Ruby types are mapped to
        # Spanner types as follows:
        #
        # | Spanner     | Ruby           | Notes  |
        # |-------------|----------------|---|
        # | `BOOL`      | `true`/`false` | |
        # | `INT64`     | `Integer`      | |
        # | `FLOAT64`   | `Float`        | |
        # | `STRING`    | `String`       | |
        # | `DATE`      | `Date`         | |
        # | `TIMESTAMP` | `Time`, `DateTime` | |
        # | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        # | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        # See [Data
        # types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @param [String] sql The SQL query string. See [Query
        #   syntax](https://cloud.google.com/spanner/docs/query-syntax).
        #
        #   The SQL query string can contain parameter placeholders. A parameter
        #   placeholder consists of "@" followed by the parameter name.
        #   Parameter names consist of any combination of letters, numbers, and
        #   underscores.
        # @param [Hash] params SQL parameters for the query string. The
        #   parameter placeholders, minus the "@", are the the hash keys, and
        #   the literal values are the hash values. If the query string contains
        #   something like "WHERE id > @msg_id", then the params must contain
        #   something like `:msg_id -> 1`.
        # @param [Boolean] streaming When `true`, all result are returned as a
        #   stream. There is no limit on the size of the returned result set.
        #   However, no individual row in the result set can exceed 100 MiB, and
        #   no column value can exceed 10 MiB.
        #
        #  When `false`, all result are returned in a single reply. This method
        #  cannot be used to return a result set larger than 10 MiB; if the
        #  query yields more data than that, the query fails with an error.
        #
        # @return [Google::Cloud::Spanner::Results]
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.session "my-instance", "my-database"
        #
        #   results = db.execute "SELECT * FROM users"
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}""
        #   end
        #
        # @example Query using query parameters:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.session "my-instance", "my-database"
        #
        #   results = db.execute "SELECT * FROM users WHERE active = @active",
        #                        params: { active: true }
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}""
        #   end
        #
        # @example Query without streaming results:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.session "my-instance", "my-database"
        #
        #   results = db.execute "SELECT * FROM users WHERE id = @user_id",
        #                        params: { user_id: 1 },
        #                        streaming: false
        #
        #   user_row = results.rows.first
        #   puts "User #{user_row[:id]} is #{user_row[:name]}""
        #
        def execute sql, params: nil, streaming: true
          ensure_service!
          if streaming
            Results.from_enum service.streaming_execute_sql path, sql,
                                                            params: params
          else
            Results.from_grpc service.execute_sql path, sql, params: params
          end
        end
        alias_method :query, :execute

        ##
        # @private Creates a new Session instance from a
        # Google::Spanner::V1::Session.
        def self.from_grpc grpc, service
          new grpc, service
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
