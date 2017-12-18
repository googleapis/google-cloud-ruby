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
    translations_resource = { detectedSourceLanguage: "en", translatedText: "Hola" }
    list_translations_resource = JSON.parse({ translations: [translations_resource] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello"], to: "es", from: nil, format: nil, model: nil, cid: nil]

    translate.service = mock
    translation = translate.translate "Hello", to: "es"
    mock.verify

    translation.text.must_equal "Hola"
    translation.origin.must_equal "Hello"
    translation.to.must_equal "es"
    translation.language.must_equal "es"
    translation.target.must_equal "es"
    translation.from.must_equal "en"
    translation.source.must_equal "en"
    translation.model.must_be :nil?
    translation.must_be :detected?
  end

  it "translates a single input with from" do
    mock = Minitest::Mock.new
    translations_resource = { translatedText: "Hola" }
    list_translations_resource = JSON.parse({ translations: [translations_resource] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello"], to: "es", model: nil, cid: nil, format: nil, from: "en"]

    translate.service = mock
    translation = translate.translate "Hello", to: "es", from: :en
    mock.verify

    translation.text.must_equal "Hola"
    translation.origin.must_equal "Hello"
    translation.to.must_equal "es"
    translation.language.must_equal "es"
    translation.target.must_equal "es"
    translation.from.must_equal "en"
    translation.source.must_equal "en"
    translation.model.must_be :nil?
    translation.wont_be :detected?
  end

  it "translates a single input with format" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "<h1>Hola</h1>" }
    list_translations_resource = JSON.parse({ translations: [translations_resource] }.to_json)
    mock.expect :translate, list_translations_resource, [["<h1>Hello</h1>"], to: "es", model: nil, cid: nil, format: "html", from: nil]

    translate.service = mock
    translation = translate.translate "<h1>Hello</h1>", to: "es", format: :html
    mock.verify

    translation.text.must_equal "<h1>Hola</h1>"
    translation.origin.must_equal "<h1>Hello</h1>"
    translation.to.must_equal "es"
    translation.language.must_equal "es"
    translation.target.must_equal "es"
    translation.from.must_equal "en"
    translation.source.must_equal "en"
    translation.model.must_be :nil?
    translation.must_be :detected?
  end

  it "translates a single input with model" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "Hola", model: "nmt" }
    list_translations_resource = JSON.parse({ translations: [translations_resource] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello"], to: "es", format: nil, from: nil, model: :nmt, cid: nil]

    translate.service = mock
    translation = translate.translate "Hello", to: "es", model: :nmt
    mock.verify

    translation.text.must_equal "Hola"
    translation.origin.must_equal "Hello"
    translation.to.must_equal "es"
    translation.language.must_equal "es"
    translation.target.must_equal "es"
    translation.from.must_equal "en"
    translation.source.must_equal "en"
    translation.model.must_equal "nmt"
    translation.must_be :detected?
  end

  it "translates a single input with cid" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "Hola" }
    list_translations_resource = JSON.parse({ translations: [translations_resource] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello"], to: "es", cid: "user-1234567899", format: nil, from: nil, model: nil]

    translate.service = mock
    translation = translate.translate "Hello", to: "es", cid: "user-1234567899"
    mock.verify

    translation.text.must_equal "Hola"
    translation.origin.must_equal "Hello"
    translation.to.must_equal "es"
    translation.language.must_equal "es"
    translation.target.must_equal "es"
    translation.from.must_equal "en"
    translation.source.must_equal "en"
    translation.model.must_be :nil?
    translation.must_be :detected?
  end

  it "translates multiple inputs" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "Hola" }
    translations_resource_2 = { detectedSourceLanguage: "en", translatedText: "Como estas hoy?" }
    list_translations_resource = JSON.parse({ translations: [translations_resource, translations_resource_2] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello", "How are you today?"], to: "es", model: nil, cid: nil, format: nil, from: nil]

    translate.service = mock
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
    translations.first.model.must_be :nil?
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.model.must_be :nil?
    translations.last.must_be :detected?
  end

  it "translates multiple inputs in an array" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "Hola" }
    translations_resource_2 = { detectedSourceLanguage: "en", translatedText: "Como estas hoy?" }
    list_translations_resource = JSON.parse({ translations: [translations_resource, translations_resource_2] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello", "How are you today?"], to: "es", model: nil, cid: nil, format: nil, from: nil]

    translate.service = mock
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
    translations.first.model.must_be :nil?
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.model.must_be :nil?
    translations.last.must_be :detected?
  end

  it "translates multiple inputs with from" do
    mock = Minitest::Mock.new
    translations_resource = { translatedText: "Hola" }
    translations_resource_2 = { translatedText: "Como estas hoy?" }
    list_translations_resource = JSON.parse({ translations: [translations_resource, translations_resource_2] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello", "How are you today?"], to: "es", model: nil, cid: nil, format: nil, from: "en"]

    translate.service = mock
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
    translations.first.model.must_be :nil?
    translations.first.wont_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.model.must_be :nil?
    translations.last.wont_be :detected?
  end

  it "translates multiple inputs in an array with from" do
    mock = Minitest::Mock.new
    translations_resource = { translatedText: "Hola" }
    translations_resource_2 = { translatedText: "Como estas hoy?" }
    list_translations_resource = JSON.parse({ translations: [translations_resource, translations_resource_2] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello", "How are you today?"], to: "es", model: nil, cid: nil, format: nil, from: "en"]

    translate.service = mock
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
    translations.first.model.must_be :nil?
    translations.first.wont_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.model.must_be :nil?
    translations.last.wont_be :detected?
  end

  it "translates multiple inputs with format" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "<h1>Hola</h1>" }
    translations_resource_2 = { detectedSourceLanguage: "en", translatedText: "Como estas <em>hoy</em>?" }
    list_translations_resource = JSON.parse({ translations: [translations_resource, translations_resource_2] }.to_json)
    mock.expect :translate, list_translations_resource, [["<h1>Hello</h1>", "How are <em>you</em> today?"], to: "es", model: nil, cid: nil, format: "html", from: nil]

    translate.service = mock
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
    translations.first.model.must_be :nil?
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas <em>hoy</em>?"
    translations.last.origin.must_equal "How are <em>you</em> today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.model.must_be :nil?
    translations.last.must_be :detected?
  end

  it "translates multiple inputs in an array with format" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "<h1>Hola</h1>" }
    translations_resource_2 = { detectedSourceLanguage: "en", translatedText: "Como estas <em>hoy</em>?" }
    list_translations_resource = JSON.parse({ translations: [translations_resource, translations_resource_2] }.to_json)
    mock.expect :translate, list_translations_resource, [["<h1>Hello</h1>", "How are <em>you</em> today?"], to: "es", model: nil, cid: nil, format: "html", from: nil]

    translate.service = mock
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
    translations.first.model.must_be :nil?
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas <em>hoy</em>?"
    translations.last.origin.must_equal "How are <em>you</em> today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.model.must_be :nil?
    translations.last.must_be :detected?
  end

  it "translates multiple inputs with cid" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "Hola" }
    translations_resource_2 = { detectedSourceLanguage: "en", translatedText: "Como estas hoy?" }
    list_translations_resource = JSON.parse({ translations: [translations_resource, translations_resource_2] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello", "How are you today?"], to: "es", cid: "user-1234567899", format: nil, from: nil, model: nil]

    translate.service = mock
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
    translations.first.model.must_be :nil?
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.model.must_be :nil?
    translations.last.must_be :detected?
  end

  it "translates multiple inputs in an array with model" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "Hola" }
    translations_resource_2 = { detectedSourceLanguage: "en", translatedText: "Como estas hoy?", model: "nmt" }
    list_translations_resource = JSON.parse({ translations: [translations_resource, translations_resource_2] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello", "How are you today?"], to: "es", format: nil, from: nil, model: "base", cid: nil]

    translate.service = mock
    translations = translate.translate ["Hello", "How are you today?"], to: "es", model: "base"
    mock.verify

    translations.count.must_equal 2

    translations.first.text.must_equal "Hola"
    translations.first.origin.must_equal "Hello"
    translations.first.to.must_equal "es"
    translations.first.language.must_equal "es"
    translations.first.target.must_equal "es"
    translations.first.from.must_equal "en"
    translations.first.source.must_equal "en"
    translations.first.model.must_be :nil?
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.model.must_equal "nmt"
    translations.last.must_be :detected?
  end

  it "translates multiple inputs with model" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "Hola", model: "base" }
    translations_resource_2 = { detectedSourceLanguage: "en", translatedText: "Como estas hoy?", model: "nmt" }
    list_translations_resource = JSON.parse({ translations: [translations_resource, translations_resource_2] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello", "How are you today?"], to: "es", format: nil, from: nil, model: :nmt, cid: nil]

    translate.service = mock
    translations = translate.translate "Hello", "How are you today?", to: "es", model: :nmt
    mock.verify

    translations.count.must_equal 2

    translations.first.text.must_equal "Hola"
    translations.first.origin.must_equal "Hello"
    translations.first.to.must_equal "es"
    translations.first.language.must_equal "es"
    translations.first.target.must_equal "es"
    translations.first.from.must_equal "en"
    translations.first.source.must_equal "en"
    translations.first.model.must_equal "base"
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.model.must_equal "nmt"
    translations.last.must_be :detected?
  end

  it "translates multiple inputs in an array with cid" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "Hola" }
    translations_resource_2 = { detectedSourceLanguage: "en", translatedText: "Como estas hoy?" }
    list_translations_resource = JSON.parse({ translations: [translations_resource, translations_resource_2] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello", "How are you today?"], to: "es", cid: "user-1234567899", format: nil, from: nil, model: nil]

    translate.service = mock
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
    translations.first.model.must_be :nil?
    translations.first.must_be :detected?

    translations.last.text.must_equal "Como estas hoy?"
    translations.last.origin.must_equal "How are you today?"
    translations.last.to.must_equal "es"
    translations.last.language.must_equal "es"
    translations.last.target.must_equal "es"
    translations.last.from.must_equal "en"
    translations.last.source.must_equal "en"
    translations.last.model.must_be :nil?
    translations.last.must_be :detected?
  end
end
