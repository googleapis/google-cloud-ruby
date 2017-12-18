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

require "translate_helper"

# This test is a ruby version of gcloud-node's translate test.

describe Google::Cloud::Translate, :translate do
  it "detects a langauge" do
    translate.detect("Hello").results.first.language.must_equal "en"
    translate.detect("Hola").results.first.language.must_equal "es"

    detections = translate.detect "Hello", "Hola"
    detections.count.must_equal 2
    detections.each { |d| d.must_be_kind_of Google::Cloud::Translate::Detection }

    detections.first.results.each { |d| d.must_be_kind_of Google::Cloud::Translate::Detection::Result }
    detections.first.language.must_equal detections.first.results.first.language
    detections.first.results.first.language.must_equal "en"
    detections.first.confidence.must_equal detections.first.results.first.confidence
    detections.first.results.first.confidence.must_equal 1.0

    detections.last.results.first.language.must_equal "es"
  end

  it "translates input" do
    translate.translate("Hello", to: "es").text.must_include "Hola"
    translate.translate("How are you today?", to: "es").text.must_equal "¿Cómo estás hoy?"

    translations = translate.translate "Hello", "How are you today?", to: "es"
    translations.count.must_equal 2
    translations.first.text.must_include "Hola"
    translations.last.text.must_equal "¿Cómo estás hoy?"
  end

  it "translates input with model attribute" do
    translation = translate.translate "Hello", to: "es", model: ""
    translation.text.must_include "Hola"
    translation.model.must_be :nil?

    translation = translate.translate "How are you today?", to: "es", model: "base"
    translation.text.must_equal "¿Cómo estás hoy?"
    translation.model.must_equal "base"

    translations = translate.translate "Hello", "How are you today?", to: :es, model: :nmt
    translations.count.must_equal 2
    translations.first.text.must_include "Hola"
    translations.first.model.must_equal "nmt"
    translations.last.text.must_equal "¿Cómo estás hoy?"
    translations.last.model.must_equal "nmt"
  end

  it "lists supported languages" do
    languages = translate.languages
    languages.count.must_be :>, 0
    languages.first.name.must_be :nil?

    languages = translate.languages "en"
    languages.count.must_be :>, 0
    languages.first.name.wont_be :nil?
  end
end
