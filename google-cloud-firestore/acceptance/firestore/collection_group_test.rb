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
    it "queries a collection group using partitions" do
      rand_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"

      document_ids = ["a", "b", "c"].map do |prefix|
        # Minimum partition size is 128.
        128.times.map do |i|
          "#{prefix}#{(i+1).to_s.rjust(3, '0')}"
        end
      end.flatten # "a001", "a002", ... "c128"
      firestore.batch do |b|
        document_ids.each do |id|
          doc_ref = rand_col.document id
          b.set doc_ref, { foo: id }
        end
      end

      collection_group = firestore.collection_group(rand_col.collection_id)

      partitions = collection_group.partitions 6
      _(partitions).must_be_kind_of Array
      _(partitions.count).must_equal 3

      _(partitions[0]).must_be_kind_of Google::Cloud::Firestore::QueryPartition
      _(partitions[0].start_at).must_be :nil?
      _(partitions[0].end_before).must_be_kind_of Array
      _(partitions[0].end_before[0]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(document_ids).must_include partitions[0].end_before[0].document_id

      _(partitions[1]).must_be_kind_of Google::Cloud::Firestore::QueryPartition
      _(partitions[1].start_at).must_be_kind_of Array
      _(partitions[1].start_at[0]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(document_ids).must_include partitions[1].start_at[0].document_id
      _(partitions[1].end_before).must_be_kind_of Array
      _(partitions[1].end_before[0]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(document_ids).must_include partitions[1].end_before[0].document_id

      # Verify that partitions are sorted ascending order
      _(partitions[0].end_before[0].document_id).must_be :<, partitions[1].end_before[0].document_id

      _(partitions[2]).must_be_kind_of Google::Cloud::Firestore::QueryPartition
      _(partitions[2].start_at).must_be_kind_of Array
      _(partitions[2].start_at[0]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(document_ids).must_include partitions[2].start_at[0].document_id
      _(partitions[2].end_before).must_be :nil?

      queries = partitions.map(&:to_query)
      _(queries.count).must_equal 3
      results = queries.map do |query|
        _(query).must_be_kind_of Google::Cloud::Firestore::Query
        query.get.map do |snp|
          _(snp).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot
          snp.document_id
        end
      end
      results.each { |result| _(result).wont_be :empty? }
      # Verify all document IDs have been returned, in original order.
      _(results.flatten).must_equal document_ids

      # Verify QueryPartition#start_at and #end_before can be used with a new Query.
      query = collection_group.order("__name__").start_at(partitions[1].start_at).end_before(partitions[1].end_before)
      result = query.get.map do |snp|
        _(snp).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot
        snp.document_id
      end
      _(result).must_equal results[1]
    end
  end
end
