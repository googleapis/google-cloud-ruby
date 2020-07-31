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

describe Google::Cloud::Firestore::Client, :cols, :mock_firestore do
  it "retrieves collections" do
    firestore_mock.expect :list_collection_ids, ["users", "lists", "todos"].to_enum, list_collection_ids_args

    col_enum = firestore.cols
    _(col_enum).must_be_kind_of Enumerator

    col_ids = col_enum.map do |col|
      _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference

      _(col.parent).must_be_kind_of Google::Cloud::Firestore::Client

      col.collection_id
    end
    _(col_ids).wont_be :empty?
    _(col_ids).must_equal ["users", "lists", "todos"]
  end

  it "retrieves collections using collections alias" do
    firestore_mock.expect :list_collection_ids, ["users", "lists", "todos"].to_enum, list_collection_ids_args

    col_enum = firestore.collections
    _(col_enum).must_be_kind_of Enumerator

    col_ids = col_enum.map do |col|
      _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference

      _(col.parent).must_be_kind_of Google::Cloud::Firestore::Client

      col.collection_id
    end
    _(col_ids).wont_be :empty?
    _(col_ids).must_equal ["users", "lists", "todos"]
  end
end
