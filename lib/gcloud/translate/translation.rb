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
    class Translation
      attr_reader :text
      attr_reader :to
      alias_method :language, :to
      alias_method :target, :to
      attr_reader :origin
      attr_reader :from
      alias_method :source, :from

      def initialize text, to, origin, from, detected
        @text = text
        @to = to
        @origin = origin
        @from = from
        @detected = detected
      end

      def detected?
        @detected
      end

      alias_method :to_s, :text
      alias_method :to_str, :text

      ##
      # @private New Translation from a TranslationsListResponse object as
      # defined by the Google API Client object.
      def self.from_response resp, text, to, from
        res = text.zip(Array(resp.data["translations"])).map do |origin, gapi|
          from_gapi gapi, to, origin, from
        end
        return res.first if res.size == 1
        res
      end

      ##
      # @private New Translation from a TranslationsResource object as defined
      # by the Google API Client object.
      def self.from_gapi gapi, to, origin, from
        from ||= gapi["detectedSourceLanguage"]
        detected = !gapi["detectedSourceLanguage"].nil?
        new gapi["translatedText"], to, origin, from, detected
      end
    end
  end
end
