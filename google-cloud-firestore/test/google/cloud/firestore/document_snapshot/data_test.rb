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

describe Google::Cloud::Firestore::DocumentSnapshot, :data, :mock_firestore do
  let(:document_path) { "users/alice" }
  let(:document_ref) { Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/#{document_path}", firestore }
  let(:document_time) { Time.now }
  let(:document) do
    Google::Cloud::Firestore::DocumentSnapshot.new.tap do |s|
      s.grpc = nil
      s.instance_variable_set :@ref, document_ref
      s.instance_variable_set :@read_at, document_time
    end
  end

  it "holds a nil value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "expires_on" => Google::Cloud::Firestore::V1::Value.new(null_value: :NULL_VALUE) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data).must_equal({ expires_on: nil })
  end

  it "holds a true value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "active" => Google::Cloud::Firestore::V1::Value.new(boolean_value: true) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data).must_equal({ active: true })
  end

  it "holds a false value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "expired" => Google::Cloud::Firestore::V1::Value.new(boolean_value: false) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data).must_equal({ expired: false })
  end

  it "holds an integer value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "score" => Google::Cloud::Firestore::V1::Value.new(integer_value: 29) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data).must_equal({ score: 29 })
  end

  it "holds a nan value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "ratio" => Google::Cloud::Firestore::V1::Value.new(double_value: Float::NAN) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data[:ratio]).must_be :nan?
  end

  it "holds an infinity value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "ratio" => Google::Cloud::Firestore::V1::Value.new(double_value: Float::INFINITY) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data).must_equal({ ratio: Float::INFINITY })
  end

  it "holds a float value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "ratio" => Google::Cloud::Firestore::V1::Value.new(double_value: 0.9) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data).must_equal({ ratio: 0.9 })
  end

  it "holds a time value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "published_at" => Google::Cloud::Firestore::V1::Value.new(timestamp_value: Google::Protobuf::Timestamp.new(seconds: 1483326245, nanos: 60000000)) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data).must_equal({ published_at: Time.parse("2017-01-02 03:04:05.06 UTC") })
  end

  it "holds a string value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "name" => Google::Cloud::Firestore::V1::Value.new(string_value: "Alice") },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data).must_equal({ name: "Alice" })
  end

  it "holds a bytes value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "avatar" => Google::Cloud::Firestore::V1::Value.new(bytes_value: "contents") },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data.keys).must_include :avatar
    _(document.data[:avatar].read).must_equal "contents"
  end

  it "holds a reference value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "friend" => Google::Cloud::Firestore::V1::Value.new(reference_value: "projects/#{project}/databases/(default)/documents/users/carol") },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data.keys).must_include :friend
    _(document.data[:friend]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(document.data[:friend].document_id).must_equal "carol"
    _(document.data[:friend].document_path).must_equal "users/carol"
    _(document.data[:friend].path).must_equal "projects/#{project}/databases/(default)/documents/users/carol"
  end

  it "holds a geo_point value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "location" => Google::Cloud::Firestore::V1::Value.new(geo_point_value: Google::Type::LatLng.new(latitude: 43.878264, longitude: -103.45700740814209)) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data).must_equal({ location: { longitude: -103.45700740814209, latitude: 43.878264 } })
  end

  it "holds an array value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "projects" => Google::Cloud::Firestore::V1::Value.new(array_value: Google::Cloud::Firestore::V1::ArrayValue.new(values: [Google::Cloud::Firestore::V1::Value.new(integer_value: 1), Google::Cloud::Firestore::V1::Value.new(integer_value: 2), Google::Cloud::Firestore::V1::Value.new(integer_value: 3)])) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data).must_equal({ projects: [1, 2, 3] })
  end

  it "holds a hash value" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "details" => Google::Cloud::Firestore::V1::Value.new(map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: { "score"=>Google::Cloud::Firestore::V1::Value.new(double_value: 0.9), "env"=>Google::Cloud::Firestore::V1::Value.new(string_value: "production"), "project_ids"=>Google::Cloud::Firestore::V1::Value.new(array_value: Google::Cloud::Firestore::V1::ArrayValue.new(values: [Google::Cloud::Firestore::V1::Value.new(integer_value: 1), Google::Cloud::Firestore::V1::Value.new(integer_value: 2), Google::Cloud::Firestore::V1::Value.new(integer_value: 3)] )) })) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data).must_equal({ details: { env: "production", score: 0.9, project_ids: [1, 2, 3] } })
  end

  it "holds all the values" do
    document.grpc = Google::Cloud::Firestore::V1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "expires_on" => Google::Cloud::Firestore::V1::Value.new(null_value: :NULL_VALUE),
                "active" => Google::Cloud::Firestore::V1::Value.new(boolean_value: true),
                "expired" => Google::Cloud::Firestore::V1::Value.new(boolean_value: false),
                "score" => Google::Cloud::Firestore::V1::Value.new(integer_value: 29),
                "ratio" => Google::Cloud::Firestore::V1::Value.new(double_value: 0.9),
                "published_at" => Google::Cloud::Firestore::V1::Value.new(timestamp_value: Google::Protobuf::Timestamp.new(seconds: 1483326245, nanos: 60000000)),
                "name" => Google::Cloud::Firestore::V1::Value.new(string_value: "Alice"),
                "avatar" => Google::Cloud::Firestore::V1::Value.new(bytes_value: "contents"),
                "friend" => Google::Cloud::Firestore::V1::Value.new(reference_value: "projects/#{project}/databases/(default)/documents/users/carol"),
                "location" => Google::Cloud::Firestore::V1::Value.new(geo_point_value: Google::Type::LatLng.new(latitude: 43.878264, longitude: -103.45700740814209)),
                "details" => Google::Cloud::Firestore::V1::Value.new(map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: { "score"=>Google::Cloud::Firestore::V1::Value.new(double_value: 0.9), "env"=>Google::Cloud::Firestore::V1::Value.new(string_value: "production"), "project_ids"=>Google::Cloud::Firestore::V1::Value.new(array_value: Google::Cloud::Firestore::V1::ArrayValue.new(values: [Google::Cloud::Firestore::V1::Value.new(integer_value: 1), Google::Cloud::Firestore::V1::Value.new(integer_value: 2), Google::Cloud::Firestore::V1::Value.new(integer_value: 3)] )) })) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    _(document.data[:expires_on]).must_be :nil?
    _(document.data[:active]).must_equal true
    _(document.data[:expired]).must_equal false
    _(document.data[:score]).must_equal 29
    _(document.data[:ratio]).must_equal 0.9
    _(document.data[:published_at]).must_equal Time.parse("2017-01-02 03:04:05.06 UTC")
    _(document.data[:name]).must_equal "Alice"
    _(document.data.keys).must_include :avatar
    _(document.data[:avatar].read).must_equal "contents"
    _(document.data.keys).must_include :friend
    _(document.data[:friend]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(document.data[:friend].document_id).must_equal "carol"
    _(document.data[:friend].document_path).must_equal "users/carol"
    _(document.data[:friend].path).must_equal "projects/#{project}/databases/(default)/documents/users/carol"
    _(document.data[:location]).must_equal({ longitude: -103.45700740814209, latitude: 43.878264 })
    _(document.data[:details]).must_equal({ env: "production", score: 0.9, project_ids: [1, 2, 3] })
  end
end
