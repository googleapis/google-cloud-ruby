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

if ARGV.length < 1 || !ENV.has_key?('BIGQUERY_PROJECT')
  puts "usage: BIGQUERY_PROJECT=<project-id> ruby bench.rb <queries.json>"
  exit 1
end

bigquery = Google::Cloud::Bigquery.new(project: ENV['BIGQUERY_PROJECT']);
queries = JSON.parse(File.open(ARGV[0]).read)

for query in queries
  start = Time.now
  numRows = 0
  numCols = 0
  timeToFirstByte = nil

  data = bigquery.query query
  while 1
    data.each do |row|
      if numRows == 0
        numCols = row.length
        timeToFirstByte = Time.now - start
      elsif numCols != row.length
        raise "expected #{numCols} cols, got #{row.length}"
      end

      numRows += 1
    end

    if data.next?
      data = data.next
    else
      break
    end
  end

  puts "query #{query}: #{numRows} rows, #{numCols} cols, first byte #{timeToFirstByte} sec, total #{Time.now - start} sec"
end
