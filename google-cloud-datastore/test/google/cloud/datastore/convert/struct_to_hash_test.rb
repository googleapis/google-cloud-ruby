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

describe Google::Cloud::Datastore::Convert, :struct_to_hash do
  let(:struct) do
    Google::Protobuf::Struct.new(fields: {
      "foo"  => Google::Protobuf::Value.new(null_value: :NULL_VALUE),
      "bar"  => Google::Protobuf::Value.new(bool_value: true),
      "baz"  => Google::Protobuf::Value.new(string_value: "bif"),
      "pi"   => Google::Protobuf::Value.new(number_value: 3.14),
      "meta" => Google::Protobuf::Value.new(struct_value: Google::Protobuf::Struct.new(fields: { "foo" => Google::Protobuf::Value.new(string_value: "bar") })),
      "msg"  => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "hello"), Google::Protobuf::Value.new(string_value: "world")]))
    })
  end

  it "converts empty struct" do
    hash = Google::Cloud::Datastore::Convert.struct_to_hash Google::Protobuf::Struct.new
    hash.must_be_kind_of Hash
    hash.must_be :empty?
  end

  it "converts complex struct" do
    hash = Google::Cloud::Datastore::Convert.struct_to_hash struct
    hash.must_be_kind_of Hash
    hash.wont_be :empty?
    hash["foo"].must_be :nil?
    hash["bar"].must_equal true
    hash["baz"].must_equal "bif"
    hash["pi"].must_equal 3.14
    hash["meta"].must_equal({ "foo" => "bar" })
    hash["msg"].must_equal ["hello", "world"]
  end
end
