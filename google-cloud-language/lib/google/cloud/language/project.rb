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
require "google/cloud/env"
require "google/cloud/language/service"
require "google/cloud/language/document"
require "google/cloud/language/annotation"

module Google
  module Cloud
    module Language
      ##
      # # Project
      #
      # Google Cloud Natural Language API reveals the structure and meaning of
      # text by offering powerful machine learning models in an easy to use REST
      # API. You can analyze text uploaded in your request or integrate with
      # your document storage on Google Cloud Storage.
      #
      # See {Google::Cloud#language}
      #
      # @example
      #   require "google/cloud/language"
      #
      #   language = Google::Cloud::Language.new
      #
      #   content = "Star Wars is a great movie. The Death Star is fearsome."
      #   annotation = language.annotate content
      #
      #   annotation.sentiment.score #=> 0.10000000149011612
      #   annotation.sentiment.magnitude #=> 1.100000023841858
      #   annotation.entities.count #=> 3
      #   annotation.sentences.count #=> 2
      #   annotation.tokens.count #=> 13
      #
      class Project
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        ##
        # @private Creates a new Language Project instance.
        def initialize service
          @service = service
        end

        # The Language project connected to.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   language.project_id #=> "my-project"
        #
        def project_id
          service.project
        end
        alias_method :project, :project_id

        ##
        # @private Default project.
        def self.default_project_id
          ENV["LANGUAGE_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud.env.project_id
        end

        ##
        # Returns a new document from the given content. No API call is made.
        #
        # @param [String, Google::Cloud::Storage::File] content A string of text
        #   to be annotated, or a Cloud Storage URI of the form
        #   `"gs://bucketname/path/to/document.ext"`; or an instance of
        #   Google::Cloud::Storage::File of the text to be annotated.
        # @param [String, Symbol] format The format of the document. Acceptable
        #   values are: `text` or `html`. If no format is provided, the document
        #   will default to `text`. Optional.
        # @param [String, Symbol] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are accepted. Optional.
        #
        # @return [Document] An document for the Language service.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   document = language.document "It was the best of times, it was..."
        #
        # @example With a Google Cloud Storage URI:
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   document = language.document "gs://bucket-name/path/to/document"
        #
        # @example With a Google Cloud Storage File object:
        #   require "google/cloud/storage"
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "bucket-name"
        #   file = bucket.file "path/to/document"
        #
        #   require "google/cloud/language"
        #   language = Google::Cloud::Language.new
        #
        #   document = language.document file
        #
        # @example With `format` and `language` options:
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   document = language.document "<p>El viejo y el mar</p>",
        #                           format: :html, language: "es"
        #
        def document content, format: nil, language: nil
          content = content.to_gs_url if content.respond_to? :to_gs_url
          if content.is_a? Document
            # Create new document with the provided format and language
            Document.from_source content.source, @service,
                                 format: (format || content.format),
                                 language: (language || content.language)
          else
            Document.from_source content, @service, format: format,
                                                    language: language
          end
        end
        alias_method :doc, :document

        ##
        # Returns a new document from the given content with the `format` value
        # `:text`. No API call is made.
        #
        # @param [String, Google::Cloud::Storage::File] content A string of text
        #   to be annotated, or a Cloud Storage URI of the form
        #   `"gs://bucketname/path/to/document.ext"`; or an instance of
        #   Google::Cloud::Storage::File of the text to be annotated.
        # @param [String, Symbol] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are accepted. Optional.
        #
        # @return [Document] An document for the Language service.
        #
        def text content, language: nil
          document content, format: :text, language: language
        end

        ##
        # Returns a new document from the given content with the `format` value
        # `:html`. No API call is made.
        #
        # @param [String, Google::Cloud::Storage::File] content A string of text
        #   to be annotated, or a Cloud Storage URI of the form
        #   `"gs://bucketname/path/to/document.ext"`; or an instance of
        #   Google::Cloud::Storage::File of the text to be annotated.
        # @param [String, Symbol] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are accepted. Optional.
        #
        # @return [Document] An document for the Language service.
        #
        def html content, language: nil
          document content, format: :html, language: language
        end

        ##
        # Analyzes the content and returns sentiment, entity, and syntactic
        # feature results, depending on the option flags. Calling `annotate`
        # with no arguments will perform **all** analysis features. Each feature
        # is priced separately. See [Pricing](https://cloud.google.com/natural-language/pricing)
        # for details.
        #
        # @param [String, Document, Google::Cloud::Storage::File] content The
        #   content to annotate. This can be an {Document} instance, or any
        #   other type that converts to an {Document}. See {#document} for
        #   details.
        # @param [Boolean] sentiment Whether to perform the sentiment analysis.
        #   Optional. The default is `false`. If every feature option is
        #   `false`, **all** features will be performed.
        # @param [Boolean] entities Whether to perform the entity analysis.
        #   Optional. The default is `false`. If every feature option is
        #   `false`, **all** features will be performed.
        # @param [Boolean] syntax Whether to perform the syntactic analysis.
        #   Optional. The default is `false`. If every feature option is
        #   `false`, **all** features will be performed.
        # @param [String, Symbol] format The format of the document. Acceptable
        #   values are: `text` or `html`. Optional.
        # @param [String, Symbol] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are accepted. Optional.
        #
        # @return [Annotation] The results for the content analysis.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   annotation = language.annotate content
        #
        #   annotation.sentiment.score #=> 0.10000000149011612
        #   annotation.sentiment.magnitude #=> 1.100000023841858
        #   annotation.entities.count #=> 3
        #   annotation.sentences.count #=> 2
        #   annotation.tokens.count #=> 13
        #
        def annotate content, sentiment: false, entities: false, syntax: false,
                     format: nil, language: nil
          ensure_service!
          doc = document content, language: language, format: format
          grpc = service.annotate doc.to_grpc, sentiment: sentiment,
                                               entities: entities,
                                               syntax: syntax
          Annotation.from_grpc grpc
        end
        alias_method :mark, :annotate
        alias_method :detect, :annotate

        ##
        # Syntactic analysis extracts linguistic information, breaking up the
        # given text into a series of sentences and tokens (generally, word
        # boundaries), providing further analysis on those tokens.
        #
        # @param [String, Document, Google::Cloud::Storage::File] content The
        #   content to annotate. This can be an {Document} instance, or any
        #   other type that converts to an {Document}. See {#document} for
        #   details.
        # @param [String, Symbol] format The format of the document. Acceptable
        #   values are: `text` or `html`. Optional.
        # @param [String, Symbol] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are accepted. Optional.
        #
        # @return [Annotation::Syntax] The results for the content syntax
        #   analysis.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #
        #   syntax = language.syntax document
        #
        #   sentence = syntax.sentences.last
        #   sentence.text #=> "The Death Star is fearsome."
        #   sentence.offset #=> 28
        #
        #   syntax.tokens.count #=> 13
        #   token = syntax.tokens.first
        #
        #   token.text #=> "Star"
        #   token.offset #=> 0
        #   token.part_of_speech.tag #=> :NOUN
        #   token.head_token_index #=> 1
        #   token.label #=> :TITLE
        #   token.lemma #=> "Star"
        #
        def syntax content, format: nil, language: nil
          ensure_service!
          doc = document content, language: language, format: format
          grpc = service.syntax doc.to_grpc
          Annotation::Syntax.from_grpc grpc
        end

        ##
        # Entity analysis inspects the given text for known entities (proper
        # nouns such as public figures, landmarks, etc.) and returns information
        # about those entities.
        #
        # @param [String, Document] content The content to annotate. This
        #   can be an {Document} instance, or any other type that converts to an
        #   {Document}. See {#document} for details.
        # @param [String, Symbol] format The format of the document. Acceptable
        #   values are: `text` or `html`. Optional.
        # @param [String, Symbol] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are accepted. Optional.
        #
        # @return [Annotation::Entities] The results for the entities analysis.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #
        #   entities = language.entities document
        #   entities.count #=> 3
        #
        def entities content, format: :text, language: nil
          ensure_service!
          doc = document content, language: language, format: format
          grpc = service.entities doc.to_grpc
          Annotation::Entities.from_grpc grpc
        end

        ##
        # Sentiment analysis inspects the given text and identifies the
        # prevailing emotional opinion within the text, especially to determine
        # a writer's attitude as positive, negative, or neutral. Currently, only
        # English is supported for sentiment analysis.
        #
        # @param [String, Document] content The content to annotate. This
        #   can be an {Document} instance, or any other type that converts to an
        #   {Document}. See {#document} for details.
        # @param [String, Symbol] format The format of the document. Acceptable
        #   values are: `text` or `html`. Optional.
        # @param [String, Symbol] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are accepted. Optional.
        #
        # @return [Annotation::Sentiment] The results for the sentiment
        #   analysis.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #
        #   sentiment = language.sentiment document
        #
        #   sentiment.score #=> 0.10000000149011612
        #   sentiment.magnitude #=> 1.100000023841858
        #   sentiment.language #=> "en"
        #
        #   sentence = sentiment.sentences.first
        #   sentence.sentiment.score #=> 0.699999988079071
        #   sentence.sentiment.magnitude #=> 0.699999988079071
        #
        def sentiment content, format: :text, language: nil
          ensure_service!
          doc = document content, language: language, format: format
          grpc = service.sentiment doc.to_grpc
          Annotation::Sentiment.from_grpc grpc
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
