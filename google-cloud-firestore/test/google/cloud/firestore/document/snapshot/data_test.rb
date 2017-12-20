# Copyright 2017, Google Inc. All rights reserved.
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

describe Google::Cloud::Firestore::Document, :data, :mock_firestore do
  let(:document_path) { "users/mike" }
  let(:document_ref) { Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/#{document_path}", firestore }
  let(:document_time) { Time.now }
  let(:document) do
    Google::Cloud::Firestore::Document::Snapshot.new.tap do |s|
      s.grpc = nil
      s.instance_variable_set :@ref, document_ref
      s.instance_variable_set :@read_at, document_time
    end
  end

  it "holds a nil value" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "expires_on" => Google::Firestore::V1beta1::Value.new(null_value: :NULL_VALUE) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data.must_equal({ expires_on: nil })
  end

  it "holds a true value" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "active" => Google::Firestore::V1beta1::Value.new(boolean_value: true) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data.must_equal({ active: true })
  end

  it "holds a false value" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "expired" => Google::Firestore::V1beta1::Value.new(boolean_value: false) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data.must_equal({ expired: false })
  end

  it "holds an integer value" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "score" => Google::Firestore::V1beta1::Value.new(integer_value: 29) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data.must_equal({ score: 29 })
  end

  it "holds a float value" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "ratio" => Google::Firestore::V1beta1::Value.new(double_value: 0.9) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data.must_equal({ ratio: 0.9 })
  end

  it "holds a time value" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "published_at" => Google::Firestore::V1beta1::Value.new(timestamp_value: Google::Protobuf::Timestamp.new(seconds: 1483326245, nanos: 60000000)) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data.must_equal({ published_at: Time.parse("2017-01-02 03:04:05.06 UTC") })
  end

  it "holds a string value" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike") },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data.must_equal({ name: "Mike" })
  end

  it "holds a bytes value" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "avatar" => Google::Firestore::V1beta1::Value.new(bytes_value: Base64.strict_encode64("contents")) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data.keys.must_include :avatar
    document.data[:avatar].read.must_equal "contents"
  end

  it "holds a reference value" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "friend" => Google::Firestore::V1beta1::Value.new(reference_value: "projects/#{project}/databases/(default)/documents/users/chris") },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data.keys.must_include :friend
    document.data[:friend].must_be_kind_of Google::Cloud::Firestore::Document::Reference
    document.data[:friend].project_id.must_equal project
    document.data[:friend].database_id.must_equal "(default)"
    document.data[:friend].document_id.must_equal "chris"
    document.data[:friend].document_path.must_equal "users/chris"
    document.data[:friend].path.must_equal "projects/#{project}/databases/(default)/documents/users/chris"
  end

  it "holds a geo_point value" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "location" => Google::Firestore::V1beta1::Value.new(geo_point_value: Google::Type::LatLng.new(latitude: 43.878264, longitude: -103.45700740814209)) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data.must_equal({ location: { longitude: -103.45700740814209, latitude: 43.878264 } })
  end

  it "holds an array value" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "projects" => Google::Firestore::V1beta1::Value.new(array_value: Google::Firestore::V1beta1::ArrayValue.new(values: [Google::Firestore::V1beta1::Value.new(integer_value: 1), Google::Firestore::V1beta1::Value.new(integer_value: 2), Google::Firestore::V1beta1::Value.new(integer_value: 3)])) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data.must_equal({ projects: [1, 2, 3] })
  end

  it "holds a hash value" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "details" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: { "score"=>Google::Firestore::V1beta1::Value.new(double_value: 0.9), "env"=>Google::Firestore::V1beta1::Value.new(string_value: "production"), "project_ids"=>Google::Firestore::V1beta1::Value.new(array_value: Google::Firestore::V1beta1::ArrayValue.new(values: [Google::Firestore::V1beta1::Value.new(integer_value: 1), Google::Firestore::V1beta1::Value.new(integer_value: 2), Google::Firestore::V1beta1::Value.new(integer_value: 3)] )) })) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data.must_equal({ details: { env: "production", score: 0.9, project_ids: [1, 2, 3] } })
  end

  it "holds all the values" do
    document.grpc = Google::Firestore::V1beta1::Document.new \
      name: "projects/#{project}/databases/(default)/documents/#{document_path}",
      fields: { "expires_on" => Google::Firestore::V1beta1::Value.new(null_value: :NULL_VALUE),
                "active" => Google::Firestore::V1beta1::Value.new(boolean_value: true),
                "expired" => Google::Firestore::V1beta1::Value.new(boolean_value: false),
                "score" => Google::Firestore::V1beta1::Value.new(integer_value: 29),
                "ratio" => Google::Firestore::V1beta1::Value.new(double_value: 0.9),
                "published_at" => Google::Firestore::V1beta1::Value.new(timestamp_value: Google::Protobuf::Timestamp.new(seconds: 1483326245, nanos: 60000000)),
                "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike"),
                "avatar" => Google::Firestore::V1beta1::Value.new(bytes_value: Base64.strict_encode64("contents")),
                "friend" => Google::Firestore::V1beta1::Value.new(reference_value: "projects/#{project}/databases/(default)/documents/users/chris"),
                "location" => Google::Firestore::V1beta1::Value.new(geo_point_value: Google::Type::LatLng.new(latitude: 43.878264, longitude: -103.45700740814209)),
                "details" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: { "score"=>Google::Firestore::V1beta1::Value.new(double_value: 0.9), "env"=>Google::Firestore::V1beta1::Value.new(string_value: "production"), "project_ids"=>Google::Firestore::V1beta1::Value.new(array_value: Google::Firestore::V1beta1::ArrayValue.new(values: [Google::Firestore::V1beta1::Value.new(integer_value: 1), Google::Firestore::V1beta1::Value.new(integer_value: 2), Google::Firestore::V1beta1::Value.new(integer_value: 3)] )) })) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)

    document.data[:expires_on].must_be :nil?
    document.data[:active].must_equal true
    document.data[:expired].must_equal false
    document.data[:score].must_equal 29
    document.data[:ratio].must_equal 0.9
    document.data[:published_at].must_equal Time.parse("2017-01-02 03:04:05.06 UTC")
    document.data[:name].must_equal "Mike"
    document.data.keys.must_include :avatar
    document.data[:avatar].read.must_equal "contents"
    document.data.keys.must_include :friend
    document.data[:friend].must_be_kind_of Google::Cloud::Firestore::Document::Reference
    document.data[:friend].project_id.must_equal project
    document.data[:friend].database_id.must_equal "(default)"
    document.data[:friend].document_id.must_equal "chris"
    document.data[:friend].document_path.must_equal "users/chris"
    document.data[:friend].path.must_equal "projects/#{project}/databases/(default)/documents/users/chris"
    document.data[:location].must_equal({ longitude: -103.45700740814209, latitude: 43.878264 })
    document.data[:details].must_equal({ env: "production", score: 0.9, project_ids: [1, 2, 3] })
  end
end
