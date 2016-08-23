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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "google/cloud/language"

class MockLanguage < Minitest::Spec
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:language) { Google::Cloud::Language::Project.new(Google::Cloud::Language::Service.new(project, credentials)) }

  let(:text_content)   { "Hello from Chris and Mike!  If you find yourself in Utah, come say hi! We love ruby and writing code." }
  let(:text_sentences) { ["Hello from Chris and Mike!", "If you find yourself in Utah, come say hi!", "We love ruby and writing code."] }
  let(:text_json)      { File.read(File.dirname(__FILE__) + "/text.json") }
  let(:html_content)   { "<html><head><title>Hello from Chris and Mike!</title></head><body><h1>If you find yourself in <strong>Utah</strong>, come say hi!</h1><p>We <em>love</em> ruby and writing code.</p></body></html>" }
  let(:html_sentences) { ["Hello from Chris and Mike!", "If you find yourself in <strong>Utah</strong>, come say hi!", "We <em>love</em> ruby and writing code."] }
  let(:html_json)      { File.read(File.dirname(__FILE__) + "/html.json") }

  # Register this spec type for when :language is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_language
  end
end
