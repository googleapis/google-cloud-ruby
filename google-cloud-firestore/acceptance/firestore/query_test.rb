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
    _(result_snp[:foo]).must_equal "bar"
  end

  it "select() supports empty fields" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "bar", bar: "foo"})

    result_snp = rand_query_col.select.get.first
    _(result_snp.data).must_be :empty?
  end

  it "has where method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "bar", bar: "foo"})

    result_snp = rand_query_col.where(:foo, :==, :bar).get.first
    _(result_snp[:foo]).must_equal "bar"
  end

  it "run query with read time argument" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    results = []
    results_1 = []

    rand_query_col.add({foo: "bar", bar: "foo"})

    sleep(1)
    read_time = Time.now
    sleep(1)

    rand_query_col.add({foo: "bar", bar: "foo"})

    rand_query_col.where(:foo, :==, :bar).get(read_time: read_time) { |doc| results << doc }
    rand_query_col.where(:foo, :==, :bar).get { |doc| results_1 << doc }

    _(results.count).must_equal 1
    _(results_1.count).must_equal 2
  end

  it "has where method with !=" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "bar", bar: "foo"})

    result_snp = rand_query_col.where(:foo, :!=, :baz).get.first
    _(result_snp[:foo]).must_equal "bar"
  end

  it "has where method with array_contains" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: ["bar", "baz", "bif"]})

    result_snp = rand_query_col.where(:foo, :array_contains, :bif).get.first
    _(result_snp[:foo]).must_equal ["bar", "baz", "bif"]
  end

  it "has where method with in" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "bar"})

    result_snp = rand_query_col.where(:foo, :in, ["bar", "baz", "bif"]).get.first
    _(result_snp[:foo]).must_equal "bar"
  end

  it "has where method with not_in" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "bar"})

    result_snp = rand_query_col.where(:foo, :not_in, ["baz", "bif"]).get.first
    _(result_snp[:foo]).must_equal "bar"
  end

  it "has where method with array_contains_any" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: ["bar", "baz", "bif"]})

    result_snp = rand_query_col.where(:foo, :array_contains_any, [:bif, :out]).get.first
    _(result_snp[:foo]).must_equal ["bar", "baz", "bif"]
  end

  it "supports NaN with equal" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    doc_ref = rand_query_col.add({foo: Float::NAN})

    result_snp = rand_query_col.where(:foo, :==, Float::NAN).get.first
    _(result_snp).wont_be :nil?
    _(result_snp[:foo]).must_be :nan?
  end

  it "supports NaN (symbol) with equal" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    doc_ref = rand_query_col.add({foo: Float::NAN})

    result_snp = rand_query_col.where(:foo, :==, :nan).get.first
    _(result_snp).wont_be :nil?
    _(result_snp[:foo]).must_be :nan?
  end

  it "supports NULL with equal" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    doc_ref = rand_query_col.add({foo: nil})

    result_snp = rand_query_col.where(:foo, :==, nil).get.first
    _(result_snp).wont_be :nil?
    _(result_snp[:foo]).must_be :nil?
  end

  it "supports NULL (symbol) with equal" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    doc_ref = rand_query_col.add({foo: nil})

    result_snp = rand_query_col.where(:foo, :==, :null).get.first
    _(result_snp).wont_be :nil?
    _(result_snp[:foo]).must_be :nil?
  end

  it "supports NaN with not equal" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    doc_ref = rand_query_col.add({foo: "bar"})

    result_snp = rand_query_col.where(:foo, :!=, Float::NAN).get.first
    _(result_snp).wont_be :nil?
    _(result_snp[:foo]).must_equal "bar"
  end

  it "supports NULL with not equal" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    doc_ref = rand_query_col.add({foo: "bar"})

    result_snp = rand_query_col.where(:foo, :!=, nil).get.first
    _(result_snp).wont_be :nil?
    _(result_snp[:foo]).must_equal "bar"
  end

  it "has order method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "a"})
    rand_query_col.add({foo: "b"})

    results = rand_query_col.order(:foo).get.map { |doc| doc[:foo] }
    _(results).must_equal ["a", "b"]

    results = rand_query_col.order(:foo, :desc).get.map { |doc| doc[:foo] }
    _(results).must_equal ["b", "a"]
  end

  it "can order by document id" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(firestore.document_id).get
    _(results.map(&:document_id)).must_equal ["doc1", "doc2"]
    _(results.map { |doc| doc[:foo] }).must_equal ["a", "b"]

    # results = rand_query_col.order(firestore.document_id, :desc).get
    # results.map(&:document_id).must_equal ["doc2", "doc1"]
    # results.map { |doc| doc[:foo] }.must_equal ["b", "a"]
  end

  it "has limit method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})
    rand_query_col.doc("doc3").create({foo: "c"})

    query = rand_query_col.order(:foo).limit 2

    results_1 = []
    query.get { |result| results_1 << result } # block directly to get, rpc
    _(results_1.map(&:document_id)).must_equal ["doc1","doc2"]
    _(results_1.map { |doc| doc[:foo] }).must_equal ["a","b"]

    results_2 = []
    query.get { |result| results_2 << result } # block directly to get, rpc
    _(results_2.map(&:document_id)).must_equal ["doc1","doc2"]
    _(results_2.map { |doc| doc[:foo] }).must_equal ["a","b"]

    results_3 = query.get # enum_for :get
    _(results_3.map(&:document_id)).must_equal ["doc1","doc2"] # rpc
    _(results_3.map { |doc| doc[:foo] }).must_equal ["a","b"] # rpc

    results_4 = query.get # enum_for :get
    _(results_4.map(&:document_id)).must_equal ["doc1","doc2"] # rpc
    _(results_4.map { |doc| doc[:foo] }).must_equal ["a","b"] # rpc
  end

  it "has limit_to_last method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})
    rand_query_col.doc("doc3").create({foo: "c"})

    query = rand_query_col.order(:foo).limit_to_last 2

    results_1 = []
    query.get { |result| results_1 << result } # block directly to get, rpc
    _(results_1.map(&:document_id)).must_equal ["doc2","doc3"]
    _(results_1.map { |doc| doc[:foo] }).must_equal ["b","c"]

    results_2 = []
    query.get { |result| results_2 << result } # block directly to get, rpc
    _(results_2.map(&:document_id)).must_equal ["doc2","doc3"]
    _(results_2.map { |doc| doc[:foo] }).must_equal ["b","c"]

    results_3 = query.get # enum_for :get
    _(results_3.map(&:document_id)).must_equal ["doc2","doc3"] # rpc
    _(results_3.map { |doc| doc[:foo] }).must_equal ["b","c"] # rpc

    results_4 = query.get # enum_for :get
    _(results_4.map(&:document_id)).must_equal ["doc2","doc3"] # rpc
    _(results_4.map { |doc| doc[:foo] }).must_equal ["b","c"] # rpc
  end

  it "has offset method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).offset(1).get
    _(results.map(&:document_id)).must_equal ["doc2"]
    _(results.map { |doc| doc[:foo] }).must_equal ["b"]
  end

  it "has start_at method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).start_at("a").get
    _(results.map(&:document_id)).must_equal ["doc1", "doc2"]
    _(results.map { |doc| doc[:foo] }).must_equal ["a", "b"]
  end

  it "has start_after method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).start_after("a").get
    _(results.map(&:document_id)).must_equal ["doc2"]
    _(results.map { |doc| doc[:foo] }).must_equal ["b"]
  end

  it "has end_before method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).end_before("b").get
    _(results.map(&:document_id)).must_equal ["doc1"]
    _(results.map { |doc| doc[:foo] }).must_equal ["a"]
  end

  it "has end_at method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).end_at("b").get
    _(results.map(&:document_id)).must_equal ["doc1", "doc2"]
    _(results.map { |doc| doc[:foo] }).must_equal ["a", "b"]
  end

  it "can call cursor methods with a DocumentSnapshot object" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})

    results = rand_query_col.order(:foo).start_at(rand_query_col.doc("doc1").get).get
    _(results.map(&:document_id)).must_equal ["doc1", "doc2"]
    _(results.map { |doc| doc[:foo] }).must_equal ["a", "b"]

    results = rand_query_col.order(:foo).start_after(rand_query_col.doc("doc1").get).get
    _(results.map(&:document_id)).must_equal ["doc2"]
    _(results.map { |doc| doc[:foo] }).must_equal ["b"]

    results = rand_query_col.order(:foo).end_before(rand_query_col.doc("doc2").get).get
    _(results.map(&:document_id)).must_equal ["doc1"]
    _(results.map { |doc| doc[:foo] }).must_equal ["a"]

    results = rand_query_col.order(:foo).end_at(rand_query_col.doc("doc2").get).get
    _(results.map(&:document_id)).must_equal ["doc1", "doc2"]
    _(results.map { |doc| doc[:foo] }).must_equal ["a", "b"]
  end

  it "has to_json method and from_json class method" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})
    rand_query_col.doc("doc3").create({foo: "c"})

    original_query = rand_query_col.order(:foo).limit_to_last 2

    json = original_query.to_json
    _(json).must_be_instance_of String

    query = Google::Cloud::Firestore::Query.from_json json, firestore
    _(query).must_be_instance_of Google::Cloud::Firestore::Query

    results_1 = []
    query.get { |result| results_1 << result } # block directly to get, rpc
    _(results_1.map(&:document_id)).must_equal ["doc2","doc3"]
    _(results_1.map { |doc| doc[:foo] }).must_equal ["b","c"]

    results_2 = []
    query.get { |result| results_2 << result } # block directly to get, rpc
    _(results_2.map(&:document_id)).must_equal ["doc2","doc3"]
    _(results_2.map { |doc| doc[:foo] }).must_equal ["b","c"]

    results_3 = query.get # enum_for :get
    _(results_3.map(&:document_id)).must_equal ["doc2","doc3"] # rpc
    _(results_3.map { |doc| doc[:foo] }).must_equal ["b","c"] # rpc

    results_4 = query.get # enum_for :get
    _(results_4.map(&:document_id)).must_equal ["doc2","doc3"] # rpc
    _(results_4.map { |doc| doc[:foo] }).must_equal ["b","c"] # rpc
  end
end
