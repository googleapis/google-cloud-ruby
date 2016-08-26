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
    # translating text first with Translate API.
    #
    # The Google Cloud Natural Language API is currently a beta release, and
    # might be changed in backward-incompatible ways. It is not subject to any
    # SLA or deprecation policy and is not intended for real-time usage in
    # critical applications.
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
    # Cloud Natural Language API supports UTF-8, UTF-16, and UTF-32 encodings.
    # (Ruby uses UTF-8 natively, which is the default sent to the API, so unless
    # you're working with text processed in different platform, you should not
    # need to set the encoding type.) Be aware that only English, Spanish, and
    # Japanese language content are supported, and `sentiment` analysis only
    # supports English text.
    #
    # Use {Language::Project#document} to create documents for the Cloud Natural
    # Language service. You can provide text or HTML content as a string:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # language = gcloud.language
    #
    # document = language.document "It was the best of times, it was..."
    # ```
    #
    # Or, you can pass a Google Cloud Storage URI for a text or HTML file:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # language = gcloud.language
    #
    # document = language.document "gs://bucket-name/path/to/document"
    # ```
    #
    # Or, you can initialize it with a Google Cloud Storage File object:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # storage = gcloud.storage
    #
    # bucket = storage.bucket "bucket-name"
    # file = bucket.file "path/to/document"
    #
    # language = gcloud.language
    #
    # document = language.document file
    # ```
    #
    # You can specify the format and language of the content:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # language = gcloud.language
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
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # language = gcloud.language
    #
    # content = "Darth Vader is the best villain in Star Wars."
    # document = language.document content
    # sentiment = document.sentiment # API call
    #
    # sentiment.polarity #=> 1.0
    # sentiment.magnitude #=> 0.8999999761581421
    # ```
    #
    # Entity analysis inspects the given text for known entities (proper nouns
    # such as public figures, landmarks, etc.) and returns information about
    # those entities. Entity analysis can be performed with the
    # {Language::Document#entities} method.
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # language = gcloud.language
    #
    # content = "Darth Vader is the best villain in Star Wars."
    # document = language.document content
    # entities = document.entities # API call
    #
    # entities.count #=> 2
    # entities.first.name #=> "Darth Vader"
    # entities.first.type #=> :PERSON
    # entities.first.name #=> "Star Wars"
    # entities.first.type #=> :WORK_OF_ART
    # ```
    #
    # Syntactic analysis extracts linguistic information, breaking up the given
    # text into a series of sentences and tokens (generally, word boundaries),
    # providing further analysis on those tokens. Syntactic analysis can be
    # performed with the {Language::Document#syntax} method.
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # language = gcloud.language
    #
    # content = "Darth Vader is the best villain in Star Wars."
    # document = language.document content
    # syntax = document.syntax # API call
    #
    # syntax.sentences.count #=> 1
    # syntax.tokens.count #=> 10
    # ```
    #
    # To run multiple features on a document in a single request, pass the flag
    # for each desired feature to {Language::Document#annotate}:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # language = gcloud.language
    #
    # content = "Darth Vader is the best villain in Star Wars."
    # document = language.document content
    # annotation = document.annotate entities: true, text: true
    #
    # annotation.sentiment #=> nil
    # annotation.entities.count #=> 2
    # annotation.sentences.count #=> 1
    # annotation.tokens.count #=> 10
    # ```
    #
    # Or, simply call {Language::Document#annotate} with no arguments to process
    # the document with **all** features:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # language = gcloud.language
    #
    # content = "Darth Vader is the best villain in Star Wars."
    # document = language.document content
    # annotation = document.annotate
    #
    # annotation.sentiment.polarity #=> 1.0
    # annotation.sentiment.magnitude #=> 0.8999999761581421
    # annotation.entities.count #=> 2
    # annotation.sentences.count #=> 1
    # annotation.tokens.count #=> 10
    # ```
    #
    module Language
    end
  end
end
