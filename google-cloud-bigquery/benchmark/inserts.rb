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

require "google/cloud/bigquery"
require "benchmark"
require "securerandom"
require "time"
require "date"

if ARGV.length < 1
  puts "usage: BIGQUERY_PROJECT=<project-id> ruby benchmark/inserts.rb 2000"
  exit 1
end

def ensure_dataset bigquery
  dataset = bigquery.dataset "insert_bench"
  dataset ||= bigquery.create_dataset "insert_bench"
  dataset
end

def ensure_table dataset
  table = dataset.table "insert_table"
  table ||= dataset.create_table "insert_table" do |schema|
    schema.string "name"
    schema.integer "age"
    schema.float "score"
    schema.boolean "active"
    schema.bytes "avatar"
    schema.timestamp "started_at"
    schema.time "duration"
    schema.datetime "target_end"
    schema.date "birthday"
  end
  table
end

def random_row bigquery
  {
    name: SecureRandom.hex(rand(20..40)),
    age: rand(20..80),
    score: rand(0.0..100.0),
    active: rand(2).zero?,
    avatar: StringIO.new(SecureRandom.hex(rand(200..400))),
    started_at: Time.now - rand(1000),
    duration: bigquery.time(rand(24), rand(60), rand(60)),
    target_end: (Time.now - rand(1000)).to_datetime,
    birthday: Date.today - rand(1000..10000)
  }
end

bigquery = Google::Cloud::Bigquery.new
insert_count = Integer(ARGV[0] || 1000)
insert_rows = Array.new(insert_count) do |i|
  random_row bigquery
end
dataset = ensure_dataset bigquery
table = ensure_table dataset
inserter = table.insert_async max_rows: insert_count

puts "*"*56
puts "  Insert benchmark for #{insert_count} rows:"
puts "*"*56
puts ""

Benchmark.bm(10) do |x|
  x.report "direct:" do
    table.insert insert_rows
  end

  x.report "async:" do
    inserter.insert insert_rows
    inserter.stop.wait!
  end
end
