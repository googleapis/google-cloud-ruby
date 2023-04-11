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

CHECKSUM = ["md5", "crc32c", nil]
DEFAULT_MIN_SIZE = 5120 #5 KiB
DEFAULT_MAX_SIZE = 10 * 1024 # 2 GiB
DEFAULT_NUM_SAMPLES = 1000
DEFAULT_BUCKET_LOCATION = "US"
DEFAULT_API = "JSON"
DEFAULT_LIB_BUFFER_SIZE = 100 * 1024 * 1024 #TODO Add github link of upload_chunk_size
TIMESTAMP = Time.now.strftime("%Y%m%d-%H%M%S")
SUCCESS_STATUS = "OK"
FAILURE_STATUS = "FAIL"
NOT_SUPPORTED = -1

HEADER = [
  "Op",
  "ObjectSize",
  "AppBufferSize",
  "LibBufferSize",
  "Crc32cEnabled",
  "MD5Enabled",
  "ApiName",
  "ElapsedTimeUs",
  "CpuTimeUs",
  "Status",
  "RunID"
]

desc "Run performance benchmark"

flag :min_size, "--min-size=EVENT" do |f|
  f.default DEFAULT_MIN_SIZE
  f.accept Integer
  f.desc "Minimum object size in bytes."
end
flag :max_size, "--max-size=PATH" do |f|
  f.default DEFAULT_MAX_SIZE
  f.accept Integer
  f.desc "Maximum object size in bytes."
end
flag :num_samples, "--num_samples=COMMIT" do |f|
  f.default DEFAULT_NUM_SAMPLES
  f.accept Integer
  f.desc "Number of iterations."
end
flag :bucket_location, "--r=NAMES" do |f|
  f.accept Array
  f.default DEFAULT_BUCKET_LOCATION
  f.desc "Bucket location."
end
flag :output, "--o[=FILES]" do |f|
  f.accept String
  f.default "benchmarking#{TIMESTAMP}.csv"
  f.desc "File output results to."
end
flag :bucket_name, "--b=NAME" do |f|
  f.accept String
  f.default "benchmarking#{TIMESTAMP}"
  f.desc "Storage bucket name."
end

include :terminal, styled: true
include :bundler
include :fileutils

def run
  require "google/cloud/storage"
  require "securerandom"
  require "csv"
  
  # Create a storage bucket to run benchmarking
  storage = Google::Cloud::Storage.new
  @bucket = storage.bucket(bucket_name) rescue nil
  @bucket = storage.create_bucket(bucket_name, location: bucket_location) if @bucket.nil?

  @results = []
  (1..num_samples).each do |i|
    puts "Running W1R3 iteration number #{i}", :bold, :yellow
    w1r3_benchmark_runner
  end

  # Output to CSV file
  output_to_csv
  puts "Succesfully ran benchmarking. Please find your output log at #{output}", :bold, :cyan

  cleanup_resources
end

def w1r3_benchmark_runner
  puts "Generate Write-1-Read-3 workload.", :bold
  # generate random size in bytes using a uniform distribution
  size = rand(min_size..max_size)
  object_name = "#{TIMESTAMP}-#{SecureRandom.uuid}"

  # generate random checksumming type: md5, crc32c or None
  checksum = CHECKSUM.sample

  @results << log_performance("WRITE", size, checksum, write(object_name, size, checksum))

  (1..3).each do |i|
    @results << log_performance("READ[#{i}]", size, checksum, read(object_name, checksum))
  end
end

def write object_name, size, checksum
  puts "Perform an upload and return latency.", :bold, :blue
  object = @bucket.file object_name
  file_path = "#{Dir.getwd}/#{SecureRandom.uuid}"

  # Create random file locally on disk
  file = File.new(file_path, "wb+")
  file.write(SecureRandom.random_bytes(size))
  file.rewind

  start_time = get_time_in_ms
  @bucket.create_file file, object_name, checksum: checksum, if_generation_match: 0
  end_time = get_time_in_ms

  # convert nanoseconds to microseconds
  elapsed_time = (end_time - start_time).round

  # Clean up local file
  cleanup_file file_path
  elapsed_time
rescue Exception => e
  NOT_SUPPORTED
end

def read object_name, checksum
  puts "Perform a download and return latency.", :bold, :blue
  object = @bucket.file object_name
  unless object.exists?
    puts "Object does not exist. Previous write failed.", :bold, :red
    exit 1
  end

  file_path = "#{Dir.getwd}/#{object_name}"

  start_time = get_time_in_ms
  File.open(file_path, "wb") do |f|
    object.download file_path, verify: checksum
  end
  end_time = get_time_in_ms

  elapsed_time = (end_time - start_time).round

  # Clean up local file
  cleanup_file file_path
  elapsed_time
rescue Exception => e
  NOT_SUPPORTED
end

def log_performance operation, size, checksum, elapsed_time
  puts "Log latency and throughput output per operation call.", :bold
  # Holds benchmarking results for each operation
  res = [
    operation, #Op
    size, #ObjectSize
    NOT_SUPPORTED, #AppBufferSize
    DEFAULT_LIB_BUFFER_SIZE, #LibBufferSize
    checksum.eql?("crc32c"), #Crc32cEnabled
    checksum.eql?("md5"), #MD5Enabled
    DEFAULT_API, #ApiName
    elapsed_time, #ElapsedTimeUs
    NOT_SUPPORTED, #CpuTimeUs
    elapsed_time.eql?(NOT_SUPPORTED) ? FAILURE_STATUS : SUCCESS_STATUS, #Status
    TIMESTAMP #RunID
  ]
end

def output_to_csv
  CSV.open(output, "w") do |csv|
    csv << HEADER
    @results.each do |res|
      csv << res
    end
  end
end

def cleanup_file file_path
  puts "Clean up local file on disk.", :bold
  File.delete file_path
end

def cleanup_resources
  # Cleanup and delete bucket
  puts "Cleaning up resources", :bold, :blue
  files = @bucket.files rescue []
  files.each { |f| f.delete }
  @bucket.delete
rescue Exception => e
  puts "Caught an exception while deleting bucket: #{e}", :bold, :red
end

def get_time_in_ms
  Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
end

