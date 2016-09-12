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


require "google/cloud/errors"
require "google/cloud/language/credentials"
require "google/cloud/language/version"
require "google/cloud/language/v1beta1/language_service_services_pb"
require "google/cloud/language/v1beta1/language_service_api"

module Google
  module Cloud
    module Language
      ##
      # @private Represents the gRPC Language service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :host, :retries, :timeout

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, retries: nil,
                       timeout: nil
          @project = project
          @credentials = credentials
          @host = host || V1beta1::LanguageServiceApi::SERVICE_ADDRESS
          @retries = retries
          @timeout = timeout
        end

        def channel
          GRPC::Core::Channel.new host, nil, chan_creds
        end

        def chan_creds
          return credentials if insecure?
          GRPC::Core::ChannelCredentials.new.compose \
            GRPC::Core::CallCredentials.new credentials.client.updater_proc
        end

        def service
          return mocked_service if mocked_service
          @service ||= \
            V1beta1::LanguageServiceApi.new(
              service_path: host,
              channel: channel,
              timeout: timeout,
              app_name: "google-cloud-language",
              app_version: Google::Cloud::Language::VERSION)
        end
        attr_accessor :mocked_service

        def insecure?
          credentials == :this_channel_is_insecure
        end

        ##
        # Returns API::BatchAnnotateImagesResponse
        def annotate doc_grpc, syntax: false, entities: false, sentiment: false,
                     encoding: nil
          if syntax == false && entities == false && sentiment == false
            syntax = true
            entities = true
            sentiment = true
          end
          features = V1beta1::AnnotateTextRequest::Features.new(
            extract_syntax: syntax, extract_entities: entities,
            extract_document_sentiment: sentiment)
          encoding = verify_encoding! encoding
          execute { service.annotate_text doc_grpc, features, encoding }
        end

        def entities doc_grpc, encoding: nil
          encoding = verify_encoding! encoding
          execute { service.analyze_entities doc_grpc, encoding }
        end

        def sentiment doc_grpc
          execute { service.analyze_sentiment doc_grpc }
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def verify_encoding! encoding
          # TODO: verify encoding against V1beta1::EncodingType
          return :UTF8 if encoding.nil?
          encoding
        end

        def execute
          yield
        rescue GRPC::BadStatus => e
          raise Google::Cloud::Error.from_error(e)
        end
      end
    end
  end
end
