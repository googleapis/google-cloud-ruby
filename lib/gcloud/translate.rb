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


require "gcloud"
require "gcloud/translate/api"

module Gcloud
  ##
  # Creates a new object for connecting to the Translate service.
  # Each call creates a new connection.
  #
  # TODO: Add info for creatign an API Key here...
  # TODO: Explain that the API Key is likely temproary and can change in a
  # future release.
  #
  # @param [String] key API Key is blah blah blah...
  #
  # @return [Gcloud::Translate::Api]
  #
  # @example
  #   require "gcloud"
  #
  #   translate = Gcloud.translate "api-key-abc123XYZ789"
  #
  #   translation = translate.translate "Hello world!", to: "la"
  #   puts translation #=> Salve mundi!
  #
  # @example Using API Key from the environment variable.
  #   require "gcloud"
  #
  #   ENV["TRANSLATE_KEY"] = "api-key-abc123XYZ789"
  #
  #   translate = Gcloud.translate
  #
  #   translation = translate.translate "Hello world!", to: "la"
  #   puts translation #=> Salve mundi!
  #
  def self.translate key = nil
    Gcloud::Translate::Api.new key
  end

  ##
  # # Google Cloud Translate
  #
  # TODO: Explain how to obtain an API Key, linking to exisitng documents on
  # Google Cloud.
  # TODO: Explain that the API Key is likely temproary and can change in a
  # future release.
  # TODO: Show how to retrieve a translation.
  # TODO: Show how to retrieve a translation setting the `from`.
  # TODO: Show how to retrieve multiple translations, including `to` and `from`.
  # TODO: Show how to detect a language.
  # TODO: Show how to detect a language for multiple input strings.
  # TODO: Show how to get all the languages supported by the Google Cloud
  # Translate service.
  # TODO: Show how to get all the languages supported by the Google Cloud
  # Translate service and specify the language the names should be shown in.
  # (English vs. Spanish vs. Russian)
  #
  module Translate
  end
end
