# Copyright 2017 Google LLC
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


require "helper"

describe Google::Cloud::Datastore::Convert, :value_to_object do
  let(:nil_value) { Google::Protobuf::Value.new null_value: :NULL_VALUE }
  let(:true_value) { Google::Protobuf::Value.new bool_value: true }
  let(:string_value) { Google::Protobuf::Value.new string_value: "bif" }
  let(:num_value) { Google::Protobuf::Value.new number_value: 3.14 }
  let(:struct_value) { Google::Protobuf::Value.new struct_value: Google::Protobuf::Struct.new(fields: { "foo" => Google::Protobuf::Value.new(string_value: "bar") }) }
  let(:list_value) { Google::Protobuf::Value.new list_value: Google::Protobuf::ListValue.new(values: [ Google::Protobuf::Value.new(string_value: "hello"),  Google::Protobuf::Value.new(string_value: "world") ]) }

  it "converts nil value" do
    obj = Google::Cloud::Datastore::Convert.value_to_object nil_value
    obj.must_be :nil?
  end

  it "converts true value" do
    obj = Google::Cloud::Datastore::Convert.value_to_object true_value
    obj.must_equal true
  end

  it "converts string value" do
    obj = Google::Cloud::Datastore::Convert.value_to_object string_value
    obj.must_equal "bif"
  end

  it "converts num value" do
    obj = Google::Cloud::Datastore::Convert.value_to_object num_value
    obj.must_equal 3.14
  end

  it "converts struct value" do
    obj = Google::Cloud::Datastore::Convert.value_to_object struct_value
    obj.must_equal({ "foo" => "bar" })
  end

  it "converts list value" do
    obj = Google::Cloud::Datastore::Convert.value_to_object list_value
    obj.must_equal ["hello", "world"]
  end
end
