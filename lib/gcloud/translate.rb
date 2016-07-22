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
  # Unlike other Cloud Platform services, which authenticate using a project ID
  # and OAuth 2.0 credentials, Google Translate API requires a public API access
  # key. (This may change in future releases of Google Translate API.) Follow
  # the general instructions at [Identifying your application to
  # Google](https://cloud.google.com/translate/v2/using_rest#auth), and the
  # specific instructions for [Server
  # keys](https://cloud.google.com/translate/v2/using_rest#creating-server-api-keys).
  #
  # @param [String] key a public API access key (not an OAuth 2.0 token)
  # @param [Integer] retries Number of times to retry requests on server error.
  #   The default value is `3`. Optional.
  # @param [Integer] timeout Default timeout to use in requests. Optional.
  #
  # @return [Gcloud::Translate::Api]
  #
  # @example
  #   require "gcloud"
  #
  #   translate = Gcloud.translate "api-key-abc123XYZ789"
  #
  #   translation = translate.translate "Hello world!", to: "la"
  #   translation.text #=> "Salve mundi!"
  #
  # @example Using API Key from the environment variable.
  #   require "gcloud"
  #
  #   ENV["TRANSLATE_KEY"] = "api-key-abc123XYZ789"
  #
  #   translate = Gcloud.translate
  #
  #   translation = translate.translate "Hello world!", to: "la"
  #   translation.text #=> "Salve mundi!"
  #
  def self.translate key = nil, retries: nil, timeout: nil
    key ||= ENV["TRANSLATE_KEY"]
    if key.nil?
      key_missing_msg = "An API key is required to use the Translate API."
      fail ArgumentError, key_missing_msg
    end

    Gcloud::Translate::Api.new(
      Gcloud::Translate::Service.new(
        key, retries: retries, timeout: timeout))
  end

  ##
  # # Google Translate API
  #
  # [Google Translate API](https://cloud.google.com/translate/) provides a
  # simple, programmatic interface for translating an arbitrary string into any
  # supported language. It is highly responsive, so websites and applications
  # can integrate with Translate API for fast, dynamic translation of source
  # text. Language detection is also available in cases where the source
  # language is unknown.
  #
  # Translate API supports more than ninety different languages, from Afrikaans
  # to Zulu. Used in combination, this enables translation between thousands of
  # language pairs. Also, you can send in HTML and receive HTML with translated
  # text back. You don't need to extract your source text or reassemble the
  # translated content.
  #
  # ## Authenticating
  #
  # Unlike other Cloud Platform services, which authenticate using a project ID
  # and OAuth 2.0 credentials, Translate API requires a public API access key.
  # (This may change in future releases of Translate API.) Follow the general
  # instructions at [Identifying your application to
  # Google](https://cloud.google.com/translate/v2/using_rest#auth), and the
  # specific instructions for [Server
  # keys](https://cloud.google.com/translate/v2/using_rest#creating-server-api-keys).
  #
  # ## Translating texts
  #
  # Translating text from one language to another is easy (and extremely fast.)
  # The only required arguments to {Gcloud::Translate::Api#translate} are a
  # string and the [ISO
  # 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) code of the
  # language to which you wish to translate.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # translate = gcloud.translate
  #
  # translation = translate.translate "Hello world!", to: "la"
  #
  # puts translation #=> Salve mundi!
  #
  # translation.from #=> "en"
  # translation.origin #=> "Hello world!"
  # translation.to #=> "la"
  # translation.text #=> "Salve mundi!"
  # ```
  #
  # You may want to use the `from` option to specify the language of the source
  # text, as the following example illustrates. (Single words do not give
  # Translate API much to work with.)
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # translate = gcloud.translate
  #
  # translation = translate.translate "chat", to: "en"
  #
  # translation.detected? #=> true
  # translation.from #=> "en"
  # translation.text #=> "chat"
  #
  # translation = translate.translate "chat", from: "fr", to: "en"
  #
  # translation.detected? #=> false
  # translation.from #=> "fr"
  # translation.text #=> "cat"
  # ```
  #
  # You can pass multiple texts to {Gcloud::Translate::Api#translate}.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # translate = gcloud.translate
  #
  # translations = translate.translate "chien", "chat", from: "fr", to: "en"
  #
  # translations.size #=> 2
  # translations[0].origin #=> "chien"
  # translations[0].text #=> "dog"
  # translations[1].origin #=> "chat"
  # translations[1].text #=> "cat"
  # ```
  #
  # By default, any HTML in your source text will be preserved.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # translate = gcloud.translate
  #
  # translation = translate.translate "<strong>Hello</strong> world!",
  #                                   to: :la
  # translation.text #=> "<strong>Salve</strong> mundi!"
  # ```
  #
  # ## Detecting languages
  #
  # You can use {Gcloud::Translate::Api#detect} to see which language the
  # Translate API ranks as the most likely source language for a text. The
  # `confidence` score is a float value between `0` and `1`.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # translate = gcloud.translate
  #
  # detection = translate.detect "chat"
  #
  # detection.text #=> "chat"
  # detection.language #=> "en"
  # detection.confidence #=> 0.59922177
  # ```
  #
  # You can pass multiple texts to {Gcloud::Translate::Api#detect}.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # translate = gcloud.translate
  #
  # detections = translate.detect "chien", "chat"
  #
  # detections.size #=> 2
  # detections[0].text #=> "chien"
  # detections[0].language #=> "fr"
  # detections[0].confidence #=> 0.7109375
  # detections[1].text #=> "chat"
  # detections[1].language #=> "en"
  # detections[1].confidence #=> 0.59922177
  # ```
  #
  # ## Listing supported languages
  #
  # Translate API adds new languages frequently. You can use
  # {Gcloud::Translate::Api#languages} to query the list of supported languages.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # translate = gcloud.translate
  #
  # languages = translate.languages
  #
  # languages.size #=> 104
  # languages[0].code #=> "af"
  # languages[0].name #=> nil
  # ```
  #
  # To receive the names of the supported languages, as well as their [ISO
  # 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) codes, provide
  # the code for the language in which you wish to receive the names.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # translate = gcloud.translate
  #
  # languages = translate.languages "en"
  #
  # languages.size #=> 104
  # languages[0].code #=> "af"
  # languages[0].name #=> "Afrikaans"
  # ```
  #
  # ## Configuring retries and timeout
  #
  # You can configure how many times API requests may be automatically retried.
  # When an API request fails, the response will be inspected to see if the
  # request meets criteria indicating that it may succeed on retry, such as
  # `500` and `503` status codes or a specific internal error code such as
  # `rateLimitExceeded`. If it meets the criteria, the request will be retried
  # after a delay. If another error occurs, the delay will be increased before a
  # subsequent attempt, until the `retries` limit is reached.
  #
  # You can also set the request `timeout` value in seconds.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # translate = gcloud.translate retries: 10, timeout: 120
  # ```
  #
  module Translate
  end
end
