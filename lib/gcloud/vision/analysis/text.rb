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


require "gcloud/vision/analysis/vertex"

module Gcloud
  module Vision
    class Analysis
      ##
      # # Text
      #
      # The result of text, or optical character recognition (OCR), detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #
      #   image = vision.image "path/to/text.png"
      #
      #   text = image.text
      #   text.locale #=> "en"
      #   text.words.count #=> 28
      #   text.text
      #   #=> "Google Cloud Client Library for Ruby an idiomatic, intuitive... "
      #
      class Text
        ##
        # @private The EntityAnnotation Google API Client object.
        attr_accessor :gapi

        ##
        # @private Creates a new Text instance.
        def initialize
          @gapi = {}
          @words = []
        end

        ##
        # The text detected in an image.
        #
        # @return [String] The entire text including newline characters.
        #
        def text
          @gapi["description"]
        end

        ##
        # The language code detected for `text`.
        #
        # @return [String] The [ISO
        #   639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
        #   language code.
        #
        def locale
          @gapi["locale"]
        end

        ##
        # The bounds for the detected text in the image.
        #
        # @return [Array<Vertex>]
        #
        def bounds
          return [] unless @gapi["boundingPoly"]
          @bounds ||= Array(@gapi["boundingPoly"]["vertices"]).map do |v|
            Vertex.from_gapi v
          end
        end

        ##
        # Each word in the detected text, with the bounds for each word.
        #
        # @return [Array<Word>]
        #
        def words
          @words
        end

        ##
        # Deeply converts object to a hash. All keys will be symbolized.
        #
        # @return [Hash]
        #
        def to_h
          to_hash
        end

        ##
        # Deeply converts object to a hash. All keys will be symbolized.
        #
        # @return [Hash]
        #
        def to_hash
          { text: text, locale: locale, bounds: bounds.map(&:to_h),
            words: words.map(&:to_h) }
        end

        # @private
        def to_s
          to_str
        end

        # @private
        def to_str
          text
        end

        # @private
        def inspect
          format "#<Text text: %s, locale: %s, bounds: %i, words: %i>",
                 text.inspect, locale.inspect, bounds.count, words.count
        end

        ##
        # @private New Analysis::Text from an array of Google API Client
        # objects.
        def self.from_gapi gapi_list
          text, *words = Array gapi_list
          return nil if text.nil?
          new.tap do |t|
            t.instance_variable_set :@gapi, text
            t.instance_variable_set :@words, words.map { |w| Word.from_gapi w }
          end
        end

        ##
        # # Word
        #
        # A word within a detected text (OCR). See {Text}.
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   vision = gcloud.vision
        #
        #   image = vision.image "path/to/text.png"
        #   text = image.text
        #
        #   words = text.words
        #   words.count #=> 28
        #
        #   word = words.first
        #   word.text #=> "Google"
        #   word.bounds.count #=> 4
        #   word.bounds.first #=> #<Vertex (x: 13, y: 8)>
        #
        class Word
          ##
          # @private The EntityAnnotation Google API Client object.
          attr_accessor :gapi

          ##
          # @private Creates a new Word instance.
          def initialize
            @gapi = {}
          end

          ##
          # The text of the word.
          #
          # @return [String]
          #
          def text
            @gapi["description"]
          end

          ##
          # The bounds of the word within the detected text.
          #
          # @return [Array<Vertex>]
          #
          def bounds
            return [] unless @gapi["boundingPoly"]
            @bounds ||= Array(@gapi["boundingPoly"]["vertices"]).map do |v|
              Vertex.from_gapi v
            end
          end

          ##
          # Deeply converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_h
            to_hash
          end

          ##
          # Deeply converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_hash
            { text: text, bounds: bounds.map(&:to_h) }
          end

          # @private
          def to_s
            to_str
          end

          # @private
          def to_str
            text
          end

          # @private
          def inspect
            format "#<Word text: %s, bounds: %i>", text.inspect, bounds.count
          end

          ##
          # @private New Analysis::Text::Word from a Google API Client object.
          def self.from_gapi gapi
            new.tap { |w| w.instance_variable_set :@gapi, gapi }
          end
        end
      end
    end
  end
end
