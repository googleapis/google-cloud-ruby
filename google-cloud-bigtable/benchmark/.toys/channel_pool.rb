# frozen_string_literal: true

# Copyright 2023 Google LLC
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

desc "Run channel pool benchmarking"

flag :instance_id, "--instance_id=INSTANCE_ID" do |f|
  f.default "temp-instance"
  f.accept String
  f.desc "Instance id of the bigtable"
end
flag :table_name, "--table_name=TABLE_NAME" do |f|
  f.default "table-1"
  f.accept String
  f.desc "Bigtable name"
end

include :terminal, styled: true
include :bundler
include :fileutils

def run

  require "google/cloud/bigtable"
  require "csv"
  require "concurrent"
  require 'securerandom'

  @bigtable_reader = Concurrent::ThreadPoolExecutor.new max_threads: 1000, max_queue: 0
  queries = 10000
  (1..50).each_with_index do |idx|
    total_time = 0
    samples = 1
    (1..samples).each do
      total_time += channel_pool_benchmark queries, idx
    end
    avg_time = (total_time/samples).round(3)
    puts "Successfully completed #{queries} using #{idx} channels with avg time of #{avg_time} seconds", :bold, :cyan
  end
end

def channel_pool_benchmark queries, channel_count
  @start_time = Time.now
  bigtable = Google::Cloud::Bigtable.new channel_count: channel_count
  table = bigtable.table instance_id, table_name, perform_lookup: true
  table.read_row SecureRandom.hex(4).to_s
  futures = []
  (1..queries).each do
    future = Concurrent::Promises.future_on @bigtable_reader, table do |table|
      table.read_row SecureRandom.hex(4).to_s
    end
    futures << future
  end
  futures.each do |future|
    future.wait!
  end
  @end_time = Time.now
  @total_time = (@end_time - @start_time).round(3)
  @total_time
end
