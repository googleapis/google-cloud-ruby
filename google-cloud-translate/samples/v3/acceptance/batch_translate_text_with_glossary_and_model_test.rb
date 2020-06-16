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
require_relative "../batch_translate_text_with_glossary_and_model"

require "minitest/mock"
require "gapic/common"
require "gapic/grpc"
require "ostruct"

describe "translate_v3_batch_translate_text_with_glossary_and_model", :translate do
  it "translates English to Japanese" do
    location_id = "us-central1"
    glossary_id = "glossary-listable"
    model_id = "my-model"
    input_uri = "gs://cloud-samples-data/text.txt"
    output_uri = "gs://my-bucket/path_to_store_results/"

    response = OpenStruct.new total_characters: 13, translated_characters: 13
    @mock_operation = Minitest::Mock.new
    @mock_operation.expect :wait_until_done!, nil
    @mock_operation.expect :response, response
    @mock_grpc_stub = Minitest::Mock.new
    @mock_grpc_stub.expect :call_rpc, @mock_operation do |rpc, request, _options:|
      assert_equal :batch_translate_text, rpc
      assert_match(/#{glossary_id}/, request.glossaries["ja"].glossary)
      assert_match(/#{model_id}/, request.models["ja"])
    end

    assert_output(/Total Characters: 13/) do
      Gapic::ServiceStub.stub :new, @mock_grpc_stub do
        translate_v3_batch_translate_text_with_glossary_and_model input_uri:   input_uri,
                                                                  output_uri:  output_uri,
                                                                  project_id:  project_id,
                                                                  location_id: location_id,
                                                                  glossary_id: glossary_id,
                                                                  model_id:    model_id
      end
    end

    @mock_grpc_stub.verify
    @mock_operation.verify
  end
end
