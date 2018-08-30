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


require "google/cloud/bigquery/data_transfer/v1/data_transfer_service_client"

module Google
  module Cloud
    module Bigquery
      module DataTransfer
        # rubocop:disable LineLength

        ##
        # # Ruby Client for BigQuery Data Transfer API ([Beta](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
        #
        # [BigQuery Data Transfer API][Product Documentation]:
        # Transfers data from partner SaaS applications to Google BigQuery on a
        # scheduled, managed basis.
        # - [Product Documentation][]
        #
        # ## Quick Start
        # In order to use this library, you first need to go through the following
        # steps:
        #
        # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
        # 2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
        # 3. [Enable the BigQuery Data Transfer API.](https://console.cloud.google.com/apis/library/bigquerydatatransfer.googleapis.com)
        # 4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
        #
        # ### Installation
        # ```
        # $ gem install google-cloud-bigquery-data_transfer
        # ```
        #
        # ### Preview
        # #### DataTransferServiceClient
        # ```rb
        # require "google/cloud/bigquery/data_transfer"
        #
        # data_transfer_service_client = Google::Cloud::Bigquery::DataTransfer.new(version: :v1)
        # formatted_parent = Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.project_path(project_id)
        #
        # # Iterate over all results.
        # data_transfer_service_client.list_data_sources(formatted_parent).each do |element|
        #   # Process element.
        # end
        #
        # # Or iterate over results one page at a time.
        # data_transfer_service_client.list_data_sources(formatted_parent).each_page do |page|
        #   # Process each page at a time.
        #   page.each do |element|
        #     # Process element.
        #   end
        # end
        # ```
        #
        # ### Next Steps
        # - Read the [BigQuery Data Transfer API Product documentation][Product Documentation]
        #   to learn more about the product and see How-to Guides.
        # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
        #   to see the full list of Cloud APIs that we cover.
        #
        # [Product Documentation]: https://cloud.google.com/bigquery/transfer/
        #
        # ## Enabling Logging
        #
        # To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library.
        # The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as shown below,
        # or a [`Google::Cloud::Logging::Logger`](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest/google/cloud/logging/logger)
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
        module V1
          # rubocop:enable LineLength

          ##
          # The Google BigQuery Data Transfer Service API enables BigQuery users to
          # configure the transfer of their data from other Google Products into BigQuery.
          # This service contains methods that are end user exposed. It backs up the
          # frontend.
          #
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
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: nil
            kwargs = {
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              metadata: metadata,
              exception_transformer: exception_transformer,
              lib_name: lib_name,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Bigquery::DataTransfer::V1::DataTransferServiceClient.new(**kwargs)
          end
        end
      end
    end
  end
end
