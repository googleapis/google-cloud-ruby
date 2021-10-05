# Copyright 2021 Google LLC
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

require "google-cloud-spanner"
require "google/cloud/config"

module Google
  module Cloud
    module Spanner
      module Admin
        module Database
          ##
          # Create a new client object for a DatabaseAdmin.
          #
          # This returns an instance of
          # [Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdmin::Client](https://googleapis.dev/ruby/google-cloud-spanner-admin-database-v1/latest/Google/Cloud/Spanner/Admin/Database/V1/DatabaseAdmin/Client.html)
          # for version V1 of the API.
          # However, you can specify specify a different API version by passing it in the
          # `version` parameter. If the DatabaseAdmin service is
          # supported by that API version, and the corresponding gem is available, the
          # appropriate versioned client will be returned.
          #
          # ## About DatabaseAdmin
          #
          # Google Cloud Spanner Database Admin Service
          #
          # The Cloud Spanner Database Admin API can be used to create, drop, and
          # list databases. It also enables updating the schema of pre-existing
          # databases. It can be also used to create, delete and list backups for a
          # database and to restore from an existing backup.
          #
          # @param version [::String, ::Symbol] The API version to connect to. Optional.
          #   Defaults to `:v1`.
          # @return [Admin::Database::V1::DatabaseAdmin::Client] A client object for the specified version.
          #
          def self.new
            if configure.emulator_host
              return Admin::Database::V1::DatabaseAdmin::Client.new do |config|
                config.credentials = :this_channel_is_insecure
                config.endpoint = configure.emulator_host
              end
            end

            Admin::Database::V1::DatabaseAdmin::Client.new
          end

          ##
          # Configure the Google Cloud Spanner Database Admin library.
          #
          # The following configuration parameters are supported:
          #
          # * `credentials` (*type:* `String, Hash, Google::Auth::Credentials`) -
          #   The path to the keyfile as a String, the contents of the keyfile as a
          #   Hash, or a Google::Auth::Credentials object.
          # * `lib_name` (*type:* `String`) -
          #   The library name as recorded in instrumentation and logging.
          # * `lib_version` (*type:* `String`) -
          #   The library version as recorded in instrumentation and logging.
          # * `interceptors` (*type:* `Array<GRPC::ClientInterceptor>`) -
          #   An array of interceptors that are run before calls are executed.
          # * `timeout` (*type:* `Numeric`) -
          #   Default timeout in seconds.
          # * `emulator_host` - (String) Host name of the emulator. Defaults to
          #   `ENV["SPANNER_EMULATOR_HOST"]`.
          # * `metadata` (*type:* `Hash{Symbol=>String}`) -
          #   Additional gRPC headers to be sent with the call.
          # * `retry_policy` (*type:* `Hash`) -
          #   The retry policy. The value is a hash with the following keys:
          #     * `:initial_delay` (*type:* `Numeric`) - The initial delay in seconds.
          #     * `:max_delay` (*type:* `Numeric`) - The max delay in seconds.
          #     * `:multiplier` (*type:* `Numeric`) - The incremental backoff multiplier.
          #     * `:retry_codes` (*type:* `Array<String>`) -
          #       The error codes that should trigger a retry.
          #
          # @return [::Google::Cloud::Config] The default configuration used by this library
          #
          def self.configure
            yield ::Google::Cloud.configure.spanner if block_given?

            ::Google::Cloud.configure.spanner
          end
        end
      end
    end
  end
end
