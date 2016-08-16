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


require "google/cloud/language/annotation"

module Google
  module Cloud
    module Language
      ##
      # # Document
      #
      # Represents an document for the Language service.
      #
      # See {Project#document}.
      #
      # TODO: Overview
      #
      # @example
      #   require "google/cloud"
      #
      #   gcloud = Google::Cloud.new
      #   language = gcloud.language
      #
      #   doc = language.document "Hello world!"
      #
      #   annotation = language.annotate doc
      #   annotation.thing #=> Some Result
      #
      class Document
        ##
        # @private Creates a new Document instance.
        def initialize
          @grpc = nil
          @service = nil
        end

        ##
        # @private New gRPC object.
        def to_grpc
          @grpc
        end

        ##
        # @private
        def self.from_grpc grpc, service
          new.tap do |i|
            i.instance_variable_set :@grpc, grpc
            i.instance_variable_set :@service, service
          end
        end

        ##
        # @private
        def self.from_source source, service, format: nil, language: nil
          source = String source
          grpc = Google::Cloud::Language::V1beta1::Document.new(
            content: source, type: :PLAIN_TEXT
          )
          from_grpc grpc, service
        end

        protected

        ##
        # Raise an error unless an active language project object is available.
        def ensure_service!
          fail "Must have active connection" unless @service
        end
      end
    end
  end
end
