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
        def text
          @gapi["description"]
        end

        ##
        # The language code detected for `text`.
        def locale
          @gapi["locale"]
        end

        ##
        # The bounds for the detected text in the image.
        def bounds
          return [] unless @gapi["boundingPoly"]
          @bounds ||= Array(@gapi["boundingPoly"]["vertices"]).map do |v|
            Vertex.from_gapi v
          end
        end

        ##
        # Each word in the detected text, with the bounds for each word.
        def words
          @words
        end

        def to_h
          to_hash
        end

        def to_hash
          { text: text, locale: locale, bounds: bounds.map(&:to_h),
            words: words.map(&:to_h) }
        end

        def to_s
          to_str
        end

        def to_str
          text
        end

        def inspect
          format "#<Text text: %s, locale: %s, bounds: %i, words: %i>",
                 description.inspect, locale.inspect, bounds.count, words.count
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
        class Word
          ##
          # @private The EntityAnnotation Google API Client object.
          attr_accessor :gapi

          ##
          # @private Creates a new Text instance.
          def initialize
            @gapi = {}
          end

          ##
          # The text of the word.
          def text
            @gapi["description"]
          end

          ##
          # The text of the word.
          def bounds
            return [] unless @gapi["boundingPoly"]
            @bounds ||= Array(@gapi["boundingPoly"]["vertices"]).map do |v|
              Vertex.from_gapi v
            end
          end

          def to_h
            to_hash
          end

          def to_hash
            { text: text, bounds: bounds.map(&:to_h) }
          end

          def to_s
            to_str
          end

          def to_str
            text
          end

          def inspect
            format "#<Word text: %s, bounds: %i>", description.inspect,
                   bounds.count
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
