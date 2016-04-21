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


module Gcloud
  module Translate
    ##
    # TODO
    class Detection
      ##
      # The text the language detection was performed on.
      #
      # @return [String]
      attr_reader :text

      ##
      # A list of of languages which were detected for the given text. The most
      # likely language detection is listed first.
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
      # The confidence of the most likely detection result.
      #
      # @return [Float]
      def confidence
        return nil if results.empty?
        results.first.confidence
      end

      ##
      # The most likely language detected. This is an iso639-1 language code.
      #
      # @return [String]
      def language
        return nil if results.empty?
        results.first.language
      end

      ##
      # @private New Detection from a DetectionsListResponse object as
      # defined by the Google API Client object.
      def self.from_response resp, text
        res = text.zip(Array(resp.data.detections)).map do |txt, gapi_list|
          results = gapi_list.map { |gapi| Result.from_gapi gapi }
          new txt, results
        end
        return res.first if res.size == 1
        res
      end

      class Result
        ##
        # The confidence of the detection result.
        #
        # @return [Float]
        attr_reader :confidence

        ##
        # The language detected. This is an iso639-1 language code.
        #
        # @return [String]
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
