# Copyright 2020 Google, LLC
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

require_relative "helper"
require_relative "../sample"

describe "Logging Samples" do
  parallelize_me!

  let(:rand_pre) { "logging_samples_test_" }
  let(:log_name) { "#{rand_pre}log_#{SecureRandom.hex}" }
  let(:payload) { "logging sample test payload" }
  let(:bucket_name) { "#{rand_pre}bucket_#{SecureRandom.hex}" }
  let(:bucket) { create_bucket_helper bucket_name }
  let(:sink_name) { "#{rand_pre}sink_#{SecureRandom.hex}" }
  let :sink do
    bucket.acl.add_owner "group-cloud-logs@google.com"
    logging.create_sink sink_name, "storage.googleapis.com/#{bucket.id}"
  end
  let :entry do
    log_entry = logging.entry
    log_entry.payload = payload
    log_entry.log_name = log_name
    log_entry.resource.type = "gae_app"
    logging.write_entries log_entry
    log_entry
  end

  describe "create_logging_client" do
    it "creates a logging client" do
      assert create_logging_client.is_a? logging.class
    end
  end

  describe "list_log_sinks" do
    after do
      logging.sink(sink_name).delete
      delete_bucket_helper bucket_name
    end

    it "lists the log sinks" do
      sink
      out, _err = capture_io do
        list_log_sinks
      end
      assert_includes out, sink_name
    end
  end

  describe "create_log_sink" do
    after do
      logging.sink(sink_name).delete
      delete_bucket_helper bucket_name
    end

    it "creates a log sink" do
      out, _err = capture_io do
        create_log_sink bucket_name: bucket_name, sink_name: sink_name
      end
      sinks = logging.sinks.map(&:name)
      assert_includes out, sink_name
      assert_includes sinks, sink_name
    end
  end

  describe "update_log_sink" do
    after do
      logging.sink(sink_name).delete
      delete_bucket_helper bucket_name
      delete_bucket_helper "#{bucket_name}_2"
    end

    it "changes the destination of a sink" do
      sink
      other_bucket_name = "#{bucket_name}_2"
      out, _err = capture_io do
        update_log_sink bucket_name: other_bucket_name, sink_name: sink_name
      end

      destination = "storage.googleapis.com/#{storage.bucket(other_bucket_name).id}"
      assert_equal out, "Updated sink destination for #{sink_name} to #{destination}\n"
      sink.reload!
      assert_equal sink.destination, destination
    end
  end

  describe "delete_log_sink" do
    after do
      delete_bucket_helper bucket_name
    end

    it "changes the destination of a sink" do
      assert_output "Deleted sink: #{sink.name}\n" do
        delete_log_sink sink_name: sink_name
      end

      refute_includes logging.sinks.map(&:name), sink_name
    end
  end

  describe "list_log_entries" do
    after do
      delete_log_helper log_name
    end

    it "lists entries of a log" do
      found = get_entries_helper entry.log_name
      # Try to reduce flakiness. We think the logging service is sometimes
      # taking a long time to index new logs.
      skip if found.empty?

      out, _err = capture_io do
        list_log_entries log_name: entry.log_name
      end
      entries = logging.entries filter: "logName:#{entry.log_name}",
                                max:    1000,
                                order:  "timestamp desc"
      entries.map! { |entry| "[#{entry.timestamp}] #{entry.log_name} #{entry.payload.inspect}" }
      out_entries = out.split "\n"
      assert(out_entries.any? { |entry| entries.include? entry })
    end
  end

  describe "write_log_entry" do
    after do
      delete_log_helper log_name
    end

    it "writes an entry to a log" do
      assert_output "Wrote payload: #{payload} to log: #{log_name}\n" do
        write_log_entry log_name: log_name, payload: payload
      end
      entries = get_entries_helper(log_name).map(&:payload)
      skip if entries.empty?
      assert_includes entries, payload
    end
  end


  describe "delete_log" do
    it "deletes a log" do
      entry
      found = get_entries_helper log_name
      skip if found.empty?
      assert_output "Deleted log: #{log_name}\n" do
        delete_log log_name: log_name
      end
      assert_empty get_entries_helper(log_name)
    end
  end

  describe "write_log_entry_using_ruby_logger" do
    after do
      delete_log_helper log_name
    end

    it "writes a log entry" do
      write_log_entry_using_ruby_logger payload: payload, log_name: log_name
      entries = get_entries_helper(log_name).map(&:payload)
      skip if entries.empty?
      assert_includes entries, payload
    end
  end
end
