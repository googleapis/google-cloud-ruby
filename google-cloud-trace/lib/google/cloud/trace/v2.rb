# Copyright 2017 Google LLC
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

require "google/cloud/trace/v2/trace_service_client"

module Google
  module Cloud
    # rubocop:disable LineLength

    ##
    # # Ruby Client for Stackdriver Trace API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Stackdriver Trace API][Product Documentation]:
    # Sends application trace data to Stackdriver Trace for viewing. Trace data is
    # collected for all App Engine applications by default. Trace data from other
    # applications can be provided using this API.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
    # 3. [Enable the Stackdriver Trace API.](https://console.cloud.google.com/apis/api/trace)
    # 4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Preview
    # #### TraceServiceClient
    # ```rb
    # require "google/cloud/trace/v2"
    #
    # trace_service_client = Google::Cloud::Trace::V2.new
    # formatted_name = Google::Cloud::Trace::V2::TraceServiceClient.project_path(project_id)
    # spans = []
    # trace_service_client.batch_write_spans(formatted_name, spans)
    # ```
    #
    # ### Next Steps
    # - Read the [Stackdriver Trace API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/trace
    #
    #
    module Trace
      module V2
        # rubocop:enable LineLength

        ##
        # This file describes an API for collecting and viewing traces and spans
        # within a trace.  A Trace is a collection of spans corresponding to a single
        # operation or set of operations for an application. A span is an individual
        # timed event which forms a node of the trace tree. A single trace may
        # contain span(s) from multiple services.
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
        def self.new \
            credentials: nil,
            scopes: nil,
            client_config: nil,
            timeout: nil,
            lib_name: nil,
            lib_version: nil
          kwargs = {
            credentials: credentials,
            scopes: scopes,
            client_config: client_config,
            timeout: timeout,
            lib_name: lib_name,
            lib_version: lib_version
          }.select { |_, v| v != nil }
          Google::Cloud::Trace::V2::TraceServiceClient.new(**kwargs)
        end
      end
    end
  end
end
