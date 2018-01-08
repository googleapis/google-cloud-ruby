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

describe Google::Cloud::Firestore::DocumentSnapshot, :get, :mock_firestore do
  let(:document_path) { "users/mike" }
  let(:document_ref) { Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/#{document_path}", firestore }
  let(:document_time) { Time.now }
  let :document_grpc do
    Google::Firestore::V1beta1::Document.new(
      name: document_ref.path,
      fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike"),
                "foo" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                  "bar" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                    "baz" => Google::Firestore::V1beta1::Value.new(string_value: "bif") })) })) },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)
    )
  end
  let(:document) do
    Google::Cloud::Firestore::DocumentSnapshot.new.tap do |s|
      s.grpc = document_grpc
      s.instance_variable_set :@ref, document_ref
      s.instance_variable_set :@read_at, document_time
    end
  end

  it "retrieves top-level value from data given a fieldpath (string)" do
    document.get("name").must_equal "Mike"
  end

  it "retrieves top-level value from data given a fieldpath (symbol)" do
    document.get(:name).must_equal "Mike"
  end

  it "retrieves top-level value from data given a fieldpath (array(string))" do
    document.get(["name"]).must_equal "Mike"
  end

  it "retrieves top-level value from data given a fieldpath (array(symbol))" do
    document.get([:name]).must_equal "Mike"
  end

  it "retrieves nested value from data given a fieldpath (string)" do
    document.get("foo.bar.baz").must_equal "bif"
  end

  it "retrieves nested value from data given a fieldpath (symbol)" do
    document.get(:"foo.bar.baz").must_equal "bif"
  end

  it "retrieves nested value from data given a fieldpath (array(string))" do
    document.get(["foo", "bar", "baz"]).must_equal "bif"
  end

  it "retrieves nested value from data given a fieldpath (array(symbol))" do
    document.get([:foo, :bar, :baz]).must_equal "bif"
  end

  it "retrieves hash structure from data given a top-level node" do
    document.get(:foo).must_equal({ bar: { baz: "bif" } })
  end

  it "returns nil when given a top-level fieldpath (string) that does not exist" do
    document.get("doesnotexist").must_be :nil?
  end

  it "returns nil when given a top-level fieldpath (symbol) that does not exist" do
    document.get(:doesnotexist).must_be :nil?
  end

  it "raises when given a nested fieldpath (string) that does not exist" do
    error = expect do
      document.get "does.not.exist"
    end.must_raise ArgumentError
    error.message.must_equal "does.not.exist is not contained in the data"
  end

  it "raises when given a nested fieldpath (symbol) that does not exist" do
    error = expect do
      document.get :"does.not.exist"
    end.must_raise ArgumentError
    error.message.must_equal "does.not.exist is not contained in the data"
  end

  it "retrieves full data given nil" do
    document.get(nil).must_equal({ foo: {bar: { baz: "bif" } }, name: "Mike" })
  end

  it "retrieves full data given an empty string" do
    document.get("").must_equal({ foo: {bar: { baz: "bif" } }, name: "Mike" })
  end

  describe "strange data" do
    let :document_grpc do
      Google::Firestore::V1beta1::Document.new(
        name: document_ref.path,
        fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike"),
                  "foo" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                    "bar.baz" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                      "bif" => Google::Firestore::V1beta1::Value.new(integer_value: 42) })) })) },
        create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)
      )
    end

    it "can still retrieve data using arrays" do
      document.get(["foo", "bar.baz", "bif"]).must_equal 42
      document.get([:foo, "bar.baz".to_sym]).must_equal({ bif: 42 })
    end
  end

  describe :[] do
    it "retrieves top-level value from data given a fieldpath (string)" do
      document["name"].must_equal "Mike"
    end

    it "retrieves top-level value from data given a fieldpath (symbol)" do
      document[:name].must_equal "Mike"
    end

    it "retrieves top-level value from data given a fieldpath (array(string))" do
      document[["name"]].must_equal "Mike"
    end

    it "retrieves top-level value from data given a fieldpath (array(symbol))" do
      document[[:name]].must_equal "Mike"
    end

    it "retrieves nested value from data given a fieldpath (string)" do
      document["foo.bar.baz"].must_equal "bif"
    end

    it "retrieves nested value from data given a fieldpath (symbol)" do
      document[:"foo.bar.baz"].must_equal "bif"
    end

    it "retrieves nested value from data given a fieldpath (array(string))" do
      document[["foo", "bar", "baz"]].must_equal "bif"
    end

    it "retrieves nested value from data given a fieldpath (array(symbol))" do
      document[[:foo, :bar, :baz]].must_equal "bif"
    end

    it "retrieves hash structure from data given a top-level node" do
      document[:foo].must_equal({ bar: { baz: "bif" } })
    end

    it "returns nil when given a top-level fieldpath (string) that does not exist" do
      document["doesnotexist"].must_be :nil?
    end

    it "returns nil when given a top-level fieldpath (symbol) that does not exist" do
      document[:doesnotexist].must_be :nil?
    end

    it "raises when given a nested fieldpath (string) that does not exist" do
      error = expect do
        document["does.not.exist"]
      end.must_raise ArgumentError
      error.message.must_equal "does.not.exist is not contained in the data"
    end

    it "raises when given a nested fieldpath (symbol) that does not exist" do
      error = expect do
        document[:"does.not.exist"]
      end.must_raise ArgumentError
      error.message.must_equal "does.not.exist is not contained in the data"
    end

    it "retrieves full data given nil" do
      document[nil].must_equal({ foo: {bar: { baz: "bif" } }, name: "Mike" })
    end

    it "retrieves full data given an empty string" do
      document[""].must_equal({ foo: {bar: { baz: "bif" } }, name: "Mike" })
    end

    describe "strange data" do
      let :document_grpc do
        Google::Firestore::V1beta1::Document.new(
          name: document_ref.path,
          fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike"),
                    "foo" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                      "bar.baz" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                        "bif" => Google::Firestore::V1beta1::Value.new(integer_value: 42) })) })) },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)
        )
      end

      it "can still retrieve data using arrays" do
        document[["foo", "bar.baz", "bif"]].must_equal 42
        document[[:foo, "bar.baz".to_sym]].must_equal({ bif: 42 })
      end
    end
  end
end
