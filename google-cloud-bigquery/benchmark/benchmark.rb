# Copyright 2017 Google Inc. All rights reserved.
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

require "google/cloud/bigquery"
require "json"

if ARGV.length < 1
  puts "usage: BIGQUERY_PROJECT=<project-id> ruby benchmark/benchmark.rb <queries.json>"
  exit 1
end

bigquery = Google::Cloud::BigQuery.new
queries = JSON.parse(File.read(ARGV[0]))

queries.each do |query|
  start = Time.now
  num_rows = 0
  num_cols = 0
  time_to_first_byte = nil

  data = bigquery.query query
  loop do
    data.each do |row|
      if num_rows == 0
        num_cols = row.length
        time_to_first_byte = Time.now - start
      elsif num_cols != row.length
        fail "expected #{num_cols} cols, got #{row.length}"
      end

      num_rows += 1
    end

    if data.next?
      data = data.next
    else
      break
    end
  end

  puts "query #{query}: #{num_rows} rows, #{num_cols} cols, "\
    "first byte #{time_to_first_byte} sec, total #{Time.now - start} sec"
end
