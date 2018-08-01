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

describe Google::Cloud::Firestore::DocumentReference, :listen, :retry, :watch_firestore do
  let(:document_path) { "watch/doc" }
  let(:document) { Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/#{document_path}", firestore }
  let(:read_time) { Time.now }
  let(:read_timestamp) { Google::Cloud::Firestore::Convert.time_to_timestamp(read_time) }
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
    class Google::Cloud::Firestore::DocumentListener
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
    class Google::Cloud::Firestore::DocumentListener
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

    doc_snapshots = []
    listener = document.listen do |doc_snp|
      doc_snapshots << doc_snp
    end

    # Start listener because we stopped this from happening in this setup
    # Pass in mock to verify incremental backoff is happening
    listener.start_with_sleep_mock sleep_mock

    wait_until { doc_snapshots.count == 6 }

    listener.stop

    verify_doc_snapshots doc_snapshots
  end

  it "restarts when GRPC::DeadlineExceeded is raised" do
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new restartable_listen_responses(GRPC::DeadlineExceeded.new)
    firestore.service.instance_variable_set :@firestore, listen_stub

    doc_snapshots = []
    listener = document.listen do |doc_snp|
      doc_snapshots << doc_snp
    end

    # Start listener because we stopped this from happening in this setup
    # Pass in mock to verify incremental backoff is happening
    listener.start_with_sleep_mock sleep_mock

    wait_until { doc_snapshots.count == 6 }

    listener.stop

    verify_doc_snapshots doc_snapshots
  end

  it "restarts when GRPC::Internal is raised" do
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new restartable_listen_responses(GRPC::Internal.new)
    firestore.service.instance_variable_set :@firestore, listen_stub

    doc_snapshots = []
    listener = document.listen do |doc_snp|
      doc_snapshots << doc_snp
    end

    # Start listener because we stopped this from happening in this setup
    # Pass in mock to verify incremental backoff is happening
    listener.start_with_sleep_mock sleep_mock

    wait_until { doc_snapshots.count == 6 }

    listener.stop

    verify_doc_snapshots doc_snapshots
  end

  it "restarts when GRPC::ResourceExhausted is raised" do
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new restartable_listen_responses(GRPC::ResourceExhausted.new)
    firestore.service.instance_variable_set :@firestore, listen_stub

    doc_snapshots = []
    listener = document.listen do |doc_snp|
      doc_snapshots << doc_snp
    end

    # Start listener because we stopped this from happening in this setup
    # Pass in mock to verify incremental backoff is happening
    listener.start_with_sleep_mock sleep_mock

    wait_until { doc_snapshots.count == 6 }

    listener.stop

    verify_doc_snapshots doc_snapshots
  end

  it "restarts when GRPC::Unauthenticated is raised" do
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new restartable_listen_responses(GRPC::Unauthenticated.new)
    firestore.service.instance_variable_set :@firestore, listen_stub

    doc_snapshots = []
    listener = document.listen do |doc_snp|
      doc_snapshots << doc_snp
    end

    # Start listener because we stopped this from happening in this setup
    # Pass in mock to verify incremental backoff is happening
    listener.start_with_sleep_mock sleep_mock

    wait_until { doc_snapshots.count == 6 }

    listener.stop

    verify_doc_snapshots doc_snapshots
  end

  it "restarts when GRPC::Unavailable is raised" do
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new restartable_listen_responses(GRPC::Unavailable.new)
    firestore.service.instance_variable_set :@firestore, listen_stub

    doc_snapshots = []
    listener = document.listen do |doc_snp|
      doc_snapshots << doc_snp
    end

    # Start listener because we stopped this from happening in this setup
    # Pass in mock to verify incremental backoff is happening
    listener.start_with_sleep_mock sleep_mock

    wait_until { doc_snapshots.count == 6 }

    listener.stop

    verify_doc_snapshots doc_snapshots
  end

  def restartable_listen_responses error
    [
      [
        add_resp,
        doc_change_resp("doc", 0, val: nil),
        current_resp("DOCUMENTSHAVEBEENADDED", 0.1),
        no_change_resp("CALLBACKSENTHERE", 0.2),

        no_change_resp("THISTOKENWILLNEVERBESEEN", 1),
        no_change_resp("NEITHERWILLTHISTOKEN", 1.1),
        doc_change_resp("doc", 1.2, val: 42),
        no_change_resp("CALLBACKSENTHERE", 1.3),

        doc_remove_resp("doc", 2),
        no_change_resp("CALLBACKSENTHERE", 2.1),

        doc_change_resp("doc", 2.8, val: "THIS CHANGE WON'T BE SEEN"),
        # Raise an error before these changes are persisted
        error
      ],
      [error],
      [error],
      [
        no_change_resp("THISTOKENWILLNEVERBESEEN", 3),
        no_change_resp("NEITHERWILLTHISTOKEN", 3.1),
        doc_change_resp("doc", 3.2, val: 11.1),
        no_change_resp("CALLBACKSENTHERE", 3.3),

        doc_delete_resp("doc", 4),
        no_change_resp("CALLBACKSENTHERE", 4.1),

        doc_change_resp("doc", 5, val: "hi"),
        no_change_resp("CALLBACKSENTHERE", 5.1)
      ]
    ]
  end

  def verify_doc_snapshots snapshots
    assert snapshots
    snapshots.count.must_equal 6
    snapshots.each { |qs| qs.must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot }

    snapshots[0].document_path.must_equal document.document_path
    snapshots[0].must_be :exists?
    snapshots[0][:val].must_be :nil?

    snapshots[1].document_path.must_equal document.document_path
    snapshots[1].must_be :exists?
    snapshots[1][:val].must_equal 42

    snapshots[2].document_path.must_equal document.document_path
    snapshots[2].must_be :missing?

    snapshots[3].document_path.must_equal document.document_path
    snapshots[3].must_be :exists?
    snapshots[3][:val].must_equal 11.1

    snapshots[4].document_path.must_equal document.document_path
    snapshots[4].must_be :missing?

    snapshots[5].document_path.must_equal document.document_path
    snapshots[5].must_be :exists?
    snapshots[5][:val].must_equal "hi"
  end
end
