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
require "google/cloud/language/v1"

module Google
  module Cloud
    module Language
      ##
      # @private Represents the gRPC Language service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :client_config, :timeout

        ##
        # Creates a new Service instance.
        def initialize project, credentials, client_config: nil,
                       timeout: nil
          @project = project
          @credentials = credentials
          @client_config = client_config || {}
          @timeout = timeout
        end

        def service
          return mocked_service if mocked_service
          @service ||= V1::LanguageServiceClient.new(
            credentials: credentials,
            timeout: timeout,
            client_config: client_config,
            lib_name: "gccl",
            lib_version: Google::Cloud::Language::VERSION)
        end
        attr_accessor :mocked_service

        ##
        # Returns API::BatchAnnotateImagesResponse
        def annotate doc_grpc, syntax: false, entities: false, sentiment: false
          if syntax == false && entities == false && sentiment == false
            syntax = true
            entities = true
            sentiment = true
          end
          features = V1::AnnotateTextRequest::Features.new(
            extract_syntax: syntax, extract_entities: entities,
            extract_document_sentiment: sentiment)
          execute do
            service.annotate_text doc_grpc, features,
                                  encoding_type: default_encoding,
                                  options: default_options
          end
        end

        def syntax doc_grpc
          execute do
            service.analyze_syntax doc_grpc,
                                   encoding_type: default_encoding,
                                   options: default_options
          end
        end

        def entities doc_grpc
          execute do
            service.analyze_entities doc_grpc,
                                     encoding_type: default_encoding,
                                     options: default_options
          end
        end

        def sentiment doc_grpc
          execute do
            service.analyze_sentiment doc_grpc,
                                      encoding_type: default_encoding,
                                      options: default_options
          end
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def default_headers
          { "google-cloud-resource-prefix" => "projects/#{@project}" }
        end

        def default_options
          Google::Gax::CallOptions.new kwargs: default_headers
        end

        def default_encoding
          utf_16_encodings = [Encoding::UTF_16, Encoding::UTF_16BE,
                              Encoding::UTF_16LE]
          return :UTF16 if utf_16_encodings.include? Encoding.default_internal

          utf_32_encodings = [Encoding::UTF_32, Encoding::UTF_32BE,
                              Encoding::UTF_32LE]
          return :UTF32 if utf_32_encodings.include? Encoding.default_internal

          # The default encoding_type for all other system settings
          :UTF8
        end

        def execute
          yield
        rescue Google::Gax::GaxError => e
          # GaxError wraps BadStatus, but exposes it as #cause
          raise Google::Cloud::Error.from_error(e.cause)
        end
      end
    end
  end
end
