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
    class Language
      ##
      # The language code. This is an iso639-1 language code.
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
      # @private New Language from a LanguagesResource object as defined by the
      # Google API Client object.
      def self.from_gapi gapi
        new gapi["language"], gapi["name"]
      end
    end
  end
end
