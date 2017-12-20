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

require "firestore_helper"

describe "Query", :firestore do
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

    results = rand_query_col.order(:__name__).get
    results.map(&:document_id).must_equal ["doc1", "doc2"]
    results.map { |doc| doc[:foo] }.must_equal ["a", "b"]

    # results = rand_query_col.order(:__name__, :desc).get
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
end
