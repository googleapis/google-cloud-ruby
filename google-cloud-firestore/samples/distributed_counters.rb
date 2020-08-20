# Copyright 2020 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


def create_counter project_id:, num_shards:
  # [START fs_create_counter]
  # project_id = "Your Google Cloud Project ID"
  # num_shards = "Number of shards for distributed counter"

  require "google/cloud/firestore"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  shards_ref = firestore.col "shards"

  # Initialize each shard with count=0
  num_shards.times do |i|
    shards_ref.doc(i).set(count: 0)
  end

  puts "Distributed counter shards collection created."
  # [END fs_create_counter]
end

def increment_counter project_id:, num_shards:
  # [START fs_increment_counter]
  # project_id = "Your Google Cloud Project ID"
  # num_shards = "Number of shards for distributed counter"

  require "google/cloud/firestore"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  # Select a shard of the counter at random
  shard_id = rand 0..num_shards
  shard_ref = firestore.doc "shards/#{shard_id}"

  # increment counter
  shard_ref.update count: firestore.field_increment(1)

  puts "Counter incremented."
  # [END fs_increment_counter]
end

def get_count project_id:
  # [START fs_get_count]
  # project_id = "Your Google Cloud Project ID"

  require "google/cloud/firestore"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  shards_ref = firestore.col_group "shards"

  count = 0
  shards_ref.get do |doc_ref|
    count += doc_ref[:count]
  end

  puts "Count value is #{count}."
  # [END fs_get_count]
end

if $PROGRAM_NAME == __FILE__
  project = ENV["FIRESTORE_PROJECT_ID"]

  case ARGV.shift
  when "create_counter"
    create_counter project_id: project, num_shards: ARGV.shift.to_i
  when "increment_counter"
    increment_counter project_id: project, num_shards: ARGV.shift.to_i
  when "get_count"
    get_count project_id: project
  else
    puts <<~USAGE
      Usage: bundle exec ruby distributed_counters.rb [command] [arguments]

      Commands:
        create_counter <num_of_shards>    Create distributed counter.
        increment_counter <num_of_shards> Increment distributed counter.
        get_count                         Get value of distributed counter.

      Environment variables:
        FIRESTORE_PROJECT_ID must be set to your Google Cloud project ID
    USAGE
  end
end
