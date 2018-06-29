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
    value = Google::Firestore::V1beta1::Value.new null_value: :NULL_VALUE

    converted = Google::Cloud::Firestore::Convert.raw_to_value nil
    converted.must_equal value
  end

  it "converts a true boolean value" do
    value = Google::Firestore::V1beta1::Value.new boolean_value: true

    converted = Google::Cloud::Firestore::Convert.raw_to_value true
    converted.must_equal value
  end

  it "converts a false boolean value" do
    value = Google::Firestore::V1beta1::Value.new boolean_value: false

    converted = Google::Cloud::Firestore::Convert.raw_to_value false
    converted.must_equal value
  end

  it "converts a integer value" do
    value = Google::Firestore::V1beta1::Value.new integer_value: 29

    converted = Google::Cloud::Firestore::Convert.raw_to_value 29
    converted.must_equal value
  end

  it "converts a double value" do
    value = Google::Firestore::V1beta1::Value.new double_value: 0.9

    converted = Google::Cloud::Firestore::Convert.raw_to_value 0.9
    converted.must_equal value
  end

  it "converts a timestamp value" do
    value = Google::Firestore::V1beta1::Value.new timestamp_value: Google::Protobuf::Timestamp.new(seconds: 1483326245, nanos: 60000000)

    converted = Google::Cloud::Firestore::Convert.raw_to_value Time.parse("2017-01-02 03:04:05.06 UTC")
    converted.must_equal value
  end

  it "converts a datetime value" do
    value = Google::Firestore::V1beta1::Value.new timestamp_value: Google::Protobuf::Timestamp.new(seconds: 1483326245, nanos: 60000000)

    converted = Google::Cloud::Firestore::Convert.raw_to_value Time.parse("2017-01-02 03:04:05.06 UTC").to_datetime
    converted.must_equal value
  end

  it "converts a date value" do
    converted = Google::Cloud::Firestore::Convert.raw_to_value Time.parse("2017-01-02 03:04:05.06 UTC").to_date
    converted.value_type.must_equal :timestamp_value
  end

  it "converts a string value" do
    value = Google::Firestore::V1beta1::Value.new string_value: "Mike"

    converted = Google::Cloud::Firestore::Convert.raw_to_value "Mike"
    converted.must_equal value
  end

  it "converts a bytes value" do
    value = Google::Firestore::V1beta1::Value.new bytes_value: "contents"

    converted = Google::Cloud::Firestore::Convert.raw_to_value StringIO.new("contents")
    converted.must_equal value
  end

  it "converts a reference value" do
    value = Google::Firestore::V1beta1::Value.new reference_value: "projects/#{project}/databases/(default)/documents/users/mike"
    converted = Google::Cloud::Firestore::Convert.raw_to_value firestore.doc("users/mike")
    converted.must_equal value
  end

  it "converts a geo_point value" do
    value = Google::Firestore::V1beta1::Value.new geo_point_value: Google::Type::LatLng.new(latitude: 43.878264, longitude: -103.45700740814209)

    converted = Google::Cloud::Firestore::Convert.raw_to_value({ longitude: -103.45700740814209, latitude: 43.878264 })
    converted.must_equal value
  end

  it "converts an array of integer values" do
    value = Google::Firestore::V1beta1::Value.new array_value: Google::Firestore::V1beta1::ArrayValue.new(values: [Google::Firestore::V1beta1::Value.new(integer_value: 1), Google::Firestore::V1beta1::Value.new(integer_value: 2), Google::Firestore::V1beta1::Value.new(integer_value: 3)])

    converted = Google::Cloud::Firestore::Convert.raw_to_value [1, 2, 3]
    converted.must_equal value
  end

  it "converts an array of string values" do
    value = Google::Firestore::V1beta1::Value.new array_value: Google::Firestore::V1beta1::ArrayValue.new(values: [Google::Firestore::V1beta1::Value.new(string_value: "foo"), Google::Firestore::V1beta1::Value.new(string_value: "bar"), Google::Firestore::V1beta1::Value.new(string_value: "baz")])

    converted = Google::Cloud::Firestore::Convert.raw_to_value %w(foo bar baz)
    converted.must_equal value
  end

  it "converts a simple hash value" do
    value = Google::Firestore::V1beta1::Value.new map_value: Google::Firestore::V1beta1::MapValue.new(fields: {"foo"=>Google::Firestore::V1beta1::Value.new(string_value: "bar")})

    converted = Google::Cloud::Firestore::Convert.raw_to_value({ foo: "bar" })
    converted.must_equal value
  end

  it "converts a complex hash value" do
    value = Google::Firestore::V1beta1::Value.new map_value: Google::Firestore::V1beta1::MapValue.new(fields: { "score"=>Google::Firestore::V1beta1::Value.new(double_value: 0.9), "env"=>Google::Firestore::V1beta1::Value.new(string_value: "production"), "project_ids"=>Google::Firestore::V1beta1::Value.new(array_value: Google::Firestore::V1beta1::ArrayValue.new(values: [Google::Firestore::V1beta1::Value.new(integer_value: 1), Google::Firestore::V1beta1::Value.new(integer_value: 2), Google::Firestore::V1beta1::Value.new(integer_value: 3)] )) })

    converted = Google::Cloud::Firestore::Convert.raw_to_value({ env: "production", score: 0.9, project_ids: [1, 2, 3] })
    converted.must_equal value
  end

  it "converts an emtpy hash value" do
    value = Google::Firestore::V1beta1::Value.new map_value: Google::Firestore::V1beta1::MapValue.new(fields: {})

    converted = Google::Cloud::Firestore::Convert.raw_to_value({})
    converted.must_equal value
  end
end
