# Copyright 2016 Google LLC
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
require "google/cloud/translate"

class MockTranslate < Minitest::Spec
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:translate) { Google::Cloud::Translate::Api.new(Google::Cloud::Translate::Service.new(project, credentials)) }

  # Register this spec type for when :mock_translate is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_translate
  end
end

class MockHttp
  attr_reader :request_count

  def initialize
    @request_count = 0
  end

  def stub_response(status, body)
    @stub_status = status
    @stub_body = body
  end

  def post(*_)
    @request_count += 1
    Faraday::Response.new.tap do |response|
      response.finish(status: @stub_status, body: @stub_body)
    end
  end
end
