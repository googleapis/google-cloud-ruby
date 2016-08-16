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
        # The Document's format. `:text` or `:html`
        #
        def format
          return :text if text?
          return :html if html?
        end

        def format= new_format
          @grpc.type = :PLAIN_TEXT if new_format.to_s == "text"
          @grpc.type = :HTML       if new_format.to_s == "html"
          @grpc.type
        end

        ##
        # Whether the Document is the TEXT format.
        #
        def text?
          @grpc.type == :PLAIN_TEXT
        end

        ##
        # Sets the Document to the TEXT format.
        #
        def text!
          @grpc.type = :PLAIN_TEXT
        end

        ##
        # Whether the Document is the HTML format.
        #
        def html?
          @grpc.type == :HTML
        end

        ##
        # Sets the Document to the HTML format.
        #
        def html!
          @grpc.type = :HTML
        end

        ##
        # The Document's language.
        #
        def language
          @grpc.language
        end

        ##
        # The Document's language.
        #
        def language= new_language
          new_language = new_language.to_s unless new_language.nil?
          @grpc.language = new_language
        end

        ##
        # TODO: Details
        #
        # @param [Boolean] text Whether to perform the textual analysis.
        #   Optional.
        # @param [Boolean] entities Whether to perform the entitiy analysis.
        #   Optional.
        # @param [Boolean] sentiment Whether to perform the sentiment analysis.
        #   Optional.
        # @param [String] encoding The encoding type used by the API to
        #   calculate offsets. Optional.
        #
        # @return [Annotation>] The results for the content analysis.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   language = gcloud.language
        #
        #   doc = language.document "Hello world!"
        #
        #   annotation = doc.annotate
        #   annotation.thing #=> Some Result
        #
        def annotate text: false, entities: false, sentiment: false,
                     encoding: nil
          ensure_service!
          grpc = @service.annotate to_grpc, text: text, entities: entities,
                                            sentiment: sentiment,
                                            encoding: encoding
          Annotation.from_grpc grpc
        end
        alias_method :mark, :annotate
        alias_method :detect, :annotate

        ##
        # TODO: Details
        #
        # @param [String] encoding The encoding type used by the API to
        #   calculate offsets. Optional.
        #
        # @return [Annotation::Entities>] The results for the entities analysis.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   language = gcloud.language
        #
        #   doc = language.document "Hello Chris and Mike!"
        #
        #   entities = doc.entities
        #   entities.count #=> 2
        #
        def entities encoding: nil
          ensure_service!
          grpc = @service.entities to_grpc, encoding: encoding
          Annotation::Entities.from_grpc grpc
        end

        ##
        # TODO: Details
        #
        # @return [Annotation::Sentiment>] The results for the sentiment
        #   analysis.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   language = gcloud.language
        #
        #   doc = language.document "Hello Chris and Mike!"
        #
        #   sentiment = doc.sentiment
        #   sentiment.polarity #=> 1.0
        #   sentiment.magnitude #=> 0.8999999761581421
        #
        def sentiment
          ensure_service!
          grpc = @service.sentiment to_grpc
          Annotation::Sentiment.from_grpc grpc
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
            content: source
          )
          if format.to_s == "html"
            grpc.type = :HTML
          else
            grpc.type = :PLAIN_TEXT
          end
          grpc.language = language.to_s unless language.nil?
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
