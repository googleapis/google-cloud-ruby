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
      # # Language
      #
      # Represents a supported languages query result. Returned by
      # {Google::Cloud::Translate::Api#languages}.
      #
      # @see https://cloud.google.com/translation/docs/discovering-supported-languages
      #   Discovering Supported Languages
      #
      # @example
      #   require "google/cloud/translate"
      #
      #   translate = Google::Cloud::Translate.new
      #
      #   languages = translate.languages "en"
      #
      #   languages.size #=> 104
      #   languages[0].code #=> "af"
      #   languages[0].name #=> "Afrikaans"
      #
      class Language
        ##
        # The language code. This is an [ISO
        # 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) language
        # code.
        #
        # @return [String]
        attr_reader :code

        ##
        # The localized name of the language, if available.
        #
        # @return [String]
        attr_reader :name

        ##
        # @private Create a new object.
        def initialize code, name
          @code = code
          @name = name
        end

        ##
        # @private New Language from a LanguagesResource object as defined by
        # the Google API Client object.
        def self.from_gapi gapi
          new gapi["language"], gapi["name"]
        end
      end
    end
  end
end
