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
require "google/cloud/trace"
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

class MockTrace < Minitest::Spec
  MockFrame = ::Struct.new :absolute_path, :lineno, :label

  def stack_frame absolute_path, lineno, label
    MockFrame.new absolute_path, lineno, label
  end

  let(:project) { "test-project" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:tracer) { Google::Cloud::Trace::Project.new(Google::Cloud::Trace::Service.new(project, credentials)) }


  # Register this spec type for when :mock_trace is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_trace
  end

  def project_path
    "projects/#{project}"
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

class StringChild < ::String; end;
