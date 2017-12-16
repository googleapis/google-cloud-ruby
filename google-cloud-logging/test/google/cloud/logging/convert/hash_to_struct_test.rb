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

describe Google::Cloud::Logging::Convert, :hash_to_struct do
  it "converts empty hash" do
    hash = {}
    struct = Google::Cloud::Logging::Convert.hash_to_struct hash
    struct.must_be_kind_of Google::Protobuf::Struct
    struct.fields.must_be_kind_of Google::Protobuf::Map
    struct.fields.keys.must_be :empty?
  end

  it "converts simple hash" do
    hash = { "foo" => "bar" }
    struct = Google::Cloud::Logging::Convert.hash_to_struct hash
    struct.must_be_kind_of Google::Protobuf::Struct
    struct.fields.must_be_kind_of Google::Protobuf::Map
    struct.fields.keys.wont_be :empty?
    bar_value = struct.fields["foo"]
    bar_value.must_be_kind_of Google::Protobuf::Value
    bar_value.kind.must_equal :string_value
    bar_value.string_value.must_equal "bar"
  end

  it "converts simple hash of symbols" do
    hash = { foo: :bar }
    struct = Google::Cloud::Logging::Convert.hash_to_struct hash
    struct.must_be_kind_of Google::Protobuf::Struct
    struct.fields.must_be_kind_of Google::Protobuf::Map
    struct.fields.keys.wont_be :empty?
    bar_value = struct.fields["foo"]
    bar_value.must_be_kind_of Google::Protobuf::Value
    bar_value.kind.must_equal :string_value
    bar_value.string_value.must_equal "bar"
  end

  it "converts hash with nil value" do
    hash = { "foo" => nil }
    struct = Google::Cloud::Logging::Convert.hash_to_struct hash
    struct.must_be_kind_of Google::Protobuf::Struct
    struct.fields.must_be_kind_of Google::Protobuf::Map
    struct.fields.keys.wont_be :empty?
    nil_value = struct.fields["foo"]
    nil_value.must_be_kind_of Google::Protobuf::Value
    nil_value.kind.must_equal :null_value
    nil_value.null_value.must_equal :NULL_VALUE
  end

  it "converts hash with int value" do
    hash = { "foo" => 123 }
    struct = Google::Cloud::Logging::Convert.hash_to_struct hash
    struct.must_be_kind_of Google::Protobuf::Struct
    struct.fields.must_be_kind_of Google::Protobuf::Map
    struct.fields.keys.wont_be :empty?
    int_value = struct.fields["foo"]
    int_value.must_be_kind_of Google::Protobuf::Value
    int_value.kind.must_equal :number_value
    int_value.number_value.must_equal 123.0
  end

  it "converts hash with float value" do
    hash = { "foo" => 456.789 }
    struct = Google::Cloud::Logging::Convert.hash_to_struct hash
    struct.must_be_kind_of Google::Protobuf::Struct
    struct.fields.must_be_kind_of Google::Protobuf::Map
    struct.fields.keys.wont_be :empty?
    float_value = struct.fields["foo"]
    float_value.must_be_kind_of Google::Protobuf::Value
    float_value.kind.must_equal :number_value
    float_value.number_value.must_equal 456.789
  end

  it "converts hash with true value" do
    hash = { "foo" => true }
    struct = Google::Cloud::Logging::Convert.hash_to_struct hash
    struct.must_be_kind_of Google::Protobuf::Struct
    struct.fields.must_be_kind_of Google::Protobuf::Map
    struct.fields.keys.wont_be :empty?
    true_value = struct.fields["foo"]
    true_value.must_be_kind_of Google::Protobuf::Value
    true_value.kind.must_equal :bool_value
    true_value.bool_value.must_equal true
  end

  it "converts hash with false value" do
    hash = { "foo" => false }
    struct = Google::Cloud::Logging::Convert.hash_to_struct hash
    struct.must_be_kind_of Google::Protobuf::Struct
    struct.fields.must_be_kind_of Google::Protobuf::Map
    struct.fields.keys.wont_be :empty?
    false_value = struct.fields["foo"]
    false_value.must_be_kind_of Google::Protobuf::Value
    false_value.kind.must_equal :bool_value
    false_value.bool_value.must_equal false
  end

  it "converts hash with hash value" do
    hash = { "foo" => { bar: :baz } }
    struct = Google::Cloud::Logging::Convert.hash_to_struct hash
    struct.must_be_kind_of Google::Protobuf::Struct
    struct.fields.must_be_kind_of Google::Protobuf::Map
    struct.fields.keys.wont_be :empty?
    hash_value = struct.fields["foo"]
    hash_value.must_be_kind_of Google::Protobuf::Value
    hash_value.kind.must_equal :struct_value
    hash_value.struct_value.fields.must_be_kind_of Google::Protobuf::Map
    hash_value.struct_value.fields["bar"].must_be_kind_of Google::Protobuf::Value
    hash_value.struct_value.fields["bar"].kind.must_equal :string_value
    hash_value.struct_value.fields["bar"].string_value.must_equal "baz"
  end

  it "converts hash with array value" do
    hash = { "foo" => ["hello", "world"] }
    struct = Google::Cloud::Logging::Convert.hash_to_struct hash
    struct.must_be_kind_of Google::Protobuf::Struct
    struct.fields.must_be_kind_of Google::Protobuf::Map
    struct.fields.keys.wont_be :empty?
    array_value = struct.fields["foo"]
    array_value.must_be_kind_of Google::Protobuf::Value
    array_value.kind.must_equal :list_value
    array_value.list_value.must_be_kind_of Google::Protobuf::ListValue
    array_value.list_value.values.wont_be :empty?
    array_value.list_value.values.first.must_equal Google::Protobuf::Value.new(string_value: "hello")
    array_value.list_value.values.last.must_equal Google::Protobuf::Value.new(string_value: "world")
  end

  it "converts complex hash" do
    hash = { foo: nil, bar: true, baz: :bif, pi: 3.14, meta: { foo: :bar }, msg: ["hello", "world"] }
    struct = Google::Cloud::Logging::Convert.hash_to_struct hash
    struct.must_be_kind_of Google::Protobuf::Struct
    struct.fields.must_be_kind_of Google::Protobuf::Map
    struct.fields.keys.wont_be :empty?

    nil_value = struct.fields["foo"]
    nil_value.must_be_kind_of Google::Protobuf::Value
    nil_value.kind.must_equal :null_value
    nil_value.null_value.must_equal :NULL_VALUE

    true_value = struct.fields["bar"]
    true_value.must_be_kind_of Google::Protobuf::Value
    true_value.kind.must_equal :bool_value
    true_value.bool_value.must_equal true

    string_value = struct.fields["baz"]
    string_value.must_be_kind_of Google::Protobuf::Value
    string_value.kind.must_equal :string_value
    string_value.string_value.must_equal "bif"

    num_value = struct.fields["pi"]
    num_value.must_be_kind_of Google::Protobuf::Value
    num_value.kind.must_equal :number_value
    num_value.number_value.must_equal 3.14

    hash_value = struct.fields["meta"]
    hash_value.must_be_kind_of Google::Protobuf::Value
    hash_value.kind.must_equal :struct_value
    hash_value.struct_value.fields.must_be_kind_of Google::Protobuf::Map
    hash_value.struct_value.fields["foo"].must_be_kind_of Google::Protobuf::Value
    hash_value.struct_value.fields["foo"].kind.must_equal :string_value
    hash_value.struct_value.fields["foo"].string_value.must_equal "bar"

    array_value = struct.fields["msg"]
    array_value.must_be_kind_of Google::Protobuf::Value
    array_value.kind.must_equal :list_value
    array_value.list_value.must_be_kind_of Google::Protobuf::ListValue
    array_value.list_value.values.wont_be :empty?
    array_value.list_value.values.first.must_equal Google::Protobuf::Value.new(string_value: "hello")
    array_value.list_value.values.last.must_equal Google::Protobuf::Value.new(string_value: "world")
  end
end
