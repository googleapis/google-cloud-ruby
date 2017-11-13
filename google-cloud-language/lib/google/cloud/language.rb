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


require "google-cloud-language"
require "google/cloud/language/project"

module Google
  module Cloud
    ##
    # # Google Cloud Natural Language API
    #
    # Google Cloud Natural Language API reveals the structure and meaning of
    # text by offering powerful machine learning models in an easy to use REST
    # API. You can use it to extract information about people, places, events
    # and much more, mentioned in text documents, news articles or blog posts.
    # You can use it to understand sentiment about your product on social media
    # or parse intent from customer conversations happening in a call center or
    # a messaging app. You can analyze text uploaded in your request or
    # integrate with your document storage on Google Cloud Storage. Combine the
    # API with the Google Cloud Speech API and extract insights from audio
    # conversations. Use with Vision API OCR to understand scanned documents.
    # Extract entities and understand sentiments in multiple languages by
    # translating text first with Cloud Translation API.
    #
    # For more information about Cloud Natural Language API, read the [Google
    # Cloud Natural Language API
    # Documentation](https://cloud.google.com/natural-language/docs/).
    #
    # The goal of google-cloud is to provide an API that is comfortable to
    # Rubyists. Authentication is handled by {Google::Cloud#language}. You can
    # provide the project and credential information to connect to the Cloud
    # Natural Language API, or if you are running on Google Compute Engine this
    # configuration is taken care of for you. You can read more about the
    # options for connecting in the [Authentication
    # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
    #
    # ## Creating documents
    #
    # Use {Language::Project#document} to create documents for the Cloud Natural
    # Language service. (The Cloud Natural Language API currently supports
    # English, Spanish, and Japanese.)
    #
    # You can provide text or HTML content as a string:
    #
    # ```ruby
    # require "google/cloud/language"
    #
    # language = Google::Cloud::Language.new
    #
    # document = language.document "It was the best of times, it was..."
    # ```
    #
    # Or, you can pass a Google Cloud Storage URI for a text or HTML file:
    #
    # ```ruby
    # require "google/cloud/language"
    #
    # language = Google::Cloud::Language.new
    #
    # document = language.document "gs://bucket-name/path/to/document"
    # ```
    #
    # Or, you can initialize it with a Google Cloud Storage File object:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "bucket-name"
    # file = bucket.file "path/to/document"
    #
    # require "google/cloud/language"
    #
    # language = Google::Cloud::Language.new
    #
    # document = language.document file
    # ```
    #
    # You can specify the format and language of the content:
    #
    # ```ruby
    # require "google/cloud/language"
    #
    # language = Google::Cloud::Language.new
    #
    # document = language.document "<p>El viejo y el mar</p>",
    #                              format: :html, language: "es"
    # ```
    #
    # Creating a Document instance does not perform an API request.
    #
    # ## Annotating documents
    #
    # The instance methods on {Language::Document} invoke Cloud Natural
    # Language's detection features individually. Each method call makes an API
    # request. If you want to run multiple features in a single request, see
    # the examples for {Language::Document#annotate}, below. Calling `annotate`
    # with no arguments will perform **all** analysis features. Each feature
    # is priced separately. See [Pricing](https://cloud.google.com/natural-language/pricing)
    # for details.
    #
    # Sentiment analysis inspects the given text and identifies the prevailing
    # emotional opinion within the text, especially to determine a writer's
    # attitude as positive, negative, or neutral. Sentiment analysis can be
    # performed with the {Language::Document#sentiment} method. Currently, only
    # English is supported for sentiment analysis.
    #
    # ```ruby
    # require "google/cloud/language"
    #
    # language = Google::Cloud::Language.new
    #
    # content = "Star Wars is a great movie. The Death Star is fearsome."
    # document = language.document content
    # sentiment = document.sentiment # API call
    #
    # sentiment.score #=> 0.10000000149011612
    # sentiment.magnitude #=> 1.100000023841858
    # ```
    #
    # Entity analysis inspects the given text for known entities (proper nouns
    # such as public figures, landmarks, etc.) and returns information about
    # those entities. Entity analysis can be performed with the
    # {Language::Document#entities} method.
    #
    # ```ruby
    # require "google/cloud/language"
    #
    # language = Google::Cloud::Language.new
    #
    # content = "Star Wars is a great movie. The Death Star is fearsome."
    # document = language.document content
    # entities = document.entities # API call
    #
    # entities.count #=> 3
    # entities.first.name #=> "Star Wars"
    # entities.first.type #=> :WORK_OF_ART
    # entities.first.mid #=> "/m/06mmr"
    # entities.first.wikipedia_url #=> "http://en.wikipedia.org/wiki/Star_Wars"
    # ```
    #
    # Syntactic analysis extracts linguistic information, breaking up the given
    # text into a series of sentences and tokens (generally, word boundaries),
    # providing further analysis on those tokens. Syntactic analysis can be
    # performed with the {Language::Document#syntax} method.
    #
    # ```ruby
    # require "google/cloud/language"
    #
    # language = Google::Cloud::Language.new
    #
    # content = "Star Wars is a great movie. The Death Star is fearsome."
    # document = language.document content
    # syntax = document.syntax # API call
    #
    # syntax.sentences.count #=> 2
    # syntax.tokens.count #=> 13
    # ```
    #
    # To run multiple features on a document in a single request, pass the flag
    # for each desired feature to {Language::Document#annotate}:
    #
    # ```ruby
    # require "google/cloud/language"
    #
    # language = Google::Cloud::Language.new
    #
    # content = "Star Wars is a great movie. The Death Star is fearsome."
    # document = language.document content
    # annotation = document.annotate entities: true, syntax: true
    #
    # annotation.entities.count #=> 3
    # annotation.sentences.count #=> 2
    # annotation.tokens.count #=> 13
    # ```
    #
    # Or, simply call {Language::Document#annotate} with no arguments to process
    # the document with **all** features:
    #
    # ```ruby
    # require "google/cloud/language"
    #
    # language = Google::Cloud::Language.new
    #
    # content = "Star Wars is a great movie. The Death Star is fearsome."
    # document = language.document content
    # annotation = document.annotate
    #
    # annotation.sentiment.score #=> 0.10000000149011612
    # annotation.sentiment.magnitude #=> 1.100000023841858
    # annotation.entities.count #=> 3
    # annotation.sentences.count #=> 2
    # annotation.tokens.count #=> 13
    # ```
    #
    module Language
      ##
      # Creates a new object for connecting to the Language service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String] project_id Identifier for a Natural Language project. If
      #   not present, the default project for the credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Language::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.goorequire
      #   "google/cloud"gle.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `"https://www.googleapis.com/auth/cloud-platform"`
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [Hash] client_config A hash of values to override the default
      #   behavior of the API client. Optional.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Language::Project]
      #
      # @example
      #   require "google/cloud/language"
      #
      #   language = Google::Cloud::Language.new
      #
      #   content = "Star Wars is a great movie. The Death Star is fearsome."
      #   document = language.document content
      #   annotation = document.annotate
      #
      def self.new project_id: nil, credentials: nil, scope: nil, timeout: nil,
                   client_config: nil, project: nil, keyfile: nil
        project_id ||= (project || Language::Project.default_project_id)
        project_id = project_id.to_s # Always cast to a string
        fail ArgumentError, "project_id is missing" if project_id.empty?

        credentials ||= (keyfile || Language::Credentials.default(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Language::Credentials.new credentials, scope: scope
        end

        Language::Project.new(
          Language::Service.new(
            project_id, credentials, timeout: timeout,
                                     client_config: client_config))
      end
    end
  end
end
