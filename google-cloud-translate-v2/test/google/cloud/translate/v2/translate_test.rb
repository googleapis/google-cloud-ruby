# Copyright 2020 Google LLC
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

describe Google::Cloud::Translate::V2::Api, :translate, :mock_translate do
  it "doesn't make an API call if text is not given" do
    translation = translate.translate
    _(translation).must_be :nil?

    translation = translate.translate to: "es", from: :en, format: :html
    _(translation).must_be :nil?
  end

  it "translates a single input" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "Hola" }
    list_translations_resource = JSON.parse({ translations: [translations_resource] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello"], to: "es", from: nil, format: nil, model: nil, cid: nil]

    translate.service = mock
    translation = translate.translate "Hello", to: "es"
    mock.verify

    _(translation.text).must_equal "Hola"
    _(translation.origin).must_equal "Hello"
    _(translation.to).must_equal "es"
    _(translation.language).must_equal "es"
    _(translation.target).must_equal "es"
    _(translation.from).must_equal "en"
    _(translation.source).must_equal "en"
    _(translation.model).must_be :nil?
    _(translation).must_be :detected?
  end

  it "translates a single input with from" do
    mock = Minitest::Mock.new
    translations_resource = { translatedText: "Hola" }
    list_translations_resource = JSON.parse({ translations: [translations_resource] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello"], to: "es", model: nil, cid: nil, format: nil, from: "en"]

    translate.service = mock
    translation = translate.translate "Hello", to: "es", from: :en
    mock.verify

    _(translation.text).must_equal "Hola"
    _(translation.origin).must_equal "Hello"
    _(translation.to).must_equal "es"
    _(translation.language).must_equal "es"
    _(translation.target).must_equal "es"
    _(translation.from).must_equal "en"
    _(translation.source).must_equal "en"
    _(translation.model).must_be :nil?
    _(translation).wont_be :detected?
  end

  it "translates a single input with format" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "<h1>Hola</h1>" }
    list_translations_resource = JSON.parse({ translations: [translations_resource] }.to_json)
    mock.expect :translate, list_translations_resource, [["<h1>Hello</h1>"], to: "es", model: nil, cid: nil, format: "html", from: nil]

    translate.service = mock
    translation = translate.translate "<h1>Hello</h1>", to: "es", format: :html
    mock.verify

    _(translation.text).must_equal "<h1>Hola</h1>"
    _(translation.origin).must_equal "<h1>Hello</h1>"
    _(translation.to).must_equal "es"
    _(translation.language).must_equal "es"
    _(translation.target).must_equal "es"
    _(translation.from).must_equal "en"
    _(translation.source).must_equal "en"
    _(translation.model).must_be :nil?
    _(translation).must_be :detected?
  end

  it "translates a single input with model" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "Hola", model: "nmt" }
    list_translations_resource = JSON.parse({ translations: [translations_resource] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello"], to: "es", format: nil, from: nil, model: :nmt, cid: nil]

    translate.service = mock
    translation = translate.translate "Hello", to: "es", model: :nmt
    mock.verify

    _(translation.text).must_equal "Hola"
    _(translation.origin).must_equal "Hello"
    _(translation.to).must_equal "es"
    _(translation.language).must_equal "es"
    _(translation.target).must_equal "es"
    _(translation.from).must_equal "en"
    _(translation.source).must_equal "en"
    _(translation.model).must_equal "nmt"
    _(translation).must_be :detected?
  end

  it "translates a single input with cid" do
    mock = Minitest::Mock.new
    translations_resource = { detectedSourceLanguage: "en", translatedText: "Hola" }
    list_translations_resource = JSON.parse({ translations: [translations_resource] }.to_json)
    mock.expect :translate, list_translations_resource, [["Hello"], to: "es", cid: "user-1234567899", format: nil, from: nil, model: nil]

    translate.service = mock
    translation = translate.translate "Hello", to: "es", cid: "user-1234567899"
    mock.verify

    _(translation.text).must_equal "Hola"
    _(translation.origin).must_equal "Hello"
    _(translation.to).must_equal "es"
    _(translation.language).must_equal "es"
    _(translation.target).must_equal "es"
    _(translation.from).must_equal "en"
    _(translation.source).must_equal "en"
    _(translation.model).must_be :nil?
    _(translation).must_be :detected?
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

    _(translations.count).must_equal 2

    _(translations.first.text).must_equal "Hola"
    _(translations.first.origin).must_equal "Hello"
    _(translations.first.to).must_equal "es"
    _(translations.first.language).must_equal "es"
    _(translations.first.target).must_equal "es"
    _(translations.first.from).must_equal "en"
    _(translations.first.source).must_equal "en"
    _(translations.first.model).must_be :nil?
    _(translations.first).must_be :detected?

    _(translations.last.text).must_equal "Como estas hoy?"
    _(translations.last.origin).must_equal "How are you today?"
    _(translations.last.to).must_equal "es"
    _(translations.last.language).must_equal "es"
    _(translations.last.target).must_equal "es"
    _(translations.last.from).must_equal "en"
    _(translations.last.source).must_equal "en"
    _(translations.last.model).must_be :nil?
    _(translations.last).must_be :detected?
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

    _(translations.count).must_equal 2

    _(translations.first.text).must_equal "Hola"
    _(translations.first.origin).must_equal "Hello"
    _(translations.first.to).must_equal "es"
    _(translations.first.language).must_equal "es"
    _(translations.first.target).must_equal "es"
    _(translations.first.from).must_equal "en"
    _(translations.first.source).must_equal "en"
    _(translations.first.model).must_be :nil?
    _(translations.first).must_be :detected?

    _(translations.last.text).must_equal "Como estas hoy?"
    _(translations.last.origin).must_equal "How are you today?"
    _(translations.last.to).must_equal "es"
    _(translations.last.language).must_equal "es"
    _(translations.last.target).must_equal "es"
    _(translations.last.from).must_equal "en"
    _(translations.last.source).must_equal "en"
    _(translations.last.model).must_be :nil?
    _(translations.last).must_be :detected?
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

    _(translations.count).must_equal 2

    _(translations.first.text).must_equal "Hola"
    _(translations.first.origin).must_equal "Hello"
    _(translations.first.to).must_equal "es"
    _(translations.first.language).must_equal "es"
    _(translations.first.target).must_equal "es"
    _(translations.first.from).must_equal "en"
    _(translations.first.source).must_equal "en"
    _(translations.first.model).must_be :nil?
    _(translations.first).wont_be :detected?

    _(translations.last.text).must_equal "Como estas hoy?"
    _(translations.last.origin).must_equal "How are you today?"
    _(translations.last.to).must_equal "es"
    _(translations.last.language).must_equal "es"
    _(translations.last.target).must_equal "es"
    _(translations.last.from).must_equal "en"
    _(translations.last.source).must_equal "en"
    _(translations.last.model).must_be :nil?
    _(translations.last).wont_be :detected?
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

    _(translations.count).must_equal 2

    _(translations.first.text).must_equal "Hola"
    _(translations.first.origin).must_equal "Hello"
    _(translations.first.to).must_equal "es"
    _(translations.first.language).must_equal "es"
    _(translations.first.target).must_equal "es"
    _(translations.first.from).must_equal "en"
    _(translations.first.source).must_equal "en"
    _(translations.first.model).must_be :nil?
    _(translations.first).wont_be :detected?

    _(translations.last.text).must_equal "Como estas hoy?"
    _(translations.last.origin).must_equal "How are you today?"
    _(translations.last.to).must_equal "es"
    _(translations.last.language).must_equal "es"
    _(translations.last.target).must_equal "es"
    _(translations.last.from).must_equal "en"
    _(translations.last.source).must_equal "en"
    _(translations.last.model).must_be :nil?
    _(translations.last).wont_be :detected?
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

    _(translations.count).must_equal 2

    _(translations.first.text).must_equal "<h1>Hola</h1>"
    _(translations.first.origin).must_equal "<h1>Hello</h1>"
    _(translations.first.to).must_equal "es"
    _(translations.first.language).must_equal "es"
    _(translations.first.target).must_equal "es"
    _(translations.first.from).must_equal "en"
    _(translations.first.source).must_equal "en"
    _(translations.first.model).must_be :nil?
    _(translations.first).must_be :detected?

    _(translations.last.text).must_equal "Como estas <em>hoy</em>?"
    _(translations.last.origin).must_equal "How are <em>you</em> today?"
    _(translations.last.to).must_equal "es"
    _(translations.last.language).must_equal "es"
    _(translations.last.target).must_equal "es"
    _(translations.last.from).must_equal "en"
    _(translations.last.source).must_equal "en"
    _(translations.last.model).must_be :nil?
    _(translations.last).must_be :detected?
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

    _(translations.count).must_equal 2

    _(translations.first.text).must_equal "<h1>Hola</h1>"
    _(translations.first.origin).must_equal "<h1>Hello</h1>"
    _(translations.first.to).must_equal "es"
    _(translations.first.language).must_equal "es"
    _(translations.first.target).must_equal "es"
    _(translations.first.from).must_equal "en"
    _(translations.first.source).must_equal "en"
    _(translations.first.model).must_be :nil?
    _(translations.first).must_be :detected?

    _(translations.last.text).must_equal "Como estas <em>hoy</em>?"
    _(translations.last.origin).must_equal "How are <em>you</em> today?"
    _(translations.last.to).must_equal "es"
    _(translations.last.language).must_equal "es"
    _(translations.last.target).must_equal "es"
    _(translations.last.from).must_equal "en"
    _(translations.last.source).must_equal "en"
    _(translations.last.model).must_be :nil?
    _(translations.last).must_be :detected?
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

    _(translations.count).must_equal 2

    _(translations.first.text).must_equal "Hola"
    _(translations.first.origin).must_equal "Hello"
    _(translations.first.to).must_equal "es"
    _(translations.first.language).must_equal "es"
    _(translations.first.target).must_equal "es"
    _(translations.first.from).must_equal "en"
    _(translations.first.source).must_equal "en"
    _(translations.first.model).must_be :nil?
    _(translations.first).must_be :detected?

    _(translations.last.text).must_equal "Como estas hoy?"
    _(translations.last.origin).must_equal "How are you today?"
    _(translations.last.to).must_equal "es"
    _(translations.last.language).must_equal "es"
    _(translations.last.target).must_equal "es"
    _(translations.last.from).must_equal "en"
    _(translations.last.source).must_equal "en"
    _(translations.last.model).must_be :nil?
    _(translations.last).must_be :detected?
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

    _(translations.count).must_equal 2

    _(translations.first.text).must_equal "Hola"
    _(translations.first.origin).must_equal "Hello"
    _(translations.first.to).must_equal "es"
    _(translations.first.language).must_equal "es"
    _(translations.first.target).must_equal "es"
    _(translations.first.from).must_equal "en"
    _(translations.first.source).must_equal "en"
    _(translations.first.model).must_be :nil?
    _(translations.first).must_be :detected?

    _(translations.last.text).must_equal "Como estas hoy?"
    _(translations.last.origin).must_equal "How are you today?"
    _(translations.last.to).must_equal "es"
    _(translations.last.language).must_equal "es"
    _(translations.last.target).must_equal "es"
    _(translations.last.from).must_equal "en"
    _(translations.last.source).must_equal "en"
    _(translations.last.model).must_equal "nmt"
    _(translations.last).must_be :detected?
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

    _(translations.count).must_equal 2

    _(translations.first.text).must_equal "Hola"
    _(translations.first.origin).must_equal "Hello"
    _(translations.first.to).must_equal "es"
    _(translations.first.language).must_equal "es"
    _(translations.first.target).must_equal "es"
    _(translations.first.from).must_equal "en"
    _(translations.first.source).must_equal "en"
    _(translations.first.model).must_equal "base"
    _(translations.first).must_be :detected?

    _(translations.last.text).must_equal "Como estas hoy?"
    _(translations.last.origin).must_equal "How are you today?"
    _(translations.last.to).must_equal "es"
    _(translations.last.language).must_equal "es"
    _(translations.last.target).must_equal "es"
    _(translations.last.from).must_equal "en"
    _(translations.last.source).must_equal "en"
    _(translations.last.model).must_equal "nmt"
    _(translations.last).must_be :detected?
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

    _(translations.count).must_equal 2

    _(translations.first.text).must_equal "Hola"
    _(translations.first.origin).must_equal "Hello"
    _(translations.first.to).must_equal "es"
    _(translations.first.language).must_equal "es"
    _(translations.first.target).must_equal "es"
    _(translations.first.from).must_equal "en"
    _(translations.first.source).must_equal "en"
    _(translations.first.model).must_be :nil?
    _(translations.first).must_be :detected?

    _(translations.last.text).must_equal "Como estas hoy?"
    _(translations.last.origin).must_equal "How are you today?"
    _(translations.last.to).must_equal "es"
    _(translations.last.language).must_equal "es"
    _(translations.last.target).must_equal "es"
    _(translations.last.from).must_equal "en"
    _(translations.last.source).must_equal "en"
    _(translations.last.model).must_be :nil?
    _(translations.last).must_be :detected?
  end
end
