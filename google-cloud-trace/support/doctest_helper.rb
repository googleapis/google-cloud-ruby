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


require "google/cloud/trace"
require "minitest/rg"
require "active_record"

module Google
  module Cloud
    module Trace
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

def mock_trace
  Google::Cloud::Trace.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    trace = Google::Cloud::Trace::Project.new(Google::Cloud::Trace::Service.new("my-project", credentials))

    trace.service.mocked_lowlevel_client = Minitest::Mock.new

    yield trace.service.mocked_lowlevel_client if block_given?

    trace
  end
end

YARD::Doctest.configure do |doctest|
  ##
  # SKIP
  #

  # Skip all GAPIC for now
  doctest.skip "Google::Cloud::Trace::V1::TraceServiceClient"

  ##
  # BEFORE (mocking)
  #

  stubbed_page = OpenStruct.new next_page_token: nil
  stubbed_page.define_singleton_method :map do |&block|
    [].map &block
  end
  stubbed_list_traces = OpenStruct.new page: stubbed_page

  doctest.before "Google::Cloud#trace" do
    mock_trace do |mock|
      mock.expect :list_traces, stubbed_list_traces, [String, Hash]
    end
  end

  doctest.before "Google::Cloud.trace" do
    mock_trace do |mock|
      mock.expect :list_traces, stubbed_list_traces, [String, Hash]
    end
  end

  doctest.before "Google::Cloud::Trace" do
    mock_trace do |mock|
      mock.expect :list_traces, stubbed_list_traces, [String, Hash]
    end
  end

  doctest.skip "Google::Cloud::Trace::Credentials" # occasionally getting "This code example is not yet mocked"

  doctest.before "Google::Cloud::Trace::Project" do
    mock_trace do |mock|
      mock.expect :list_traces, stubbed_list_traces, [String, Hash]
    end
  end

  doctest.before "Google::Cloud::Trace::Project#get_trace" do
    mock_trace do |mock|
      mock.expect :get_trace, stubbed_list_traces, [String, String]
    end
  end

  doctest.before "Google::Cloud::Trace::Project#patch_traces" do
    mock_trace do |mock|
      mock.expect :patch_traces, stubbed_list_traces, [String, Google::Devtools::Cloudtrace::V1::Traces]
    end
  end

  doctest.before "Google::Cloud::Trace::LabelKey.set_stack_trace" do
    mock_trace
  end

  doctest.before "Google::Cloud::Trace::Notifications.instrument" do
    mocked_connection = Minitest::Mock.new
    mocked_connection.expect :execute, nil, [String]
    ActiveRecord::Base.define_singleton_method :connection do
      mocked_connection
    end
  end
end
