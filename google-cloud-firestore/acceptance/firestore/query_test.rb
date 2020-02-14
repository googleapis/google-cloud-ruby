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

require "firestore_helper"

describe "Query", :firestore_acceptance do
  it "has select method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "bar", bar: "foo"})

    result_snp = rand_query_col.select("foo").get.first
    result_snp[:foo].must_equal "bar"
  end

  it "select() supports empty fields" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "bar", bar: "foo"})

    result_snp = rand_query_col.select.get.first
    result_snp.data.must_be :empty?
  end

  it "has where method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "bar", bar: "foo"})

    result_snp = rand_query_col.where(:foo, :==, :bar).get.first
    result_snp[:foo].must_equal "bar"
  end

  it "has where method with array_contains" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: ["bar", "baz", "bif"]})

    result_snp = rand_query_col.where(:foo, :array_contains, :bif).get.first
    result_snp[:foo].must_equal ["bar", "baz", "bif"]
  end

  it "has where method with in" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "bar"})

    result_snp = rand_query_col.where(:foo, :in, ["bar", "baz", "bif"]).get.first
    result_snp[:foo].must_equal "bar"
  end

  it "has where method with array_contains_any" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: ["bar", "baz", "bif"]})

    result_snp = rand_query_col.where(:foo, :array_contains_any, [:bif, :out]).get.first
    result_snp[:foo].must_equal ["bar", "baz", "bif"]
  end

  it "supports NaN" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    doc_ref = rand_query_col.add({foo: Float::NAN})

    result_snp = rand_query_col.where(:foo, :==, Float::NAN).get.first
    result_snp.wont_be :nil?
    result_snp[:foo].must_be :nan?
  end

  it "supports NaN (symbol)" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    doc_ref = rand_query_col.add({foo: Float::NAN})

    result_snp = rand_query_col.where(:foo, :==, :nan).get.first
    result_snp.wont_be :nil?
    result_snp[:foo].must_be :nan?
  end

  it "supports NULL" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    doc_ref = rand_query_col.add({foo: nil})

    result_snp = rand_query_col.where(:foo, :==, nil).get.first
    result_snp.wont_be :nil?
    result_snp[:foo].must_be :nil?
  end

  it "supports NULL (symbol)" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    doc_ref = rand_query_col.add({foo: nil})

    result_snp = rand_query_col.where(:foo, :==, :null).get.first
    result_snp.wont_be :nil?
    result_snp[:foo].must_be :nil?
  end

  it "has order method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "a"})
    rand_query_col.add({foo: "b"})

    results = rand_query_col.order(:foo).get.map { |doc| doc[:foo] }
    results.must_equal ["a", "b"]

    results = rand_query_col.order(:foo, :desc).get.map { |doc| doc[:foo] }
    results.must_equal ["b", "a"]
  end

  it "can order by document id" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(firestore.document_id).get
    results.map(&:document_id).must_equal ["doc1", "doc2"]
    results.map { |doc| doc[:foo] }.must_equal ["a", "b"]

    # results = rand_query_col.order(firestore.document_id, :desc).get
    # results.map(&:document_id).must_equal ["doc2", "doc1"]
    # results.map { |doc| doc[:foo] }.must_equal ["b", "a"]
  end

  it "has limit method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).limit(1).get
    results.map(&:document_id).must_equal ["doc1"]
    results.map { |doc| doc[:foo] }.must_equal ["a"]
  end

  it "has offset method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).offset(1).get
    results.map(&:document_id).must_equal ["doc2"]
    results.map { |doc| doc[:foo] }.must_equal ["b"]
  end

  it "has start_at method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).start_at("a").get
    results.map(&:document_id).must_equal ["doc1", "doc2"]
    results.map { |doc| doc[:foo] }.must_equal ["a", "b"]
  end

  it "has start_after method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).start_after("a").get
    results.map(&:document_id).must_equal ["doc2"]
    results.map { |doc| doc[:foo] }.must_equal ["b"]
  end

  it "has end_before method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).end_before("b").get
    results.map(&:document_id).must_equal ["doc1"]
    results.map { |doc| doc[:foo] }.must_equal ["a"]
  end

  it "has end_at method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).end_at("b").get
    results.map(&:document_id).must_equal ["doc1", "doc2"]
    results.map { |doc| doc[:foo] }.must_equal ["a", "b"]
  end

  it "can call cursor methods with a DocumentSnapshot object" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).start_at(rand_query_col.doc("doc1").get).get
    results.map(&:document_id).must_equal ["doc1", "doc2"]
    results.map { |doc| doc[:foo] }.must_equal ["a", "b"]

    results = rand_query_col.order(:foo).start_after(rand_query_col.doc("doc1").get).get
    results.map(&:document_id).must_equal ["doc2"]
    results.map { |doc| doc[:foo] }.must_equal ["b"]

    results = rand_query_col.order(:foo).end_before(rand_query_col.doc("doc2").get).get
    results.map(&:document_id).must_equal ["doc1"]
    results.map { |doc| doc[:foo] }.must_equal ["a"]

    results = rand_query_col.order(:foo).end_at(rand_query_col.doc("doc2").get).get
    results.map(&:document_id).must_equal ["doc1", "doc2"]
    results.map { |doc| doc[:foo] }.must_equal ["a", "b"]
  end

  describe "Collection Group" do
    it "queries a collection group" do
      collection_group = "b-#{SecureRandom.hex(4)}"
      doc_paths = [
          "abc/123/#{collection_group}/cg-doc1",
          "abc/123/#{collection_group}/cg-doc2",
          "#{collection_group}/cg-doc3",
          "#{collection_group}/cg-doc4",
          "def/456/#{collection_group}/cg-doc5",
          "#{collection_group}/virtual-doc/nested-coll/not-cg-doc",
          "x#{collection_group}/not-cg-doc",
          "#{collection_group}x/not-cg-doc",
          "abc/123/#{collection_group}x/not-cg-doc",
          "abc/123/x#{collection_group}/not-cg-doc",
          "abc/#{collection_group}"
      ]
      firestore.batch do |b|
        doc_paths.each do |doc_path|
          doc_ref = firestore.document doc_path
          b.set doc_ref, {x: 1}
        end
      end

      query = firestore.collection_group collection_group
      snapshots = query.get
      snapshots.map(&:document_id).must_equal ["cg-doc1", "cg-doc2", "cg-doc3", "cg-doc4", "cg-doc5"]
    end

    it "queries a collection group with start_at and end_at" do
      collection_group = "b-#{SecureRandom.hex(4)}"
      doc_paths = [
        "a/a/#{collection_group}/cg-doc1",
        "a/b/a/b/#{collection_group}/cg-doc2",
        "a/b/#{collection_group}/cg-doc3",
        "a/b/c/d/#{collection_group}/cg-doc4",
        "a/c/#{collection_group}/cg-doc5",
        "#{collection_group}/cg-doc6",
        "a/b/nope/nope"
      ]
      firestore.batch do |b|
        doc_paths.each do |doc_path|
          doc_ref = firestore.document doc_path
          b.set doc_ref, {x: 1}
        end
      end

      query = firestore.collection_group(collection_group)
        .order_by("__name__")
        .start_at(firestore.document("a/b"))
        .end_at(firestore.document("a/b0"))

      snapshots = query.get
      snapshots.map(&:document_id).must_equal ["cg-doc2", "cg-doc3", "cg-doc4"]

      query = firestore.collection_group(collection_group)
        .order_by("__name__")
        .start_after(firestore.document("a/b"))
        .end_before(firestore.document("a/b/#{collection_group}/cg-doc3"))
      snapshots = query.get
      snapshots.map(&:document_id).must_equal ["cg-doc2"]
    end

    it "queries a collection group with filters" do
      collection_group = "b-#{SecureRandom.hex(4)}"
      doc_paths = [
        "a/a/#{collection_group}/cg-doc1",
        "a/b/a/b/#{collection_group}/cg-doc2",
        "a/b/#{collection_group}/cg-doc3",
        "a/b/c/d/#{collection_group}/cg-doc4",
        "a/c/#{collection_group}/cg-doc5",
        "#{collection_group}/cg-doc6",
        "a/b/nope/nope"
      ]
      firestore.batch do |b|
        doc_paths.each do |doc_path|
          doc_ref = firestore.document doc_path
          b.set doc_ref, {x: 1}
        end
      end

      query = firestore.collection_group(collection_group)
        .where("__name__", ">=", firestore.document("a/b"))
        .where("__name__", "<=", firestore.document("a/b0"))

      snapshots = query.get
      snapshots.map(&:document_id).must_equal ["cg-doc2", "cg-doc3", "cg-doc4"]

      query = firestore.collection_group(collection_group)
        .where("__name__", ">", firestore.document("a/b"))
        .where(
          "__name__", "<", firestore.document("a/b/#{collection_group}/cg-doc3")
        )
      snapshots = query.get
      snapshots.map(&:document_id).must_equal ["cg-doc2"]
    end
  end
end
