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

describe Google::Cloud::Firestore::Convert, :is_nested do
  # These tests are a sanity check on the implementation of the conversion methods.
  # These tests are testing private methods and this is generally not a great idea.
  # But these conversions are so important that it was decided to do it anyway.

  it "finds values belonging to a hash" do
    obj = { foo: "FOO", bar: :HELLO }

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal true
  end

  it "finds values belonging to an array" do
    obj = ["FOO", :HELLO]

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal true
  end

  it "finds values belonging to a nested hash" do
    obj = { foo: "FOO", bar: { baz: :HELLO } }

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal true
  end

  it "finds values belonging to a hash nested under an array" do
    obj = [:ZOMG, { foo: "FOO", bar: :HELLO }]

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal true
  end

  it "finds values belonging to a nested array" do
    obj = ["FOO", ["BAR", :HELLO]]

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal true
  end

  it "finds values belonging to an array nested under a hash" do
    obj = { foo: ["FOO", :HELLO] }

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal true
  end

  it "finds value that is the object" do
    obj = :HELLO

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal true
  end

  it "does not find value on nil" do
    obj = nil

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal false
  end

  it "does not find value on a hash" do
    obj = { foo: "BAR", baz: "BIF" }

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal false
  end

  it "does not find value on an array" do
    obj = ["BAZ", "BIF"]

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal false
  end

  it "does not find value on a nested hash" do
    obj = { foo: { bar: :BAZ } }

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal false
  end

  it "does not find value on a hash nested under an array" do
    obj = ["BAZ", "BIF", { foo: :BAR }]

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal false
  end

  it "does not find value on a nested array" do
    obj = [:foo, :bar, ["BAZ", "BIF"]]

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal false
  end

  it "does not find value on an array nested under a hash" do
    obj = { foo: { bar: ["BAZ", "BIF"] } }

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal false
  end

  it "does not find value on empty hash" do
    obj = {}

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal false
  end

  it "does not find value on empty array" do
    obj = []

    resp = Google::Cloud::Firestore::Convert.is_nested obj, :HELLO
    resp.must_equal false
  end
end
