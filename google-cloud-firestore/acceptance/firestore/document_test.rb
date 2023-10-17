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

describe "Document", :firestore_acceptance do
  it "has properties" do
    doc_ref = firestore.doc "col/doc"

    _(doc_ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(doc_ref.document_id).must_equal "doc"
    _(doc_ref.document_path).must_equal "col/doc"

    col_ref = doc_ref.parent
    _(col_ref.collection_id).must_equal "col"
    _(col_ref.collection_path).must_equal "col"
  end

  it "has collection method" do
    doc_ref = firestore.doc "col/doc"

    sub_col = doc_ref.col "subcol"
    _(sub_col.collection_id).must_equal "subcol"
    _(sub_col.collection_path).must_equal "col/doc/subcol"
    _(sub_col.parent.document_path).must_equal doc_ref.document_path
  end

  it "has create and get method" do
    doc_ref = root_col.doc

    doc_ref.create foo: :a
    doc_snp = doc_ref.get
    _(doc_snp[:foo]).must_equal "a"
  end

  it "has set method" do
    all_values = {
      name: "hello world",
      active: true,
      score: 42,
      large_score: 1234567890000,
      ratio: 0.1,
      infinity: Float::INFINITY,
      negative_infinity: -Float::INFINITY,
      nan: Float::NAN,
      object: { foo: "bar", "😀".to_sym => "😜" },
      empty_object: {},
      date: Time.parse("Mar 18, 1985 08:20:00.123 GMT+1000 (CET)"),
      linked: firestore.doc("col1/ref1"),
      list: ["foo", 42, "bar"],
      empty_list: [],
      null: nil,
      location: { longitude: -122.947778, latitude: 50.1430847 },
      binary: StringIO.new("\x01\x02")
    }

    doc_ref = root_col.doc
    doc_ref.set all_values
    doc_snp = doc_ref.get

    _(doc_snp[:name]).must_equal all_values[:name]
    _(doc_snp[:active]).must_equal all_values[:active]
    _(doc_snp[:score]).must_equal all_values[:score]
    _(doc_snp[:large_score]).must_equal all_values[:large_score]
    _(doc_snp[:ratio]).must_equal all_values[:ratio]
    _(doc_snp[:infinity]).must_equal all_values[:infinity]
    _(doc_snp[:negative_infinity]).must_equal all_values[:negative_infinity]
    _(doc_snp[:nan]).must_be :nan?
    _(doc_snp[:object]).must_equal all_values[:object]
    _(doc_snp[:date]).must_equal all_values[:date]
    _(doc_snp[:linked]).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(doc_snp[:linked].document_path).must_equal all_values[:linked].document_path
    _(doc_snp[:list]).must_equal all_values[:list]
    _(doc_snp[:empty_list]).must_equal all_values[:empty_list]
    _(doc_snp[:null]).must_be :nil?
    _(doc_snp[:location]).must_equal all_values[:location]
    _(doc_snp[:binary]).must_be_kind_of StringIO
    doc_snp[:binary].rewind
    all_values[:binary].rewind
    _(doc_snp[:binary].read).must_equal all_values[:binary].read
  end

  it "merge empty fields to a document" do
    all_values = {
      name: "hello world",
    }
    doc_ref = root_col.doc

    doc_ref.set all_values
    doc_snp = doc_ref.get
    _(doc_snp[:name]).must_equal all_values[:name]

    doc_ref.set({nullField: nil}, merge: true)
    doc_snp = doc_ref.get
    _(doc_snp[:nullField]).must_be :nil?
  end

  it "supports server timestamps" do
    data = {
      a: :bar,
      b: { remove: "bar"},
      d: { keep: "bar"},
      f: firestore.field_server_time,
    }
    timestamp = Time.now

    doc_ref = root_col.doc
    data_2 = {
      a: :bar,
      b: { keep: "bar"},
      d: firestore.field_server_time
    }
    doc_ref.set data_2
    doc_snp = doc_ref.get

    set_timestamp = doc_snp.get "d"
    _(set_timestamp).wont_be :nil?
    _(doc_snp.data).must_equal({
      a: "bar",
      b: { keep: "bar" },
      d: set_timestamp,
    })

    data_3 = {
      a: firestore.field_server_time,
      b: { c: firestore.field_server_time },
      "e.f" => firestore.field_server_time
    }

    doc_ref.update data_3
    doc_snp = doc_ref.get

    update_timestamp = doc_snp[:a]
    _(update_timestamp).wont_be :nil?
    expected_data = {
      a: update_timestamp,
      b: { c: update_timestamp, keep: "bar" },
      d: set_timestamp,
      e: { f: update_timestamp }
    }

    assert_equal_unordered expected_data, doc_snp.data
  end

  it "supports set with merge" do
    doc_ref = root_col.doc

    doc_ref.set({ "a.1" => "foo", nested: { "b.1" => "bar" } })
    doc_ref.set({ "a.2" => "foo", nested: { "b.2" => "bar" } }, merge: true)

    doc_snp = doc_ref.get
    expected_data = {
      "a.1".to_sym =>"foo",
      "a.2".to_sym =>"foo",
      nested: {
        "b.1".to_sym =>"bar",
        "b.2".to_sym =>"bar"
      }
    }

    assert_equal_unordered expected_data, doc_snp.data
  end

  it "supports server timestamps for merge" do
    doc_ref = root_col.doc

    doc_ref.set({ a: :b })
    doc_ref.set({ c: firestore.field_server_time }, merge: true)

    doc_snp = doc_ref.get
    timestamp = doc_snp.get :c
    _(timestamp).wont_be :nil?
    _(doc_snp.data).must_equal({
      a: "b",
      c: timestamp,
    })
  end

  it "has update method" do
    doc_ref = root_col.doc

    set_result = doc_ref.set({ foo: "a" })
    doc_ref.update({ foo: "b" }, update_time: set_result.update_time)

    doc_snp = doc_ref.get
    _(doc_snp.data).must_equal({
      foo: "b",
    })
  end

  it "can manipulate arrays" do
    doc_ref = root_col.doc

    doc_ref.set({ list: [1, 2, 3] })

    doc_snp = doc_ref.get
    _(doc_snp.data).must_equal({
      list: [1, 2, 3],
    })

    doc_ref.update({ list: firestore.field_array_union(42) })

    doc_snp = doc_ref.get
    _(doc_snp.data).must_equal({
      list: [1, 2, 3, 42],
    })

    doc_ref.update({ list: firestore.field_array_delete(42) })

    doc_snp = doc_ref.get
    _(doc_snp.data).must_equal({
      list: [1, 2, 3],
    })
  end

  it "enforces that updated document exists" do
    doc_ref = root_col.doc

    expect do
      doc_ref.update({ foo: "b" })
    end.must_raise Google::Cloud::NotFoundError
  end

  it "has delete method" do
    doc_ref = root_col.doc

    doc_ref.set({ foo: "a" })

    doc_snp = doc_ref.get
    _(doc_snp).must_be :exists?

    doc_ref.delete

    doc_snp = doc_ref.get
    _(doc_snp).wont_be :exists?
  end

  it "can delete a non-existing document" do
    doc_ref = root_col.doc

    doc_snp = doc_ref.get
    _(doc_snp).wont_be :exists?

    doc_ref.delete

    doc_snp = doc_ref.get
    _(doc_snp).wont_be :exists?
  end

  it "supports non-alphanumeric field names" do
    doc_ref = root_col.doc

    doc_ref.set({ "!.\`" => { "!.\`" => "value" } })

    doc_snp = doc_ref.get
    expected_data = { "!.\`".to_sym => { "!.\`".to_sym => "value" } }

    assert_equal_unordered expected_data, doc_snp.data
  end

  it "has collections method" do
    skip if Google::Cloud.configure.firestore.transport == :rest
    collections_doc_ref = root_col.add

    collections = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
    collections.each do |collection|
      collections_doc_ref.col(collection).add
    end

    sub_cols = collections_doc_ref.cols
    _(sub_cols).must_be_kind_of Enumerator
    _(sub_cols.to_a.count).must_equal collections.count
    _(sub_cols.map(&:collection_id).sort).must_equal collections.sort

    collection_ids = []
    # cols/collections also accepts a block
    collections_doc_ref.collections do |col|
      _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference
      _(col.collection_id).wont_be :empty?
      collection_ids << col.collection_id
    end
    _(collection_ids.count).must_equal collections.count
    _(collection_ids.sort).must_equal collections.sort
  end

  it "has collections method with read time" do
    skip if Google::Cloud.configure.firestore.transport == :rest
    collections_doc_ref = root_col.add

    collections = ["a", "b", "c", "d", "e"]
    collections.each do |collection|
      collections_doc_ref.col(collection).add
    end

    sleep(1)
    read_time = Time.now
    sleep(1)

    collections_2 = ["f", "g", "h", "i", "j"]
    collections_2.each do |collection|
      collections_doc_ref.col(collection).add
    end

    sub_cols = collections_doc_ref.cols read_time: read_time
    _(sub_cols).must_be_kind_of Enumerator
    _(sub_cols.to_a.count).must_equal collections.count
    _(sub_cols.map(&:collection_id).sort).must_equal collections.sort
    sub_cols = collections_doc_ref.cols
    _(sub_cols).must_be_kind_of Enumerator
    _(sub_cols.to_a.count).must_equal (collections + collections_2).count
    _(sub_cols.map(&:collection_id).sort).must_equal (collections + collections_2).sort
  end

  it "can add and delete fields sequentially" do
    doc_ref = root_col.doc

    doc_ref.create({})
    _(doc_ref.get.data).must_equal({})

    doc_ref.delete
    _(doc_ref.get).wont_be :exists?

    doc_ref.create({ a: { b: "c" } })
    _(doc_ref.get.data).must_equal({ a: { b: "c" } })

    doc_ref.set({})
    _(doc_ref.get.data).must_equal({})

    doc_ref.set({ a: { b: "c" } })
    _(doc_ref.get.data).must_equal({ a: { b: "c" } })

    doc_ref.set({ a: { d: "e" } }, merge: true)
    _(doc_ref.get.data).must_equal({ a: { b: "c", d: "e" } })

    # INFO: the original test used nested deletes, but that is not allowed...
    # doc_ref.update({ a: { d: firestore.field_delete } })
    doc_ref.update({ "a.d" => firestore.field_delete })
    _(doc_ref.get.data).must_equal({ a: { b: "c" } })

    # INFO: the original test used nested deletes, but that is not allowed...
    # doc_ref.update({ a: { b: firestore.field_delete } })
    doc_ref.update({ "a.b" => firestore.field_delete })
    _(doc_ref.get.data).must_equal({ a: {} })

    doc_ref.update({ a: { e: "foo" } })
    _(doc_ref.get.data).must_equal({ a: { e: "foo" } })

    doc_ref.update({ f: "foo" })
    _(doc_ref.get.data).must_equal({ a: { e: "foo" }, f: "foo" })

    doc_ref.update({ f: { g: "foo" } })
    _(doc_ref.get.data).must_equal({ a: { e: "foo" }, f: { g: "foo" } })

    doc_ref.update({ "f.h" => "foo" })
    _(doc_ref.get.data).must_equal({ a: { e: "foo" }, f: { g: "foo", h: "foo" } })

    doc_ref.update({ "f.g" => firestore.field_delete })
    _(doc_ref.get.data).must_equal({ a: { e: "foo" }, f: { h: "foo" } })

    doc_ref.update({ "f.h" => firestore.field_delete })
    _(doc_ref.get.data).must_equal({ a: { e: "foo" }, f: {} })

    doc_ref.update({ "f" => firestore.field_delete })
    _(doc_ref.get.data).must_equal({ a: { e: "foo" } })

    doc_ref.update({ "i.j" => { k: "foo" } })
    _(doc_ref.get.data).must_equal({ a: { e: "foo" }, i: { j: { k: "foo" } } })

    doc_ref.update({ "i.j.l" => {} })
    _(doc_ref.get.data).must_equal({ a: { e: "foo" }, i: { j: { k: "foo", l: {} } } })

    doc_ref.update({ i: firestore.field_delete })
    _(doc_ref.get.data).must_equal({ a: { e: "foo" } })

    doc_ref.update({ a: firestore.field_delete })
    _(doc_ref.get.data).must_equal({})
  end

  it "can add and delete fields with server timestamps" do
    times = []
    doc_ref = root_col.doc

    doc_ref.create({ time: firestore.field_server_time, a: { b: firestore.field_server_time } })
    doc_snp = doc_ref.get
    _(doc_snp[:time]).must_be_kind_of Time
    times << doc_snp[:time]
    _(doc_snp[:a][:b]).must_equal times[0]
    _(doc_snp.get(:time)).must_equal times[0]
    _(doc_snp.get("a.b".to_sym)).must_equal times[0]
    _(doc_snp.get("time")).must_equal times[0]
    _(doc_snp.get("a.b")).must_equal times[0]

    doc_ref.set({ time: firestore.field_server_time, a: { c: firestore.field_server_time } })
    doc_snp = doc_ref.get
    _(doc_snp[:time]).must_be_kind_of Time
    times << doc_snp[:time]
    assert_nil doc_snp[:a][:b]
    _(doc_snp[:a][:c]).must_equal times[1]

    doc_ref.set({ time: firestore.field_server_time, a: { d: firestore.field_server_time } }, merge: true)
    doc_snp = doc_ref.get
    _(doc_snp[:time]).must_be_kind_of Time
    times << doc_snp[:time]
    assert_nil doc_snp[:a][:b]
    _(doc_snp[:a][:c]).must_equal times[1]
    _(doc_snp[:a][:d]).must_equal times[2]

    doc_ref.set({ time: firestore.field_server_time, e: firestore.field_server_time }, merge: true)
    doc_snp = doc_ref.get
    _(doc_snp[:time]).must_be_kind_of Time
    times << doc_snp[:time]
    assert_nil doc_snp[:a][:b]
    _(doc_snp[:a][:c]).must_equal times[1]
    _(doc_snp[:a][:d]).must_equal times[2]
    _(doc_snp[:e]).must_equal times[3]

    doc_ref.set({ time: firestore.field_server_time, e: { f: firestore.field_server_time } }, merge: true)
    doc_snp = doc_ref.get
    _(doc_snp[:time]).must_be_kind_of Time
    times << doc_snp[:time]
    assert_nil doc_snp[:a][:b]
    _(doc_snp[:a][:c]).must_equal times[1]
    _(doc_snp[:a][:d]).must_equal times[2]
    _(doc_snp[:e][:f]).must_equal times[4]

    doc_ref.update({ time: firestore.field_server_time, "g.h" => firestore.field_server_time })
    doc_snp = doc_ref.get
    _(doc_snp[:time]).must_be_kind_of Time
    times << doc_snp[:time]
    assert_nil doc_snp[:a][:b]
    _(doc_snp[:a][:c]).must_equal times[1]
    _(doc_snp[:a][:d]).must_equal times[2]
    _(doc_snp[:e][:f]).must_equal times[4]
    _(doc_snp[:g][:h]).must_equal times[5]

    doc_ref.update({ time: firestore.field_server_time, "g.j.k" => firestore.field_server_time })
    doc_snp = doc_ref.get
    _(doc_snp[:time]).must_be_kind_of Time
    times << doc_snp[:time]
    assert_nil doc_snp[:a][:b]
    _(doc_snp[:a][:c]).must_equal times[1]
    _(doc_snp[:a][:d]).must_equal times[2]
    _(doc_snp[:e][:f]).must_equal times[4]
    _(doc_snp[:g][:h]).must_equal times[5]
    _(doc_snp[:g][:j][:k]).must_equal times[6]
  end

  it "can update numeric fields with transforms" do
    doc_ref = root_col.doc

    doc_ref.create({ num: 1, a: { b: 1 } })
    doc_snp = doc_ref.get
    _(doc_snp[:a][:b]).must_equal 1
    _(doc_snp.get(:num)).must_equal 1
    _(doc_snp.get("a.b".to_sym)).must_equal 1
    _(doc_snp.get("num")).must_equal 1
    _(doc_snp.get("a.b")).must_equal 1

    doc_ref.set({ num: firestore.field_increment(50), a: { c: firestore.field_maximum(100) } })
    doc_snp = doc_ref.get
    _(doc_snp[:num]).must_equal 50
    assert_nil doc_snp[:a][:b]
    _(doc_snp[:a][:c]).must_equal 100

    doc_ref.set({ num: firestore.field_increment(1), a: { d: firestore.field_minimum(-100) } }, merge: true)
    doc_snp = doc_ref.get
    _(doc_snp[:num]).must_equal 51
    assert_nil doc_snp[:a][:b]
    _(doc_snp[:a][:c]).must_equal 100
    _(doc_snp[:a][:d]).must_equal -100

    doc_ref.set({ num: firestore.field_minimum(100), e: firestore.field_minimum(100) }, merge: true)
    doc_snp = doc_ref.get
    _(doc_snp[:num]).must_equal 51
    assert_nil doc_snp[:a][:b]
    _(doc_snp[:a][:c]).must_equal 100
    _(doc_snp[:a][:d]).must_equal -100
    _(doc_snp[:e]).must_equal 100

    doc_ref.set({ num: firestore.field_maximum(-100), e: { f: firestore.field_maximum(100) } }, merge: true)
    doc_snp = doc_ref.get
    _(doc_snp[:num]).must_equal 51
    assert_nil doc_snp[:a][:b]
    _(doc_snp[:a][:c]).must_equal 100
    _(doc_snp[:a][:d]).must_equal -100
    _(doc_snp[:e][:f]).must_equal 100

    doc_ref.update({ num: firestore.field_minimum(-100), e: { f: firestore.field_maximum(1000) } })
    doc_snp = doc_ref.get
    _(doc_snp[:num]).must_equal -100
    assert_nil doc_snp[:a][:b]
    _(doc_snp[:a][:c]).must_equal 100
    _(doc_snp[:a][:d]).must_equal -100
    _(doc_snp[:e][:f]).must_equal 1000

    doc_ref.update({ num: firestore.field_maximum(100), e: { f: firestore.field_minimum(10) } })
    doc_snp = doc_ref.get
    _(doc_snp[:num]).must_equal 100
    assert_nil doc_snp[:a][:b]
    _(doc_snp[:a][:c]).must_equal 100
    _(doc_snp[:a][:d]).must_equal -100
    _(doc_snp[:e][:f]).must_equal 10
  end

  def assert_equal_unordered a, b, msg = nil
    msg = message(msg) {
      "Expected #{mu_pp a} to be equivalent to #{mu_pp b}"
    }

    assert_kind_of Enumerable, a
    assert_kind_of Enumerable, b

    c = Hash.new { |h,k| h[k] = 0 }; a.each do |e| c[e] += 1 end
    d = Hash.new { |h,k| h[k] = 0 }; b.each do |e| d[e] += 1 end

    assert c == d, msg
  end
end
