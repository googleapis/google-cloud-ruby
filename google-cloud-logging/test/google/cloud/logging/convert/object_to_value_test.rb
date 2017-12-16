# Copyright 2017 Google LLC
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

describe Google::Cloud::Logging::Convert, :object_to_value do
  let(:null_value) { Google::Protobuf::Value.new null_value: :NULL_VALUE }
  let(:true_value) { Google::Protobuf::Value.new bool_value: true }
  let(:string_value) { Google::Protobuf::Value.new string_value: "bif" }
  let(:num_value) { Google::Protobuf::Value.new number_value: 3.14 }
  let(:struct_value) { Google::Protobuf::Value.new struct_value: Google::Protobuf::Struct.new(fields: { "foo" => Google::Protobuf::Value.new(string_value: "bar") }) }
  let(:list_value) { Google::Protobuf::Value.new list_value: Google::Protobuf::ListValue.new(values: [ Google::Protobuf::Value.new(string_value: "hello"),  Google::Protobuf::Value.new(string_value: "world") ]) }

  it "converts nil object" do
    value = Google::Cloud::Logging::Convert.object_to_value nil
    value.must_equal null_value
  end

  it "converts true object" do
    value = Google::Cloud::Logging::Convert.object_to_value true
    value.must_equal true_value
  end

  it "converts string object" do
    value = Google::Cloud::Logging::Convert.object_to_value "bif"
    value.must_equal string_value
  end

  it "converts num object" do
    value = Google::Cloud::Logging::Convert.object_to_value 3.14
    value.must_equal num_value
  end

  it "converts struct object" do
    value = Google::Cloud::Logging::Convert.object_to_value({ "foo" => "bar" })
    value.must_equal struct_value
  end

  it "converts list object" do
    value = Google::Cloud::Logging::Convert.object_to_value ["hello", "world"]
    value.must_equal list_value
  end
end
