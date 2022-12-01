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
  it "watches a limit query" do
    watch_col = root_col.doc("watch-limit-#{SecureRandom.hex(4)}").col("watch-query")

    watch_col.doc("int 5").create val: 5
    watch_col.doc("int 4").create val: 4
    watch_col.doc("int 3").create val: 3

    snps = []
    listener = watch_col.order(:val).limit(2).listen { |snp| snps << snp }

    wait_until { snps.count == 1 }

    firestore.batch do |b|
      b.create watch_col.doc("int 2"), { val: 1 }
      b.create watch_col.doc("int 1"), { val: 0 }
    end

    wait_until { snps.count == 2 }

    listener.stop

    _(snps.count).must_equal 2
    _(snps[0].count).must_equal 2
    _(snps[0].docs.map(&:document_id)).must_equal ["int 3", "int 4"]
    _(snps[0].changes.map(&:type)).must_equal [:added, :added]
    _(snps[0].changes.map(&:doc).map(&:document_id)).must_equal ["int 3", "int 4"]
    _(snps[1].count).must_equal 2
    _(snps[1].docs.map(&:document_id)).must_equal ["int 1", "int 2"]
    _(snps[1].changes.map(&:type)).must_equal [:removed, :removed, :added, :added]
    _(snps[1].changes.map(&:doc).map(&:document_id)).must_equal ["int 3", "int 4", "int 1", "int 2"]
  end

  it "watches a limit_to_last query" do
    watch_col = root_col.doc("watch-limit_to_last-#{SecureRandom.hex(4)}").col("watch-query")

    watch_col.doc("int 3").create val: 3
    watch_col.doc("int 2").create val: 2
    watch_col.doc("int 1").create val: 1

    snps = []
    listener = watch_col.order(:val).limit_to_last(2).listen { |snp| snps << snp }

    wait_until { snps.count == 1 }

    firestore.batch do |b|
      b.create watch_col.doc("int 5"), { val: 5 }
      b.create watch_col.doc("int 4"), { val: 4 }
    end

    wait_until { snps.count == 2 }

    listener.stop

    _(snps.count).must_equal 2
    _(snps[0].count).must_equal 2
    _(snps[0].docs.map(&:document_id)).must_equal ["int 2", "int 3"]
    _(snps[0].changes.map(&:type)).must_equal [:added, :added]
    _(snps[0].changes.map(&:doc).map(&:document_id)).must_equal ["int 2", "int 3"]
    _(snps[1].count).must_equal 2
    _(snps[1].docs.map(&:document_id)).must_equal ["int 4", "int 5"]
    _(snps[1].changes.map(&:type)).must_equal [:removed, :removed, :added, :added]
    _(snps[1].changes.map(&:doc).map(&:document_id)).must_equal ["int 2", "int 3", "int 4", "int 5"]
  end

  it "watches a query" do
    watch_col = root_col.doc("watch-#{SecureRandom.hex(4)}").col("watch-query")

    watch_col.doc("nil").create val: nil
    watch_col.doc("int").create val: 0
    watch_col.doc("true").create val: true
    watch_col.doc("false").create val: false
    watch_col.doc("num").create val: 0.0
    watch_col.doc("str").create val: ""
    watch_col.doc("time").create val: Time.now
    watch_col.doc("array").create val: []
    watch_col.doc("hash").create val: {}
    watch_col.doc("ref").create val: root_col.doc("ref")
    watch_col.doc("geo").create val: { longitude: 45, latitude: 45 }
    watch_col.doc("io").create val: StringIO.new

    snps = []
    listener = watch_col.order(:val, :desc).listen { |snp| snps << snp }

    wait_until { snps.count == 1 }

    watch_col.doc("added").create val: false

    wait_until { snps.count == 2 }

    watch_col.doc("array").delete

    wait_until { snps.count == 3 }

    watch_col.doc("added").update({val: true})

    wait_until { snps.count == 4 }

    listener.stop

    _(snps.count).must_equal 4
    snps.each { |qs| _(qs).must_be_kind_of Google::Cloud::Firestore::QuerySnapshot }

    _(snps[0].count).must_equal 12
    _(snps[0].changes.count).must_equal 12
    _(snps[0].docs.map(&:document_id)).must_equal ["hash", "array", "geo", "ref", "io", "str", "time", "num", "int", "true", "false", "nil"]
    snps[0].changes.each { |change| _(change).must_be :added? }
    _(snps[0].changes.map(&:doc).map(&:document_id)).must_equal ["hash", "array", "geo", "ref", "io", "str", "time", "num", "int", "true", "false", "nil"]

    _(snps[1].count).must_equal 13
    _(snps[1].changes.count).must_equal 1
    _(snps[1].docs.map(&:document_id)).must_equal ["hash", "array", "geo", "ref", "io", "str", "time", "num", "int", "true", "false", "added", "nil"]
    snps[1].changes.each { |change| _(change).must_be :added? }
    _(snps[1].changes.map(&:doc).map(&:document_id)).must_equal ["added"]

    _(snps[2].count).must_equal 12
    _(snps[2].changes.count).must_equal 1
    _(snps[2].docs.map(&:document_id)).must_equal ["hash", "geo", "ref", "io", "str", "time", "num", "int", "true", "false", "added", "nil"]
    snps[2].changes.each { |change| _(change).must_be :removed? }
    _(snps[2].changes.map(&:doc).map(&:document_id)).must_equal ["array"]

    _(snps[3].count).must_equal 12
    _(snps[3].changes.count).must_equal 1
    _(snps[3].docs.map(&:document_id)).must_equal ["hash", "geo", "ref", "io", "str", "time", "num", "int", "true", "added", "false", "nil"]
    snps[3].changes.each { |change| _(change).must_be :modified? }
    _(snps[3].changes.map(&:doc).map(&:document_id)).must_equal ["added"]
  end

  it "watches a document" do
    watch_col = root_col.doc("watch-#{SecureRandom.hex(4)}").col("watch-docs")

    watch_col.doc("watch-doc").create val: true

    snps = []
    listener = watch_col.doc("watch-doc").listen { |snp| snps << snp }

    wait_until { snps.count == 1 }

    watch_col.doc("watch-doc").update({val: false})

    wait_until { snps.count == 2 }

    watch_col.doc("watch-doc").delete

    wait_until { snps.count == 3 }

    watch_col.doc("watch-doc").set({val: 1})

    wait_until { snps.count == 4 }

    listener.stop

    _(snps.count).must_equal 4
    snps.each { |qs| _(qs).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot }

    _(snps[0].document_path).must_equal watch_col.doc("watch-doc").document_path
    _(snps[0]).must_be :exists?
    _(snps[0][:val]).must_equal true

    _(snps[1].document_path).must_equal watch_col.doc("watch-doc").document_path
    _(snps[1]).must_be :exists?
    _(snps[1][:val]).must_equal false

    _(snps[2].document_path).must_equal watch_col.doc("watch-doc").document_path
    _(snps[2]).must_be :missing?

    _(snps[3].document_path).must_equal watch_col.doc("watch-doc").document_path
    _(snps[3]).must_be :exists?
    _(snps[3][:val]).must_equal 1
  end

  def wait_until &block
    wait_count = 0
    until block.call
      fail "wait_until criteria was not met" if wait_count > 6
      wait_count += 1
      sleep (2**wait_count) + rand(0..wait_count)
    end
  end
end
