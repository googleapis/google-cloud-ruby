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

##
# This file is here to be autorequired by bundler, so that the
# Google::Cloud.translate and Google::Cloud#translate methods can be available,
# but the library and all dependencies won't be loaded until required and used.


gem "google-cloud-core"
require "google/cloud" unless defined? Google::Cloud.new
require "google/cloud/config"
require "googleauth"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Cloud Translation API. Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the {file:AUTHENTICATION.md Authentication Guide}.
    #
    # To use the legacy v2 client, call {Google::Cloud::Translate.new} and specify `version: :v2`.
    #
    # @param [String] key a public API access key (not an OAuth 2.0 token)
    # @param [String, Array<String>] scopes The OAuth 2.0 scopes controlling the set of resources and operations that
    #   the connection can access. See [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scopes are:
    #
    #   * `https://www.googleapis.com/auth/cloud-platform`
    #   * `https://www.googleapis.com/auth/cloud-translation`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Translate::V3::TranslationServiceClient]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   client = gcloud.translate
    #
    #   project_id = "my-project-id"
    #   location_id = "us-central1"
    #   model_id = "my-automl-model-id"
    #
    #   # The `model` type requested for this translation.
    #   model = "projects/#{project_id}/locations/#{location_id}/models/#{model_id}"
    #   # The content to translate in string format
    #   contents = ["Hello, world!"]
    #   # Required. The BCP-47 language code to use for translation.
    #   target_language = "fr"
    #   # Optional. The BCP-47 language code of the input text.
    #   source_language = "en"
    #   # Optional. Can be "text/plain" or "text/html".
    #   mime_type = "text/plain"
    #   parent = client.class.location_path project_id, location_id
    #
    #   response = client.translate_text contents, target_language, parent,
    #     source_language_code: source_language, model: model, mime_type: mime_type
    #
    #   # Display the translation for each input text provided
    #   response.translations.each do |translation|
    #     puts "Translated text: #{translation.translated_text}"
    #   end
    #
    def translate scopes: nil, timeout: nil
      Google::Cloud.translate credentials: @keyfile, scopes: scopes, timeout: (timeout || @timeout)
    end

    ##
    # Creates a new object for connecting to the Cloud Translation API. Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the {file:AUTHENTICATION.md Authentication Guide}.
    #
    # To use the legacy v2 client, call {Google::Cloud::Translate.new} and specify `version: :v2`.
    #
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to the keyfile as a String, the contents of
    #   the keyfile as a Hash, or a Google::Auth::Credentials object. (See {Google::Cloud::Translate::V3::Credentials})
    # @param [String, Array<String>] scopes The OAuth 2.0 scopes controlling the set of resources and operations that
    #   the connection can access. See [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scopes are:
    #
    #   * `https://www.googleapis.com/auth/cloud-platform`
    #   * `https://www.googleapis.com/auth/cloud-translation`
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Translate::V3::TranslationServiceClient]
    #
    # @example
    #   require "google/cloud"
    #
    #   client = Google::Cloud.translate
    #
    #   project_id = "my-project-id"
    #   location_id = "us-central1"
    #   model_id = "my-automl-model-id"
    #
    #   # The `model` type requested for this translation.
    #   model = "projects/#{project_id}/locations/#{location_id}/models/#{model_id}"
    #   # The content to translate in string format
    #   contents = ["Hello, world!"]
    #   # Required. The BCP-47 language code to use for translation.
    #   target_language = "fr"
    #   # Optional. The BCP-47 language code of the input text.
    #   source_language = "en"
    #   # Optional. Can be "text/plain" or "text/html".
    #   mime_type = "text/plain"
    #   parent = client.class.location_path project_id, location_id
    #
    #   response = client.translate_text contents, target_language, parent,
    #     source_language_code: source_language, model: model, mime_type: mime_type
    #
    #   # Display the translation for each input text provided
    #   response.translations.each do |translation|
    #     puts "Translated text: #{translation.translated_text}"
    #   end
    #
    def self.translate credentials: nil, scopes: nil, timeout: nil
      require "google/cloud/translate/v3"
      Google::Cloud::Translate::V3.new credentials: credentials, scopes: scopes, timeout: timeout
    end
  end
end

# Set the default translate configuration
Google::Cloud.configure.add_config! :translate do |config|
  default_project = Google::Cloud::Config.deferred do
    ENV["TRANSLATE_PROJECT"]
  end
  default_creds = Google::Cloud::Config.deferred do
    Google::Cloud::Config.credentials_from_env(
      "TRANSLATE_CREDENTIALS", "TRANSLATE_CREDENTIALS_JSON", "TRANSLATE_KEYFILE", "TRANSLATE_KEYFILE_JSON"
    )
  end
  default_key = Google::Cloud::Config.deferred do
    ENV["TRANSLATE_KEY"] || ENV["GOOGLE_CLOUD_KEY"]
  end

  config.add_field! :project_id, default_project, match: String, allow_nil: true
  config.add_field! :credentials, default_creds, match: [String, Hash, Google::Auth::Credentials], allow_nil: true
  config.add_field! :key, default_key, match: String, allow_nil: true
  config.add_field! :scope, nil, match: [String, Array]
  config.add_field! :retries, nil, match: Integer
  config.add_field! :timeout, nil, match: Integer
  config.add_field! :endpoint, nil, match: String
end
