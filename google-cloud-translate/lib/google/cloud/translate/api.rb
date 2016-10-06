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


require "google/cloud/translate/service"
require "google/cloud/translate/translation"
require "google/cloud/translate/detection"
require "google/cloud/translate/language"

module Google
  module Cloud
    module Translate
      ##
      # # Api
      #
      # Represents top-level access to the Google Translate API. Each instance
      # requires a public API access key. To create a key, follow the general
      # instructions at [Identifying your application to
      # Google](https://cloud.google.com/translate/v2/using_rest#auth), and the
      # specific instructions for [Server
      # keys](https://cloud.google.com/translate/v2/using_rest#creating-server-api-keys).
      # See {Google::Cloud#translate}.
      #
      # @see https://cloud.google.com/translate/v2/getting_started Translate API
      #   Getting Started
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
      class Api
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private Creates a new Translate Api instance.
        #
        # See {Google::Cloud.translate}
        def initialize service
          @service = service
        end

        ##
        # Returns text translations from one language to another.
        #
        # @see https://cloud.google.com/translate/v2/using_rest#Translate
        #   Translate Text
        #
        # @param [String] text The text or texts to translate.
        # @param [String] to The target language into which the text should be
        #   translated. This is required. The value must be an [ISO
        #   639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
        #   language code.
        # @param [String] from The source language of the text or texts. This is
        #   an [ISO
        #   639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
        #   language code. This is optional.
        # @param [String] format The format of the text. Possible values include
        #   `:text` and `:html`. This is optional. The Translate API default is
        #   `:html`.
        # @param [String] cid The customization id for translate. This is
        #   optional.
        #
        # @return [Translation, Array<Translation>] A single {Translation}
        #   object if just one text was given, or an array of {Translation}
        #   objects if multiple texts were given.
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
        #   translation.detected? #=> true
        #   translation.from #=> "en"
        #   translation.origin #=> "Hello world!"
        #   translation.to #=> "la"
        #   translation.text #=> "Salve mundi!"
        #
        # @example Setting the `from` language.
        #   require "google/cloud/translate"
        #
        #   translate = Google::Cloud::Translate.new
        #
        #   translation = translate.translate "Hello world!",
        #                                     from: :en, to: :la
        #   translation.detected? #=> false
        #   translation.text #=> "Salve mundi!"
        #
        # @example Retrieving multiple translations.
        #   require "google/cloud/translate"
        #
        #   translate = Google::Cloud::Translate.new
        #
        #   translations = translate.translate "Hello my friend.",
        #                                      "See you soon.",
        #                                      from: "en", to: "la"
        #   translations.count #=> 2
        #   translations[0].text #=> "Salve amice."
        #   translations[1].text #=> "Vide te mox."
        #
        # @example Preserving HTML tags.
        #   require "google/cloud/translate"
        #
        #   translate = Google::Cloud::Translate.new
        #
        #   translation = translate.translate "<strong>Hello</strong> world!",
        #                                     to: :la
        #   translation.text #=> "<strong>Salve</strong> mundi!"
        #
        def translate *text, to: nil, from: nil, format: nil, cid: nil
          return nil if text.empty?
          fail ArgumentError, "to is required" if to.nil?
          to = to.to_s
          from = from.to_s if from
          format = format.to_s if format
          text = Array(text).flatten
          gapi = service.translate text, to: to, from: from,
                                         format: format, cid: cid
          Translation.from_gapi_list gapi, text, to, from
        end

        ##
        # Detect the most likely language or languages of a text or multiple
        # texts.
        #
        # @see https://cloud.google.com/translate/v2/using_rest#detect-language
        #   Detect Language
        #
        # @param [String] text The text or texts upon which language detection
        #   should be performed.
        #
        # @return [Detection, Array<Detection>] A single {Detection} object if
        #   just one text was given, or an array of {Detection} objects if
        #   multiple texts were given.
        #
        # @example
        #   require "google/cloud/translate"
        #
        #   translate = Google::Cloud::Translate.new
        #
        #   detection = translate.detect "Hello world!"
        #   detection.language #=> "en"
        #   detection.confidence #=> 0.7100697
        #
        # @example Detecting multiple texts.
        #   require "google/cloud/translate"
        #
        #   translate = Google::Cloud::Translate.new
        #
        #   detections = translate.detect "Hello world!",
        #                                 "Bonjour le monde!"
        #   detections.count #=> 2
        #   detections.first.language #=> "en"
        #   detections.first.confidence #=> 0.7100697
        #   detections.last.language #=> "fr"
        #   detections.last.confidence #=> 0.40440267
        #
        def detect *text
          return nil if text.empty?
          text = Array(text).flatten
          gapi = service.detect(text)
          Detection.from_gapi gapi, text
        end

        ##
        # List the languages supported by the API. These are the languages to
        # and from which text can be translated.
        #
        # @see https://cloud.google.com/translate/v2/using_rest#supported-languages
        #   Discover Supported Languages
        #
        # @param [String] language The language and collation in which the names
        #   of the languages are returned. If this is `nil` then no names are
        #   returned.
        #
        # @return [Array<Language>] An array of {Language} objects supported by
        #   the API.
        #
        # @example
        #   require "google/cloud/translate"
        #
        #   translate = Google::Cloud::Translate.new
        #
        #   languages = translate.languages
        #   languages.count #=> 104
        #
        #   english = languages.detect { |l| l.code == "en" }
        #   english.name #=> nil
        #
        # @example Get all languages with their names in French.
        #   require "google/cloud/translate"
        #
        #   translate = Google::Cloud::Translate.new
        #
        #   languages = translate.languages "fr"
        #   languages.count #=> 104
        #
        #   english = languages.detect { |l| l.code == "en" }
        #   english.name #=> "Anglais"
        #
        def languages language = nil
          language = language.to_s if language
          gapi = service.languages language
          Array(gapi.languages).map { |g| Language.from_gapi g }
        end
      end
    end
  end
end
