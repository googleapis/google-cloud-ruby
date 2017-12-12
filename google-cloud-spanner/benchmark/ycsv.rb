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

# See usage at https://github.com/haih-g/YCSBClientCloudSpanner

# To make a package so it can work with PerfKitBenchmarker:
#   $ cd google-cloud-spanner; tar -cvzf ycsb-ruby.0.0.1.tar.gz benchmark/

require "google/cloud/spanner"
require "optparse"
require "set"
require "securerandom"

OPERATIONS = ["readproportion", "updateproportion", "scanproportion", "insertproportion"].to_set

command = ARGV.shift
if command != "run"
  puts "command not supported: #{command}"
  exit 1
end

options = {
  num_bucket: 1000
}
OptionParser.new do |opts|
  opts.on("-P", "--workload FILE", "path to YCSB workload file") do |fname|
    File.open(fname, "r") do |file|
      while (line = file.gets)
        pos = line.index("=")
        next if pos.nil? || !OPERATIONS.include?(line[0...pos])
        options[line[0...pos].strip.to_sym] = line[pos+1..-1].strip
      end
    end
  end
  opts.on("-p", "--parameter PARAM", "the key=value pair of parameter") do |p|
    pos = p.index("=")
    fail "require key=value format, found #{p}" if pos.nil?
    options[p[0...pos].to_sym] = p[pos+1..-1]
  end
  opts.on("-b", "--num_bucket BUCKET", "the number of buckets in output") do |b|
    options[:num_bucket] = b
  end
end.parse!

puts options

spanner = Google::Cloud::Spanner.new project: options[:"cloudspanner.project"]
database = spanner.client options[:"cloudspanner.instance"],
                          options[:"cloudspanner.database"]

# Load keys
keys = []
results = database.execute "SELECT u.id FROM #{options[:table]} u"
results.rows.each do |row|
  keys << row[0]
end

# Run workload
total_weight = 0.0
weights = []
operations = []
OPERATIONS.each do |op|
  weight = options[op.to_sym].to_f
  next if weight <= 0.0
  total_weight += weight
  op_code = op.split("proportion")[0]
  operations << op_code
  weights << total_weight
end

class Workload
  attr_reader :latencies_ms

  def initialize database, options, total_weight, weights, operations, keys
    @database = database
    @options = options
    @total_weight = total_weight
    @weights = weights
    @operations = operations
    @latencies_ms = {}
    @keys = keys
    operations.each do |op|
      @latencies_ms[op] = []
    end
  end

  def run
    i = 0
    operation_count = @options[:operationcount].to_i
    while i < operation_count
      i += 1
      weight = rand * @total_weight
      (0...@weights.count).each do |j|
        if weight <= @weights[j] then
          do_operation @database,
                       @options[:table],
                       @operations[j],
                       @latencies_ms
          break
        end
      end
    end
  end

  def do_operation(database, table, operation, latencies_ms)
    key = @keys[rand @keys.count]
    start = Time.now
    if operation == "read"
      do_read(database, table, key)
    elsif operation == "update"
      do_update(database, table, key)
    else
      fail "unsupported operation: #{operation}"
    end
    latencies_ms[operation] << (Time.now - start)*1000
  end

  def do_read database, table, key
    database.snapshot do |snp|
      results = snp.execute "SELECT u.* FROM #{table} u WHERE u.id=\"#{key}\""
      results.rows.each do |row|
        key = row[0]
        (1...10).each do |i|
          field = row[i]
        end
      end
    end
  end

  def do_update database, table, key
    field = rand 0...10
    value = SecureRandom.hex(100)
    database.commit do |c|
      c.update table, [{ "id" => key, "field#{field}" => value }]
    end
  end
end

start = Time.now
workload = Workload.new database,
                        options,
                        total_weight,
                        weights,
                        operations,
                        keys
workload.run
overall_duration = Time.now - start

overall_op_count = workload.latencies_ms.values.map { |l| l.count }.reduce(:+)

puts "[OVERALL], RunTime(ms), #{overall_duration*1000}"
puts "[OVERALL], Throughput(ops/sec), #{overall_op_count.to_f/overall_duration}"
workload.latencies_ms.keys.each do |op|
  latencies_ms = workload.latencies_ms[op].sort
  count = latencies_ms.count
  opup = op.upcase
  puts "[#{opup}], Operations, #{count}"
  puts "[#{opup}], AverageLatency(us), #{latencies_ms.reduce(:+)*1000/count}"
  puts "[#{opup}], MinLatency(us), #{latencies_ms.first*1000}"
  puts "[#{opup}], MaxLatency(us), #{latencies_ms.last*1000}"

  percentile = -> (pc) { latencies_ms[(latencies_ms.count*pc).round-1]*1000 }
  puts "[#{opup}], 95thPercentileLatency(us), #{percentile.call 0.95}"
  puts "[#{opup}], 99thPercentileLatency(us), #{percentile.call 0.99}"
  puts "[#{opup}], 99.9thPercentileLatency(us), #{percentile.call 0.999}"
  puts "[#{opup}], Return=OK, #{count}"
  (0...options[:num_bucket]).each do |j|
    hi = latencies_ms.bsearch_index { |l| l >= j+1 } || count
    lo = latencies_ms.bsearch_index { |l| l >= j } || count
    puts "[#{opup}], #{j}, #{hi - lo}"
  end
  lo = latencies_ms.bsearch_index { |l| l >= options[:num_bucket] } || count
  puts "[#{opup}], >#{options[:num_bucket]}, #{count - lo}"
end
