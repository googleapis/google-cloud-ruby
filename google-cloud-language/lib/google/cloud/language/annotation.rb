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
      # The results of all requested document annotations.
      #
      # See {Project#annotate} and {Document#annotate}.
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
      class Annotation
        ##
        # @private The AnnotateTextResponse Google API Client object.
        attr_accessor :grpc

        ##
        # @private Creates a new Annotation instance.
        def initialize
          @grpc = nil
        end

        def sentences
          @sentences ||= begin
            Array(grpc.sentences).map { |g| TextSpan.from_grpc g.text }
          end
        end

        def tokens
          @tokens ||= Array(grpc.tokens).map { |g| Token.from_grpc g }
        end

        def entities
          @entities ||= Entities.from_grpc @grpc
        end

        def sentiment
          return nil if @grpc.document_sentiment.nil?
          @sentiment ||= Sentiment.from_grpc @grpc
        end

        def language
          @grpc.language
        end

        ##
        # @private New Annotation from a V1beta1::AnnotateTextResponse object.
        def self.from_grpc grpc
          new.tap { |a| a.instance_variable_set :@grpc, grpc }
        end

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
          # @private New TextSpan from a V1beta1::TextSpan object.
          def self.from_grpc grpc
            new grpc.content, grpc.begin_offset
          end
        end

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
          # @private New Token from a V1beta1::Token object.
          def self.from_grpc grpc
            text_span = TextSpan.from_grpc grpc.text
            new text_span, grpc.part_of_speech.tag,
                grpc.dependency_edge.head_token_index,
                grpc.dependency_edge.label, grpc.lemma
          end
        end

        class Entities < DelegateClass(::Array)
          attr_accessor :language

          ##
          # @private Create a new Entities with an array of Entity instances.
          def initialize entities = [], language = nil
            super entities
            @language = language
          end

          def unknown
            select(&:unknown?)
          end

          def people
            select(&:person?)
          end

          def locations
            select(&:location?)
          end
          alias_method :places, :locations

          def organizations
            select(&:organization?)
          end

          def events
            select(&:event?)
          end

          def artwork
            select(&:artwork?)
          end

          def goods
            select(&:good?)
          end

          def other
            select(&:other?)
          end

          ##
          # @private New Entities from a V1beta1::AnnotateTextResponse or
          # V1beta1::AnalyzeEntitiesResponse object.
          def self.from_grpc grpc
            entities = Array(grpc.entities).map { |g| Entity.from_grpc g }
            new entities, grpc.language
          end
        end

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

          def unknown?
            type == :UNKNOWN
          end

          def person?
            type == :PERSON
          end

          def location?
            type == :LOCATION
          end
          alias_method :place?, :location?

          def organization?
            type == :ORGANIZATION
          end

          def event?
            type == :EVENT
          end

          def artwork?
            type == :WORK_OF_ART
          end

          def good?
            type == :CONSUMER_GOOD
          end

          def other?
            type == :OTHER
          end

          def wikipedia_url
            metadata["wikipedia_url"]
          end

          ##
          # @private New Entity from a V1beta1::Entity object.
          def self.from_grpc grpc
            metadata = Core::GRPCUtils.map_to_hash grpc.metadata
            mentions = Array(grpc.mentions).map do |g|
              TextSpan.from_grpc g.text
            end
            new grpc.name, grpc.type, metadata, grpc.salience, mentions
          end
        end

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
          # @private New Sentiment from a V1beta1::AnnotateTextResponse or
          # V1beta1::AnalyzeSentimentResponse object.
          def self.from_grpc grpc
            new grpc.document_sentiment.polarity,
                grpc.document_sentiment.magnitude, grpc.language
          end
        end
      end
    end
  end
end
