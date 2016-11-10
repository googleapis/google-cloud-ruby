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


require "google/cloud/core/grpc_utils"

module Google
  module Cloud
    module Language
      ##
      # # Annotation
      #
      # The results of all requested document analysis features.
      #
      # See {Project#annotate} and {Document#annotate}.
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
      #   annotation.sentiment.polarity #=> 1.0
      #   annotation.sentiment.magnitude #=> 0.8999999761581421
      #   annotation.entities.count #=> 2
      #   annotation.sentences.count #=> 1
      #   annotation.tokens.count #=> 10
      #
      class Annotation
        ##
        # @private The AnnotateTextResponse Google API Client object.
        attr_accessor :grpc

        ##
        # @private Creates a new Annotation instance.
        def initialize
          @grpc = nil
        end

        ##
        # The sentences returned by syntactic analysis.
        #
        # @return [Array<TextSpan>] an array of pieces of text including
        #   relative location
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "I love dogs. I hate cats."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   text_span = annotation.sentences.last
        #   text_span.text #=> "I hate cats."
        #   text_span.offset #=> 13
        #
        def sentences
          @sentences ||= begin
            Array(grpc.sentences).map { |g| TextSpan.from_grpc g.text }
          end
        end

        ##
        # The tokens returned by syntactic analysis.
        #
        # @return [Array<Token>] an array of the smallest syntactic building
        #   blocks of the text
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
        #   annotation.tokens.count #=> 10
        #   token = annotation.tokens.first
        #
        #   token.text_span.text #=> "Darth"
        #   token.text_span.offset #=> 0
        #   token.part_of_speech #=> :NOUN
        #   token.head_token_index #=> 1
        #   token.label #=> :NN
        #   token.lemma #=> "Darth"
        #
        def tokens
          @tokens ||= Array(grpc.tokens).map { |g| Token.from_grpc g }
        end

        ##
        # The entities returned by entity analysis.
        #
        # @return [Entities]
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
        #   entities = annotation.entities
        #   entities.count #=> 2
        #   entity = entities.first
        #
        #   entity.name #=> "Darth Vader"
        #   entity.type #=> :PERSON
        #   entity.salience #=> 0.8421939611434937
        #   entity.mentions.count #=> 1
        #   entity.mentions.first.text # => "Darth Vader"
        #   entity.mentions.first.offset # => 0
        #   entity.wikipedia_url #=> "http://en.wikipedia.org/wiki/Darth_Vader"
        #
        def entities
          @entities ||= Entities.from_grpc @grpc
        end

        ##
        # The result of sentiment analysis.
        #
        # @return [Sentiment]
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Darth Vader is the best villain in Star Wars."
        #   document = language.document content
        #   annotation = document.annotate
        #   sentiment = annotation.sentiment
        #
        #   sentiment.polarity #=> 1.0
        #   sentiment.magnitude #=> 0.8999999761581421
        #   sentiment.language #=> "en"
        #
        def sentiment
          return nil if @grpc.document_sentiment.nil?
          @sentiment ||= Sentiment.from_grpc @grpc
        end

        ##
        # The language of the document (if not specified, the language is
        # automatically detected). Both ISO and BCP-47 language codes are
        # supported.
        #
        # @return [String] the language code
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Darth Vader is the best villain in Star Wars."
        #   document = language.document content
        #   annotation = document.annotate
        #   annotation.language #=> "en"
        #
        def language
          @grpc.language
        end

        # @private
        def to_s
          tmplt = "(sentences: %i, tokens: %i, entities: %i," \
                  " sentiment: %s, language: %s)"
          format tmplt, sentences.count, tokens.count, entities.count,
                 !sentiment.nil?, language.inspect
        end

        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end

        ##
        # @private New Annotation from a V1::AnnotateTextResponse object.
        def self.from_grpc grpc
          new.tap { |a| a.instance_variable_set :@grpc, grpc }
        end

        ##
        # Represents a piece of text including relative location.
        #
        # @attr_reader [String] text The content of the output text.
        # @attr_reader [Integer] offset The API calculates the beginning offset
        #   of the content in the original document according to the `encoding`
        #   specified in the API request.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "I love dogs. I hate cats."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   text_span = annotation.sentences.last
        #   text_span.text #=> "I hate cats."
        #   text_span.offset #=> 13
        #
        class TextSpan
          attr_reader :text, :offset
          alias_method :content, :text
          alias_method :begin_offset, :offset

          ##
          # @private Creates a new Token instance.
          def initialize text, offset
            @text   = text
            @offset = offset
          end

          ##
          # @private New TextSpan from a V1::TextSpan object.
          def self.from_grpc grpc
            new grpc.content, grpc.begin_offset
          end
        end

        ##
        # Represents the smallest syntactic building block of the text. Returned
        # by syntactic analysis.
        #
        # @attr_reader [TextSpan] text_span The token text.
        # @attr_reader [Symbol] part_of_speech Represents part of speech
        #   information for a token.
        # @attr_reader [Integer] head_token_index Represents the head of this
        #   token in the dependency tree. This is the index of the token which
        #   has an arc going to this token. The index is the position of the
        #   token in the array of tokens returned by the API method. If this
        #   token is a root token, then the headTokenIndex is its own index.
        # @attr_reader [Symbol] label The parse label for the token.
        # @attr_reader [String] lemma [Lemma](https://en.wikipedia.org/wiki/Lemma_(morphology))
        #   of the token.
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
        #   annotation.tokens.count #=> 10
        #   token = annotation.tokens.first
        #
        #   token.text_span.text #=> "Darth"
        #   token.text_span.offset #=> 0
        #   token.part_of_speech #=> :NOUN
        #   token.head_token_index #=> 1
        #   token.label #=> :NN
        #   token.lemma #=> "Darth"
        #
        class Token
          attr_reader :text_span, :part_of_speech, :head_token_index, :label,
                      :lemma

          ##
          # @private Creates a new Token instance.
          def initialize text_span, part_of_speech, head_token_index, label,
                         lemma
            @text_span        = text_span
            @part_of_speech   = part_of_speech
            @head_token_index = head_token_index
            @label            = label
            @lemma            = lemma
          end

          def text
            @text_span.text
          end
          alias_method :content, :text

          def offset
            @text_span.offset
          end
          alias_method :begin_offset, :offset

          ##
          # @private New Token from a V1::Token object.
          def self.from_grpc grpc
            text_span = TextSpan.from_grpc grpc.text
            new text_span, grpc.part_of_speech.tag,
                grpc.dependency_edge.head_token_index,
                grpc.dependency_edge.label, grpc.lemma
          end
        end

        ##
        # The entities returned by entity analysis.
        #
        # @attr_reader [String] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are supported.
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
        #   entities = annotation.entities
        #   entities.count #=> 2
        #   entities.people.count #=> 1
        #   entities.artwork.count #=> 1
        #
        class Entities < DelegateClass(::Array)
          attr_accessor :language

          ##
          # @private Create a new Entities with an array of Entity instances.
          def initialize entities = [], language = nil
            super entities
            @language = language
          end

          ##
          # Returns the entities for which {Entity#type} is `:UNKNOWN`.
          #
          # @return [Array<Entity>]
          #
          def unknown
            select(&:unknown?)
          end

          ##
          # Returns the entities for which {Entity#type} is `:PERSON`.
          #
          # @return [Array<Entity>]
          #
          def people
            select(&:person?)
          end

          ##
          # Returns the entities for which {Entity#type} is `:LOCATION`.
          #
          # @return [Array<Entity>]
          #
          def locations
            select(&:location?)
          end
          alias_method :places, :locations

          ##
          # Returns the entities for which {Entity#type} is `:ORGANIZATION`.
          #
          # @return [Array<Entity>]
          #
          def organizations
            select(&:organization?)
          end

          ##
          # Returns the entities for which {Entity#type} is `:EVENT`.
          #
          # @return [Array<Entity>]
          #
          def events
            select(&:event?)
          end

          ##
          # Returns the entities for which {Entity#type} is `:WORK_OF_ART`.
          #
          # @return [Array<Entity>]
          #
          def artwork
            select(&:artwork?)
          end

          ##
          # Returns the entities for which {Entity#type} is `:CONSUMER_GOOD`.
          #
          # @return [Array<Entity>]
          #
          def goods
            select(&:good?)
          end

          ##
          # Returns the entities for which {Entity#type} is `:OTHER`.
          #
          # @return [Array<Entity>]
          #
          def other
            select(&:other?)
          end

          ##
          # @private New Entities from a V1::AnnotateTextResponse or
          # V1::AnalyzeEntitiesResponse object.
          def self.from_grpc grpc
            entities = Array(grpc.entities).map { |g| Entity.from_grpc g }
            new entities, grpc.language
          end
        end

        ##
        # Represents a phrase in the text that is a known entity, such as a
        # person, an organization, or location. The API associates information,
        # such as salience and mentions, with entities.
        #
        # @attr_reader [String] name The representative name for the entity.
        # @attr_reader [Symbol] type The type of the entity.
        # @attr_reader [Hash<String,String>] metadata Metadata associated with
        #   the entity. Currently, only Wikipedia URLs are provided, if
        #   available. The associated key is "wikipedia_url".
        # @attr_reader [Float] salience The salience score associated with the
        #   entity in the [0, 1.0] range. The salience score for an entity
        #   provides information about the importance or centrality of that
        #   entity to the entire document text. Scores closer to 0 are less
        #   salient, while scores closer to 1.0 are highly salient.
        # @attr_reader [Array<TextSpan>] mentions The mentions of this entity in
        #   the input document. The API currently supports proper noun mentions.
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
        #   entities = annotation.entities
        #   entities.count #=> 2
        #   entity = entities.first
        #
        #   entity.name #=> "Darth Vader"
        #   entity.type #=> :PERSON
        #   entity.salience #=> 0.8421939611434937
        #   entity.mentions.count #=> 1
        #   entity.mentions.first.text # => "Darth Vader"
        #   entity.mentions.first.offset # => 0
        #   entity.wikipedia_url #=> "http://en.wikipedia.org/wiki/Darth_Vader"
        #
        class Entity
          attr_reader :name, :type, :metadata, :salience, :mentions

          ##
          # @private Creates a new Entity instance.
          def initialize name, type, metadata, salience, mentions
            @name     = name
            @type     = type
            @metadata = metadata
            @salience = salience
            @mentions = mentions
          end

          ##
          # Returns `true` if {#type} is `:UNKNOWN`.
          #
          # @return [Boolean]
          #
          def unknown?
            type == :UNKNOWN
          end

          ##
          # Returns `true` if {#type} is `:PERSON`.
          #
          # @return [Boolean]
          #
          def person?
            type == :PERSON
          end

          ##
          # Returns `true` if {#type} is `:LOCATION`.
          #
          # @return [Boolean]
          #
          def location?
            type == :LOCATION
          end
          alias_method :place?, :location?

          ##
          # Returns `true` if {#type} is `:ORGANIZATION`.
          #
          # @return [Boolean]
          #
          def organization?
            type == :ORGANIZATION
          end

          ##
          # Returns `true` if {#type} is `:EVENT`.
          #
          # @return [Boolean]
          #
          def event?
            type == :EVENT
          end

          ##
          # Returns `true` if {#type} is `:WORK_OF_ART`.
          #
          # @return [Boolean]
          #
          def artwork?
            type == :WORK_OF_ART
          end

          ##
          # Returns `true` if {#type} is `:CONSUMER_GOOD`.
          #
          # @return [Boolean]
          #
          def good?
            type == :CONSUMER_GOOD
          end

          ##
          # Returns `true` if {#type} is `:OTHER`.
          #
          # @return [Boolean]
          #
          def other?
            type == :OTHER
          end

          ##
          # Returns the `wikipedia_url` property of the {#metadata}.
          #
          # @return [String]
          #
          def wikipedia_url
            metadata["wikipedia_url"]
          end

          ##
          # @private New Entity from a V1::Entity object.
          def self.from_grpc grpc
            metadata = Core::GRPCUtils.map_to_hash grpc.metadata
            mentions = Array(grpc.mentions).map do |g|
              TextSpan.from_grpc g.text
            end
            new grpc.name, grpc.type, metadata, grpc.salience, mentions
          end
        end

        ##
        # Represents the result of sentiment analysis.
        #
        # @attr_reader [Float] polarity Polarity of the sentiment in the
        #   [-1.0, 1.0] range. Larger numbers represent more positive
        #   sentiments.
        # @attr_reader [Float] magnitude A non-negative number in the [0, +inf]
        #   range, which represents the absolute magnitude of sentiment
        #   regardless of polarity (positive or negative).
        # @attr_reader [String] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are supported.
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
        #   sentiment = annotation.sentiment
        #   sentiment.polarity #=> 1.0
        #   sentiment.magnitude #=> 0.8999999761581421
        #   sentiment.language #=> "en"
        #
        class Sentiment
          attr_reader :polarity, :magnitude, :language

          ##
          # @private Creates a new Sentiment instance.
          def initialize polarity, magnitude, language
            @polarity  = polarity
            @magnitude = magnitude
            @language  = language
          end

          ##
          # @private New Sentiment from a V1::AnnotateTextResponse or
          # V1::AnalyzeSentimentResponse object.
          def self.from_grpc grpc
            new grpc.document_sentiment.polarity,
                grpc.document_sentiment.magnitude, grpc.language
          end
        end
      end
    end
  end
end
