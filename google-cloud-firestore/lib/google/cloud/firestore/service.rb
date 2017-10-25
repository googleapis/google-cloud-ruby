# Copyright 2017, Google Inc. All rights reserved.
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


require "google/cloud/errors"
require "google/cloud/firestore/credentials"
require "google/cloud/firestore/version"
require "google/cloud/firestore/v1beta1"

module Google
  module Cloud
    module Firestore
      ##
      # @private Represents the gRPC Firestore service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :host, :timeout, :client_config

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, timeout: nil,
                       client_config: nil
          @project = project
          @credentials = credentials
          @host = host || V1beta1::FirestoreClient::SERVICE_ADDRESS
          @timeout = timeout
          @client_config = client_config || {}
        end

        def channel
          require "grpc"
          GRPC::Core::Channel.new host, nil, chan_creds
        end

        def chan_creds
          return credentials if insecure?
          require "grpc"
          GRPC::Core::ChannelCredentials.new.compose \
            GRPC::Core::CallCredentials.new credentials.client.updater_proc
        end

        def firestore
          @firestore ||= \
            V1beta1::FirestoreClient.new(
              service_path: host,
              channel: channel,
              timeout: timeout,
              client_config: client_config,
              lib_name: "gccl",
              lib_version: Google::Cloud::Firestore::VERSION)
        end

        def insecure?
          credentials == :this_channel_is_insecure
        end

        def list_documents parent, collection_id, token: nil
          options = call_options parent: database_path, token: token

          execute do
            firestore.list_documents parent, collection_id, nil, nil, nil,
                                     options: options
          end
        end

        def get_document path, mask: nil
          options = call_options parent: database_path

          execute do
            firestore.get_document path, document_mask(mask), options: options
          end
        end

        def list_collections parent, token: nil, page_size: nil
          options = call_options parent: database_path, token: token

          execute do
            firestore.list_collection_ids parent, page_size: page_size,
                                                  options: options
          end
        end

        def database_path project_id: project, database_id: "(default)"
          V1beta1::FirestoreClient.database_root_path project_id, database_id
        end

        def documents_path project_id: project, database_id: "(default)"
          V1beta1::FirestoreClient.document_root_path project_id, database_id
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def default_headers parent = nil
          parent ||= database_path
          { "google-cloud-resource-prefix" => parent }
        end

        def call_options parent: nil, token: nil
          Google::Gax::CallOptions.new({
            kwargs: default_headers(parent),
            page_token: token
          }.delete_if { |_, v| v.nil? })
        end

        def document_mask mask
          return nil if mask.nil?

          mask = Array mask
          return nil if mask.empty?

          Google::Firestore::V1beta1::DocumentMask.new field_paths: mask
        end

        def execute
          yield
        rescue Google::Gax::GaxError => e
          # GaxError wraps BadStatus, but exposes it as #cause
          raise Google::Cloud::Error.from_error(e.cause)
        rescue GRPC::BadStatus => e
          raise Google::Cloud::Error.from_error(e)
        end
      end
    end
  end
end
