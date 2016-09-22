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

require "google/cloud/translate"

# TODO: Pull up for reuse across services
module Google
  module Cloud
    def self.stub_service name
      original_method = "__google_cloud_yard_doctest__#{name}"
      raise "Method '#{name}' not found." unless respond_to?(name) && methods.map(&:to_s).include?(name.to_s)
      alias_method original_method, name
      define_method name do |*args|
        yield *args
      end
    end

    def self.unstub_service name
      original_method = "__google_cloud_yard_doctest__#{name}"
      if respond_to?(original_method) && methods.map(&:to_s).include?(original_method.to_s)
        puts "undef_method #{name}"
        undef_method name
        alias_method name, original_method
        undef_method original_method
      end
    end
  end
end

# TODO: Pull up for reuse across services
def mock_service name
  #if name == :translate # TODO: case for each service
  Google::Cloud.stub_service name do |*args|
    key = "test-api-key"
    translate = Google::Cloud::Translate::Api.new(Google::Cloud::Translate::Service.new(key))

    translate.service.mocked_service = Minitest::Mock.new
    yield translate.service.mocked_service
    translate
  end
end

# Mocks: setup and teardown for all tests

YARD::Doctest.configure do |doctest|
  doctest.skip "Google::Cloud.translate" # Do not unit test service factory class methods
  doctest.before("Google::Cloud#translate") do
    mock_service :translate do |mock|
      res_attrs = { detected_source_language: "en", translated_text: "Salve mundi!" }
      mock.expect :list_translations, list_translations_response([res_attrs]), [["Hello world!"], "la", {:cid=>nil, :format=>nil, :source=>nil}]
    end
  end
  doctest.before("Google::Cloud#translate@Using API Key from the environment variable.") do
    mock_service :translate do |mock|
      res_attrs = { detected_source_language: "en", translated_text: "Salve mundi!" }
      mock.expect :list_translations, list_translations_response([res_attrs]), [["Hello world!"], "la", {:cid=>nil, :format=>nil, :source=>nil}]
    end
  end
  doctest.before("Google::Cloud::Translate::Api") do
    mock_service :translate do |mock|
      res_attrs = { detected_source_language: "en", translated_text: "Salve mundi!" }
      mock.expect :list_translations, list_translations_response([res_attrs]), [["Hello world!"], "la", {:cid=>nil, :format=>nil, :source=>nil}]
    end
  end
  doctest.before("Google::Cloud::Translate::Api#translate") do
    mock_service :translate do |mock|
      res_attrs = { detected_source_language: "en", translated_text: "Salve mundi!" }
      mock.expect :list_translations, list_translations_response([res_attrs]), [["Hello world!"], "la", {:cid=>nil, :format=>nil, :source=>nil}]
    end
  end
  doctest.before("Google::Cloud::Translate::Api#translate@Setting the `from` language.") do
    mock_service :translate do |mock|
      res_attrs = { detected_source_language: nil, translated_text: "Salve mundi!" }
      mock.expect :list_translations, list_translations_response([res_attrs]), [["Hello world!"], "la", {:cid=>nil, :format=>nil, :source=>"en"}]
    end
  end
  doctest.before("Google::Cloud::Translate::Api#translate@Retrieving multiple translations.") do
    mock_service :translate do |mock|
      res_attrs_1 = { detected_source_language: nil, translated_text: "Salve amice." }
      res_attrs_2 = { detected_source_language: nil, translated_text: "Vide te mox." }
      mock.expect :list_translations, list_translations_response([res_attrs_1, res_attrs_2]), [["Hello my friend.", "See you soon."], "la", {:cid=>nil, :format=>nil, :source=>"en"}]
    end
  end
  doctest.before("Google::Cloud::Translate::Api#translate@Preserving HTML tags.") do
    mock_service :translate do |mock|
      res_attrs = { detected_source_language: nil, translated_text: "<strong>Salve</strong> mundi!" }
      mock.expect :list_translations, list_translations_response([res_attrs]), [["<strong>Hello</strong> world!"], "la", {:cid=>nil, :format=>nil, :source=>nil}]
    end
  end
  doctest.before("Google::Cloud::Translate::Api#detect") do
    mock_service :translate do |mock|
      res_attrs = { confidence: 0.7100697, language: "en", is_reliable: false }
      mock.expect :list_detections, list_detections_response([res_attrs]), [["Hello world!"]]
    end
  end
  doctest.before("Google::Cloud::Translate::Api#detect@Detecting multiple texts.") do
    mock_service :translate do |mock|
      res_attrs = { confidence: 0.7100697, language: "en", is_reliable: false }
      res_attrs_2 = { confidence: 0.40440267, language: "fr", is_reliable: false }
      mock.expect :list_detections, list_detections_response([res_attrs, res_attrs_2]), [["Hello world!", "Bonjour le monde!"]]
    end
  end
  doctest.before("Google::Cloud::Translate::Api#languages") do
    mock_service :translate do |mock|
      res_attrs = { language: "en", name: nil }
      mock.expect :list_languages, list_languages_response(res_attrs), [{:target=>nil}]
    end
  end
  doctest.before("Google::Cloud::Translate::Api#languages@Get all languages with their names in French.") do
    mock_service :translate do |mock|
      res_attrs = { language: "en", name: "Anglais" }
      mock.expect :list_languages, list_languages_response(res_attrs), [{:target=>"fr"}]
    end
  end
  doctest.before("Google::Cloud::Translate::Detection") do
    mock_service :translate do |mock|
      res_attrs = { confidence: 0.7109375, language: "fr", is_reliable: false }
      res_attrs_2 = { confidence: 0.59922177, language: "en", is_reliable: false }
      mock.expect :list_detections, list_detections_response([res_attrs, res_attrs_2]), [["chien", "chat"]]
    end
  end
  doctest.before("Google::Cloud::Translate::Language") do
    mock_service :translate do |mock|
      res_attrs = { language: "af", name: "Afrikaans" }
      mock.expect :list_languages, list_languages_response(res_attrs), [{:target=>"en"}]
    end
  end
  doctest.before("Google::Cloud::Translate::Translation") do
    mock_service :translate do |mock|
      res_attrs = { detected_source_language: "en", translated_text: "Salve mundi!" }
      mock.expect :list_translations, list_translations_response([res_attrs]), [["Hello world!"], "la", {:cid=>nil, :format=>nil, :source=>nil}]
    end
  end

  doctest.after do
    #Google::Cloud.unstub_service :translate  # TODO: Investigate why this has no effect, fix, and restore
  end
end

# Fixture helpers

def list_translations_response attrs_arr
  translations = attrs_arr.map do |attrs|
    Google::Cloud::Translate::Service::API::TranslationsResource.new attrs
  end
  Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: translations
end

def list_detections_response attrs_arr
  detections = attrs_arr.map do |attrs|
    [Google::Cloud::Translate::Service::API::DetectionsResource.new(attrs)]
  end
  Google::Cloud::Translate::Service::API::ListDetectionsResponse.new detections: detections
end

def list_languages_response attrs
  languages_resources = (1..104).map do
    Google::Cloud::Translate::Service::API::LanguagesResource.new attrs
  end
  Google::Cloud::Translate::Service::API::ListLanguagesResponse.new languages: languages_resources
end




