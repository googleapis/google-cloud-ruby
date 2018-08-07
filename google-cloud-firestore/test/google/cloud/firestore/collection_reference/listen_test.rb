# Copyright 2018 Google LLC
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

describe Google::Cloud::Firestore::CollectionReference, :listen, :watch_firestore do
  let(:collection_id) { "watch" }
  let(:collection) { Google::Cloud::Firestore::CollectionReference.from_path "projects/#{project}/databases/(default)/documents/#{collection_id}", firestore }

  it "listens to a query and yields query snapshots" do
    listen_responses = [
      add_resp,
      doc_change_resp("nil",   0, val: nil),
      doc_change_resp("false", 0, val: false),
      doc_change_resp("true",  0, val: true),
      doc_change_resp("int",   0, val: 1),
      doc_change_resp("num",   0, val: 3.14),
      doc_change_resp("str",   0, val: ""),
      doc_change_resp("io",    0, val: StringIO.new),
      doc_change_resp("time",  0, val: read_time),
      doc_change_resp("ref2",  0, val: firestore.doc("C/d2")),
      doc_change_resp("ref1",  0, val: firestore.doc("C/d1")),
      doc_change_resp("geo2",  0, val: { "longitude" => 40, "latitude" => 50 }),
      doc_change_resp("geo1",  0, val: { longitude: 45, latitude: 45 }),
      doc_change_resp("array", 0, val: []),
      doc_change_resp("hash",  0, val: {}),
      current_resp("DOCUMENTSHAVEBEENADDED", 0.1),

      no_change_resp("THISTOKENWILLNEVERBESEEN", 1),
      no_change_resp("NEITHERWILLTHISTOKEN", 1.1),
      doc_change_resp("int", 1.2, val: 42),
      doc_change_resp("num", 1.2, val: 11.1),
      no_change_resp("DOCUMENTSUPDATEDTOKEN", 1.3),

      no_change_resp("THISTOKENWILLNEVERBESEEN2", 2),
      no_change_resp("NEITHERWILLTHISTOKEN2", 2.1),
      doc_change_resp("array", 2.2, val: [1, 2, 3]),
      no_change_resp("DOCUMENTUPDATEDTOKEN", 2.3),

      doc_delete_resp("array", 3),
      doc_remove_resp("hash",  3),
      no_change_resp("DOCUMENTSDELETEDTOKEN", 3.1)
    ]
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new [listen_responses]
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    listener = collection.order(:val).listen do |query_snp|
      query_snapshots << query_snp
    end

    wait_until { query_snapshots.count == 4 }

    listener.stop

    # assert snapshots
    query_snapshots.count.must_equal 4
    query_snapshots.each { |qs| qs.must_be_kind_of Google::Cloud::Firestore::QuerySnapshot }

    query_snapshots[0].count.must_equal 14
    query_snapshots[0].changes.count.must_equal 14
    query_snapshots[0].docs.map(&:document_id).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[0].changes.each { |change| change.must_be :added? }
    query_snapshots[0].changes.map(&:doc).map(&:document_id).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]

    query_snapshots[1].count.must_equal 14
    query_snapshots[1].changes.count.must_equal 2
    query_snapshots[1].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[1].changes.each { |change| change.must_be :modified? }
    query_snapshots[1].changes.map(&:doc).map(&:document_id).must_equal ["num", "int"]

    query_snapshots[2].count.must_equal 14
    query_snapshots[2].changes.count.must_equal 1
    query_snapshots[2].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[2].changes.each { |change| change.must_be :modified? }
    query_snapshots[2].changes.map(&:doc).map(&:document_id).must_equal ["array"]

    query_snapshots[3].count.must_equal 12
    query_snapshots[3].changes.count.must_equal 2
    query_snapshots[3].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2"]
    query_snapshots[3].changes.each { |change| change.must_be :removed? }
    query_snapshots[3].changes.map(&:doc).map(&:document_id).must_equal ["array", "hash"]
  end

  it "resets when RESET is returned" do
    listen_responses = [
      [
        add_resp,
        doc_change_resp("nil",   0, val: nil),
        doc_change_resp("false", 0, val: false),
        doc_change_resp("true",  0, val: true),
        doc_change_resp("int",   0, val: 1),
        doc_change_resp("num",   0, val: 3.14),
        doc_change_resp("str",   0, val: ""),
        doc_change_resp("io",    0, val: StringIO.new),
        doc_change_resp("time",  0, val: read_time),
        doc_change_resp("ref2",  0, val: firestore.doc("C/d2")),
        doc_change_resp("ref1",  0, val: firestore.doc("C/d1")),
        doc_change_resp("geo2",  0, val: { "longitude" => 40, "latitude" => 50 }),
        doc_change_resp("geo1",  0, val: { longitude: 45, latitude: 45 }),
        doc_change_resp("array", 0, val: []),
        doc_change_resp("hash",  0, val: {}),
        current_resp("DOCUMENTSHAVEBEENADDED", 0.1),

        no_change_resp("THISTOKENWILLNEVERBESEEN", 1),
        no_change_resp("NEITHERWILLTHISTOKEN", 1.1),
        doc_change_resp("int", 1.2, val: 84),
        doc_change_resp("num", 1.2, val: 22.2),
        reset_resp
      ],
      [
        add_resp,
        no_change_resp("THISTOKENWILLNEVERBESEEN", 2),
        no_change_resp("NEITHERWILLTHISTOKEN", 2.1),
        doc_change_resp("nil",   0, val: nil),
        doc_change_resp("false", 0, val: false),
        doc_change_resp("true",  0, val: true),
        doc_change_resp("int",   0, val: 1),
        doc_change_resp("num",   0, val: 3.14),
        doc_change_resp("str",   0, val: ""),
        doc_change_resp("io",    0, val: StringIO.new),
        doc_change_resp("time",  0, val: read_time),
        doc_change_resp("ref2",  0, val: firestore.doc("C/d2")),
        doc_change_resp("ref1",  0, val: firestore.doc("C/d1")),
        doc_change_resp("geo2",  0, val: { "longitude" => 40, "latitude" => 50 }),
        doc_change_resp("geo1",  0, val: { longitude: 45, latitude: 45 }),
        doc_change_resp("array", 0, val: []),
        doc_change_resp("hash",  0, val: {}),
        doc_change_resp("int",   1, val: 42),
        doc_change_resp("num",   1, val: 11.1),
        current_resp("DOCUMENTSHAVEBEENADDEDAGAIN", 2.2),
        no_change_resp("DOCUMENTSUPDATEDTOKENAGAIN", 2.3),

        no_change_resp("THISTOKENWILLNEVERBESEEN2", 3),
        no_change_resp("NEITHERWILLTHISTOKEN2", 3.1),
        doc_change_resp("array", 3.2, val: [1, 2, 3]),
        no_change_resp("DOCUMENTUPDATEDTOKEN", 3.3),

        doc_delete_resp("array", 4),
        doc_remove_resp("hash",  4),
        no_change_resp("DOCUMENTSDELETEDTOKEN", 4.1)
      ]
    ]
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new listen_responses
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    listener = collection.order(:val).listen do |query_snp|
      query_snapshots << query_snp
    end

    wait_until { query_snapshots.count == 4 }

    listener.stop

    # assert snapshots
    query_snapshots.count.must_equal 4
    query_snapshots.each { |qs| qs.must_be_kind_of Google::Cloud::Firestore::QuerySnapshot }

    query_snapshots[0].count.must_equal 14
    query_snapshots[0].changes.count.must_equal 14
    query_snapshots[0].docs.map(&:document_id).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[0].changes.each { |change| change.must_be :added? }
    query_snapshots[0].changes.map(&:doc).map(&:document_id).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]

    query_snapshots[1].count.must_equal 14
    query_snapshots[1].changes.count.must_equal 2
    query_snapshots[1].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[1].changes.each { |change| change.must_be :modified? }
    query_snapshots[1].changes.map(&:doc).map(&:document_id).must_equal ["num", "int"]

    query_snapshots[2].count.must_equal 14
    query_snapshots[2].changes.count.must_equal 1
    query_snapshots[2].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[2].changes.each { |change| change.must_be :modified? }
    query_snapshots[2].changes.map(&:doc).map(&:document_id).must_equal ["array"]

    query_snapshots[3].count.must_equal 12
    query_snapshots[3].changes.count.must_equal 2
    query_snapshots[3].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2"]
    query_snapshots[3].changes.each { |change| change.must_be :removed? }
    query_snapshots[3].changes.map(&:doc).map(&:document_id).must_equal ["array", "hash"]
  end

  it "resets when FILTER count is incorrect" do
    listen_responses = [
      [
        add_resp,
        doc_change_resp("nil",   0, val: nil),
        doc_change_resp("false", 0, val: false),
        doc_change_resp("true",  0, val: true),
        doc_change_resp("int",   0, val: 1),
        doc_change_resp("num",   0, val: 3.14),
        doc_change_resp("str",   0, val: ""),
        doc_change_resp("io",    0, val: StringIO.new),
        doc_change_resp("time",  0, val: read_time),
        doc_change_resp("ref2",  0, val: firestore.doc("C/d2")),
        doc_change_resp("ref1",  0, val: firestore.doc("C/d1")),
        doc_change_resp("geo2",  0, val: { "longitude" => 40, "latitude" => 50 }),
        doc_change_resp("geo1",  0, val: { longitude: 45, latitude: 45 }),
        doc_change_resp("array", 0, val: []),
        doc_change_resp("hash",  0, val: {}),
        current_resp("DOCUMENTSHAVEBEENADDED", 0.1),

        no_change_resp("THISTOKENWILLNEVERBESEEN", 1),
        no_change_resp("NEITHERWILLTHISTOKEN", 1.1),
        doc_change_resp("int", 1.2, val: 84),
        doc_change_resp("num", 1.2, val: 22.2),
        filter_resp(12) # count is incorrect, reset
      ],
      [
        add_resp,
        no_change_resp("THISTOKENWILLNEVERBESEEN", 2),
        no_change_resp("NEITHERWILLTHISTOKEN", 2.1),
        doc_change_resp("nil",   0, val: nil),
        doc_change_resp("false", 0, val: false),
        doc_change_resp("true",  0, val: true),
        doc_change_resp("int",   0, val: 1),
        doc_change_resp("num",   0, val: 3.14),
        doc_change_resp("str",   0, val: ""),
        doc_change_resp("io",    0, val: StringIO.new),
        doc_change_resp("time",  0, val: read_time),
        doc_change_resp("ref2",  0, val: firestore.doc("C/d2")),
        doc_change_resp("ref1",  0, val: firestore.doc("C/d1")),
        doc_change_resp("geo2",  0, val: { "longitude" => 40, "latitude" => 50 }),
        doc_change_resp("geo1",  0, val: { longitude: 45, latitude: 45 }),
        doc_change_resp("array", 0, val: []),
        doc_change_resp("hash",  0, val: {}),
        doc_change_resp("int",   1, val: 42),
        doc_change_resp("num",   1, val: 11.1),
        current_resp("DOCUMENTSHAVEBEENADDEDAGAIN", 2.2),
        no_change_resp("DOCUMENTSUPDATEDTOKENAGAIN", 2.3),
        filter_resp(14), # count is correct, no reset

        no_change_resp("THISTOKENWILLNEVERBESEEN2", 3),
        no_change_resp("NEITHERWILLTHISTOKEN2", 3.1),
        doc_change_resp("array", 3.2, val: [1, 2, 3]),
        no_change_resp("DOCUMENTUPDATEDTOKEN", 3.3),

        doc_delete_resp("array", 4),
        doc_remove_resp("hash",  4),
        no_change_resp("DOCUMENTSDELETEDTOKEN", 4.1)
      ]
    ]
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new listen_responses
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    listener = collection.order(:val).listen do |query_snp|
      query_snapshots << query_snp
    end

    wait_until { query_snapshots.count == 4 }

    listener.stop

    # assert snapshots
    query_snapshots.count.must_equal 4
    query_snapshots.each { |qs| qs.must_be_kind_of Google::Cloud::Firestore::QuerySnapshot }

    query_snapshots[0].count.must_equal 14
    query_snapshots[0].changes.count.must_equal 14
    query_snapshots[0].docs.map(&:document_id).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[0].changes.each { |change| change.must_be :added? }
    query_snapshots[0].changes.map(&:doc).map(&:document_id).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]

    query_snapshots[1].count.must_equal 14
    query_snapshots[1].changes.count.must_equal 2
    query_snapshots[1].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[1].changes.each { |change| change.must_be :modified? }
    query_snapshots[1].changes.map(&:doc).map(&:document_id).must_equal ["num", "int"]

    query_snapshots[2].count.must_equal 14
    query_snapshots[2].changes.count.must_equal 1
    query_snapshots[2].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[2].changes.each { |change| change.must_be :modified? }
    query_snapshots[2].changes.map(&:doc).map(&:document_id).must_equal ["array"]

    query_snapshots[3].count.must_equal 12
    query_snapshots[3].changes.count.must_equal 2
    query_snapshots[3].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2"]
    query_snapshots[3].changes.each { |change| change.must_be :removed? }
    query_snapshots[3].changes.map(&:doc).map(&:document_id).must_equal ["array", "hash"]
  end
end
