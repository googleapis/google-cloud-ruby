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


module Google
  module Cloud
    module Translate
      ##
      # # Translation
      #
      # Represents a translation query result. Returned by
      # {Google::Cloud::Translate::Api#translate}.
      #
      # @see https://cloud.google.com/translate/v2/using_rest#Translate
      #   Translate Text
      #
      # @example
      #   require "google/cloud/translate"
      #
      #   translate = Google::Cloud::Translate.new
      #
      #   translation = translate.translate "Hello world!", to: "la"
      #
      #   translation.to_s #=> "Salve mundi!"
      #
      #   translation.from #=> "en"
      #   translation.origin #=> "Hello world!"
      #   translation.to #=> "la"
      #   translation.text #=> "Salve mundi!"
      #
      class Translation
        ##
        # The translated result.
        #
        # @return [String]
        attr_reader :text
        alias_method :to_s, :text
        alias_method :to_str, :text

        ##
        # The original query text that was translated.
        #
        # @return [String]
        attr_reader :origin

        ##
        # The target language into which the text was translated.
        #
        # @return [String]
        attr_reader :to
        alias_method :language, :to
        alias_method :target, :to

        ##
        # The source language from which the text was translated.
        attr_reader :from
        alias_method :source, :from

        ##
        # @private Create a new object.
        def initialize text, to, origin, from, detected
          @text = text
          @to = to
          @origin = origin
          @from = from
          @detected = detected
        end

        ##
        # Determines if the source language was detected by the Google Cloud
        # Translate API.
        #
        # @return [Boolean] `true` if the source language was detected by the
        #   Translate service, `false` if the source language was provided in
        #   the request
        def detected?
          @detected
        end

        ##
        # @private New Translation from a TranslationsListResponse object as
        # defined by the Google API Client object.
        def self.from_gapi_list gapi, text, to, from
          res = text.zip(Array(gapi["translations"])).map do |origin, g|
            from_gapi g, to, origin, from
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
end
