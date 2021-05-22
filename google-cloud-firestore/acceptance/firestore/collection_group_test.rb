# Copyright 2021 Google LLC
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

require "firestore_helper"

describe Google::Cloud::Firestore::CollectionGroup, :firestore_acceptance do
  describe "#get" do
    it "queries a collection group" do
      collection_id = "b-#{SecureRandom.hex(4)}"
      doc_paths = [
          "abc/123/#{collection_id}/cg-doc1",
          "abc/123/#{collection_id}/cg-doc2",
          "#{collection_id}/cg-doc3",
          "#{collection_id}/cg-doc4",
          "def/456/#{collection_id}/cg-doc5",
          "#{collection_id}/virtual-doc/nested-coll/not-cg-doc",
          "x#{collection_id}/not-cg-doc",
          "#{collection_id}x/not-cg-doc",
          "abc/123/#{collection_id}x/not-cg-doc",
          "abc/123/x#{collection_id}/not-cg-doc",
          "abc/#{collection_id}"
      ]
      firestore.batch do |b|
        doc_paths.each do |doc_path|
          doc_ref = firestore.document doc_path
          b.set doc_ref, {x: 1}
        end
      end

      collection_group = firestore.collection_group(collection_id)
      snapshots = collection_group.get
      _(snapshots.map(&:document_id)).must_equal ["cg-doc1", "cg-doc2", "cg-doc3", "cg-doc4", "cg-doc5"]
    end

    it "queries a collection group with start_at and end_at" do
      collection_id = "b-#{SecureRandom.hex(4)}"
      doc_paths = [
        "a/a/#{collection_id}/cg-doc1",
        "a/b/a/b/#{collection_id}/cg-doc2",
        "a/b/#{collection_id}/cg-doc3",
        "a/b/c/d/#{collection_id}/cg-doc4",
        "a/c/#{collection_id}/cg-doc5",
        "#{collection_id}/cg-doc6",
        "a/b/nope/nope"
      ]
      firestore.batch do |b|
        doc_paths.each do |doc_path|
          doc_ref = firestore.document doc_path
          b.set doc_ref, {x: 1}
        end
      end

      collection_group = firestore.collection_group(collection_id)
        .order_by("__name__")
        .start_at(firestore.document("a/b"))
        .end_at(firestore.document("a/b0"))

      snapshots = collection_group.get
      _(snapshots.map(&:document_id)).must_equal ["cg-doc2", "cg-doc3", "cg-doc4"]

      collection_group = firestore.collection_group(collection_id)
        .order_by("__name__")
        .start_after(firestore.document("a/b"))
        .end_before(firestore.document("a/b/#{collection_id}/cg-doc3"))
      snapshots = collection_group.get
      _(snapshots.map(&:document_id)).must_equal ["cg-doc2"]
    end

    it "queries a collection group with filters" do
      collection_id = "b-#{SecureRandom.hex(4)}"
      doc_paths = [
        "a/a/#{collection_id}/cg-doc1",
        "a/b/a/b/#{collection_id}/cg-doc2",
        "a/b/#{collection_id}/cg-doc3",
        "a/b/c/d/#{collection_id}/cg-doc4",
        "a/c/#{collection_id}/cg-doc5",
        "#{collection_id}/cg-doc6",
        "a/b/nope/nope"
      ]
      firestore.batch do |b|
        doc_paths.each do |doc_path|
          doc_ref = firestore.document doc_path
          b.set doc_ref, {x: 1}
        end
      end

      collection_group = firestore.collection_group(collection_id)
        .where("__name__", ">=", firestore.document("a/b"))
        .where("__name__", "<=", firestore.document("a/b0"))

      snapshots = collection_group.get
      _(snapshots.map(&:document_id)).must_equal ["cg-doc2", "cg-doc3", "cg-doc4"]

      collection_group = firestore.collection_group(collection_id)
        .where("__name__", ">", firestore.document("a/b"))
        .where(
          "__name__", "<", firestore.document("a/b/#{collection_id}/cg-doc3")
        )
      snapshots = collection_group.get
      _(snapshots.map(&:document_id)).must_equal ["cg-doc2"]
    end
  end

  describe "#partitions" do
    it "queries a collection group with partitions" do
      document_count = 2 * 128 + 127 # Minimum partition size is 128.
      rand_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      firestore.batch do |b|
        document_count.times do |i|
          doc_ref = rand_col.document i
          b.set doc_ref, {foo: i}
        end
      end

      collection_group = firestore.collection_group(rand_col.collection_id)

      partitions = collection_group.partitions 3
      _(partitions).must_be_kind_of Google::Cloud::Firestore::QueryPartition::List
      _(partitions.count).must_equal 3
    end
  end
end
