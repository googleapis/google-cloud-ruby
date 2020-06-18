# Copyright 2020 Google LLC
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

require_relative "helper"
require_relative "../translate_text_with_glossary_and_model"

require "minitest/mock"
require "gapic/common"
require "gapic/grpc"
require "ostruct"

describe "translate_v3_translate_text_with_glossary_and_model", :translate do
  it "translates English to French" do
    location_id = "us-central1"
    glossary_id = "glossary-listable"
    model_id = "my-model"

    @mock_grpc_stub = Minitest::Mock.new
    translation = OpenStruct.new translated_text: "Bonjour le monde!"
    response = OpenStruct.new translations: [translation]
    @mock_grpc_stub.expect :call_rpc, response do |rpc, request, options:|
      assert_equal :translate_text, rpc
      assert_instance_of Google::Cloud::Translate::V3::TranslateTextRequest, request
      refute_nil options
      assert_match(/#{glossary_id}/, request.glossary_config.glossary)
      assert_match(/#{model_id}/, request.model)
    end

    assert_output "Translated text: Bonjour le monde!\n" do
      Gapic::ServiceStub.stub :new, @mock_grpc_stub do
        translate_v3_translate_text_with_glossary_and_model project_id:  project_id,
                                                            location_id: location_id,
                                                            glossary_id: glossary_id,
                                                            model_id:    model_id
      end
    end

    @mock_grpc_stub.verify
  end
end
