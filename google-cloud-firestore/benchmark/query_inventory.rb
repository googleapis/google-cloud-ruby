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

require "google/cloud/firestore"
require "ostruct"
require "benchmark"

$project_id = "projectID"
$credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
$service = Google::Cloud::Firestore::Service.new $project_id, $credentials
$firestore = Google::Cloud::Firestore::Client.new $service
$col = $firestore.col("benchmark")
$query = $col.order(:val, :desc).order($firestore.document_id)

def new_doc_snp doc_path, data = {}
  doc_grpc = Google::Firestore::V1beta1::Document.new(
    name: "projects/#{$project_id}/databases/(default)/benchmark/#{doc_path}",
    fields: Google::Cloud::Firestore::Convert.hash_to_fields(data),
    create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
    update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now)
  )
  Google::Cloud::Firestore::DocumentSnapshot.from_document doc_grpc, $firestore, read_at: Time.now
end

def sort_array_inventory ary
  new_ary = ary.sort &($query_inventory.method(:query_comparison_proc))
  # Add the following make the sort more comparable to what inventory does
  new_order = Hash[new_ary.map(&:path).each_with_index.to_a]
  new_ary
end

$query_inventory = Google::Cloud::Firestore::QueryListener::Inventory.new $query

array_inventory = nil
snapshot_inventory = nil

$init_docs = Array.new(25_000) do |i|
  new_doc_snp "doc-#{i}", val: i
end.reverse
$init_docs.each do |doc|
  $query_inventory.add doc
end

Benchmark.bm(25) do |x|
  x.report('init 25k array:') { array_inventory = sort_array_inventory($init_docs) }
  x.report('init 25k inventory:')  { snapshot_inventory = $query_inventory.to_query_snapshot(Time.now).docs }
end

raise "sorted docs no longer match" if array_inventory.map(&:document_id) != snapshot_inventory.map(&:document_id)

new_doc = new_doc_snp("doc-add", val: 500)

Benchmark.bm(25) do |x|
  x.report('insert 1 into array:') { array_inventory << new_doc; array_inventory = sort_array_inventory(array_inventory) }
  x.report('insert 1 into inventory:')  { $query_inventory.add(new_doc); snapshot_inventory = $query_inventory.to_query_snapshot(Time.now).docs }
end

raise "sorted docs no longer match" if array_inventory.map(&:document_id) != snapshot_inventory.map(&:document_id)

new_random_docs = Array.new(500) do |i|
  new_doc_snp("doc2-#{i}", val: i)
end.shuffle

Benchmark.bm(25) do |x|
  x.report('bulk insert 500 array:') do
    new_random_docs.each do |new_random_doc|
      array_inventory << new_random_doc
    end
    array_inventory = sort_array_inventory(array_inventory)
  end
  x.report('bulk insert 500 inventory:') do
    new_random_docs.each do |new_random_doc|
      $query_inventory.add new_random_doc
    end
    snapshot_inventory = $query_inventory.to_query_snapshot(Time.now).docs
  end
end

raise "sorted docs no longer match" if array_inventory.map(&:document_id) != snapshot_inventory.map(&:document_id)

Benchmark.bm(25) do |x|
  x.report('delete 1 from array:') { array_inventory.delete_at(array_inventory.find_index { |doc| doc.path == new_doc.path }); array_inventory = sort_array_inventory(array_inventory) }
  x.report('delete 1 from inventory:')  { $query_inventory.delete(new_doc.path); snapshot_inventory = $query_inventory.to_query_snapshot(Time.now).docs }
end

raise "sorted docs no longer match" if array_inventory.map(&:document_id) != snapshot_inventory.map(&:document_id)
