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

describe Google::Cloud::Firestore::Convert, :remove_from do
  # These tests are a sanity check on the implementation of the conversion methods.
  # These tests are testing private methods and this is generally not a great idea.
  # But these conversions are so important that it was decided to do it anyway.

  it "finds paths belonging to a hash" do
    orig = { foo: "FOO", bar: :HELLO }

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_equal({ "foo" => "FOO" })
    paths.must_equal [:bar]
  end

  it "does not find paths belonging to an array" do
    orig = ["FOO", :HELLO]

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_be :nil?
    paths.must_be :empty?
  end

  it "finds paths belonging to a nested hash" do
    orig = { foo: "FOO", bar: { baz: :HELLO } }

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_equal({ "foo" => "FOO" })
    paths.must_equal ["bar.baz"]
  end

  it "finds paths belonging to a deeply nested hash" do
    orig = { foo: { bar: { baz: { bif: :HELLO } } } }

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_equal({ })
    paths.must_equal ["foo.bar.baz.bif"]
  end

  it "does not find paths belonging to a hash nested under an array" do
    orig = [:ZOMG, { "foo" => "FOO", "bar" => :HELLO }]

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_be :nil?
    paths.must_be :empty?
  end

  it "does not find paths belonging to a nested array" do
    orig = ["FOO", ["BAR", :HELLO]]

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_be :nil?
    paths.must_be :empty?
  end

  it "raises when finding paths belonging to an array nested under a hash" do
    orig = { foo: ["FOO", :HELLO] }

    error = expect do
      Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    end.must_raise ArgumentError
    error.message.must_equal "cannot nest HELLO under arrays"
  end

  it "does not find value that is the object" do
    orig = :HELLO

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_be :nil?
    paths.must_be :empty?
  end

  it "does not find value on nil" do
    orig = nil

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_be :nil?
    paths.must_be :empty?
  end

  it "does not find value on a hash" do
    orig = { foo: "BAR", baz: "BIF" }

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_equal({ "foo" => "BAR", "baz" => "BIF" })
    paths.must_be :empty?
  end

  it "does not find value on an array" do
    orig = ["BAZ", "BIF"]

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_be :nil?
    paths.must_be :empty?
  end

  it "does not find value on a nested hash" do
    orig = { foo: { bar: :BAZ } }

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_equal({ "foo" => { "bar" => :BAZ } })
    paths.must_be :empty?
  end

  it "does not find value on a hash nested under an array" do
    orig = ["BAZ", "BIF", { foo: :BAR }]

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_be :nil?
    paths.must_be :empty?
  end

  it "does not find value on a nested array" do
    orig = [:foo, :bar, ["BAZ", "BIF"]]

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_be :nil?
    paths.must_be :empty?
  end

  it "does not find value on an array nested under a hash" do
    orig = { foo: { bar: ["BAZ", "BIF"] } }

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_equal({ "foo" => { "bar" => ["BAZ", "BIF"] } })
    paths.must_be :empty?
  end

  it "does not find value on empty hash" do
    orig = {}

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_equal({ })
    paths.must_be :empty?
  end

  it "does not find value on empty array" do
    orig = []

    hash, paths = Google::Cloud::Firestore::Convert.remove_from orig, :HELLO
    hash.must_be :nil?
    paths.must_be :empty?
  end
end
