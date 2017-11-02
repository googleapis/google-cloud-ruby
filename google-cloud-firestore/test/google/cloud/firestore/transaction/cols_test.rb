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

describe Google::Cloud::Firestore::Transaction, :cols, :mock_firestore do
  let(:transaction_id) { "transaction123" }
  let(:transaction) do
    Google::Cloud::Firestore::Transaction.from_database(firestore).tap do |b|
      b.instance_variable_set :@transaction_id, transaction_id
    end
  end

  it "retrieves collections" do
    firestore_mock.expect :list_collection_ids, ["users", "lists", "todos"].to_enum, ["projects/#{project}/databases/(default)/documents", options: default_options]

    col_enum = transaction.cols
    col_enum.must_be_kind_of Enumerator

    col_ids = col_enum.map do |col|
      col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference

      col.parent.must_be_kind_of Google::Cloud::Firestore::Database
      col.parent.project_id.must_equal project
      col.parent.database_id.must_equal "(default)"

      col.context.must_equal transaction
      col.parent.must_equal firestore

      col.collection_id
    end
    col_ids.wont_be :empty?
    col_ids.must_equal ["users", "lists", "todos"]
  end

  it "retrieves collections using collections alias" do
    firestore_mock.expect :list_collection_ids, ["users", "lists", "todos"].to_enum, ["projects/#{project}/databases/(default)/documents", options: default_options]

    col_enum = transaction.collections
    col_enum.must_be_kind_of Enumerator

    col_ids = col_enum.map do |col|
      col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference

      col.parent.must_be_kind_of Google::Cloud::Firestore::Database
      col.parent.project_id.must_equal project
      col.parent.database_id.must_equal "(default)"

      col.context.must_equal transaction
      col.parent.must_equal firestore

      col.collection_id
    end
    col_ids.wont_be :empty?
    col_ids.must_equal ["users", "lists", "todos"]
  end
end
