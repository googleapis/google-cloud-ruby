# Copyright 2017 Google LLC
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
require "google/cloud/error_reporting"

class MockErrorReporting < Minitest::Spec
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:error_reporting) {
    Google::Cloud::ErrorReporting::Project.new(
      Google::Cloud::ErrorReporting::Service.new(
        project, credentials
      )
    )
  }

  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_error_reporting
  end

  def random_error_event_hash
    timestamp = Time.parse "2014-10-02T15:01:23.045123456Z"
    {
      "event_time" => {
        "seconds" => timestamp.to_i,
        "nanos" => timestamp.nsec
      },
      "message" => "error message",
      "service_context" => random_service_context_hash,
      "context" => random_error_context_hash,
    }
  end

  def random_service_context_hash
    {
      "service" => "default",
      "version" => "v1"
    }
  end

  def random_error_context_hash
    {
      "user" => "testerson",
      "http_request" => random_http_request_context_hash,
      "report_location" => random_source_location_hash,
    }
  end

  def random_http_request_context_hash
    {
      "method" => "GET",
      "url" => "http://test.local/foo?bar=baz",
      "user_agent" => "google-cloud/1.0.0",
      "referrer" => "http://test/local/referrer",
      "response_status_code" => 200,
      "remote_ip" => "127.0.0.1",
    }
  end

  def random_source_location_hash
    {
      "file_path" => "/path/to/file.txt",
      "line_number" => 5,
      "function_name" => "testee"
    }
  end
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
