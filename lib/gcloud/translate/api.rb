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


require "gcloud/translate/connection"
require "gcloud/translate/translation"
require "gcloud/translate/detection"
require "gcloud/translate/language"
require "gcloud/translate/errors"

module Gcloud
  module Translate
    ##
    # TODO
    class Api
      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private Creates a new Translate Api instance.
      #
      # See {Gcloud.translate}
      def initialize key
        key ||= ENV["TRANSLATE_KEY"]
        if key.nil?
          key_mising_msg = "An API key is required to use the Translate API."
          fail ArgumentError, key_mising_msg
        end
        @connection = Connection.new key
      end

      ##
      # Returns text translations from one language to another.
      #
      # @param [String] text The text to translate.
      # @param [String] to The target language into which the text should be
      #   translated. This is an iso639-1 language code.
      # @param [String] from The source language of the text. This is an
      #   iso639-1 language code. This is optional.
      # @param [String] text The format of the text. Possible values include
      #   `:text` and `:html`. This is optional.
      # @param [String] cid The customization id for translate. This is
      #   optional.
      #
      # @return [Translation, Array<Translation>] A single {Translation} object
      #   if just one text was given, or an array of {Translation} objects if
      #   multiple texts were given.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   translate = gcloud.translate
      #
      #   translation = translate.translate "Hello world!", to: "la"
      #   puts translation #=> Salve mundi!
      #
      # @example Setting the `from` language.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   translate = gcloud.translate
      #
      #   translation = translate.translate "Hello world!"
      #                                     to: :la, from: :en,
      #   puts translation #=> Salve mundi!
      #
      # @example Retrieving multiple translations.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   translate = gcloud.translate
      #
      #   translations = translate.translate "Hello my friend.",
      #                                      "See you soon.",
      #                                      to: "la", from: "en"
      #   puts translations.count #=> 2
      #   puts translations #=> Salve mi amice.
      #                     #=> Vide te mox.
      #
      # @example Retrieving translation containing HTML tags.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   translate = gcloud.translate
      #
      #   translation = translate.translate "<em>Hello</em> world!",
      #                                     to: :la, from: :en,
      #                                     format: :html
      #   puts translation #=> <em>Salve</em> mundi!
      #
      def translate *text, to: nil, from: nil, format: nil, cid: nil
        return nil if text.empty?
        fail ArgumentError, "to is required" if to.nil?
        to = to.to_s
        from = from.to_s if from
        format = format.to_s if format
        resp = connection.translate(*text, to: to, from: from,
                                           format: format, cid: cid)
        fail ApiError.from_response(resp) unless resp.success?
        puts resp.body
        Translation.from_response resp, text, to, from
      end

      ##
      # Detect the language of text.
      #
      # @param [String] text The text to detect.
      #
      # @return [Detection, Array<Detection>] A single {Detection} object if
      #   just one text was given, or an array of {Detection} objects if
      #   multiple texts were given.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   translate = gcloud.translate
      #
      #   detection = translate.detect "Hello world!"
      #   puts detection.language #=> en
      #   puts detection.confidence #=> 0.7100697
      #
      # @example Detecting multiple texts.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   translate = gcloud.translate
      #
      #   detections = translate.detect "Hello world!",
      #                                 "Bonjour le monde!"
      #   puts detections.count #=> 2
      #   puts detection.first.language #=> en
      #   puts detection.first.confidence #=> 0.7100697
      #   puts detection.last.language #=> fr
      #   puts detection.last.confidence #=> 0.40440267
      #
      def detect *text
        return nil if text.empty?
        resp = connection.detect(*text)
        fail ApiError.from_response(resp) unless resp.success?
        Detection.from_response resp, text
      end

      ##
      # List the languages supported by the API. These are the languages that
      # text can be translated to and from.
      #
      # @param [String] language The language and collation in which the names
      #   of the languages are returned. If this is `nil` then no names are
      #   returned.
      #
      # @return [Array<Language>] An array of {Language} objects supported by
      #   the API.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   translate = gcloud.translate
      #
      #   languages = translate.languages
      #   puts languages.count #=> 104
      #
      #   english = languages.detect { |l| l.code == "en" }
      #   puts english.name #=> nil
      #
      # @example Get all languages with their names in French.Anglais
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   translate = gcloud.translate
      #
      #   languages = translate.languages "fr"
      #   puts languages.count #=> 104
      #
      #   english = languages.detect { |l| l.code == "en" }
      #   puts english.name #=> Anglais
      #
      def languages language = nil
        language = language.to_s if language
        resp = connection.languages language
        fail ApiError.from_response(resp) unless resp.success?
        Array(resp.data["languages"]).map { |gapi| Language.from_gapi gapi }
      end
    end
  end
end
