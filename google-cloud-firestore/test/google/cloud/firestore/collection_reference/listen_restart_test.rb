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

describe Google::Cloud::Firestore::CollectionReference, :listen, :backoff, :watch_firestore do
  let(:collection_id) { "watch" }
  let(:collection) { Google::Cloud::Firestore::CollectionReference.from_path "projects/#{project}/databases/(default)/documents/#{collection_id}", firestore }
  let(:read_time) { Time.now }
  let :sleep_mock do
    m = Minitest::Mock.new
    # 3 errors, 3 incremental sleep calls
    m.expect :sleep, nil, [1.0]
    m.expect :sleep, nil, [1.3]
    m.expect :sleep, nil, [1.3*1.3]
    m
  end
  before do
    # Remove start method, make no-op
    class Google::Cloud::Firestore::QueryListener
      alias_method :start_for_realz, :start
      remove_method :start

      def start
        self
      end

      def start_with_sleep_mock sleep_mock
        @sleep_mock = sleep_mock
        start_for_realz
      end

      def sleep val
        @sleep_mock.sleep val
      end
    end
  end

  after do
    # restore start method, cleanup our methods
    class Google::Cloud::Firestore::QueryListener
      alias_method :start, :start_for_realz
      remove_method :start_for_realz
      remove_method :sleep
    end

    # verify the sleep mock
    sleep_mock
  end

  it "restarts when GRPC::Cancelled is raised" do
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new restartable_listen_responses(GRPC::Cancelled.new)
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    listener = collection.order(:val).listen do |query_snp|
      query_snapshots << query_snp
    end

    # Start listener because we stopped this from happening in this setup
    # Pass in mock to verify incremental backoff is happening
    listener.start_with_sleep_mock sleep_mock

    wait_until { query_snapshots.count == 4 }

    listener.stop

    verify_query_snapshots query_snapshots
  end

  it "restarts when GRPC::DeadlineExceeded is raised" do
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new restartable_listen_responses(GRPC::DeadlineExceeded.new)
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    listener = collection.order(:val).listen do |query_snp|
      query_snapshots << query_snp
    end

    # Start listener because we stopped this from happening in this setup
    # Pass in mock to verify incremental backoff is happening
    listener.start_with_sleep_mock sleep_mock

    wait_until { query_snapshots.count == 4 }

    listener.stop

    verify_query_snapshots query_snapshots
  end

  it "restarts when GRPC::Internal is raised" do
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new restartable_listen_responses(GRPC::Internal.new)
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    listener = collection.order(:val).listen do |query_snp|
      query_snapshots << query_snp
    end

    # Start listener because we stopped this from happening in this setup
    # Pass in mock to verify incremental backoff is happening
    listener.start_with_sleep_mock sleep_mock

    wait_until { query_snapshots.count == 4 }

    listener.stop

    verify_query_snapshots query_snapshots
  end

  it "restarts when GRPC::ResourceExhausted is raised" do
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new restartable_listen_responses(GRPC::ResourceExhausted.new)
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    listener = collection.order(:val).listen do |query_snp|
      query_snapshots << query_snp
    end

    # Start listener because we stopped this from happening in this setup
    # Pass in mock to verify incremental backoff is happening
    listener.start_with_sleep_mock sleep_mock

    wait_until { query_snapshots.count == 4 }

    listener.stop

    verify_query_snapshots query_snapshots
  end

  it "restarts when GRPC::Unauthenticated is raised" do
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new restartable_listen_responses(GRPC::Unauthenticated.new)
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    listener = collection.order(:val).listen do |query_snp|
      query_snapshots << query_snp
    end

    # Start listener because we stopped this from happening in this setup
    # Pass in mock to verify incremental backoff is happening
    listener.start_with_sleep_mock sleep_mock

    wait_until { query_snapshots.count == 4 }

    listener.stop

    verify_query_snapshots query_snapshots
  end

  it "restarts when GRPC::Unavailable is raised" do
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new restartable_listen_responses(GRPC::Unavailable.new)
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    listener = collection.order(:val).listen do |query_snp|
      query_snapshots << query_snp
    end

    # Start listener because we stopped this from happening in this setup
    # Pass in mock to verify incremental backoff is happening
    listener.start_with_sleep_mock sleep_mock

    wait_until { query_snapshots.count == 4 }

    listener.stop

    verify_query_snapshots query_snapshots
  end



  def restartable_listen_responses error
    [
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
        no_change_resp("SENDQUERYSNAPSHOTNOW", 0.2),

        no_change_resp("THISTOKENWILLNEVERBESEEN", 1),
        no_change_resp("NEITHERWILLTHISTOKEN", 1.1),
        doc_change_resp("false", 1.2, val: true),
        doc_change_resp("true", 1.2, val: false),
        # Raise an error before these changes are persisted
        error
      ],
      [error],
      [error],
      [
        # Re-add all the original documents, except the ones that changed
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
        doc_change_resp("int",   1, val: 42),
        doc_change_resp("num",   1, val: 11.1),
        current_resp("DOCUMENTSHAVEBEENADDED", 2.2),
        no_change_resp("SENDQUERYSNAPSHOTNOW", 2.3),

        no_change_resp("THISTOKENWILLNEVERBESEEN2", 3),
        no_change_resp("NEITHERWILLTHISTOKEN2", 3.1),
        doc_change_resp("array", 3.2, val: [1, 2, 3]),
        no_change_resp("DOCUMENTUPDATEDTOKEN", 3.3),

        doc_delete_resp("array", 4),
        doc_remove_resp("hash",  4),
        no_change_resp("DOCUMENTSDELETEDTOKEN", 4.1)
      ]
    ]
  end

  def verify_query_snapshots snapshots
    snapshots.count.must_equal 4
    snapshots.each { |qs| qs.must_be_kind_of Google::Cloud::Firestore::QuerySnapshot }

    snapshots[0].count.must_equal 14
    snapshots[0].changes.count.must_equal 14
    snapshots[0].docs.map(&:document_id).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    snapshots[0].changes.each { |change| change.must_be :added? }
    snapshots[0].changes.map(&:doc).map(&:document_id).must_equal ["nil", "false", "true", "int", "num", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]

    snapshots[1].count.must_equal 14
    snapshots[1].changes.count.must_equal 2
    snapshots[1].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    snapshots[1].changes.each { |change| change.must_be :modified? }
    snapshots[1].changes.map(&:doc).map(&:document_id).must_equal ["num", "int"]

    snapshots[2].count.must_equal 14
    snapshots[2].changes.count.must_equal 1
    snapshots[2].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2", "array", "hash"]
    snapshots[2].changes.each { |change| change.must_be :modified? }
    snapshots[2].changes.map(&:doc).map(&:document_id).must_equal ["array"]

    snapshots[3].count.must_equal 12
    snapshots[3].changes.count.must_equal 2
    snapshots[3].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "time", "str", "io", "ref1", "ref2", "geo1", "geo2"]
    snapshots[3].changes.each { |change| change.must_be :removed? }
    snapshots[3].changes.map(&:doc).map(&:document_id).must_equal ["array", "hash"]
  end
end
