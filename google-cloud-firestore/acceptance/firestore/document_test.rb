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

    doc_ref.must_be_kind_of Google::Cloud::Firestore::DocumentReference
    doc_ref.document_id.must_equal "doc"
    doc_ref.document_path.must_equal "col/doc"

    col_ref = doc_ref.parent
    col_ref.collection_id.must_equal "col"
    col_ref.collection_path.must_equal "col"
  end

  it "has collection method" do
    doc_ref = firestore.doc "col/doc"

    sub_col = doc_ref.col "subcol"
    sub_col.collection_id.must_equal "subcol"
    sub_col.collection_path.must_equal "col/doc/subcol"
    sub_col.parent.document_path.must_equal doc_ref.document_path
  end

  it "has create and get method" do
    doc_ref = root_col.doc

    doc_ref.create foo: :a
    doc_snp = doc_ref.get
    doc_snp[:foo].must_equal "a"
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
      location: { longitude: 50.1430847, latitude: -122.947778 },
      binary: StringIO.new("\x01\x02")
    }

    doc_ref = root_col.doc
    doc_ref.set all_values
    doc_snp = doc_ref.get

    doc_snp[:name].must_equal all_values[:name]
    doc_snp[:active].must_equal all_values[:active]
    doc_snp[:score].must_equal all_values[:score]
    doc_snp[:large_score].must_equal all_values[:large_score]
    doc_snp[:ratio].must_equal all_values[:ratio]
    doc_snp[:infinity].must_equal all_values[:infinity]
    doc_snp[:negative_infinity].must_equal all_values[:negative_infinity]
    doc_snp[:nan].must_be :nan?
    doc_snp[:object].must_equal all_values[:object]
    doc_snp[:date].must_equal all_values[:date]
    doc_snp[:linked].must_be_kind_of Google::Cloud::Firestore::DocumentReference
    doc_snp[:linked].document_path.must_equal all_values[:linked].document_path
    doc_snp[:list].must_equal all_values[:list]
    doc_snp[:empty_list].must_equal all_values[:empty_list]
    doc_snp[:null].must_be :nil?
    doc_snp[:location].must_equal all_values[:location]
    doc_snp[:binary].must_be_kind_of StringIO
    doc_snp[:binary].rewind
    all_values[:binary].rewind
    doc_snp[:binary].read.must_equal all_values[:binary].read
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
    doc_ref.set a: :bar,
                b: { keep: "bar"},
                d: firestore.field_server_time
    doc_snp = doc_ref.get

    set_timestamp = doc_snp.get "d"
    set_timestamp.wont_be :nil?
    doc_snp.data.must_equal({
      a: "bar",
      b: { keep: "bar" },
      d: set_timestamp,
    })

    doc_ref.update a: firestore.field_server_time,
                   b: { c: firestore.field_server_time },
                   "e.f" => firestore.field_server_time
    doc_snp = doc_ref.get

    update_timestamp = doc_snp[:a]
    update_timestamp.wont_be :nil?
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
    timestamp.wont_be :nil?
    doc_snp.data.must_equal({
      a: "b",
      c: timestamp,
    })
  end

  it "has update method" do
    doc_ref = root_col.doc

    set_result = doc_ref.set({ foo: "a" })
    doc_ref.update({ foo: "b" }, update_time: set_result.update_time)

    doc_snp = doc_ref.get
    doc_snp.data.must_equal({
      foo: "b",
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
    doc_snp.must_be :exists?

    doc_ref.delete

    doc_snp = doc_ref.get
    doc_snp.wont_be :exists?
  end

  it "can delete a non-existing document" do
    doc_ref = root_col.doc

    doc_snp = doc_ref.get
    doc_snp.wont_be :exists?

    doc_ref.delete

    doc_snp = doc_ref.get
    doc_snp.wont_be :exists?
  end

  it "supports non-alphanumeric field names" do
    doc_ref = root_col.doc

    doc_ref.set({ "!.\`" => { "!.\`" => "value" } })

    doc_snp = doc_ref.get
    expected_data = { "!.\`".to_sym => { "!.\`".to_sym => "value" } }

    assert_equal_unordered expected_data, doc_snp.data
  end

  it "has collections method" do
    collections_doc_ref = root_col.add

    collections = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
    collections.each do |collection|
      collections_doc_ref.col(collection).add
    end

    sub_cols = collections_doc_ref.cols
    sub_cols.to_a.count.must_equal collections.count
    sub_cols.map(&:collection_id).sort.must_equal collections.sort
  end

  it "can add and delete fields sequentially" do
    doc_ref = root_col.doc

    doc_ref.create({})
    doc_ref.get.data.must_equal({})

    doc_ref.delete
    doc_ref.get.wont_be :exists?

    doc_ref.create({ a: { b: "c" } })
    doc_ref.get.data.must_equal({ a: { b: "c" } })

    doc_ref.set({})
    doc_ref.get.data.must_equal({})

    doc_ref.set({ a: { b: "c" } })
    doc_ref.get.data.must_equal({ a: { b: "c" } })

    doc_ref.set({ a: { d: "e" } }, merge: true)
    doc_ref.get.data.must_equal({ a: { b: "c", d: "e" } })

    # INFO: the original test used nested deletes, but that is not allowed...
    # doc_ref.update({ a: { d: firestore.field_delete } })
    doc_ref.update({ "a.d" => firestore.field_delete })
    doc_ref.get.data.must_equal({ a: { b: "c" } })

    # INFO: the original test used nested deletes, but that is not allowed...
    # doc_ref.update({ a: { b: firestore.field_delete } })
    doc_ref.update({ "a.b" => firestore.field_delete })
    doc_ref.get.data.must_equal({ a: {} })

    doc_ref.update({ a: { e: "foo" } })
    doc_ref.get.data.must_equal({ a: { e: "foo" } })

    doc_ref.update({ f: "foo" })
    doc_ref.get.data.must_equal({ a: { e: "foo" }, f: "foo" })

    doc_ref.update({ f: { g: "foo" } })
    doc_ref.get.data.must_equal({ a: { e: "foo" }, f: { g: "foo" } })

    doc_ref.update({ "f.h" => "foo" })
    doc_ref.get.data.must_equal({ a: { e: "foo" }, f: { g: "foo", h: "foo" } })

    doc_ref.update({ "f.g" => firestore.field_delete })
    doc_ref.get.data.must_equal({ a: { e: "foo" }, f: { h: "foo" } })

    doc_ref.update({ "f.h" => firestore.field_delete })
    doc_ref.get.data.must_equal({ a: { e: "foo" }, f: {} })

    doc_ref.update({ "f" => firestore.field_delete })
    doc_ref.get.data.must_equal({ a: { e: "foo" } })

    doc_ref.update({ "i.j" => { k: "foo" } })
    doc_ref.get.data.must_equal({ a: { e: "foo" }, i: { j: { k: "foo" } } })

    doc_ref.update({ "i.j.l" => {} })
    doc_ref.get.data.must_equal({ a: { e: "foo" }, i: { j: { k: "foo", l: {} } } })

    doc_ref.update({ i: firestore.field_delete })
    doc_ref.get.data.must_equal({ a: { e: "foo" } })

    doc_ref.update({ a: firestore.field_delete })
    doc_ref.get.data.must_equal({})
  end

  it "can add and delete fields with server timestamps" do
    times = []
    doc_ref = root_col.doc

    doc_ref.create({ time: firestore.field_server_time, a: { b: firestore.field_server_time } })
    doc_snp = doc_ref.get
    doc_snp[:time].must_be_kind_of Time
    times << doc_snp[:time]
    doc_snp[:a][:b].must_equal times[0]
    doc_snp.get(:time).must_equal times[0]
    doc_snp.get("a.b".to_sym).must_equal times[0]
    doc_snp.get("time").must_equal times[0]
    doc_snp.get("a.b").must_equal times[0]

    doc_ref.set({ time: firestore.field_server_time, a: { c: firestore.field_server_time } })
    doc_snp = doc_ref.get
    doc_snp[:time].must_be_kind_of Time
    times << doc_snp[:time]
    doc_snp[:a][:b].must_be :nil?
    doc_snp[:a][:c].must_equal times[1]

    doc_ref.set({ time: firestore.field_server_time, a: { d: firestore.field_server_time } }, merge: true)
    doc_snp = doc_ref.get
    doc_snp[:time].must_be_kind_of Time
    times << doc_snp[:time]
    doc_snp[:a][:b].must_be :nil?
    doc_snp[:a][:c].must_equal times[1]
    doc_snp[:a][:d].must_equal times[2]

    doc_ref.set({ time: firestore.field_server_time, e: firestore.field_server_time }, merge: true)
    doc_snp = doc_ref.get
    doc_snp[:time].must_be_kind_of Time
    times << doc_snp[:time]
    doc_snp[:a][:b].must_be :nil?
    doc_snp[:a][:c].must_equal times[1]
    doc_snp[:a][:d].must_equal times[2]
    doc_snp[:e].must_equal times[3]

    doc_ref.set({ time: firestore.field_server_time, e: { f: firestore.field_server_time } }, merge: true)
    doc_snp = doc_ref.get
    doc_snp[:time].must_be_kind_of Time
    times << doc_snp[:time]
    doc_snp[:a][:b].must_be :nil?
    doc_snp[:a][:c].must_equal times[1]
    doc_snp[:a][:d].must_equal times[2]
    doc_snp[:e][:f].must_equal times[4]

    doc_ref.update({ time: firestore.field_server_time, "g.h" => firestore.field_server_time })
    doc_snp = doc_ref.get
    doc_snp[:time].must_be_kind_of Time
    times << doc_snp[:time]
    doc_snp[:a][:b].must_be :nil?
    doc_snp[:a][:c].must_equal times[1]
    doc_snp[:a][:d].must_equal times[2]
    doc_snp[:e][:f].must_equal times[4]
    doc_snp[:g][:h].must_equal times[5]

    doc_ref.update({ time: firestore.field_server_time, "g.j.k" => firestore.field_server_time })
    doc_snp = doc_ref.get
    doc_snp[:time].must_be_kind_of Time
    times << doc_snp[:time]
    doc_snp[:a][:b].must_be :nil?
    doc_snp[:a][:c].must_equal times[1]
    doc_snp[:a][:d].must_equal times[2]
    doc_snp[:e][:f].must_equal times[4]
    doc_snp[:g][:h].must_equal times[5]
    doc_snp[:g][:j][:k].must_equal times[6]
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
