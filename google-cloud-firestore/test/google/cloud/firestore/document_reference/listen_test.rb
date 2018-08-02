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
    doc_snapshots.count.must_equal 6
    doc_snapshots.each { |qs| qs.must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot }

    doc_snapshots[0].document_path.must_equal document.document_path
    doc_snapshots[0].must_be :exists?
    doc_snapshots[0][:val].must_be :nil?

    doc_snapshots[1].document_path.must_equal document.document_path
    doc_snapshots[1].must_be :exists?
    doc_snapshots[1][:val].must_equal 42

    doc_snapshots[2].document_path.must_equal document.document_path
    doc_snapshots[2].must_be :missing?

    doc_snapshots[3].document_path.must_equal document.document_path
    doc_snapshots[3].must_be :exists?
    doc_snapshots[3][:val].must_equal 11.1

    doc_snapshots[4].document_path.must_equal document.document_path
    doc_snapshots[4].must_be :missing?

    doc_snapshots[5].document_path.must_equal document.document_path
    doc_snapshots[5].must_be :exists?
    doc_snapshots[5][:val].must_equal "hi"
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
    doc_snapshots.count.must_equal 6
    doc_snapshots.each { |qs| qs.must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot }

    doc_snapshots[0].document_path.must_equal document.document_path
    doc_snapshots[0].must_be :exists?
    doc_snapshots[0][:val].must_be :nil?

    doc_snapshots[1].document_path.must_equal document.document_path
    doc_snapshots[1].must_be :exists?
    doc_snapshots[1][:val].must_equal 42

    doc_snapshots[2].document_path.must_equal document.document_path
    doc_snapshots[2].must_be :missing?

    doc_snapshots[3].document_path.must_equal document.document_path
    doc_snapshots[3].must_be :exists?
    doc_snapshots[3][:val].must_equal 11.1

    doc_snapshots[4].document_path.must_equal document.document_path
    doc_snapshots[4].must_be :missing?

    doc_snapshots[5].document_path.must_equal document.document_path
    doc_snapshots[5].must_be :exists?
    doc_snapshots[5][:val].must_equal "hi"
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
    doc_snapshots.count.must_equal 6
    doc_snapshots.each { |qs| qs.must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot }

    doc_snapshots[0].document_path.must_equal document.document_path
    doc_snapshots[0].must_be :exists?
    doc_snapshots[0][:val].must_be :nil?

    doc_snapshots[1].document_path.must_equal document.document_path
    doc_snapshots[1].must_be :exists?
    doc_snapshots[1][:val].must_equal 42

    doc_snapshots[2].document_path.must_equal document.document_path
    doc_snapshots[2].must_be :missing?

    doc_snapshots[3].document_path.must_equal document.document_path
    doc_snapshots[3].must_be :exists?
    doc_snapshots[3][:val].must_equal 11.1

    doc_snapshots[4].document_path.must_equal document.document_path
    doc_snapshots[4].must_be :missing?

    doc_snapshots[5].document_path.must_equal document.document_path
    doc_snapshots[5].must_be :exists?
    doc_snapshots[5][:val].must_equal "hi"
  end
end
181
