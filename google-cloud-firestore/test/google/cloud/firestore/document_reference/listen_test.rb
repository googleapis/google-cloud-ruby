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

describe Google::Cloud::Firestore::DocumentReference, :listen, :mock_firestore do
  let(:document_path) { "users/mike" }
  let(:document) { Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/#{document_path}", firestore }
  let(:read_time) { Time.now }
  let(:read_timestamp) { Google::Cloud::Firestore::Convert.time_to_timestamp(read_time) }

  it "listens to a query and yields query snapshots" do
    listen_responses = [
      add_resp,
      doc_change_resp(val: nil),
      current_resp("DOCUMENTSHAVEBEENADDED"),

      no_change_resp("THISTOKENWILLNEVERBESEEN"),
      no_change_resp("NEITHERWILLTHISTOKEN"),
      doc_change_resp(val: 42),
      no_change_resp("DOCUMENTSUPDATEDTOKEN"),

      doc_remove_resp,
      no_change_resp("DOCUMENTREMOVEDEDTOKEN"),

      no_change_resp("THISTOKENWILLNEVERBESEEN"),
      no_change_resp("NEITHERWILLTHISTOKEN"),
      doc_change_resp(val: 11.1),
      no_change_resp("DOCUMENTUPDATEDTOKEN"),

      doc_delete_resp,
      no_change_resp("DOCUMENTDELETEDTOKEN"),

      doc_change_resp(val: "hi"),
      no_change_resp("DOCUMENTUPDATEDTOKEN")
    ]
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new listen_responses.each
    firestore.service.instance_variable_set :@firestore, listen_stub

    doc_snapshots = []
    listener = document.listen do |doc_snp|
      doc_snapshots << doc_snp
    end

    wait_count = 0
    while doc_snapshots.count < 6
      fail "total number of calls were never made" if wait_count > 100
      wait_count += 1
      sleep 0.01
    end

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

  def add_resp
    Google::Firestore::V1beta1::ListenResponse.new(
      target_change: Google::Firestore::V1beta1::TargetChange.new(
        target_change_type: :ADD
      )
    )
  end

  def current_resp token
    Google::Firestore::V1beta1::ListenResponse.new(
      target_change: Google::Firestore::V1beta1::TargetChange.new(
        target_change_type: :CURRENT,
        resume_token: token,
        read_time: read_timestamp
      )
    )
  end

  def no_change_resp token
    Google::Firestore::V1beta1::ListenResponse.new(
      target_change: Google::Firestore::V1beta1::TargetChange.new(
        target_change_type: :NO_CHANGE,
        resume_token: token,
        read_time: read_timestamp
      )
    )
  end

  def doc_change_resp data
    Google::Firestore::V1beta1::ListenResponse.new(
      document_change: Google::Firestore::V1beta1::DocumentChange.new(
        document: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/watch/users/mike",
          fields: Google::Cloud::Firestore::Convert.hash_to_fields(data),
          create_time: read_timestamp,
          update_time: read_timestamp
        )
      )
    )
  end

  def doc_delete_resp
    Google::Firestore::V1beta1::ListenResponse.new(
      document_delete: Google::Firestore::V1beta1::DocumentDelete.new(
        document: "projects/#{project}/databases/(default)/watch/users/mike",
        read_time: read_timestamp
      )
    )
  end

  def doc_remove_resp
    Google::Firestore::V1beta1::ListenResponse.new(
      document_remove: Google::Firestore::V1beta1::DocumentRemove.new(
        document: "projects/#{project}/databases/(default)/watch/users/mike",
        read_time: read_timestamp
      )
    )
  end
end
