# Copyright 2016 Google Inc. All rights reserved.
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

require "google/cloud/storage"
require "google/cloud/logging"

# class File
#   def self.file? f
#     true
#   end
#   def self.readable? f
#     true
#   end
#   def self.read *args
#     "fake file data"
#   end
# end

module Google
  module Cloud
    module Storage
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
    end
    module Logging
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
      class Credentials
        # Override the default constructor
        def self.new *args
          OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
        end
      end
    end
    module Core
      module Environment
      # Create default unmocked methods that will raise if ever called
        def self.gce_vm? connection: nil
          raise "This code example is not yet mocked"
        end
        def self.get_metadata_attribute uri, attr_name, connection: nil
          raise "This code example is not yet mocked"
        end
      end
    end
  end
end

def mock_storage
  Google::Cloud::Storage.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    storage = Google::Cloud::Storage::Project.new(Google::Cloud::Storage::Service.new("my-todo-project", credentials))

    storage.service.mocked_service = Minitest::Mock.new

    yield storage.service.mocked_service if block_given?

    storage
  end
end

def mock_logging
  Google::Cloud::Logging.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    logging = Google::Cloud::Logging::Project.new(Google::Cloud::Logging::Service.new("my-project", credentials))

    logging.service.mocked_logging = Minitest::Mock.new
    logging.service.mocked_metrics = Minitest::Mock.new
    logging.service.mocked_sinks = Minitest::Mock.new

    if block_given?
      yield logging.service.mocked_logging,
            logging.service.mocked_metrics,
            logging.service.mocked_sinks
    end
    logging
  end
end

YARD::Doctest.configure do |doctest|
  ##
  # SKIP
  #

  # Skip all GAPIC for now
  doctest.skip "Google::Cloud::Logging::V2::LoggingServiceV2Client"
  doctest.skip "Google::Cloud::Logging::V2::MetricsServiceV2Client"
  doctest.skip "Google::Cloud::Logging::V2::ConfigServiceV2Client"  # Sinks

  # Skip all aliases, since tests would be exact duplicates
  doctest.skip "Google::Cloud::Logging::Logger#log"
  doctest.skip "Google::Cloud::Logging::Logger#sev_threshold="
  doctest.skip "Google::Cloud::Logging::Metric#refresh!"
  doctest.skip "Google::Cloud::Logging::Project#find_entries"
  doctest.skip "Google::Cloud::Logging::Project#new_entry"
  doctest.skip "Google::Cloud::Logging::Project#find_resource_descriptors"
  doctest.skip "Google::Cloud::Logging::Project#new_resource"
  doctest.skip "Google::Cloud::Logging::Project#find_sinks"
  doctest.skip "Google::Cloud::Logging::Project#new_sink"
  doctest.skip "Google::Cloud::Logging::Project#get_sink"
  doctest.skip "Google::Cloud::Logging::Project#find_sink"
  doctest.skip "Google::Cloud::Logging::Project#find_metrics"
  doctest.skip "Google::Cloud::Logging::Project#new_metric"
  doctest.skip "Google::Cloud::Logging::Project#get_metric"
  doctest.skip "Google::Cloud::Logging::Project#find_metric"
  doctest.skip "Google::Cloud::Logging::Project#find_logs"
  doctest.skip "Google::Cloud::Logging::Project#log_names"
  doctest.skip "Google::Cloud::Logging::Project#find_log_names"
  doctest.skip "Google::Cloud::Logging::Sink#start_time"
  doctest.skip "Google::Cloud::Logging::Sink#start_time="
  doctest.skip "Google::Cloud::Logging::Sink#end_time"
  doctest.skip "Google::Cloud::Logging::Sink#end_time="
  doctest.skip "Google::Cloud::Logging::Sink#refresh!"

  # Skip private methods
  doctest.skip "Google::Cloud::Logging::Middleware.default_monitored_resource"

  ##
  # BEFORE (mocking)
  #

  doctest.before "Google::Cloud.logging" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :list_log_entries, list_entries_res, [Array, Hash]
    end
  end

  doctest.before "Google::Cloud#logging" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :list_log_entries, list_entries_res, [Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :list_log_entries, list_entries_res, [Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging.new" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :list_log_entries, list_entries_res, [Array, Hash]
    end
  end

  doctest.skip "Google::Cloud::Logging::Credentials" # occasionally getting "This code example is not yet mocked"

  doctest.before "Google::Cloud::Logging::Project" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :list_log_entries, list_entries_res, [Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#entry" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :write_log_entries, nil, [Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#entries" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :list_log_entries, list_entries_res("next_page_token"), [Array, Hash]
      mock.expect :list_log_entries, list_entries_res, [Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#write_entries" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :write_log_entries, nil, [Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#entry" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :write_log_entries, nil, [Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#logs" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :list_logs, list_logs_res("next_page_token"), ["projects/my-project", Hash]
      mock.expect :list_logs, list_logs_res, ["projects/my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#delete_log" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :delete_log, nil, ["projects/my-project/logs/my_app_log", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#resource_descriptors" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_res, [Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#sink" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_sinks.expect :get_sink, nil, ["projects/my-project/sinks/existing-sink", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#sink@By default `nil` will be returned if the sink does not exist." do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_sinks.expect :get_sink, nil, ["projects/my-project/sinks/non-existing-sink", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#sinks" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_sinks.expect :list_sinks, list_sinks_res, ["projects/my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#create_metric" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_metrics.expect :create_log_metric, nil, ["projects/my-project", Google::Logging::V2::LogMetric, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#metric" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_metrics.expect :get_log_metric, nil, ["projects/my-project/metrics/existing_metric", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#metric@By default `nil` will be returned if metric does not exist." do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_metrics.expect :get_log_metric, nil, ["projects/my-project/metrics/non_existing_metric", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#metrics" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_metrics.expect :list_log_metrics, list_metrics_res, ["projects/my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Project#create_sink" do
    mock_storage do |mock|
      mock.expect :insert_bucket, bucket_gapi, ["my-todo-project", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :insert_bucket_access_control, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::BucketAccessControl, Hash]
    end
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_sinks.expect :create_sink, nil, ["projects/my-project", Google::Logging::V2::LogSink, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::ResourceDescriptor" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_res, [Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Sink" do
    mock_storage do |mock|
      mock.expect :insert_bucket, bucket_gapi, ["my-todo-project", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :insert_bucket_access_control, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::BucketAccessControl, Hash]
    end
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_sinks.expect :create_sink, nil, ["projects/my-project", Google::Logging::V2::LogSink, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Sink#delete" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_sinks.expect :get_sink, nil, ["projects/my-project/sinks/severe_errors", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Entry" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :write_log_entries, nil, [Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Entry::List" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :list_log_entries, list_entries_res, [Array, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Log::List" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock.expect :list_logs, list_logs_res, ["projects/my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Metric" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_metrics.expect :create_log_metric, nil, ["projects/my-project", Google::Logging::V2::LogMetric, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Metric#save" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_metrics.expect :get_log_metric, OpenStruct.new(name: "severe_errors"), ["projects/my-project/metrics/severe_errors", Hash]
      mock_metrics.expect :update_log_metric, nil, ["projects/my-project/metrics/severe_errors", Google::Logging::V2::LogMetric, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Metric#delete" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_metrics.expect :get_log_metric, OpenStruct.new(name: "severe_errors"), ["projects/my-project/metrics/severe_errors", Hash]
      mock_metrics.expect :delete_log_metric, nil, ["projects/my-project/metrics/severe_errors", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Metric#reload!" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_metrics.expect :get_log_metric, OpenStruct.new(name: "severe_errors", filter: "logName:syslog"), ["projects/my-project/metrics/severe_errors", Hash]
      mock_metrics.expect :get_log_metric, OpenStruct.new(filter: "logName:syslog"), ["projects/my-project/metrics/severe_errors", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Metric::List" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_metrics.expect :list_log_metrics, list_metrics_res, ["projects/my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Sink#save" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_sinks.expect :get_sink, OpenStruct.new(name: "severe_errors"), ["projects/my-project/sinks/severe_errors", Hash]
      mock_sinks.expect :update_sink, nil, ["projects/my-project/sinks/severe_errors", Google::Logging::V2::LogSink, Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Sink#delete" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_sinks.expect :get_sink, OpenStruct.new(name: "severe_errors"), ["projects/my-project/sinks/severe_errors", Hash]
      mock_sinks.expect :delete_sink, nil, ["projects/my-project/sinks/severe_errors", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Sink::List" do
    mock_logging do |mock, mock_metrics, mock_sinks|
      mock_sinks.expect :list_sinks, list_sinks_res, ["projects/my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::Logging::Middleware" do
    Google::Cloud.define_singleton_method :env do
      OpenStruct.new(:app_engine? => false, :container_engine? => false, :compute_engine? => false)
    end
  end

  doctest.before "Google::Cloud::Logging::Middleware.build_monitored_resource@If running from GAE, returns default resource" do
    Google::Cloud.define_singleton_method :env do
      OpenStruct.new(:app_engine? => true, :container_engine? => false, :compute_engine? => true)
    end
  end

  doctest.before "Google::Cloud::Logging::Middleware.build_monitored_resource@If running from GKE, returns default resource" do
    Google::Cloud.define_singleton_method :env do
      OpenStruct.new(:app_engine? => false, :container_engine? => true, :compute_engine? => true)
    end
  end

  doctest.before "Google::Cloud::Logging::Middleware.build_monitored_resource@If running from GCE, return default resource" do
    Google::Cloud.define_singleton_method :env do
      OpenStruct.new(:app_engine? => false, :container_engine? => false, :compute_engine? => true)
    end
  end
end

# Fixture helpers

def list_entries_res token = nil
  OpenStruct.new(
    page: OpenStruct.new(
      response: Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, token))
    )
  )
end

def list_logs_res token = nil
  OpenStruct.new(
    page: OpenStruct.new(
      response: Google::Logging::V2::ListLogsResponse.decode_json(list_logs_json(3, token))
    )
  )
end

def list_resource_descriptors_res
  Google::Logging::V2::ListMonitoredResourceDescriptorsResponse.decode_json(list_resource_descriptors_json(3))
end


def get_sink_res
  Google::Logging::V2::LogSink.decode_json(random_sink_hash.merge("name" => sink_name).to_json)
end

def list_sinks_res
  OpenStruct.new(
    page: OpenStruct.new(
      response: Google::Logging::V2::ListSinksResponse.decode_json(list_sinks_json(3))
    )
  )
end

def list_metrics_res
  OpenStruct.new(
    page: OpenStruct.new(
      response: Google::Logging::V2::ListLogMetricsResponse.decode_json(list_metrics_json(3))
    )
  )
end

def list_resource_descriptors_json count = 2, token = nil
  {
    resource_descriptors: count.times.map { random_resource_descriptor_hash },
    next_page_token: token
  }.delete_if { |_, v| v.nil? }.to_json
end

def list_metrics_json count = 2, token = nil
  {
    metrics: count.times.map { random_metric_hash },
    next_page_token: token
  }.delete_if { |_, v| v.nil? }.to_json
end

def list_entries_json count = 2, token = nil
  {
    entries: count.times.map { random_entry_hash },
    next_page_token: token
  }.delete_if { |_, v| v.nil? }.to_json
end

def random_entry_hash
  timestamp = Time.parse "2014-10-02T15:01:23.045123456Z"
  {
    "log_name"  => "projects/my-projectid/logs/syslog",
    "resource"  => random_resource_hash,
    "timestamp" => {
      "seconds" => timestamp.to_i,
      "nanos"   => timestamp.nsec
    },
    "severity"  => :DEFAULT,
    "insert_id" => "abc123",
    "labels" => {
      "env" => "production",
      "foo" => "bar"
    },
    "text_payload" => "payload",
    "http_request" => random_http_request_hash,
    "operation"    => random_operation_hash
  }
end

def random_http_request_hash
  {
    "request_method" => "GET",
    "request_url" => "http://test.local/foo?bar=baz",
    "request_size" => 123,
    "status" => 200,
    "response_size" => 456,
    "user_agent" => "google-cloud/1.0.0",
    "remote_ip" => "127.0.0.1",
    "referer" => "http://test.local/referer",
    "cache_hit" => false,
    "cache_validated_with_origin_server" => false
  }
end

def random_operation_hash
  {
    "id" => "xyz789",
    "producer" => "MyApp.MyClass#my_method",
    "first" => false,
    "last" => false
  }
end

def random_resource_hash
  {
    "type" => "gae_app",
    "labels" => {
      "module_id" => "1",
      "version_id" => "20150925t173233"
    }
  }
end

def random_resource_descriptor_hash
  {
    "type"         => "cloudsql_database",
    "display_name" => "Cloud SQL Database",
    "description"  => "This resource is a Cloud SQL Database",
    "labels"       => [
      {
       "key"          => "database_id",
       "description"  => "The ID of the database."
      },
      {
       "key"          => "zone",
       "value_type"   => :STRING,
       "description"  => "The GCP zone in which the database is running."
      }
    ]
  }
end

def random_sink_hash
  {
    "name"                  => "my-severe-errors-to-pubsub",
    "destination"           => "storage.googleapis.com/a-bucket",
    "filter"                => "logName:syslog AND severity>=ERROR",
    "output_version_format" => :VERSION_FORMAT_UNSPECIFIED,
    "writer_identity"       => "roles/owner",
    "start_time"            => { "seconds" => 1479920135, "nanos" => 711253000 }
  }
end

def random_metric_hash
  {
    "name"        => "severe_errors",
    "description" => "The servere errors metric",
    "filter"      => "logName:syslog AND severity>=ERROR"
  }
end

def list_sinks_json count = 2, token = nil
  {
    sinks: count.times.map { random_sink_hash },
    next_page_token: token
  }.delete_if { |_, v| v.nil? }.to_json
end

def list_logs_json count = 2, token = nil
  {
    log_names: count.times.map { "log-name" },
    next_page_token: token
  }.delete_if { |_, v| v.nil? }.to_json
end

# Storage helpers

def object_access_control_gapi
  entity = "project-owners-1234567890"
  Google::Apis::StorageV1::ObjectAccessControl.new entity: entity
end

def bucket_gapi name = "my-bucket"
  Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name).to_json
end

def random_bucket_hash(name = "my-bucket",
  url_root="https://www.googleapis.com/storage/v1", location="US",
  storage_class="STANDARD", versioning=nil, logging_bucket=nil,
  logging_prefix=nil, website_main=nil, website_404=nil)
  versioning_config = { "enabled" => versioning } if versioning
  { "kind" => "storage#bucket",
    "id" => name,
    "selfLink" => "#{url_root}/b/#{name}",
    "projectNumber" => "1234567890",
    "name" => name,
    "timeCreated" => Time.now,
    "metageneration" => "1",
    "owner" => { "entity" => "project-owners-1234567890" },
    "location" => location,
    "cors" => [{"origin"=>["http://example.org"], "method"=>["GET","POST","DELETE"], "responseHeader"=>["X-My-Custom-Header"], "maxAgeSeconds"=>3600},{"origin"=>["http://example.org"], "method"=>["GET","POST","DELETE"], "responseHeader"=>["X-My-Custom-Header"], "maxAgeSeconds"=>3600}],
    "logging" => logging_hash(logging_bucket, logging_prefix),
    "storageClass" => storage_class,
    "versioning" => versioning_config,
    "website" => website_hash(website_main, website_404),
    "etag" => "CAE=" }.delete_if { |_, v| v.nil? }
end

def logging_hash(bucket, prefix)
  { "logBucket"       => bucket,
    "logObjectPrefix" => prefix,
  }.delete_if { |_, v| v.nil? } if bucket || prefix
end

def website_hash(website_main, website_404)
  { "mainPageSuffix" => website_main,
    "notFoundPage"   => website_404,
  }.delete_if { |_, v| v.nil? } if website_main || website_404
end
