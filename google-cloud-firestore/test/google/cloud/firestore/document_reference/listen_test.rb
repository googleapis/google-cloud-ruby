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

describe Google::Cloud::Firestore::DocumentReference, :listen, :watch_firestore do
  let(:document_path) { "watch/doc" }
  let(:document) { Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/#{document_path}", firestore }
  let(:read_time) { Time.now }
  let(:read_timestamp) { Google::Cloud::Firestore::Convert.time_to_timestamp(read_time) }

  it "listens to a query and yields query snapshots" do
    listen_responses = [
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

      no_change_resp("THISTOKENWILLNEVERBESEEN", 3),
      no_change_resp("NEITHERWILLTHISTOKEN", 3.1),
      doc_change_resp("doc", 3.2, val: 11.1),
      no_change_resp("CALLBACKSENTHERE", 3.3),

      doc_delete_resp("doc", 4),
      no_change_resp("CALLBACKSENTHERE", 4.1),

      doc_change_resp("doc", 5, val: "hi"),
      no_change_resp("CALLBACKSENTHERE", 5.1)
    ]
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new [listen_responses]
    firestore.service.instance_variable_set :@firestore, listen_stub

    doc_snapshots = []
    listener = document.listen do |doc_snp|
      doc_snapshots << doc_snp
    end

    wait_until { doc_snapshots.count == 6 }

    listener.stop

    # assert snapshots
    _(doc_snapshots.count).must_equal 6
    doc_snapshots.each { |qs| _(qs).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot }

    _(doc_snapshots[0].document_path).must_equal document.document_path
    _(doc_snapshots[0]).must_be :exists?
    _(doc_snapshots[0][:val]).must_be :nil?

    _(doc_snapshots[1].document_path).must_equal document.document_path
    _(doc_snapshots[1]).must_be :exists?
    _(doc_snapshots[1][:val]).must_equal 42

    _(doc_snapshots[2].document_path).must_equal document.document_path
    _(doc_snapshots[2]).must_be :missing?

    _(doc_snapshots[3].document_path).must_equal document.document_path
    _(doc_snapshots[3]).must_be :exists?
    _(doc_snapshots[3][:val]).must_equal 11.1

    _(doc_snapshots[4].document_path).must_equal document.document_path
    _(doc_snapshots[4]).must_be :missing?

    _(doc_snapshots[5].document_path).must_equal document.document_path
    _(doc_snapshots[5]).must_be :exists?
    _(doc_snapshots[5][:val]).must_equal "hi"
  end

  it "resets when RESET is returned" do
    listen_responses = [
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
        reset_resp
      ],
      [
        add_resp,
        no_change_resp("THISTOKENWILLNEVERBESEEN", 3),
        no_change_resp("NEITHERWILLTHISTOKEN", 3.1),
        doc_change_resp("doc", 3.2, val: 11.1),
        current_resp("DOCUMENTSHAVEBEENADDED", 3.3),
        no_change_resp("CALLBACKSENTHERE", 3.4),

        doc_delete_resp("doc", 4),
        no_change_resp("CALLBACKSENTHERE", 4.1),

        doc_change_resp("doc", 5, val: "hi"),
        no_change_resp("CALLBACKSENTHERE", 5.1)
      ]
    ]
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new listen_responses
    firestore.service.instance_variable_set :@firestore, listen_stub

    doc_snapshots = []
    listener = document.listen do |doc_snp|
      doc_snapshots << doc_snp
    end

    wait_until { doc_snapshots.count == 6 }

    listener.stop

    # assert snapshots
    _(doc_snapshots.count).must_equal 6
    doc_snapshots.each { |qs| _(qs).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot }

    _(doc_snapshots[0].document_path).must_equal document.document_path
    _(doc_snapshots[0]).must_be :exists?
    _(doc_snapshots[0][:val]).must_be :nil?

    _(doc_snapshots[1].document_path).must_equal document.document_path
    _(doc_snapshots[1]).must_be :exists?
    _(doc_snapshots[1][:val]).must_equal 42

    _(doc_snapshots[2].document_path).must_equal document.document_path
    _(doc_snapshots[2]).must_be :missing?

    _(doc_snapshots[3].document_path).must_equal document.document_path
    _(doc_snapshots[3]).must_be :exists?
    _(doc_snapshots[3][:val]).must_equal 11.1

    _(doc_snapshots[4].document_path).must_equal document.document_path
    _(doc_snapshots[4]).must_be :missing?

    _(doc_snapshots[5].document_path).must_equal document.document_path
    _(doc_snapshots[5]).must_be :exists?
    _(doc_snapshots[5][:val]).must_equal "hi"
  end

  it "resets when FILTER count is incorrect" do
    listen_responses = [
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

        filter_resp(2) # count is incorrect, reset
      ],
      [
        add_resp,
        no_change_resp("THISTOKENWILLNEVERBESEEN", 3),
        no_change_resp("NEITHERWILLTHISTOKEN", 3.1),
        doc_change_resp("doc", 3.2, val: 11.1),
        current_resp("DOCUMENTSHAVEBEENADDED", 3.3),
        no_change_resp("CALLBACKSENTHERE", 3.4),

        filter_resp(1), # count is correct, no reset

        doc_delete_resp("doc", 4),
        no_change_resp("CALLBACKSENTHERE", 4.1),

        doc_change_resp("doc", 5, val: "hi"),
        no_change_resp("CALLBACKSENTHERE", 5.1)
      ]
    ]
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new listen_responses
    firestore.service.instance_variable_set :@firestore, listen_stub

    doc_snapshots = []
    listener = document.listen do |doc_snp|
      doc_snapshots << doc_snp
    end

    wait_until { doc_snapshots.count == 6 }

    listener.stop

    # assert snapshots
    _(doc_snapshots.count).must_equal 6
    doc_snapshots.each { |qs| _(qs).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot }

    _(doc_snapshots[0].document_path).must_equal document.document_path
    _(doc_snapshots[0]).must_be :exists?
    _(doc_snapshots[0][:val]).must_be :nil?

    _(doc_snapshots[1].document_path).must_equal document.document_path
    _(doc_snapshots[1]).must_be :exists?
    _(doc_snapshots[1][:val]).must_equal 42

    _(doc_snapshots[2].document_path).must_equal document.document_path
    _(doc_snapshots[2]).must_be :missing?

    _(doc_snapshots[3].document_path).must_equal document.document_path
    _(doc_snapshots[3]).must_be :exists?
    _(doc_snapshots[3][:val]).must_equal 11.1

    _(doc_snapshots[4].document_path).must_equal document.document_path
    _(doc_snapshots[4]).must_be :missing?

    _(doc_snapshots[5].document_path).must_equal document.document_path
    _(doc_snapshots[5]).must_be :exists?
    _(doc_snapshots[5][:val]).must_equal "hi"
  end

  it "invokes on_error callbacks when the listener receives errors" do
    err_msg = "test listener error"
    listen_responses = [
      [
        doc_change_resp("doc", 0, val: 1),
        current_resp("DOCUMENTSHAVEBEENCHANGED", 0.1),
        no_change_resp("THISTOKENWILLNEVERBESEEN", 1),
        ArgumentError.new(err_msg)
      ],
      [
        doc_change_resp("doc", 0, val: 1),
        current_resp("DOCUMENTSHAVEBEENCHANGED", 0.1),
        no_change_resp("THISTOKENWILLNEVERBESEEN", 1)
      ]
    ]
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new listen_responses
    firestore.service.instance_variable_set :@firestore, listen_stub

    doc_snapshots = []
    errors_1 = []
    errors_2 = []

    out, err = capture_io do # Capture the error raised from listener thread.
      listener = document.listen do |doc_snp|
        doc_snapshots << doc_snp
      end

      listener.on_error do |error|
        errors_1 << error
      end

      listener.on_error do |error|
        errors_2 << error
      end

      wait_until { doc_snapshots.count == 1 && errors_1.count == 1 && errors_2.count == 1 }

      listener.stop
    end

    _(errors_1.count).must_equal 1
    _(errors_1[0]).must_be_kind_of ArgumentError
    _(errors_1[0].message).must_equal err_msg

    _(errors_2.count).must_equal 1
    _(errors_2[0]).must_be_kind_of ArgumentError
    _(errors_2[0].message).must_equal err_msg

    # assert snapshots
    _(doc_snapshots.count).must_equal 1
    doc_snapshots.each { |qs| _(qs).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot }

    _(doc_snapshots[0].document_path).must_equal document.document_path
    _(doc_snapshots[0]).must_be :exists?
    _(doc_snapshots[0][:val]).must_equal 1
  end

  it "raises when on_error is called without a block" do
    listener = document.listen do |doc_snp|
      raise "should not be called"
    end

    error = expect do
      listener.on_error
    end.must_raise ArgumentError
    _(error.message).must_equal "on_error must be called with a block"

    listener.stop
  end
end
