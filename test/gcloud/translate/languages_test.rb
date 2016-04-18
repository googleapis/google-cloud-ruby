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

describe Gcloud::Translate::Api, :languages, :mock_translate do
  it "lists languages without a language" do
    mock_connection.get "/language/translate/v2/languages" do |env|
      env.params["key"].must_equal key
      env.params["target"].must_be :nil?
      [200, { "Content-Type" => "application/json" },
       language_json]
    end

    languages = translate.languages
    languages.count.must_be :>, 0
    languages.first.name.must_be :nil?
  end

  it "lists languages with a language" do
    mock_connection.get "/language/translate/v2/languages" do |env|
      env.params["key"].must_equal key
      env.params["target"].must_equal "en"
      [200, { "Content-Type" => "application/json" },
       language_json("en")]
    end

    languages = translate.languages "en"
    languages.count.must_be :>, 0
    languages.first.name.wont_be :nil?
  end
end
