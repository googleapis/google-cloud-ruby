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


require "google/gax"
require "pathname"

module Google
  module Cloud
    module Bigtable
      # rubocop:disable LineLength

      ##
      # # Ruby Client for Cloud Bigtable Admin API ([Alpha](https://github.com/googleapis/google-cloud-ruby#versioning))
      #
      # [Cloud Bigtable Admin API][Product Documentation]:
      #
      # - [Product Documentation][]
      #
      # ## Quick Start
      # In order to use this library, you first need to go through the following
      # steps:
      #
      # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
      # 2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
      # 3. [Enable the Cloud Bigtable Admin API.](https://console.cloud.google.com/apis/library/bigtableadmin.googleapis.com)
      # 4. [Setup Authentication.](https://googleapis.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
      #
      # ### Installation
      # ```
      # $ gem install google-cloud-bigtable
      # ```
      #
      # ### Next Steps
      # - Read the [Cloud Bigtable Admin API Product documentation][Product Documentation]
      #   to learn more about the product and see How-to Guides.
      # - View this [repository's main README](https://github.com/googleapis/google-cloud-ruby/blob/master/README.md)
      #   to see the full list of Cloud APIs that we cover.
      #
      # [Product Documentation]: https://cloud.google.com/bigtable-admin
      #
      # ## Enabling Logging
      #
      # To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library.
      # The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as shown below,
      # or a [`Google::Cloud::Logging::Logger`](https://googleapis.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest/google/cloud/logging/logger)
      # that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb)
      # and the gRPC [spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb) for additional information.
      #
      # Configuring a Ruby stdlib logger:
      #
      # ```ruby
      # require "logger"
      #
      # module MyLogger
      #   LOGGER = Logger.new $stderr, level: Logger::WARN
      #   def logger
      #     LOGGER
      #   end
      # end
      #
      # # Define a gRPC module-level logger method before grpc/logconfig.rb loads.
      # module GRPC
      #   extend MyLogger
      # end
      # ```
      #
      module Admin
        # rubocop:enable LineLength

        FILE_DIR = File.realdirpath(Pathname.new(__FILE__).join("..").join("admin"))

        AVAILABLE_VERSIONS = Dir["#{FILE_DIR}/*"]
          .select { |file| File.directory?(file) }
          .select { |dir| Google::Gax::VERSION_MATCHER.match(File.basename(dir)) }
          .select { |dir| File.exist?(dir + ".rb") }
          .map { |dir| File.basename(dir) }

        module BigtableInstanceAdmin
          ##
          # Service for creating, configuring, and deleting Cloud Bigtable Instances and
          # Clusters. Provides access to the Instance and Cluster schemas only, not the
          # tables' metadata or data stored in those tables.
          #
          # @param version [Symbol, String]
          #   The major version of the service to be used. By default :v2
          #   is used.
          # @overload new(version:, credentials:, scopes:, client_config:, timeout:)
          #   @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #     Provides the means for authenticating requests made by the client. This parameter can
          #     be many types.
          #     A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #     authenticating requests made by this client.
          #     A `String` will be treated as the path to the keyfile to be used for the construction of
          #     credentials for this client.
          #     A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #     credentials for this client.
          #     A `GRPC::Core::Channel` will be used to make calls through.
          #     A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #     should already be composed with a `GRPC::Core::CallCredentials` object.
          #     A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #     metadata for requests, generally, to give OAuth credentials.
          #   @param scopes [Array<String>]
          #     The OAuth scopes for this service. This parameter is ignored if
          #     an updater_proc is supplied.
          #   @param client_config [Hash]
          #     A Hash for call options for each method. See
          #     Google::Gax#construct_settings for the structure of
          #     this data. Falls back to the default config if not specified
          #     or the specified config is missing data points.
          #   @param timeout [Numeric]
          #     The default timeout, in seconds, for calls made through this client.
          #   @param metadata [Hash]
          #     Default metadata to be sent with each request. This can be overridden on a per call basis.
          #   @param exception_transformer [Proc]
          #     An optional proc that intercepts any exceptions raised during an API call to inject
          #     custom error handling.
          def self.new(*args, version: :v2, **kwargs)
            unless AVAILABLE_VERSIONS.include?(version.to_s.downcase)
              raise "The version: #{version} is not available. The available versions " \
                "are: [#{AVAILABLE_VERSIONS.join(", ")}]"
            end

            require "#{FILE_DIR}/#{version.to_s.downcase}"
            version_module = Google::Cloud::Bigtable::Admin
              .constants
              .select {|sym| sym.to_s.downcase == version.to_s.downcase}
              .first
            Google::Cloud::Bigtable::Admin.const_get(version_module)::BigtableInstanceAdmin.new(*args, **kwargs)
          end
        end

        module BigtableTableAdmin
          ##
          # Service for creating, configuring, and deleting Cloud Bigtable tables.
          #
          #
          # Provides access to the table schemas only, not the data stored within
          # the tables.
          #
          # @param version [Symbol, String]
          #   The major version of the service to be used. By default :v2
          #   is used.
          # @overload new(version:, credentials:, scopes:, client_config:, timeout:)
          #   @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #     Provides the means for authenticating requests made by the client. This parameter can
          #     be many types.
          #     A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #     authenticating requests made by this client.
          #     A `String` will be treated as the path to the keyfile to be used for the construction of
          #     credentials for this client.
          #     A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #     credentials for this client.
          #     A `GRPC::Core::Channel` will be used to make calls through.
          #     A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #     should already be composed with a `GRPC::Core::CallCredentials` object.
          #     A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #     metadata for requests, generally, to give OAuth credentials.
          #   @param scopes [Array<String>]
          #     The OAuth scopes for this service. This parameter is ignored if
          #     an updater_proc is supplied.
          #   @param client_config [Hash]
          #     A Hash for call options for each method. See
          #     Google::Gax#construct_settings for the structure of
          #     this data. Falls back to the default config if not specified
          #     or the specified config is missing data points.
          #   @param timeout [Numeric]
          #     The default timeout, in seconds, for calls made through this client.
          #   @param metadata [Hash]
          #     Default metadata to be sent with each request. This can be overridden on a per call basis.
          #   @param exception_transformer [Proc]
          #     An optional proc that intercepts any exceptions raised during an API call to inject
          #     custom error handling.
          def self.new(*args, version: :v2, **kwargs)
            unless AVAILABLE_VERSIONS.include?(version.to_s.downcase)
              raise "The version: #{version} is not available. The available versions " \
                "are: [#{AVAILABLE_VERSIONS.join(", ")}]"
            end

            require "#{FILE_DIR}/#{version.to_s.downcase}"
            version_module = Google::Cloud::Bigtable::Admin
              .constants
              .select {|sym| sym.to_s.downcase == version.to_s.downcase}
              .first
            Google::Cloud::Bigtable::Admin.const_get(version_module)::BigtableTableAdmin.new(*args, **kwargs)
          end
        end
      end
    end
  end
end
