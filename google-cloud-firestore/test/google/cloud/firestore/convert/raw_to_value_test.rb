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

describe Google::Cloud::Firestore::Convert, :raw_to_value, :mock_firestore do
  # These tests are a sanity check on the implementation of the conversion methods.
  # These tests are testing private methods and this is generally not a great idea.
  # But these conversions are so important that it was decided to do it anyway.

  it "converts a true boolean value" do
    value = Google::Cloud::Firestore::V1::Value.new null_value: :NULL_VALUE

    converted = Google::Cloud::Firestore::Convert.raw_to_value nil
    _(converted).must_equal value
  end

  it "converts a true boolean value" do
    value = Google::Cloud::Firestore::V1::Value.new boolean_value: true

    converted = Google::Cloud::Firestore::Convert.raw_to_value true
    _(converted).must_equal value
  end

  it "converts a false boolean value" do
    value = Google::Cloud::Firestore::V1::Value.new boolean_value: false

    converted = Google::Cloud::Firestore::Convert.raw_to_value false
    _(converted).must_equal value
  end

  it "converts a integer value" do
    value = Google::Cloud::Firestore::V1::Value.new integer_value: 29

    converted = Google::Cloud::Firestore::Convert.raw_to_value 29
    _(converted).must_equal value
  end

  it "converts a double value" do
    value = Google::Cloud::Firestore::V1::Value.new double_value: 0.9

    converted = Google::Cloud::Firestore::Convert.raw_to_value 0.9
    _(converted).must_equal value
  end

  it "converts a nan value" do
    value = Google::Cloud::Firestore::V1::Value.new double_value: Float::NAN

    converted = Google::Cloud::Firestore::Convert.raw_to_value Float::NAN
    _(converted).must_equal value
  end

  it "converts an infinity value" do
    value = Google::Cloud::Firestore::V1::Value.new double_value: Float::INFINITY

    converted = Google::Cloud::Firestore::Convert.raw_to_value Float::INFINITY
    _(converted).must_equal value
  end

  it "converts a timestamp value" do
    value = Google::Cloud::Firestore::V1::Value.new timestamp_value: Google::Protobuf::Timestamp.new(seconds: 1483326245, nanos: 60000000)

    converted = Google::Cloud::Firestore::Convert.raw_to_value Time.parse("2017-01-02 03:04:05.06 UTC")
    _(converted).must_equal value
  end

  it "converts a datetime value" do
    value = Google::Cloud::Firestore::V1::Value.new timestamp_value: Google::Protobuf::Timestamp.new(seconds: 1483326245, nanos: 60000000)

    converted = Google::Cloud::Firestore::Convert.raw_to_value Time.parse("2017-01-02 03:04:05.06 UTC").to_datetime
    _(converted).must_equal value
  end

  it "converts a date value" do
    converted = Google::Cloud::Firestore::Convert.raw_to_value Time.parse("2017-01-02 03:04:05.06 UTC").to_date
    _(converted.value_type).must_equal :timestamp_value
  end

  it "converts a string value" do
    value = Google::Cloud::Firestore::V1::Value.new string_value: "Alice"

    converted = Google::Cloud::Firestore::Convert.raw_to_value "Alice"
    _(converted).must_equal value
  end

  it "converts a bytes value" do
    value = Google::Cloud::Firestore::V1::Value.new bytes_value: "c\0ntents"

    converted = Google::Cloud::Firestore::Convert.raw_to_value StringIO.new("c\0ntents")
    _(converted).must_equal value
  end

  it "converts a reference value" do
    value = Google::Cloud::Firestore::V1::Value.new reference_value: "projects/#{project}/databases/(default)/documents/users/alice"
    converted = Google::Cloud::Firestore::Convert.raw_to_value firestore.doc("users/alice")
    _(converted).must_equal value
  end

  it "converts a geo_point value" do
    value = Google::Cloud::Firestore::V1::Value.new geo_point_value: Google::Type::LatLng.new(latitude: 43.878264, longitude: -103.45700740814209)

    converted = Google::Cloud::Firestore::Convert.raw_to_value({ "longitude" => -103.45700740814209, "latitude" => 43.878264 })
    _(converted).must_equal value
  end

  it "converts an array of integer values" do
    value = Google::Cloud::Firestore::V1::Value.new array_value: Google::Cloud::Firestore::V1::ArrayValue.new(values: [Google::Cloud::Firestore::V1::Value.new(integer_value: 1), Google::Cloud::Firestore::V1::Value.new(integer_value: 2), Google::Cloud::Firestore::V1::Value.new(integer_value: 3)])

    converted = Google::Cloud::Firestore::Convert.raw_to_value [1, 2, 3]
    _(converted).must_equal value
  end

  it "converts an array of string values" do
    value = Google::Cloud::Firestore::V1::Value.new array_value: Google::Cloud::Firestore::V1::ArrayValue.new(values: [Google::Cloud::Firestore::V1::Value.new(string_value: "foo"), Google::Cloud::Firestore::V1::Value.new(string_value: "bar"), Google::Cloud::Firestore::V1::Value.new(string_value: "baz")])

    converted = Google::Cloud::Firestore::Convert.raw_to_value %w(foo bar baz)
    _(converted).must_equal value
  end

  it "converts a simple hash value" do
    value = Google::Cloud::Firestore::V1::Value.new map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: {"foo"=>Google::Cloud::Firestore::V1::Value.new(string_value: "bar")})

    converted = Google::Cloud::Firestore::Convert.raw_to_value({ foo: "bar" })
    _(converted).must_equal value
  end

  it "converts a complex hash value" do
    value = Google::Cloud::Firestore::V1::Value.new map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: { "score"=>Google::Cloud::Firestore::V1::Value.new(double_value: 0.9), "env"=>Google::Cloud::Firestore::V1::Value.new(string_value: "production"), "project_ids"=>Google::Cloud::Firestore::V1::Value.new(array_value: Google::Cloud::Firestore::V1::ArrayValue.new(values: [Google::Cloud::Firestore::V1::Value.new(integer_value: 1), Google::Cloud::Firestore::V1::Value.new(integer_value: 2), Google::Cloud::Firestore::V1::Value.new(integer_value: 3)] )) })

    converted = Google::Cloud::Firestore::Convert.raw_to_value({ env: "production", score: 0.9, project_ids: [1, 2, 3] })
    _(converted).must_equal value
  end

  it "converts an emtpy hash value" do
    value = Google::Cloud::Firestore::V1::Value.new map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: {})

    converted = Google::Cloud::Firestore::Convert.raw_to_value({})
    _(converted).must_equal value
  end
end
