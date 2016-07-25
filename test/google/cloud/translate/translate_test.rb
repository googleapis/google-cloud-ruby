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

require "helper"

describe Google::Cloud::Translate::Api, :translate, :mock_translate do
  it "doesn't make an API call if text is not given" do
    translation = translate.translate
    translation.must_be :nil?

    translation = translate.translate to: "es", from: :en, format: :html
    translation.must_be :nil?
  end

  it "translates a single input" do
    mock = Minitest::Mock.new
    translations_resource = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "Hola"
    list_translations_resource = Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: [translations_resource]
    mock.expect :list_translations, list_translations_resource, [["Hello"], "es", {cid: nil, format: nil, source: nil}]

    translate.service.mocked_service = mock
    translation = translate.translate "Hello", to: "es"
    mock.verify

    translation.text.must_equal "Hola"
    translation.origin.must_equal "Hello"
    translation.to.must_equal "es"
    translation.language.must_equal "es"
    translation.target.must_equal "es"
    translation.from.must_equal "en"
    translation.source.must_equal "en"
    translation.must_be :detected?
  end

  it "translates a single input with from" do
    mock = Minitest::Mock.new
    translations_resource = Google::Cloud::Translate::Service::API::TranslationsResource.new translated_text: "Hola"
    list_translations_resource = Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: [translations_resource]
    mock.expect :list_translations, list_translations_resource, [["Hello"], "es", {cid: nil, format: nil, source: "en"}]

    translate.service.mocked_service = mock
    translation = translate.translate "Hello", to: "es", from: :en
    mock.verify

    translation.text.must_equal "Hola"
    translation.origin.must_equal "Hello"
    translation.to.must_equal "es"
    translation.language.must_equal "es"
    translation.target.must_equal "es"
    translation.from.must_equal "en"
    translation.source.must_equal "en"
    translation.wont_be :detected?
  end

  it "translates a single input with format" do
    mock = Minitest::Mock.new
    translations_resource = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "<h1>Hola</h1>"
    list_translations_resource = Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: [translations_resource]
    mock.expect :list_translations, list_translations_resource, [["<h1>Hello</h1>"], "es", {cid: nil, format: "html", source: nil}]

    translate.service.mocked_service = mock
    translation = translate.translate "<h1>Hello</h1>", to: "es", format: :html
    mock.verify

    translation.text.must_equal "<h1>Hola</h1>"
    translation.origin.must_equal "<h1>Hello</h1>"
    translation.to.must_equal "es"
    translation.language.must_equal "es"
    translation.target.must_equal "es"
    translation.from.must_equal "en"
    translation.source.must_equal "en"
    translation.must_be :detected?
  end

  it "translates a single input with cid" do
    mock = Minitest::Mock.new
    translations_resource = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "Hola"
    list_translations_resource = Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: [translations_resource]
    mock.expect :list_translations, list_translations_resource, [["Hello"], "es", {cid: "user-1234567899", format: nil, source: nil}]

    translate.service.mocked_service = mock
    translation = translate.translate "Hello", to: "es", cid: "user-1234567899"
    mock.verify

    translation.text.must_equal "Hola"
    translation.origin.must_equal "Hello"
    translation.to.must_equal "es"
    translation.language.must_equal "es"
    translation.target.must_equal "es"
    translation.from.must_equal "en"
    translation.source.must_equal "en"
    translation.must_be :detected?
  end

  it "translates multiple inputs" do
    mock = Minitest::Mock.new
    translations_resource = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "Hola"
    translations_resource_2 = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "Como estas hoy?"
    list_translations_resource = Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: [translations_resource, translations_resource_2]
    mock.expect :list_translations, list_translations_resource, [["Hello", "How are you today?"], "es", {cid: nil, format: nil, source: nil}]

    translate.service.mocked_service = mock
    translations = translate.translate "Hello", "How are you today?", to: "es"
    mock.verify

    translations.count.must_equal 2

    translations.first.text.must_equal "Hola"
    translations.first.origin.must_equal "Hello"
    translations.first.to.must_equal "es"
    translations.first.language.must_equal "es"
    translations.first.target.must_equal "es"
    translations.first.from.must_equal "en"
    translations.first.source.must_equal "en"
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.must_be :detected?
  end

  it "translates multiple inputs in an array" do
    mock = Minitest::Mock.new
    translations_resource = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "Hola"
    translations_resource_2 = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "Como estas hoy?"
    list_translations_resource = Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: [translations_resource, translations_resource_2]
    mock.expect :list_translations, list_translations_resource, [["Hello", "How are you today?"], "es", {cid: nil, format: nil, source: nil}]

    translate.service.mocked_service = mock
    translations = translate.translate ["Hello", "How are you today?"], to: "es"
    mock.verify

    translations.count.must_equal 2

    translations.first.text.must_equal "Hola"
    translations.first.origin.must_equal "Hello"
    translations.first.to.must_equal "es"
    translations.first.language.must_equal "es"
    translations.first.target.must_equal "es"
    translations.first.from.must_equal "en"
    translations.first.source.must_equal "en"
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.must_be :detected?
  end

  it "translates multiple inputs with from" do
    mock = Minitest::Mock.new
    translations_resource = Google::Cloud::Translate::Service::API::TranslationsResource.new translated_text: "Hola"
    translations_resource_2 = Google::Cloud::Translate::Service::API::TranslationsResource.new translated_text: "Como estas hoy?"
    list_translations_resource = Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: [translations_resource, translations_resource_2]
    mock.expect :list_translations, list_translations_resource, [["Hello", "How are you today?"], "es", {cid: nil, format: nil, source: "en"}]

    translate.service.mocked_service = mock
    translations = translate.translate "Hello", "How are you today?", to: :es, from: :en
    mock.verify

    translations.count.must_equal 2

    translations.first.text.must_equal "Hola"
    translations.first.origin.must_equal "Hello"
    translations.first.to.must_equal "es"
    translations.first.language.must_equal "es"
    translations.first.target.must_equal "es"
    translations.first.from.must_equal "en"
    translations.first.source.must_equal "en"
    translations.first.wont_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.wont_be :detected?
  end

  it "translates multiple inputs in an array with from" do
    mock = Minitest::Mock.new
    translations_resource = Google::Cloud::Translate::Service::API::TranslationsResource.new translated_text: "Hola"
    translations_resource_2 = Google::Cloud::Translate::Service::API::TranslationsResource.new translated_text: "Como estas hoy?"
    list_translations_resource = Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: [translations_resource, translations_resource_2]
    mock.expect :list_translations, list_translations_resource, [["Hello", "How are you today?"], "es", {cid: nil, format: nil, source: "en"}]

    translate.service.mocked_service = mock
    translations = translate.translate ["Hello", "How are you today?"], to: :es, from: :en
    mock.verify

    translations.count.must_equal 2

    translations.first.text.must_equal "Hola"
    translations.first.origin.must_equal "Hello"
    translations.first.to.must_equal "es"
    translations.first.language.must_equal "es"
    translations.first.target.must_equal "es"
    translations.first.from.must_equal "en"
    translations.first.source.must_equal "en"
    translations.first.wont_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.wont_be :detected?
  end

  it "translates multiple inputs with format" do
    mock = Minitest::Mock.new
    translations_resource = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "<h1>Hola</h1>"
    translations_resource_2 = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "Como estas <em>hoy</em>?"
    list_translations_resource = Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: [translations_resource, translations_resource_2]
    mock.expect :list_translations, list_translations_resource, [["<h1>Hello</h1>", "How are <em>you</em> today?"], "es", {cid: nil, format: "html", source: nil}]

    translate.service.mocked_service = mock
    translations = translate.translate "<h1>Hello</h1>", "How are <em>you</em> today?", to: "es", format: :html
    mock.verify

    translations.count.must_equal 2

    translations.first.text.must_equal "<h1>Hola</h1>"
    translations.first.origin.must_equal "<h1>Hello</h1>"
    translations.first.to.must_equal "es"
    translations.first.language.must_equal "es"
    translations.first.target.must_equal "es"
    translations.first.from.must_equal "en"
    translations.first.source.must_equal "en"
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas <em>hoy</em>?"
    translations.last.origin.must_equal "How are <em>you</em> today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.must_be :detected?
  end

  it "translates multiple inputs in an array with format" do
    mock = Minitest::Mock.new
    translations_resource = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "<h1>Hola</h1>"
    translations_resource_2 = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "Como estas <em>hoy</em>?"
    list_translations_resource = Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: [translations_resource, translations_resource_2]
    mock.expect :list_translations, list_translations_resource, [["<h1>Hello</h1>", "How are <em>you</em> today?"], "es", {cid: nil, format: "html", source: nil}]

    translate.service.mocked_service = mock
    translations = translate.translate ["<h1>Hello</h1>", "How are <em>you</em> today?"], to: "es", format: :html
    mock.verify

    translations.count.must_equal 2

    translations.first.text.must_equal "<h1>Hola</h1>"
    translations.first.origin.must_equal "<h1>Hello</h1>"
    translations.first.to.must_equal "es"
    translations.first.language.must_equal "es"
    translations.first.target.must_equal "es"
    translations.first.from.must_equal "en"
    translations.first.source.must_equal "en"
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas <em>hoy</em>?"
    translations.last.origin.must_equal "How are <em>you</em> today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.must_be :detected?
  end

  it "translates multiple inputs with cid" do
    mock = Minitest::Mock.new
    translations_resource = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "Hola"
    translations_resource_2 = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "Como estas hoy?"
    list_translations_resource = Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: [translations_resource, translations_resource_2]
    mock.expect :list_translations, list_translations_resource, [["Hello", "How are you today?"], "es", {cid: "user-1234567899", format: nil, source: nil}]

    translate.service.mocked_service = mock
    translations = translate.translate "Hello", "How are you today?", to: "es", cid: "user-1234567899"
    mock.verify

    translations.count.must_equal 2

    translations.first.text.must_equal "Hola"
    translations.first.origin.must_equal "Hello"
    translations.first.to.must_equal "es"
    translations.first.language.must_equal "es"
    translations.first.target.must_equal "es"
    translations.first.from.must_equal "en"
    translations.first.source.must_equal "en"
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.must_be :detected?
  end

  it "translates multiple inputs in an array with cid" do
    mock = Minitest::Mock.new
    translations_resource = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "Hola"
    translations_resource_2 = Google::Cloud::Translate::Service::API::TranslationsResource.new detected_source_language: "en", translated_text: "Como estas hoy?"
    list_translations_resource = Google::Cloud::Translate::Service::API::ListTranslationsResponse.new translations: [translations_resource, translations_resource_2]
    mock.expect :list_translations, list_translations_resource, [["Hello", "How are you today?"], "es", {cid: "user-1234567899", format: nil, source: nil}]

    translate.service.mocked_service = mock
    translations = translate.translate ["Hello", "How are you today?"], to: "es", cid: "user-1234567899"
    mock.verify

    translations.count.must_equal 2

    translations.first.text.must_equal "Hola"
    translations.first.origin.must_equal "Hello"
    translations.first.to.must_equal "es"
    translations.first.language.must_equal "es"
    translations.first.target.must_equal "es"
    translations.first.from.must_equal "en"
    translations.first.source.must_equal "en"
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.must_be :detected?
  end
end
