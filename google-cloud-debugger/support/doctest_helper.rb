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


require "google/cloud/debugger"
require "minitest/rg"

module Google
  module Cloud
    module Debugger
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

def mock_debugger
  Google::Cloud::Debugger.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    debugger = Google::Cloud::Debugger::Project.new(
      Google::Cloud::Debugger::Service.new("my-project", credentials),
      service_name: nil, service_version: nil)

    debugger.service.mocked_debugger = Minitest::Mock.new
    debugger.service.mocked_transmitter = Minitest::Mock.new

    if block_given?
      yield debugger.service.mocked_debugger,
            debugger.service.mocked_transmitter
    end
    debugger
  end
end

YARD::Doctest.configure do |doctest|
  ##
  # SKIP
  #

  # Skip all GAPIC and GRPC classes
  doctest.skip "Google::Cloud::Debugger::V2::Controller2Client"
  doctest.skip "Google::Cloud::Debugger::V2::Debugger2Client"
  doctest.skip "Google::Devtools::Clouddebugger::V2"

  # Skip methods that work only during evaluation
  doctest.skip "Google::Cloud::Debugger.allow_mutating_methods!"

  # Skip all aliases
  doctest.skip "Google::Cloud::Debugger::Project#attach"

  doctest.before "Google::Cloud::Debugger.new" do
    mock_debugger
  end

  doctest.before "Google::Cloud#debugger" do
    mock_debugger
  end

  doctest.before "Google::Cloud.debugger" do
    mock_debugger
  end

  doctest.skip "Google::Cloud::Debugger::Credentials" # occasionally getting "This code example is not yet mocked"

  doctest.before "Google::Cloud::Debugger::Breakpoint::Variable.from_rb_var@Custom compound variable conversion" do
    class Foo
      def initialize a: nil, b: nil
        @a = a
        @b = b
      end

      def inspect
        "#<Foo:0xXXXXXX @a=#{@a}, @b=#{@b}>"
      end
    end
  end

  doctest.before "Google::Cloud::Debugger::Project" do
    mock_debugger
  end

  doctest.before "Google::Cloud::Debugger::Agent" do
    mock_debugger
  end
end
