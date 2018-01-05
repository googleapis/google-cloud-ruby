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

require "firestore_helper"

describe "Watch", :firestore_acceptance do
  it "watches a query" do
    watch_col = root_col.doc("watch").col("watch-query")

    watch_col.doc("nil").create(val: nil)
    watch_col.doc("int").create(val: 0)
    watch_col.doc("true").create(val: true)
    watch_col.doc("false").create(val: false)
    watch_col.doc("num").create(val: 0.0)
    watch_col.doc("str").create(val: "")
    watch_col.doc("array").create(val: [])
    watch_col.doc("hash").create(val: {})
    watch_col.doc("io").create(val: StringIO.new)

    query_snapshots = []
    listener = watch_col.order(:val, :desc).listen do |query_snp|
      query_snapshots << query_snp
    end

    wait_until { query_snapshots.count == 1 }

    watch_col.doc("added").create(val: false)

    wait_until { query_snapshots.count == 2 }

    watch_col.doc("array").delete

    wait_until { query_snapshots.count == 3 }

    watch_col.doc("added").update(val: true)

    wait_until { query_snapshots.count == 4 }

    listener.stop

    query_snapshots.count.must_equal 4
    query_snapshots.each { |qs| qs.must_be_kind_of Google::Cloud::Firestore::QuerySnapshot }

    query_snapshots[0].count.must_equal 9
    query_snapshots[0].changes.count.must_equal 9
    query_snapshots[0].docs.map(&:document_id).must_equal ["hash", "array", "io", "str", "num", "int", "true", "false", "nil"]
    query_snapshots[0].changes.each { |change| change.must_be :added? }
    query_snapshots[0].changes.map(&:doc).map(&:document_id).must_equal ["hash", "array", "io", "str", "num", "int", "true", "false", "nil"]

    query_snapshots[1].count.must_equal 10
    query_snapshots[1].changes.count.must_equal 1
    query_snapshots[1].docs.map(&:document_id).must_equal ["hash", "array", "io", "str", "num", "int", "true", "false", "added", "nil"]
    query_snapshots[1].changes.each { |change| change.must_be :added? }
    query_snapshots[1].changes.map(&:doc).map(&:document_id).must_equal ["added"]

    query_snapshots[2].count.must_equal 9
    query_snapshots[2].changes.count.must_equal 1
    query_snapshots[2].docs.map(&:document_id).must_equal ["hash", "io", "str", "num", "int", "true", "false", "added", "nil"]
    query_snapshots[2].changes.each { |change| change.must_be :removed? }
    query_snapshots[2].changes.map(&:doc).map(&:document_id).must_equal ["array"]

    query_snapshots[3].count.must_equal 9
    query_snapshots[3].changes.count.must_equal 1
    query_snapshots[3].docs.map(&:document_id).must_equal ["hash", "io", "str", "num", "int", "true", "added", "false", "nil"]
    query_snapshots[3].changes.each { |change| change.must_be :modified? }
    query_snapshots[3].changes.map(&:doc).map(&:document_id).must_equal ["added"]
  end

  it "watches a document" do
    watch_col = root_col.doc("watch").col("watch-docs")

    watch_col.doc("watch-doc").create(val: true)

    doc_snapshots = []
    listener = watch_col.doc("watch-doc").listen do |doc_snp|
      doc_snapshots << doc_snp
    end

    wait_until { doc_snapshots.count == 1 }

    watch_col.doc("watch-doc").update(val: false)

    wait_until { doc_snapshots.count == 2 }

    watch_col.doc("watch-doc").delete

    wait_until { doc_snapshots.count == 3 }

    watch_col.doc("watch-doc").set(val: 1)

    wait_until { doc_snapshots.count == 4 }

    listener.stop

    doc_snapshots.count.must_equal 4
    doc_snapshots.each { |qs| qs.must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot }

    doc_snapshots[0].document_path.must_equal watch_col.doc("watch-doc").document_path
    doc_snapshots[0].must_be :exists?
    doc_snapshots[0][:val].must_equal true

    doc_snapshots[1].document_path.must_equal watch_col.doc("watch-doc").document_path
    doc_snapshots[1].must_be :exists?
    doc_snapshots[1][:val].must_equal false

    doc_snapshots[2].document_path.must_equal watch_col.doc("watch-doc").document_path
    doc_snapshots[2].must_be :missing?

    doc_snapshots[3].document_path.must_equal watch_col.doc("watch-doc").document_path
    doc_snapshots[3].must_be :exists?
    doc_snapshots[3][:val].must_equal 1
  end

  def wait_until &block
    wait_count = 0
    until block.call
      fail "wait_until criterial was not met" if wait_count > 200
      wait_count += 1
      sleep 0.01
    end
  end
end
