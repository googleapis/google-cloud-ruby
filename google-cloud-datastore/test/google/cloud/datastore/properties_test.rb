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

require "helper"
require "stringio"
require "tempfile"

describe Google::Cloud::Datastore::Properties, :mock_datastore do
  let(:time_obj) { Time.new(2014, 1, 1, 0, 0, 0, 0) }
  let(:time_grpc) { Google::Protobuf::Timestamp.new(seconds: time_obj.to_i, nanos: time_obj.nsec) }

  # #
  # This is testing a helper.
  # These tests are for sanity only.
  # This is not part of the public API.
  # Testing implementation, not behavior.

  it "decodes empty value" do
    value = Google::Datastore::V1::Value.new
    raw = Google::Cloud::Datastore::Convert.from_value value
    raw.must_be :nil?
  end

  it "encodes a string" do
    raw = "hello, i am a string"
    value = Google::Cloud::Datastore::Convert.to_value raw
    value.value_type.must_equal :string_value
    value.string_value.must_equal raw
  end

  it "decodes a string" do
    str = "ohai, i am also a string"
    value = Google::Datastore::V1::Value.new
    value.string_value = str
    raw = Google::Cloud::Datastore::Convert.from_value value
    raw.must_equal str
  end

  it "encodes nil" do
    value = Google::Cloud::Datastore::Convert.to_value nil
    value.value_type.must_equal :null_value
    value.null_value.must_equal :NULL_VALUE
  end

  it "decodes NULL" do
    value = Google::Datastore::V1::Value.new
    value.null_value = :NULL_VALUE
    raw = Google::Cloud::Datastore::Convert.from_value value
    raw.must_be :nil?
  end

  it "encodes true" do
    value = Google::Cloud::Datastore::Convert.to_value true
    value.value_type.must_equal :boolean_value
    value.boolean_value.must_equal true
  end

  it "decodes true" do
    value = Google::Datastore::V1::Value.new
    value.boolean_value = true
    raw = Google::Cloud::Datastore::Convert.from_value value
    raw.must_equal true
  end

  it "encodes false" do
    value = Google::Cloud::Datastore::Convert.to_value false
    value.value_type.must_equal :boolean_value
    value.boolean_value.must_equal false
  end

  it "decodes false" do
    value = Google::Datastore::V1::Value.new
    value.boolean_value = false
    raw = Google::Cloud::Datastore::Convert.from_value value
    raw.must_equal false
  end

  it "encodes integer" do
    raw = 1234
    value = Google::Cloud::Datastore::Convert.to_value raw
    value.value_type.must_equal :integer_value
    value.integer_value.must_equal raw
  end

  it "decodes integer" do
    num = 1234
    value = Google::Datastore::V1::Value.new
    value.integer_value = num
    raw = Google::Cloud::Datastore::Convert.from_value value
    raw.must_equal num
  end

  it "encodes float" do
    raw = 12.34
    value = Google::Cloud::Datastore::Convert.to_value raw
    value.value_type.must_equal :double_value
    value.double_value.must_equal raw
  end

  it "decodes float" do
    num = 12.34
    value = Google::Datastore::V1::Value.new
    value.double_value = num
    raw = Google::Cloud::Datastore::Convert.from_value value
    raw.must_equal num
  end

  it "encodes Key" do
    key = Google::Cloud::Datastore::Key.new "Thing", 123
    value = Google::Cloud::Datastore::Convert.to_value key
    value.value_type.must_equal :key_value
    value.key_value.must_equal key.to_grpc
  end

  it "decodes Key" do
    key = Google::Cloud::Datastore::Key.new "Thing", 123
    value = Google::Datastore::V1::Value.new
    value.key_value = key.to_grpc
    raw = Google::Cloud::Datastore::Convert.from_value value
    assert_kind_of Google::Cloud::Datastore::Key, raw
    refute_kind_of Google::Datastore::V1::Key, raw
    raw.to_grpc.must_equal key.to_grpc
  end

  it "encodes Entity" do
    entity = Google::Cloud::Datastore::Entity.new
    entity.key = Google::Cloud::Datastore::Key.new "Thing", 123
    entity["name"] = "Thing 1"
    value = Google::Cloud::Datastore::Convert.to_value entity
    value.value_type.must_equal :entity_value
    value.entity_value.properties.must_equal entity.to_grpc.properties
    value.entity_value.key.must_be :nil? # embedded entities can't have keys
  end

  it "decodes Entity" do
    entity = Google::Cloud::Datastore::Entity.new
    entity.key = Google::Cloud::Datastore::Key.new "Thing", 123
    entity["name"] = "Thing 1"
    value = Google::Datastore::V1::Value.new
    value.entity_value = entity.to_grpc
    raw = Google::Cloud::Datastore::Convert.from_value value
    assert_kind_of Google::Cloud::Datastore::Entity, raw
    refute_kind_of Google::Datastore::V1::Entity, raw
    raw_grpc = raw.to_grpc
    entity_grpc = entity.to_grpc
    raw_grpc.must_equal entity_grpc
  end

  it "encodes Array" do
    array = ["string", 123, true]
    value = Google::Cloud::Datastore::Convert.to_value array
    value.value_type.must_equal :array_value
    value.array_value.must_equal Google::Datastore::V1::ArrayValue.new(
      values: [Google::Datastore::V1::Value.new(string_value: "string"),
               Google::Datastore::V1::Value.new(integer_value: 123),
               Google::Datastore::V1::Value.new(boolean_value: true)]
    )
  end

  it "decodes Array" do
    value = Google::Datastore::V1::Value.new
    value.array_value = Google::Datastore::V1::ArrayValue.new(
      values: [ Google::Datastore::V1::Value.new.tap { |v| v.string_value = "string" },
                Google::Datastore::V1::Value.new.tap { |v| v.integer_value = 123 },
                Google::Datastore::V1::Value.new.tap { |v| v.boolean_value = true }]
    )
    raw = Google::Cloud::Datastore::Convert.from_value value
    assert_kind_of Array, raw
    raw.count.must_equal 3
    raw[0].must_equal "string"
    raw[1].must_equal 123
    raw[2].must_equal true
  end

  it "encodes Time" do
    value = Google::Cloud::Datastore::Convert.to_value time_obj
    value.value_type.must_equal :timestamp_value
    value.timestamp_value.must_equal time_grpc
  end

  it "encodes Date" do
    date_obj = time_obj.to_date
    value = Google::Cloud::Datastore::Convert.to_value date_obj
    value.value_type.must_equal :timestamp_value
    value.timestamp_value.must_equal Google::Protobuf::Timestamp.new(seconds: date_obj.to_time.to_i)
  end

  it "encodes DateTime" do
    datetime_obj = time_obj.to_datetime
    value = Google::Cloud::Datastore::Convert.to_value datetime_obj
    value.value_type.must_equal :timestamp_value
    value.timestamp_value.must_equal time_grpc
  end

  it "decodes timestamp" do
    value = Google::Datastore::V1::Value.new
    value.timestamp_value = time_grpc
    raw = Google::Cloud::Datastore::Convert.from_value value
    raw.must_equal time_obj
  end

  it "encodes IO as blob" do
    raw = File.open "acceptance/data/CloudPlatform_128px_Retina.png", "rb"
    value = Google::Cloud::Datastore::Convert.to_value raw
    value.value_type.must_equal :blob_value
    value.blob_value.must_equal File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb").force_encoding("ASCII-8BIT")
  end

  it "encodes StringIO as blob" do
    raw = StringIO.new(File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb"))
    value = Google::Cloud::Datastore::Convert.to_value raw
    value.value_type.must_equal :blob_value
    value.blob_value.must_equal File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb").force_encoding("ASCII-8BIT")
  end

  it "encodes Temfile as blob" do
    raw = Tempfile.new "raw"
    raw.binmode
    raw.write(File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb"))
    raw.rewind
    value = Google::Cloud::Datastore::Convert.to_value raw
    value.value_type.must_equal :blob_value
    value.blob_value.must_equal File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb").force_encoding("ASCII-8BIT")
  end

  it "decodes blob to StringIO" do
    value = Google::Datastore::V1::Value.new
    value.blob_value = File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb").force_encoding("ASCII-8BIT")
    raw = Google::Cloud::Datastore::Convert.from_value value
    raw.must_be_kind_of StringIO
    raw.read.must_equal StringIO.new(File.read("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb")).read
  end

  it "encodes location hash" do
    latlng_obj = {latitude: 37.4220041, longitude: -122.0862462}
    value = Google::Cloud::Datastore::Convert.to_value latlng_obj
    value.value_type.must_equal :geo_point_value
    value.geo_point_value.must_equal Google::Type::LatLng.new(latitude: 37.4220041, longitude: -122.0862462)
  end

  it "decodes geo_point" do
    value = Google::Datastore::V1::Value.new
    value.geo_point_value = Google::Type::LatLng.new(latitude: 37.4220041, longitude: -122.0862462)
    raw = Google::Cloud::Datastore::Convert.from_value value
    raw.must_equal({latitude: 37.4220041, longitude: -122.0862462})
  end
end
