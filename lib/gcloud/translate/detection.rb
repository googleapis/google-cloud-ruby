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
      attr_reader :text
      attr_reader :results

      def initialize text, results
        @text = text
        @results = results
      end

      def confidence
        return nil if results.empty?
        results.first.confidence
      end

      def language
        return nil if results.empty?
        results.first.language
      end

      def reliable?
        return nil if results.empty?
        results.first.reliable?
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
        attr_reader :confidence
        attr_reader :language

        def initialize confidence, language, reliable
          @confidence = confidence
          @language = language
          @reliable = reliable
        end

        def reliable?
          @reliable
        end

        ##
        # @private New Detection::Result from a DetectionsResource object as
        # defined by the Google API Client object.
        def self.from_gapi gapi
          new gapi["confidence"], gapi["language"], gapi["isReliable"]
        end
      end
    end
  end
end
