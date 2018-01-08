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

describe Google::Cloud::Firestore::Convert, :select_by_field_paths do
  # These tests are a sanity check on the implementation of the conversion methods.
  # These tests are testing private methods and this is generally not a great idea.
  # But these conversions are so important that it was decided to do it anyway.

  it "finds all selected field paths" do
    orig = { "foo" => "FOO", "bar" => "BAR" }
    paths = [
      Google::Cloud::Firestore::FieldPath.new("foo"),
      Google::Cloud::Firestore::FieldPath.new("bar")
    ]

    result = Google::Cloud::Firestore::Convert.select_by_field_paths orig, paths
    result.must_equal({ "foo" => "FOO", "bar" => "BAR" })
  end

  it "finds all nested selected field paths" do
    orig = { "foo" => { "bar" => "BAR", "baz" => "BAZ" } }
    paths = [
      Google::Cloud::Firestore::FieldPath.new("foo", "bar"),
      Google::Cloud::Firestore::FieldPath.new("foo", "baz")
    ]

    result = Google::Cloud::Firestore::Convert.select_by_field_paths orig, paths
    result.must_equal({ "foo" => { "bar" => "BAR", "baz" => "BAZ" } })
  end

  it "finds deeply nested selected field paths" do
    orig = { "foo" => { "bar" => { "baz" => { "bif" => "BIF" } } } }
    paths = [
      Google::Cloud::Firestore::FieldPath.new("foo", "bar", "baz", "bif")
    ]

    result = Google::Cloud::Firestore::Convert.select_by_field_paths orig, paths
    result.must_equal({ "foo" => { "bar" => { "baz" => { "bif" => "BIF" } } } })
  end

  it "finds partial using field paths" do
    orig = { "foo" => "FOO", "bar" => "BAR" }
    paths = [
      Google::Cloud::Firestore::FieldPath.new("foo")
    ]

    result = Google::Cloud::Firestore::Convert.select_by_field_paths orig, paths
    result.must_equal({ "foo" => "FOO" })
  end

  it "finds partial from nested selected field paths" do
    orig = { "foo" => { "bar" => "BAR", "baz" => "BAZ" }, "mike" => :hi }
    paths = [
      Google::Cloud::Firestore::FieldPath.new("foo", "baz")
    ]

    result = Google::Cloud::Firestore::Convert.select_by_field_paths orig, paths
    result.must_equal({ "foo" => { "baz" => "BAZ" } })
  end
end
