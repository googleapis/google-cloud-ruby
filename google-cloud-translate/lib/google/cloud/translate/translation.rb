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
      # @see https://cloud.google.com/translation/docs/translating-text#Translate
      #   Translating Text
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
        #
        # @return [String]
        attr_reader :from
        alias_method :source, :from

        ##
        # The model used by the service to perform the translation. When this is
        # set to `nmt`, the translation was performed using premium neural
        # machine translation model. If it is not set or model is set to `base`,
        # then the translation was done using standard model. In almost all
        # cases, the model type in response should match the model type
        # requested. However, in some limited situations this might not be the
        # case. In these cases, the request had `nmt` parameter, but the
        # response has `base` set or model is not returned. This happens when
        # neural translation did not give a satisfactory translation and we
        # completed the translation using the standard model. If this happens,
        # you will charged at the standard edition rate and not at the premium
        # rate.
        #
        # @return [String]
        attr_reader :model

        ##
        # @private Create a new object.
        def initialize text, to, origin, from, model, detected
          @text = text
          @to = to
          @origin = origin
          @from = from
          @model = model
          @detected = detected
        end

        ##
        # Determines if the source language was detected by the Google Cloud
        # Cloud Translation API.
        #
        # @return [Boolean] `true` if the source language was detected by the
        #   Cloud Translation API, `false` if the source language was provided
        #   in the request
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
          new gapi["translatedText"], to, origin, from, gapi["model"], detected
        end
      end
    end
  end
end
