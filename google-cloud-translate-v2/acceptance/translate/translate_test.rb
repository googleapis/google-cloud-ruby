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

require "translate_helper"

# This test is a ruby version of gcloud-node's translate test.

describe Google::Cloud::Translate, :translate do
  it "detects a langauge" do
    _(translate.detect("Hello").results.first.language).must_equal "en"
    _(translate.detect("Hola").results.first.language).must_equal "es"

    detections = translate.detect "Hello", "Hola"
    _(detections.count).must_equal 2
    detections.each { |d| _(d).must_be_kind_of Google::Cloud::Translate::V2::Detection }

    detections.first.results.each { |d| _(d).must_be_kind_of Google::Cloud::Translate::V2::Detection::Result }
    _(detections.first.language).must_equal detections.first.results.first.language
    _(detections.first.results.first.language).must_equal "en"
    _(detections.first.confidence).must_equal detections.first.results.first.confidence
    _(detections.first.results.first.confidence).must_equal 1.0

    _(detections.last.results.first.language).must_equal "es"
  end

  it "translates input" do
    _(translate.translate("Hello", to: "es").text).must_include "Hola"
    _(translate.translate("How are you today?", to: "es").text).must_equal "¿Cómo estás hoy?"

    translations = translate.translate "Hello", "How are you today?", to: "es"
    _(translations.count).must_equal 2
    _(translations.first.text).must_include "Hola"
    _(translations.last.text).must_equal "¿Cómo estás hoy?"
  end

  it "translates input with model attribute" do
    translation = translate.translate "Hello", to: "es", model: ""
    _(translation.text).must_include "Hola"
    _(translation.model).must_be :nil?

    translation = translate.translate "How are you today?", to: "es", model: "base"
    _(translation.text).must_equal "¿Cómo estás hoy?"
    _(translation.model).must_equal "base"

    translations = translate.translate "Hello", "How are you today?", to: :es, model: :nmt
    _(translations.count).must_equal 2
    _(translations.first.text).must_include "Hola"
    _(translations.first.model).must_equal "nmt"
    _(translations.last.text).must_equal "¿Cómo estás hoy?"
    _(translations.last.model).must_equal "nmt"
  end

  it "lists supported languages" do
    languages = translate.languages
    _(languages.count).must_be :>, 0
    _(languages.first.name).must_be :nil?

    languages = translate.languages "en"
    _(languages.count).must_be :>, 0
    _(languages.first.name).wont_be :nil?
  end
end
