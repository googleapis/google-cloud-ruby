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
require "gcloud/datastore"

describe Gcloud::Datastore::Properties do
  let(:time_obj) { Time.new(2014, 1, 1, 0, 0, 0, 0) }
  let(:time_grpc) { Google::Protobuf::Timestamp.new(seconds: time_obj.to_i, nanos: time_obj.nsec) }

  # #
  # This is testing a helper.
  # These tests are for sanity only.
  # This is not part of the public API.
  # Testing implementation, not behavior.

  it "encodes a string" do
    raw = "hello, i am a string"
    value = Gcloud::GRPCUtils.to_value raw
    value.string_value.must_equal raw
    value.timestamp_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.array_value.must_be :nil?
  end

  it "decodes a string" do
    str = "ohai, i am also a string"
    value = Google::Datastore::V1beta3::Value.new
    value.string_value = str
    raw = Gcloud::GRPCUtils.from_value value
    raw.must_equal str
  end

  it "encodes nil" do
    value = Gcloud::GRPCUtils.to_value nil
    value.must_be :nil?

    # value.boolean_value.must_be :nil?
    # value.timestamp_value.must_be :nil?
    # value.key_value.must_be :nil?
    # value.entity_value.must_be :nil?
    # value.double_value.must_be :nil?
    # value.integer_value.must_be :nil?
    # value.string_value.must_be :nil?
    # value.array_value.must_be :nil?
  end

  it "decodes NULL" do
    value = Google::Datastore::V1beta3::Value.new
    raw = Gcloud::GRPCUtils.from_value value
    raw.must_equal nil
  end

  it "encodes true" do
    value = Gcloud::GRPCUtils.to_value true
    value.boolean_value.must_equal true
    value.timestamp_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.array_value.must_be :nil?
  end

  it "decodes true" do
    value = Google::Datastore::V1beta3::Value.new
    value.boolean_value = true
    raw = Gcloud::GRPCUtils.from_value value
    raw.must_equal true
  end

  it "encodes false" do
    value = Gcloud::GRPCUtils.to_value false
    value.boolean_value.must_equal false
    value.timestamp_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.array_value.must_be :nil?
  end

  it "decodes false" do
    value = Google::Datastore::V1beta3::Value.new
    value.boolean_value = false
    raw = Gcloud::GRPCUtils.from_value value
    raw.must_equal false
  end

  it "encodes integer" do
    raw = 1234
    value = Gcloud::GRPCUtils.to_value raw
    value.integer_value.must_equal raw
    value.timestamp_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.string_value.must_be :nil?
    value.array_value.must_be :nil?
  end

  it "decodes integer" do
    num = 1234
    value = Google::Datastore::V1beta3::Value.new
    value.integer_value = num
    raw = Gcloud::GRPCUtils.from_value value
    raw.must_equal num
  end

  it "encodes float" do
    raw = 12.34
    value = Gcloud::GRPCUtils.to_value raw
    value.double_value.must_equal raw
    value.timestamp_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.array_value.must_be :nil?
  end

  it "decodes float" do
    num = 12.34
    value = Google::Datastore::V1beta3::Value.new
    value.double_value = num
    raw = Gcloud::GRPCUtils.from_value value
    raw.must_equal num
  end

  it "encodes Key" do
    key = Gcloud::Datastore::Key.new "Thing", 123
    value = Gcloud::GRPCUtils.to_value key
    value.key_value.must_equal key.to_grpc
    value.timestamp_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.array_value.must_be :nil?
  end

  it "decodes Key" do
    key = Gcloud::Datastore::Key.new "Thing", 123
    value = Google::Datastore::V1beta3::Value.new
    value.key_value = key.to_grpc
    raw = Gcloud::GRPCUtils.from_value value
    assert_kind_of Gcloud::Datastore::Key, raw
    refute_kind_of Google::Datastore::V1beta3::Key, raw
    raw.to_grpc.must_equal key.to_grpc
  end

  it "encodes Entity" do
    entity = Gcloud::Datastore::Entity.new
    entity.key = Gcloud::Datastore::Key.new "Thing", 123
    entity["name"] = "Thing 1"
    value = Gcloud::GRPCUtils.to_value entity
    value.key_value.must_be :nil?
    value.entity_value.must_equal entity.to_grpc
    value.timestamp_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.array_value.must_be :nil?
  end

  it "decodes Entity" do
    entity = Gcloud::Datastore::Entity.new
    entity.key = Gcloud::Datastore::Key.new "Thing", 123
    entity["name"] = "Thing 1"
    value = Google::Datastore::V1beta3::Value.new
    value.entity_value = entity.to_grpc
    raw = Gcloud::GRPCUtils.from_value value
    assert_kind_of Gcloud::Datastore::Entity, raw
    refute_kind_of Google::Datastore::V1beta3::Entity, raw
    raw_grpc = raw.to_grpc
    entity_grpc = entity.to_grpc
    raw_grpc.must_equal entity_grpc
  end

  it "encodes Array" do
    array = ["string", 123, true]
    value = Gcloud::GRPCUtils.to_value array
    value.array_value.wont_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.timestamp_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
  end

  it "decodes Array" do
    value = Google::Datastore::V1beta3::Value.new
    value.array_value = Google::Datastore::V1beta3::ArrayValue.new(
      values: [ Google::Datastore::V1beta3::Value.new.tap { |v| v.string_value = "string" },
                Google::Datastore::V1beta3::Value.new.tap { |v| v.integer_value = 123 },
                Google::Datastore::V1beta3::Value.new.tap { |v| v.boolean_value = true }]
    )
    raw = Gcloud::GRPCUtils.from_value value
    assert_kind_of Array, raw
    raw.count.must_equal 3
    raw[0].must_equal "string"
    raw[1].must_equal 123
    raw[2].must_equal true
  end

  it "encodes Time" do
    value = Gcloud::GRPCUtils.to_value time_obj
    value.timestamp_value.must_equal time_grpc
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.array_value.must_be :nil?
  end

  it "encodes Date" do
    date_obj = time_obj.to_date
    value = Gcloud::GRPCUtils.to_value date_obj
    value.timestamp_value.must_equal Google::Protobuf::Timestamp.new(seconds: date_obj.to_time.to_i)
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.array_value.must_be :nil?
  end

  it "encodes DateTime" do
    datetime_obj = time_obj.to_datetime
    value = Gcloud::GRPCUtils.to_value datetime_obj
    value.timestamp_value.must_equal time_grpc
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.array_value.must_be :nil?
  end

  it "decodes timestamp" do
    value = Google::Datastore::V1beta3::Value.new
    value.timestamp_value = time_grpc
    raw = Gcloud::GRPCUtils.from_value value
    raw.must_equal time_obj
  end
end
