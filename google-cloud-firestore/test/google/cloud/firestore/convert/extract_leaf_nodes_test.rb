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

describe Google::Cloud::Firestore::Convert, :extract_leaf_nodes do
  # These tests are a sanity check on the implementation of the conversion methods.
  # These tests are testing private methods and this is generally not a great idea.
  # But these conversions are so important that it was decided to do it anyway.

  it "finds paths belonging to a hash" do
    orig = { foo: "FOO", bar: "BAR" }

    paths = Google::Cloud::Firestore::Convert.extract_leaf_nodes orig
    paths.must_equal ["foo", "bar"]
  end

  it "finds paths belonging to a nested hash" do
    orig = { foo: { bar: "BAR", baz: "BAZ" } }

    paths = Google::Cloud::Firestore::Convert.extract_leaf_nodes orig
    paths.must_equal ["foo.bar", "foo.baz"]
  end

  it "finds paths belonging to a deeply nested hash" do
    orig = { foo: { bar: { baz: { bif: "BIF" } } } }

    paths = Google::Cloud::Firestore::Convert.extract_leaf_nodes orig
    paths.must_equal ["foo.bar.baz.bif"]
  end
end
