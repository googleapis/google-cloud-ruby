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

def new_doc_grpc doc_path, data = {}
  Google::Firestore::V1beta1::Document.new(
    name: "projects/#{$project_id}/databases/(default)/benchmark/#{doc_path}",
    fields: Google::Cloud::Firestore::Convert.hash_to_fields(data),
    create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
    update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now)
  )
end

def new_doc_snp doc_grpc
  Google::Cloud::Firestore::DocumentSnapshot.from_document doc_grpc, $firestore, read_at: Time.now
end

def sort_array_inventory ary
  new_ary = ary.sort &($query_inventory.method(:query_comparison_proc))
  # Add the following make the sort more comparable to what inventory does
  new_order = Hash[new_ary.map(&:path).each_with_index.to_a]
  new_ary
end

$query_inventory = Google::Cloud::Firestore::Watch::Inventory.new $firestore, $query

array_inventory = nil
snapshot_inventory = nil
array_counter = 0
snapshot_counter = 0

# warm up the RBTree library
RBTree.new

$init_docs = Array.new(5000) do |i|
  new_doc_grpc "doc-#{i}", val: rand(25000)
end
GC.disable
Benchmark.bm(25) do |x|
  x.report('init 5k array:') do
    array_inventory = []
    array_inventory = $init_docs.map { |doc_grpc| new_doc_snp doc_grpc }
    array_inventory = sort_array_inventory(array_inventory)

    array_counter = $query_inventory.reset_comp_proc_counter!
  end
  x.report('init 5k inventory:') do
    $init_docs.each_slice(25) do |docs|
      docs.each { |doc_grpc| $query_inventory.add doc_grpc }
      $query_inventory.persist("", Time.now);
    end
    snapshot_inventory = $query_inventory.build_query_snapshot.docs

    snapshot_counter = $query_inventory.reset_comp_proc_counter!
  end
end
GC.enable
puts "Array comparisons: #{array_counter}"
puts "Inventory comparisons: #{snapshot_counter}"
raise "sorted docs no longer match" if array_inventory.map(&:document_id) != snapshot_inventory.map(&:document_id)
GC.disable
new_doc = new_doc_grpc("doc-add", val: rand(25000))

Benchmark.bm(25) do |x|
  x.report('insert 1 into array:') do
    array_inventory << new_doc_snp(new_doc)
    array_inventory = sort_array_inventory(array_inventory)

    array_counter = $query_inventory.reset_comp_proc_counter!
  end
  x.report('insert 1 into inventory:') do
    $query_inventory.add(new_doc)
    $query_inventory.persist("", Time.now)
    snapshot_inventory = $query_inventory.build_query_snapshot.docs

    snapshot_counter = $query_inventory.reset_comp_proc_counter!
  end
end
GC.enable
puts "Array comparisons: #{array_counter}"
puts "Inventory comparisons: #{snapshot_counter}"
raise "sorted docs no longer match" if array_inventory.map(&:document_id) != snapshot_inventory.map(&:document_id)
GC.disable
new_random_docs = Array.new(5) do |i|
  new_doc_grpc("doc2-#{i}", val: rand(25000))
end

Benchmark.bm(25) do |x|
  x.report('bulk insert 5 array:') do
    array_inventory += new_random_docs.map { |doc_grpc| new_doc_snp doc_grpc }
    array_inventory = sort_array_inventory(array_inventory)

    array_counter = $query_inventory.reset_comp_proc_counter!
  end
  x.report('bulk insert 5 inventory:') do
    new_random_docs.each do |new_random_doc|
      $query_inventory.add new_random_doc
    end
    $query_inventory.persist("", Time.now);
    snapshot_inventory = $query_inventory.build_query_snapshot.docs

    snapshot_counter = $query_inventory.reset_comp_proc_counter!
  end
end
GC.enable
puts "Array comparisons: #{array_counter}"
puts "Inventory comparisons: #{snapshot_counter}"
raise "sorted docs no longer match" if array_inventory.map(&:document_id) != snapshot_inventory.map(&:document_id)
GC.disable
new_random_docs = Array.new(50) do |i|
  new_doc_grpc("doc3-#{i}", val: rand(25000))
end

Benchmark.bm(25) do |x|
  x.report('bulk insert 50 array:') do
    array_inventory += new_random_docs.map { |doc_grpc| new_doc_snp doc_grpc }
    array_inventory = sort_array_inventory(array_inventory)

    array_counter = $query_inventory.reset_comp_proc_counter!
  end
  x.report('bulk insert 50 inventory:') do
    new_random_docs.each do |new_random_doc|
      $query_inventory.add new_random_doc
    end
    $query_inventory.persist("", Time.now);
    snapshot_inventory = $query_inventory.build_query_snapshot.docs

    snapshot_counter = $query_inventory.reset_comp_proc_counter!
  end
end
GC.enable
puts "Array comparisons: #{array_counter}"
puts "Inventory comparisons: #{snapshot_counter}"
raise "sorted docs no longer match" if array_inventory.map(&:document_id) != snapshot_inventory.map(&:document_id)
GC.disable
new_random_docs = Array.new(500) do |i|
  new_doc_grpc("doc4-#{i}", val: rand(25000))
end

Benchmark.bm(25) do |x|
  x.report('bulk insert 500 array:') do
    array_inventory += new_random_docs.map { |doc_grpc| new_doc_snp doc_grpc }
    array_inventory = sort_array_inventory(array_inventory)

    array_counter = $query_inventory.reset_comp_proc_counter!
  end
  x.report('bulk insert 500 inventory:') do
    new_random_docs.each do |new_random_doc|
      $query_inventory.add new_random_doc
    end
    $query_inventory.persist("", Time.now);
    snapshot_inventory = $query_inventory.build_query_snapshot.docs

    snapshot_counter = $query_inventory.reset_comp_proc_counter!
  end
end
GC.enable
puts "Array comparisons: #{array_counter}"
puts "Inventory comparisons: #{snapshot_counter}"
raise "sorted docs no longer match" if array_inventory.map(&:document_id) != snapshot_inventory.map(&:document_id)
GC.disable
Benchmark.bm(25) do |x|
  x.report('delete 1 from array:') do
    array_inventory.delete_at(array_inventory.find_index { |doc| doc.path == new_doc.name })
    # Don't need to re-sort when deleting
    # array_inventory = sort_array_inventory(array_inventory)

    array_counter = $query_inventory.reset_comp_proc_counter!
  end
  x.report('delete 1 from inventory:')  do
    $query_inventory.delete(new_doc.name)
    $query_inventory.persist("", Time.now)
    snapshot_inventory = $query_inventory.build_query_snapshot.docs

    snapshot_counter = $query_inventory.reset_comp_proc_counter!
  end
end
GC.enable
puts "Array comparisons: #{array_counter}"
puts "Inventory comparisons: #{snapshot_counter}"
raise "sorted docs no longer match" if array_inventory.map(&:document_id) != snapshot_inventory.map(&:document_id)
