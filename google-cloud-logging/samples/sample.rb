# Copyright 2021 Google LLC
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

def create_logging_client
  require "google/cloud/logging"

  logging = Google::Cloud::Logging.new

  puts "Created #{logging}"
  logging
end

def list_log_sinks
  # [START logging_list_sinks]
  require "google/cloud/logging"

  logging = Google::Cloud::Logging.new

  logging.sinks.each do |sink|
    puts "#{sink.name}: #{sink.filter} -> #{sink.destination}"
  end
  # [END logging_list_sinks]
end

def create_log_sink bucket_name:, sink_name:
  # [START logging_create_sink]
  require "google/cloud/logging"

  logging = Google::Cloud::Logging.new
  storage = Google::Cloud::Storage.new
  # bucket_name = "name-of-my-storage-bucket"
  bucket  = storage.create_bucket bucket_name

  # Grant owner permission to Cloud Logging service
  email = "cloud-logs@google.com"
  bucket.acl.add_owner "group-#{email}"

  # sink_name = "name-of-my-sink"
  sink = logging.create_sink sink_name, "storage.googleapis.com/#{bucket.id}"
  puts "#{sink.name}: #{sink.filter} -> #{sink.destination}"
  # [END logging_create_sink]
end

def update_log_sink bucket_name:, sink_name:
  # [START logging_update_sink]
  require "google/cloud/logging"

  logging = Google::Cloud::Logging.new
  storage = Google::Cloud::Storage.new
  # bucket_name = "name-of-my-storage-bucket"
  bucket  = storage.create_bucket bucket_name
  # sink_name = "name-of-my-sink"
  sink    = logging.sink sink_name

  sink.destination = "storage.googleapis.com/#{bucket.id}"

  sink.save
  puts "Updated sink destination for #{sink.name} to #{sink.destination}"
  # [END logging_update_sink]
end

def delete_log_sink sink_name:
  # [START logging_delete_sink]
  require "google/cloud/logging"

  logging = Google::Cloud::Logging.new

  # sink_name = "name-of-my-sink"
  sink = logging.sink sink_name
  sink.delete
  puts "Deleted sink: #{sink.name}"
  # [END logging_delete_sink]
end

def list_log_entries log_name:
  # [START logging_list_log_entries]
  require "google/cloud/logging"

  # log_name = "my_log_name"
  logging = Google::Cloud::Logging.new
  entries = logging.entries filter: "logName:#{log_name}",
                            max:    1000,
                            order:  "timestamp desc"

  entries.each do |entry|
    puts "[#{entry.timestamp}] #{entry.log_name} #{entry.payload.inspect}"
  end
  # [END logging_list_log_entries]
end

def write_log_entry log_name:, payload:
  # [START logging_write_log_entry]
  require "google/cloud/logging"

  logging = Google::Cloud::Logging.new

  entry = logging.entry
  # payload = "The data you want to log"
  entry.payload = payload
  # log_name = "The name of the log to write to"
  entry.log_name = log_name
  entry.severity = :NOTICE
  entry.resource.type = "gae_app"
  entry.resource.labels[:module_id] = "default"
  entry.resource.labels[:version_id] = "20160101t163030"

  logging.write_entries entry
  puts "Wrote payload: #{entry.payload} to log: #{entry.log_name}"
  # [END logging_write_log_entry]
end

def delete_log log_name:
  # [START logging_delete_log]
  require "google/cloud/logging"

  logging = Google::Cloud::Logging.new

  # log_name = "The name of the log"
  logging.delete_log log_name
  puts "Deleted log: #{log_name}"
  # [END logging_delete_log]
end

def write_log_entry_using_ruby_logger payload:, log_name:
  # [START logging_write_log_entry_using_ruby_logger]
  require "google/cloud/logging"

  logging  = Google::Cloud::Logging.new
  resource = logging.resource "gae_app", module_id:  "default",
                                         version_id: "20160101t163030"

  # log_name = "The name of the log"
  logger = logging.logger log_name, resource

  # payload = "Data to be logged"
  logger.info payload
  # [END logging_write_log_entry_using_ruby_logger]
end
