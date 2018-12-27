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


require "google/cloud/error_reporting"



module Google
  module Cloud
    module ErrorReporting
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

def mock_error_reporting
  credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
  # Replace configure for the doc tests
  Google::Cloud::ErrorReporting.send :define_method, :configure do |*args|
    OpenStruct.new(credentials: credentials)
  end
  Google::Cloud::ErrorReporting.stub_new do |*args|
    error_reporting = Google::Cloud::ErrorReporting::Project.new(Google::Cloud::ErrorReporting::Service.new("my-project", credentials))

    error_reporting.service.mocked_error_reporting = Minitest::Mock.new

    yield error_reporting.service.mocked_error_reporting if block_given?

    error_reporting
  end
end

YARD::Doctest.configure do |doctest|
  ##
  # SKIP
  #

  # Skip all GAPIC for now
  doctest.skip "Google::Cloud::ErrorReporting::V1beta1::ErrorGroupServiceClient"
  doctest.skip "Google::Cloud::ErrorReporting::V1beta1::ErrorStatsServiceClient"
  doctest.skip "Google::Cloud::ErrorReporting::V1beta1::ReportErrorsServiceClient"

  ##
  # BEFORE (mocking)
  #

  doctest.before "Google::Cloud#error_reporting" do
    mock_error_reporting do |mock|
      mock.expect :report_error_event, nil, [String, Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
    end
  end

  doctest.before "Google::Cloud.error_reporting" do
    mock_error_reporting do |mock|
      mock.expect :report_error_event, nil, [String, Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
    end
  end

  doctest.before "Google::Cloud::ErrorReporting" do
    mock_error_reporting
  end

  doctest.before "Google::Cloud::ErrorReporting::ErrorEvent" do
    mock_error_reporting do |mock|
      mock.expect :report_error_event, nil, [String, Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
    end
  end

  doctest.before "Google::Cloud::ErrorReporting::Project" do
    mock_error_reporting do |mock|
      mock.expect :report_error_event, nil, [String, Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
    end
  end

  doctest.skip "Google::Cloud::ErrorReporting::Credentials" # occasionally getting "This code example is not yet mocked"

  doctest.before "Google::Cloud::ErrorReporting::Service" do
    mock_error_reporting do |mock|
      mock.expect :report_error_event, nil, [String, Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent]
    end
  end
end
