# Copyright 2016 Google LLC
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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "google/cloud/logging"
require "grpc"

##
# Monkey-Patch CallOptions to support Mocks
class Google::Gax::CallOptions
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, CallOptions objects do not match with ===.
  # Therefore, we must add this capability.
  def === other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout === other.timeout &&
      retry_options === other.retry_options &&
      page_token === other.page_token &&
      kwargs === other.kwargs
  end
  def == other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout == other.timeout &&
      retry_options == other.retry_options &&
      page_token == other.page_token &&
      kwargs == other.kwargs
  end
end

class MockLogging < Minitest::Spec
  let(:project) { "test" }
  let(:default_options) { Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}" }) }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:logging) { Google::Cloud::Logging::Project.new(Google::Cloud::Logging::Service.new(project, credentials)) }

  # Register this spec type for when :mock_logging is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_logging
  end

  def token_options token
    Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}" },
                                 page_token: token)
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
        "env"  => "production",
        "foo"  => "bar"
      },
      "text_payload"    => "payload",
      "http_request"    => random_http_request_hash,
      "operation"       => random_operation_hash,
      "trace"           => "projects/my-projectid/traces/06796866738c859f2f19b7cfb3214824",
      "source_location" => random_source_location_hash,
      "trace_sampled"   => true
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

  def random_source_location_hash
    {
      "file" => "my_app/my_class.rb",
      "line" => 321,
      "function" => "#my_method"
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
        },
        {
         "key"          => "active",
         "value_type"   => :BOOL,
         "description"  => "Whether the database is active."
        },
        {
         "key"          => "max_connections",
         "value_type"   => :INT64,
         "description"  => "The maximum number of connections it supports."
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

  def project_path
    "projects/#{project}"
  end

  ##
  # Helper method to loop until block yields true or timeout.
  def wait_until_true timeout = 5
    begin_t = Time.now

    until yield
      return :timeout if Time.now - begin_t > timeout
      sleep 0.1
    end

    :completed
  end
end
