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

require "translate_helper"

# This test is a ruby version of gcloud-node's translate test.

describe Gcloud::Translate, :translate do
  it "detects a langauge" do
    translate.detect("Hello").results.first.language.must_equal "en"
    translate.detect("Hola").results.first.language.must_equal "es"

    detections = translate.detect "Hello", "Hola"
    detections.count.must_equal 2
    detections.first.results.first.language.must_equal "en"
    detections.last.results.first.language.must_equal "es"
  end

  it "translates input" do
    translate.translate("Hello", to: "es").text.must_equal "Hola"
    translate.translate("How are you today?", to: "es").text.must_equal "Como estas hoy?"

    translations = translate.translate "Hello", "How are you today?", to: "es"
    translations.count.must_equal 2
    translations.first.text.must_equal "Hola"
    translations.last.text.must_equal "Como estas hoy?"
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
