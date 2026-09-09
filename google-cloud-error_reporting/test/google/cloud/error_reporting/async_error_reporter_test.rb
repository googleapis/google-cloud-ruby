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


require "helper"

describe Google::Cloud::ErrorReporting::AsyncErrorReporter, :mock_error_reporting do
  let(:mocked_error_reporting) { Minitest::Mock.new }
  let(:reporter) { Google::Cloud::ErrorReporting::AsyncErrorReporter.new mocked_error_reporting }

  before do
    reporter.on_error do |error|
      raise error.inspect
    end
  end

  it "reports a single error" do
    event = Object.new

    mocked_error_reporting.expect :report, nil, [event]

    reporter.report event
    reporter.stop! 10

    mocked_error_reporting.verify
  end

  it "reports multiple errors" do
    event1 = Object.new
    event2 = Object.new

    # Use class for report arguments, since they can be reported out of order
    mocked_error_reporting.expect :report, nil, [Object]
    mocked_error_reporting.expect :report, nil, [Object]

    reporter.report event1
    reporter.report event2
    reporter.stop! 10

    mocked_error_reporting.verify
  end
end
