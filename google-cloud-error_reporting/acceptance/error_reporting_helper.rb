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
require "google/cloud/error_reporting"
require "grpc"

er_credentials = Google::Cloud::ErrorReporting::Credentials.default
$error_stats_vtk_client = Google::Cloud::ErrorReporting::V1beta1::ErrorStatsServiceClient.new credentials: er_credentials

module Acceptance
  class ErrorReportingTest < Minitest::Test
    ##
    # Setup shared client objects
    def setup
      @error_stats_vtk_client = $error_stats_vtk_client

      refute_nil @error_stats_vtk_client,
                 "You do not have an active error stats vtk client to run the tests."
    end

    def wait_until attempts=20
      delay = 2
      while delay <= attempts
        sleep delay
        result = yield
        return result if result
        delay += 1
      end
      nil
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :logging is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :error_reporting
    end
  end
end
