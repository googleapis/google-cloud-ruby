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

  it "listens to a limit query" do
    listen_responses = [
      add_resp,
      doc_change_resp("int 1", 0, val: 1),
      doc_change_resp("int 2", 0, val: 2),
      # doc_change_resp("int 3", 0, val: 3), # excluded by the limit clause
      current_resp("DOCUMENTSHAVEBEENADDED", 0.1),

      no_change_resp("THISTOKENWILLNEVERBESEEN", 1),
      no_change_resp("NEITHERWILLTHISTOKEN", 1.1),
    ]
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new [listen_responses]
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    listener = collection.order(:val).limit(2).listen do |query_snp|
      query_snapshots << query_snp
    end

    wait_until { query_snapshots.count == 1 }

    listener.stop

    # assert snapshots
    _(query_snapshots.count).must_equal 1
    _(query_snapshots[0].count).must_equal 2
    _(query_snapshots[0].changes.count).must_equal 2
    _(query_snapshots[0].docs.map(&:document_id)).must_equal ["int 1", "int 2"]
    _(query_snapshots[0].changes.map(&:type)).must_equal [:added, :added]
    _(query_snapshots[0].changes.map(&:doc).map(&:document_id)).must_equal ["int 1", "int 2"]
  end

  it "listens to a limit_to_last query" do
    listen_responses = [
      add_resp,
      # doc_change_resp("int 1", 0, val: 1), # excluded by the limit clause
      doc_change_resp("int 2", 0, val: 2),
      doc_change_resp("int 3", 0, val: 3),
      current_resp("DOCUMENTSHAVEBEENADDED", 0.1),

      no_change_resp("THISTOKENWILLNEVERBESEEN", 1),
      no_change_resp("NEITHERWILLTHISTOKEN", 1.1),
    ]
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new [listen_responses]
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    listener = collection.order(:val).limit_to_last(2).listen do |query_snp|
      query_snapshots << query_snp
    end

    wait_until { query_snapshots.count == 1 }

    listener.stop

    # assert snapshots
    _(query_snapshots.count).must_equal 1
    _(query_snapshots[0].count).must_equal 2
    _(query_snapshots[0].changes.count).must_equal 2
    _(query_snapshots[0].docs.map(&:document_id)).must_equal ["int 2", "int 3"]
    _(query_snapshots[0].changes.map(&:type)).must_equal [:added, :added]
    _(query_snapshots[0].changes.map(&:doc).map(&:document_id)).must_equal ["int 2", "int 3"]
  end

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
    _(query_snapshots.count).must_equal 4
    query_snapshots.each { |qs| _(qs).must_be_kind_of Google::Cloud::Firestore::QuerySnapshot }

    _(query_snapshots[0].count).must_equal 14
    _(query_snapshots[0].changes.count).must_equal 14
    _(query_snapshots[0].docs.map(&:document_id)).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[0].changes.each { |change| _(change).must_be :added? }
    _(query_snapshots[0].changes.map(&:doc).map(&:document_id)).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]

    _(query_snapshots[1].count).must_equal 14
    _(query_snapshots[1].changes.count).must_equal 2
    _(query_snapshots[1].docs.map(&:document_id)).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[1].changes.each { |change| _(change).must_be :modified? }
    _(query_snapshots[1].changes.map(&:doc).map(&:document_id)).must_equal ["num", "int"]

    _(query_snapshots[2].count).must_equal 14
    _(query_snapshots[2].changes.count).must_equal 1
    _(query_snapshots[2].docs.map(&:document_id)).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[2].changes.each { |change| _(change).must_be :modified? }
    _(query_snapshots[2].changes.map(&:doc).map(&:document_id)).must_equal ["array"]

    _(query_snapshots[3].count).must_equal 12
    _(query_snapshots[3].changes.count).must_equal 2
    _(query_snapshots[3].docs.map(&:document_id)).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2"]
    query_snapshots[3].changes.each { |change| _(change).must_be :removed? }
    _(query_snapshots[3].changes.map(&:doc).map(&:document_id)).must_equal ["array", "hash"]
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
    _(query_snapshots.count).must_equal 4
    query_snapshots.each { |qs| _(qs).must_be_kind_of Google::Cloud::Firestore::QuerySnapshot }

    _(query_snapshots[0].count).must_equal 14
    _(query_snapshots[0].changes.count).must_equal 14
    _(query_snapshots[0].docs.map(&:document_id)).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[0].changes.each { |change| _(change).must_be :added? }
    _(query_snapshots[0].changes.map(&:doc).map(&:document_id)).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]

    _(query_snapshots[1].count).must_equal 14
    _(query_snapshots[1].changes.count).must_equal 2
    _(query_snapshots[1].docs.map(&:document_id)).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[1].changes.each { |change| _(change).must_be :modified? }
    _(query_snapshots[1].changes.map(&:doc).map(&:document_id)).must_equal ["num", "int"]

    _(query_snapshots[2].count).must_equal 14
    _(query_snapshots[2].changes.count).must_equal 1
    _(query_snapshots[2].docs.map(&:document_id)).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[2].changes.each { |change| _(change).must_be :modified? }
    _(query_snapshots[2].changes.map(&:doc).map(&:document_id)).must_equal ["array"]

    _(query_snapshots[3].count).must_equal 12
    _(query_snapshots[3].changes.count).must_equal 2
    _(query_snapshots[3].docs.map(&:document_id)).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2"]
    query_snapshots[3].changes.each { |change| _(change).must_be :removed? }
    _(query_snapshots[3].changes.map(&:doc).map(&:document_id)).must_equal ["array", "hash"]
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
    _(query_snapshots.count).must_equal 4
    query_snapshots.each { |qs| _(qs).must_be_kind_of Google::Cloud::Firestore::QuerySnapshot }

    _(query_snapshots[0].count).must_equal 14
    _(query_snapshots[0].changes.count).must_equal 14
    _(query_snapshots[0].docs.map(&:document_id)).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[0].changes.each { |change| _(change).must_be :added? }
    _(query_snapshots[0].changes.map(&:doc).map(&:document_id)).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]

    _(query_snapshots[1].count).must_equal 14
    _(query_snapshots[1].changes.count).must_equal 2
    _(query_snapshots[1].docs.map(&:document_id)).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[1].changes.each { |change| _(change).must_be :modified? }
    _(query_snapshots[1].changes.map(&:doc).map(&:document_id)).must_equal ["num", "int"]

    _(query_snapshots[2].count).must_equal 14
    _(query_snapshots[2].changes.count).must_equal 1
    _(query_snapshots[2].docs.map(&:document_id)).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    query_snapshots[2].changes.each { |change| _(change).must_be :modified? }
    _(query_snapshots[2].changes.map(&:doc).map(&:document_id)).must_equal ["array"]

    _(query_snapshots[3].count).must_equal 12
    _(query_snapshots[3].changes.count).must_equal 2
    _(query_snapshots[3].docs.map(&:document_id)).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2"]
    query_snapshots[3].changes.each { |change| _(change).must_be :removed? }
    _(query_snapshots[3].changes.map(&:doc).map(&:document_id)).must_equal ["array", "hash"]
  end

  it "invokes on_error callbacks when the listener receives errors" do
    err_msg = "test listener error"
    listen_responses = [
      [
        doc_change_resp("int 1", 0, val: 1),
        doc_change_resp("int 2", 0, val: 2),
        current_resp("DOCUMENTSHAVEBEENCHANGED", 0.1),
        no_change_resp("THISTOKENWILLNEVERBESEEN", 1),
        ArgumentError.new(err_msg)
      ],[
        doc_change_resp("int 1", 0, val: 1),
        doc_change_resp("int 2", 0, val: 2),
        current_resp("DOCUMENTSHAVEBEENCHANGED", 0.1),
        no_change_resp("THISTOKENWILLNEVERBESEEN", 1)
      ]
    ]
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new listen_responses
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    errors_1 = []
    errors_2 = []

    out, err = capture_io do # Capture the error raised from listener thread.
      listener = collection.order(:val).listen do |query_snp|
        query_snapshots << query_snp
      end

      listener.on_error do |error|
        errors_1 << error
      end

      listener.on_error do |error|
        errors_2 << error
      end

      wait_until { query_snapshots.count == 1 && errors_1.count == 1 && errors_2.count == 1 }

      listener.stop
    end

    _(errors_1.count).must_equal 1
    _(errors_1[0]).must_be_kind_of ArgumentError
    _(errors_1[0].message).must_equal err_msg

    _(errors_2.count).must_equal 1
    _(errors_2[0]).must_be_kind_of ArgumentError
    _(errors_2[0].message).must_equal err_msg

    # assert snapshots
    _(query_snapshots.count).must_equal 1
    _(query_snapshots[0].count).must_equal 2
    _(query_snapshots[0].changes.count).must_equal 2
    _(query_snapshots[0].docs.map(&:document_id)).must_equal ["int 1", "int 2"]
    _(query_snapshots[0].changes.map(&:type)).must_equal [:added, :added]
    _(query_snapshots[0].changes.map(&:doc).map(&:document_id)).must_equal ["int 1", "int 2"]
  end

  it "raises when on_error is called without a block" do
    listener = collection.order(:val).listen do |query_snp|
      raise "should not be called"
    end

    error = expect do
      listener.on_error
    end.must_raise ArgumentError
    _(error.message).must_equal "on_error must be called with a block"

    listener.stop
  end
end
