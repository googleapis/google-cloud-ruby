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

describe Google::Cloud::Firestore::Query, :listen, :mock_firestore do
  let(:query_grpc) { StructuredQuery.new(from: [StructuredQuery::CollectionSelector.new(collection_id: "watch")]) }
  let(:query) { Google::Cloud::Firestore::Query.start nil, "#{firestore.path}/documents", firestore }
  let(:read_time) { Time.now }
  let(:read_timestamp) { Google::Cloud::Firestore::Convert.time_to_timestamp(read_time) }

  it "listens to a query and yields query snapshots" do
    listen_responses = [
      add_resp,
      doc_change_resp("nil", val: nil),
      doc_change_resp("false", val: false),
      doc_change_resp("true", val: true),
      doc_change_resp("int", val: 1),
      doc_change_resp("num", val: 3.14),
      doc_change_resp("str", val: ""),
      doc_change_resp("io", val: StringIO.new),
      doc_change_resp("array", val: []),
      doc_change_resp("hash", val: {}),
      current_resp("DOCUMENTSHAVEBEENADDED"),

      no_change_resp("THISTOKENWILLNEVERBESEEN"),
      no_change_resp("NEITHERWILLTHISTOKEN"),
      doc_change_resp("int", val: 42),
      doc_change_resp("num", val: 11.1),
      no_change_resp("DOCUMENTSUPDATEDTOKEN"),

      no_change_resp("THISTOKENWILLNEVERBESEEN2"),
      no_change_resp("NEITHERWILLTHISTOKEN2"),
      doc_change_resp("array", val: [1, 2, 3]),
      no_change_resp("DOCUMENTUPDATEDTOKEN"),

      doc_delete_resp("array"),
      doc_remove_resp("hash"),
      no_change_resp("DOCUMENTSDELETEDTOKEN")
    ]
    # set stub because we can't mock a streaming request/response
    listen_stub = StreamingListenStub.new listen_responses.each
    firestore.service.instance_variable_set :@firestore, listen_stub

    query_snapshots = []
    listener = query.order(:val).listen do |query_snp|
      query_snapshots << query_snp
    end

    wait_count = 0
    while query_snapshots.count < 4
      fail "total number of calls were never made" if wait_count > 100
      wait_count += 1
      sleep 0.01
    end

    listener.stop

    # assert snapshots
    query_snapshots.count.must_equal 4
    query_snapshots.each { |qs| qs.must_be_kind_of Google::Cloud::Firestore::QuerySnapshot }

    query_snapshots[0].count.must_equal 9
    query_snapshots[0].changes.count.must_equal 9
    query_snapshots[0].docs.map(&:document_id).must_equal ["nil", "false", "true", "int", "num", "str", "io", "array", "hash"]
    query_snapshots[0].changes.each { |change| change.must_be :added? }
    query_snapshots[0].changes.map(&:doc).map(&:document_id).must_equal ["nil", "false", "true", "int", "num", "str", "io", "array", "hash"]

    query_snapshots[1].count.must_equal 9
    query_snapshots[1].changes.count.must_equal 2
    query_snapshots[1].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "str", "io", "array", "hash"]
    query_snapshots[1].changes.each { |change| change.must_be :modified? }
    query_snapshots[1].changes.map(&:doc).map(&:document_id).must_equal ["int", "num"]

    query_snapshots[2].count.must_equal 9
    query_snapshots[2].changes.count.must_equal 1
    query_snapshots[2].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "str", "io", "array", "hash"]
    query_snapshots[2].changes.each { |change| change.must_be :modified? }
    query_snapshots[2].changes.map(&:doc).map(&:document_id).must_equal ["array"]

    query_snapshots[3].count.must_equal 7
    query_snapshots[3].changes.count.must_equal 2
    query_snapshots[3].docs.map(&:document_id).must_equal ["nil", "false", "true", "num", "int", "str", "io"]
    query_snapshots[3].changes.each { |change| change.must_be :removed? }
    query_snapshots[3].changes.map(&:doc).map(&:document_id).must_equal ["array", "hash"]
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

  def doc_change_resp doc_path, data
    Google::Firestore::V1beta1::ListenResponse.new(
      document_change: Google::Firestore::V1beta1::DocumentChange.new(
        document: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/watch/#{doc_path}",
          fields: Google::Cloud::Firestore::Convert.hash_to_fields(data),
          create_time: read_timestamp,
          update_time: read_timestamp
        )
      )
    )
  end

  def doc_delete_resp doc_path
    Google::Firestore::V1beta1::ListenResponse.new(
      document_delete: Google::Firestore::V1beta1::DocumentDelete.new(
        document: "projects/#{project}/databases/(default)/watch/#{doc_path}",
        read_time: read_timestamp
      )
    )
  end

  def doc_remove_resp doc_path
    Google::Firestore::V1beta1::ListenResponse.new(
      document_remove: Google::Firestore::V1beta1::DocumentRemove.new(
        document: "projects/#{project}/databases/(default)/watch/#{doc_path}",
        read_time: read_timestamp
      )
    )
  end
end
