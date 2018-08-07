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
require "stackprof"

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

$query_inventory = Google::Cloud::Firestore::Watch::Inventory.new $firestore, $query

# warm up the RBTree library
RBTree.new

$init_docs = Array.new(5000) do |i|
  new_doc_grpc "doc-#{i}", val: rand(25000)
end

GC.disable

StackProf.run(mode: :cpu, out: "benchmark/watch_sort_perf.dump", interval: 10) do
  $init_docs.each_slice(25) do |docs|
    docs.each { |doc_grpc| $query_inventory.add doc_grpc }
    $query_inventory.persist("", Time.now);
  end
  $query_inventory.build_query_snapshot
end

GC.enable

puts `stackprof benchmark/watch_sort_perf.dump --text`
