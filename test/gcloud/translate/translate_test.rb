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

describe Gcloud::Translate::Api, :translate, :mock_translate do
  it "doesn't make an API call if text is not given" do
    translation = translate.translate
    translation.must_be :nil?

    translation = translate.translate to: "es", from: :en, format: :html
    translation.must_be :nil?
  end

  it "translates a single input" do
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   "Hello"
      env.params["target"].must_equal "es"
      env.params["source"].must_be :nil?
      env.params["format"].must_be :nil?
      env.params["cid"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       translate_json("Hola", "en")]
    end

    translation = translate.translate "Hello", to: "es"
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
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   "Hello"
      env.params["target"].must_equal "es"
      env.params["source"].must_equal "en"
      env.params["format"].must_be :nil?
      env.params["cid"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       translate_json("Hola", nil)]
    end

    translation = translate.translate "Hello", to: "es", from: :en
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
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   "<h1>Hello</h1>"
      env.params["target"].must_equal "es"
      env.params["source"].must_be :nil?
      env.params["format"].must_equal "html"
      env.params["cid"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       translate_json("<h1>Hola</h1>", "en")]
    end

    translation = translate.translate "<h1>Hello</h1>", to: "es", format: :html
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
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   "Hello"
      env.params["target"].must_equal "es"
      env.params["source"].must_be :nil?
      env.params["format"].must_be :nil?
      env.params["cid"].must_equal "user-1234567899"
      [200, { "Content-Type" => "application/json" },
       translate_json("Hola", "en")]
    end

    translation = translate.translate "Hello", to: "es", cid: "user-1234567899"
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
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   ["Hello", "How are you today?"]
      env.params["target"].must_equal "es"
      env.params["source"].must_be :nil?
      env.params["format"].must_be :nil?
      env.params["cid"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       translate_json("Hola", "en", "Como estas hoy?", "en")]
    end

    translations = translate.translate "Hello", "How are you today?", to: "es"
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
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   ["Hello", "How are you today?"]
      env.params["target"].must_equal "es"
      env.params["source"].must_be :nil?
      env.params["format"].must_be :nil?
      env.params["cid"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       translate_json("Hola", "en", "Como estas hoy?", "en")]
    end

    translations = translate.translate ["Hello", "How are you today?"], to: "es"
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
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   ["Hello", "How are you today?"]
      env.params["target"].must_equal "es"
      env.params["source"].must_equal "en"
      env.params["format"].must_be :nil?
      env.params["cid"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       translate_json("Hola", nil, "Como estas hoy?", nil)]
    end

    translations = translate.translate "Hello", "How are you today?", to: :es, from: :en
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
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   ["Hello", "How are you today?"]
      env.params["target"].must_equal "es"
      env.params["source"].must_equal "en"
      env.params["format"].must_be :nil?
      env.params["cid"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       translate_json("Hola", nil, "Como estas hoy?", nil)]
    end

    translations = translate.translate ["Hello", "How are you today?"], to: :es, from: :en
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
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   ["<h1>Hello</h1>", "How are <em>you</em> today?"]
      env.params["target"].must_equal "es"
      env.params["source"].must_be :nil?
      env.params["format"].must_equal "html"
      env.params["cid"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       translate_json("<h1>Hola</h1>", "en", "Como estas <em>hoy</em>?", "en")]
    end

    translations = translate.translate "<h1>Hello</h1>", "How are <em>you</em> today?", to: "es", format: :html
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
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   ["<h1>Hello</h1>", "How are <em>you</em> today?"]
      env.params["target"].must_equal "es"
      env.params["source"].must_be :nil?
      env.params["format"].must_equal "html"
      env.params["cid"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       translate_json("<h1>Hola</h1>", "en", "Como estas <em>hoy</em>?", "en")]
    end

    translations = translate.translate ["<h1>Hello</h1>", "How are <em>you</em> today?"], to: "es", format: :html
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
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   ["Hello", "How are you today?"]
      env.params["target"].must_equal "es"
      env.params["source"].must_be :nil?
      env.params["format"].must_be :nil?
      env.params["cid"].must_equal "user-1234567899"
      [200, { "Content-Type" => "application/json" },
       translate_json("Hola", "en", "Como estas hoy?", "en")]
    end

    translations = translate.translate "Hello", "How are you today?", to: "es", cid: "user-1234567899"
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
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   ["Hello", "How are you today?"]
      env.params["target"].must_equal "es"
      env.params["source"].must_be :nil?
      env.params["format"].must_be :nil?
      env.params["cid"].must_equal "user-1234567899"
      [200, { "Content-Type" => "application/json" },
       translate_json("Hola", "en", "Como estas hoy?", "en")]
    end

    translations = translate.translate ["Hello", "How are you today?"], to: "es", cid: "user-1234567899"
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
