# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Google
  module Cloud
    module Translate
      ##
      # # Detection
      #
      # Represents a detect language query result. Returned by
      # {Google::Cloud::Translate::Api#detect}.
      #
      # @see https://cloud.google.com/translation/docs/detecting-language
      #   Detecting Language
      #
      # @example
      #   require "google/cloud/translate"
      #
      #   translate = Google::Cloud::Translate.new
      #
      #   detections = translate.detect "chien", "chat"
      #
      #   detections.size #=> 2
      #   detections[0].text #=> "chien"
      #   detections[0].language #=> "fr"
      #   detections[0].confidence #=> 0.7109375
      #   detections[1].text #=> "chat"
      #   detections[1].language #=> "en"
      #   detections[1].confidence #=> 0.59922177
      #
      class Detection
        ##
        # The text upon which the language detection was performed.
        #
        # @return [String]
        attr_reader :text

        ##
        # The list of detection results for the given text. The most likely
        # language is listed first, and its attributes can be accessed through
        # {#language} and {#confidence}.
        #
        # @return [Array<Detection::Result>]
        attr_reader :results

        ##
        # @private Create a new object.
        def initialize text, results
          @text = text
          @results = results
        end

        ##
        # The confidence that the language detection result is correct. The
        # closer this value is to 1, the higher the confidence in language
        # detection.
        #
        # @return [Float] a value between 0 and 1
        def confidence
          return nil if results.empty?
          results.first.confidence
        end

        ##
        # The most likely language that was detected. This is an [ISO
        # 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) language
        # code.
        #
        # @return [String] the language code
        def language
          return nil if results.empty?
          results.first.language
        end

        ##
        # @private New Detection from a ListDetectionsResponse object as
        # defined by the Google API Client object.
        def self.from_gapi gapi, text
          res = text.zip(Array(gapi["detections"])).map do |txt, detections|
            results = detections.map { |g| Result.from_gapi g }
            new txt, results
          end
          return res.first if res.size == 1
          res
        end

        ##
        # # Result
        #
        # Represents an individual result in a
        # {Google::Cloud::Translate::Detection} result.
        #
        class Result
          ##
          # The confidence that the language detection result is correct. The
          # closer this value is to 1, the higher the confidence in language
          # detection.
          #
          # @return [Float] a value between 0 and 1
          attr_reader :confidence

          ##
          # The language detected. This is an [ISO
          # 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
          # language code.
          #
          # @return [String] the language code
          attr_reader :language

          ##
          # @private Create a new object.
          def initialize confidence, language
            @confidence = confidence
            @language = language
          end

          ##
          # @private New Detection::Result from a DetectionsResource object as
          # defined by the Google API Client object.
          def self.from_gapi gapi
            new gapi["confidence"], gapi["language"]
          end
        end
      end
    end
  end
end
