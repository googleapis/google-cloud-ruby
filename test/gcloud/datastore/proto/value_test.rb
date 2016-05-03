# Copyright 2014 Google Inc. All rights reserved.
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
require "gcloud/datastore/entity"
require "gcloud/datastore/key"
require "stringio"
require "tempfile"
require "base64"

describe "Proto Value methods" do
  let(:time_obj) { Time.new(2014, 1, 1, 0, 0, 0, 0) }
  let(:time_num) { 1388534400000000 }

  ##
  # This is testing a helper.
  # These tests are for sanity only.
  # This is not part of the public API.
  # Testing implementation, not behavior.

  it "encodes a string" do
    raw = "hello, i am a string"
    value = Gcloud::Datastore::Proto.to_proto_value raw
    value.string_value.must_equal raw
    value.timestamp_microseconds_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "decodes a string" do
    str = "ohai, i am also a string"
    value = Gcloud::Datastore::Proto::Value.new
    value.string_value = str
    raw = Gcloud::Datastore::Proto.from_proto_value value
    raw.must_equal str
  end

  it "encodes nil" do
    value = Gcloud::Datastore::Proto.to_proto_value nil
    value.boolean_value.must_be :nil?
    value.timestamp_microseconds_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "decodes NULL" do
    value = Gcloud::Datastore::Proto::Value.new
    raw = Gcloud::Datastore::Proto.from_proto_value value
    raw.must_equal nil
  end

  it "encodes true" do
    value = Gcloud::Datastore::Proto.to_proto_value true
    value.boolean_value.must_equal true
    value.timestamp_microseconds_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "decodes true" do
    value = Gcloud::Datastore::Proto::Value.new
    value.boolean_value = true
    raw = Gcloud::Datastore::Proto.from_proto_value value
    raw.must_equal true
  end

  it "encodes false" do
    value = Gcloud::Datastore::Proto.to_proto_value false
    value.boolean_value.must_equal false
    value.timestamp_microseconds_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "decodes false" do
    value = Gcloud::Datastore::Proto::Value.new
    value.boolean_value = false
    raw = Gcloud::Datastore::Proto.from_proto_value value
    raw.must_equal false
  end

  it "encodes Time" do
    value = Gcloud::Datastore::Proto.to_proto_value time_obj
    value.timestamp_microseconds_value.must_equal time_num
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "encodes Date" do
    date_obj = time_obj.to_date
    value = Gcloud::Datastore::Proto.to_proto_value time_obj
    value.timestamp_microseconds_value.must_equal time_num
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "encodes DateTime" do
    datetime_obj = time_obj.to_datetime
    value = Gcloud::Datastore::Proto.to_proto_value datetime_obj
    value.timestamp_microseconds_value.must_equal time_num
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "decodes timestamp" do
    value = Gcloud::Datastore::Proto::Value.new
    value.timestamp_microseconds_value = time_num
    raw = Gcloud::Datastore::Proto.from_proto_value value
    raw.must_equal time_obj
  end

  it "encodes integer" do
    raw = 1234
    value = Gcloud::Datastore::Proto.to_proto_value raw
    value.integer_value.must_equal raw
    value.timestamp_microseconds_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "decodes integer" do
    num = 1234
    value = Gcloud::Datastore::Proto::Value.new
    value.integer_value = num
    raw = Gcloud::Datastore::Proto.from_proto_value value
    raw.must_equal num
  end

  it "encodes float" do
    raw = 12.34
    value = Gcloud::Datastore::Proto.to_proto_value raw
    value.double_value.must_equal raw
    value.timestamp_microseconds_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "decodes float" do
    num = 12.34
    value = Gcloud::Datastore::Proto::Value.new
    value.double_value = num
    raw = Gcloud::Datastore::Proto.from_proto_value value
    raw.must_equal num
  end

  it "encodes Key" do
    key = Gcloud::Datastore::Key.new "Thing", 123
    value = Gcloud::Datastore::Proto.to_proto_value key
    value.key_value.must_equal key.to_proto
    value.timestamp_microseconds_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "decodes Key" do
    key = Gcloud::Datastore::Key.new "Thing", 123
    value = Gcloud::Datastore::Proto::Value.new
    value.key_value = key.to_proto
    raw = Gcloud::Datastore::Proto.from_proto_value value
    assert_kind_of Gcloud::Datastore::Key, raw
    refute_kind_of Gcloud::Datastore::Proto::Key, raw
    raw.to_proto.must_equal key.to_proto
  end

  it "encodes Entity" do
    entity = Gcloud::Datastore::Entity.new
    entity.key = Gcloud::Datastore::Key.new "Thing", 123
    entity["name"] = "Thing 1"
    value = Gcloud::Datastore::Proto.to_proto_value entity
    value.key_value.must_be :nil?
    value.entity_value.must_equal entity.to_proto
    value.timestamp_microseconds_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "decodes Entity" do
    entity = Gcloud::Datastore::Entity.new
    entity.key = Gcloud::Datastore::Key.new "Thing", 123
    entity["name"] = "Thing 1"
    value = Gcloud::Datastore::Proto::Value.new
    value.entity_value = entity.to_proto
    raw = Gcloud::Datastore::Proto.from_proto_value value
    assert_kind_of Gcloud::Datastore::Entity, raw
    refute_kind_of Gcloud::Datastore::Proto::Entity, raw
    # Fix up the indexed values so they can match
    raw_proto = raw.to_proto
    raw_proto.property.first.value.indexed = true
    entity_proto = entity.to_proto
    entity_proto.property.first.value.indexed = true
    raw_proto.must_equal entity_proto
  end

  it "encodes Array" do
    array = ["string", 123, true]
    value = Gcloud::Datastore::Proto.to_proto_value array
    value.list_value.wont_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.timestamp_microseconds_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
  end

  it "decodes List" do
    value = Gcloud::Datastore::Proto::Value.new
    value.list_value = [
      Gcloud::Datastore::Proto::Value.new.tap { |v| v.string_value = "string" },
      Gcloud::Datastore::Proto::Value.new.tap { |v| v.integer_value = 123 },
      Gcloud::Datastore::Proto::Value.new.tap { |v| v.boolean_value = true },
    ]
    raw = Gcloud::Datastore::Proto.from_proto_value value
    assert_kind_of Array, raw
    raw.count.must_equal 3
    raw[0].must_equal "string"
    raw[1].must_equal 123
    raw[2].must_equal true
  end

  it "encodes IO as blob" do
    raw = File.open "acceptance/data/CloudPlatform_128px_Retina.png"
    value = Gcloud::Datastore::Proto.to_proto_value raw
    value.blob_value.must_equal Base64.strict_encode64(File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb"))
    value.timestamp_microseconds_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "encodes StringIO as blob" do
    raw = StringIO.new(File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb"))
    value = Gcloud::Datastore::Proto.to_proto_value raw
    value.blob_value.must_equal Base64.strict_encode64(File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb"))
    value.timestamp_microseconds_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "encodes Temfile as blob" do
    raw = Tempfile.new "raw"
    raw.write(File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb"))
    raw.rewind
    value = Gcloud::Datastore::Proto.to_proto_value raw
    value.blob_value.must_equal Base64.strict_encode64(File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb"))
    value.timestamp_microseconds_value.must_be :nil?
    value.key_value.must_be :nil?
    value.entity_value.must_be :nil?
    value.boolean_value.must_be :nil?
    value.double_value.must_be :nil?
    value.integer_value.must_be :nil?
    value.string_value.must_be :nil?
    value.list_value.must_be :nil?
  end

  it "decodes blob to StringIO" do
    value = Gcloud::Datastore::Proto::Value.new
    value.blob_value = Base64.strict_encode64(File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb"))
    raw = Gcloud::Datastore::Proto.from_proto_value value
    raw.must_be_kind_of StringIO
    raw.read.must_equal StringIO.new(File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb")).read
  end
end
