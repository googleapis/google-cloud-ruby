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
      # Represents a document for the Language service.
      #
      # Cloud Natural Language API supports UTF-8, UTF-16, and UTF-32 encodings.
      # (Ruby uses UTF-8 natively, which is the default sent to the API, so
      # unless you're working with text processed in different platform, you
      # should not need to set the encoding type.)
      #
      # Be aware that only English, Spanish, and Japanese language content are
      # supported.
      #
      # See {Project#document}.
      #
      # @example
      #   require "google/cloud/language"
      #
      #   language = Google::Cloud::Language.new
      #
      #   content = "Darth Vader is the best villain in Star Wars."
      #   document = language.document content
      #   annotation = document.annotate
      #
      #   annotation.entities.count #=> 2
      #   annotation.sentiment.score #=> 1.0
      #   annotation.sentiment.magnitude #=> 0.8999999761581421
      #   annotation.sentences.count #=> 1
      #   annotation.tokens.count #=> 10
      #
      class Document
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        ##
        # @private Creates a new document instance.
        def initialize
          @grpc = nil
          @service = nil
        end

        ##
        # @private Whether the document has content.
        #
        def content?
          @grpc.source == :content
        end

        ##
        # @private Whether the document source is a Google Cloud Storage URI.
        #
        def url?
          @grpc.source == :gcs_content_uri
        end

        ##
        # @private The source of the document's content.
        #
        def source
          return @grpc.content if content?
          @grpc.gcs_content_uri
        end

        ##
        # The document's format.
        #
        # @return [Symbol] `:text` or `:html`
        #
        def format
          return :text if text?
          return :html if html?
        end

        ##
        # Sets the document's format.
        #
        # @param [Symbol, String] new_format Accepted values are `:text` or
        #   `:html`.
        #
        # @example
        #   document = language.document "<p>The Old Man and the Sea</p>"
        #   document.format = :html
        #
        def format= new_format
          @grpc.type = :PLAIN_TEXT if new_format.to_s == "text"
          @grpc.type = :HTML       if new_format.to_s == "html"
          @grpc.type
        end

        ##
        # Whether the document is the `TEXT` format.
        #
        # @return [Boolean]
        #
        def text?
          @grpc.type == :PLAIN_TEXT
        end

        ##
        # Sets the document to the `TEXT` format.
        #
        def text!
          @grpc.type = :PLAIN_TEXT
        end

        ##
        # Whether the document is the `HTML` format.
        #
        # @return [Boolean]
        #
        def html?
          @grpc.type == :HTML
        end

        ##
        # Sets the document to the `HTML` format.
        #
        def html!
          @grpc.type = :HTML
        end

        ##
        # The document's language. ISO and BCP-47 language codes are supported.
        #
        # @return [String]
        #
        def language
          @grpc.language
        end

        ##
        # Sets the document's language.
        #
        # @param [String, Symbol] new_language ISO and BCP-47 language codes are
        #   accepted.
        #
        # @example
        #   document = language.document "<p>El viejo y el mar</p>"
        #   document.language = "es"
        #
        def language= new_language
          @grpc.language = new_language.to_s
        end

        ##
        # Analyzes the document and returns sentiment, entity, and syntactic
        # feature results, depending on the option flags. Calling `annotate`
        # with no arguments will perform **all** analysis features. Each feature
        # is priced separately. See [Pricing](https://cloud.google.com/natural-language/pricing)
        # for details.
        #
        # @param [Boolean] sentiment Whether to perform sentiment analysis.
        #   Optional. The default is `false`. If every feature option is
        #   `false`, **all** features will be performed.
        # @param [Boolean] entities Whether to perform the entity analysis.
        #   Optional. The default is `false`. If every feature option is
        #   `false`, **all** features will be performed.
        # @param [Boolean] syntax Whether to perform syntactic analysis.
        #   Optional. The default is `false`. If every feature option is
        #   `false`, **all** features will be performed.
        # @param [String] encoding The encoding type used by the API to
        #   calculate offsets. Optional.
        #
        # @return [Annotation] The results of the content analysis.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Darth Vader is the best villain in Star Wars."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   annotation.sentiment.score #=> 1.0
        #   annotation.sentiment.magnitude #=> 0.8999999761581421
        #   annotation.entities.count #=> 2
        #   annotation.sentences.count #=> 1
        #   annotation.tokens.count #=> 10
        #
        # @example With feature flags:
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Darth Vader is the best villain in Star Wars."
        #   document = language.document content
        #   annotation = document.annotate entities: true, text: true
        #
        #   annotation.sentiment #=> nil
        #   annotation.entities.count #=> 2
        #   annotation.sentences.count #=> 1
        #   annotation.tokens.count #=> 10
        #
        def annotate sentiment: false, entities: false, syntax: false,
                     encoding: nil
          ensure_service!
          grpc = service.annotate to_grpc, sentiment: sentiment,
                                           entities: entities,
                                           syntax: syntax,
                                           encoding: encoding
          Annotation.from_grpc grpc
        end
        alias_method :mark, :annotate
        alias_method :detect, :annotate

        ##
        # Syntactic analysis extracts linguistic information, breaking up the
        # given text into a series of sentences and tokens (generally, word
        # boundaries), providing further analysis on those tokens.
        #
        # @param [String] encoding The encoding type used by the API to
        #   calculate offsets. Optional.
        #
        # @return [Annotation::Syntax] The results for the content analysis.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Darth Vader is the best villain in Star Wars."
        #   document = language.document content
        #
        #   syntax = document.syntax
        #
        #   sentence = syntax.sentences.last
        #   sentence.text #=> "Darth Vader is the best villain in Star Wars."
        #   sentence.offset #=> 0
        #
        #   syntax.tokens.count #=> 10
        #   token = syntax.tokens.first
        #
        #   token.text #=> "Darth"
        #   token.offset #=> 0
        #   token.part_of_speech.tag #=> :NOUN
        #   token.head_token_index #=> 1
        #   token.label #=> :NN
        #   token.lemma #=> "Darth"
        #
        def syntax encoding: nil
          ensure_service!
          grpc = service.syntax to_grpc, encoding: encoding
          Annotation::Syntax.from_grpc grpc
        end

        ##
        # Entity analysis inspects the given text for known entities (proper
        # nouns such as public figures, landmarks, etc.) and returns information
        # about those entities.
        #
        # @param [String] encoding The encoding type used by the API to
        #   calculate offsets. Optional.
        #
        # @return [Annotation::Entities] The results for the entities analysis.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        # content = "Darth Vader is the best villain in Star Wars."
        # document = language.document content
        # entities = document.entities # API call
        #
        # entities.count #=> 2
        # entities.first.name #=> "Darth Vader"
        # entities.first.type #=> :PERSON
        # entities.first.name #=> "Star Wars"
        # entities.first.type #=> :WORK_OF_ART
        #
        def entities encoding: nil
          ensure_service!
          grpc = service.entities to_grpc, encoding: encoding
          Annotation::Entities.from_grpc grpc
        end

        ##
        # Sentiment analysis inspects the given text and identifies the
        # prevailing emotional opinion within the text, especially to determine
        # a writer's attitude as positive, negative, or neutral. Currently, only
        # English is supported for sentiment analysis.
        #
        # @param [String] encoding The encoding type used by the API to
        #   calculate offsets. Optional.
        #
        # @return [Annotation::Sentiment] The results for the sentiment
        #   analysis.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Darth Vader is the best villain in Star Wars."
        #   document = language.document content
        #
        #   sentiment = document.sentiment
        #
        #   sentiment.score #=> 1.0
        #   sentiment.magnitude #=> 0.8999999761581421
        #   sentiment.language #=> "en"
        #
        #   sentence = sentiment.sentences.first
        #   sentence.sentiment.score #=> 1.0
        #   sentence.sentiment.magnitude #=> 0.8999999761581421
        #
        def sentiment encoding: nil
          ensure_service!
          grpc = service.sentiment to_grpc, encoding: encoding
          Annotation::Sentiment.from_grpc grpc
        end

        # @private
        def inspect
          "#<#{self.class.name} (" \
            "#{(content? ? "\"#{source[0, 16]}...\"" : source)}, " \
            "format: #{format.inspect}, language: #{language.inspect})>"
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
          grpc = Google::Cloud::Language::V1::Document.new
          if source.start_with? "gs://"
            grpc.gcs_content_uri = source
            format ||= :html if source.end_with? ".html"
          else
            grpc.content = source
          end
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
          fail "Must have active connection" unless service
        end
      end
    end
  end
end
