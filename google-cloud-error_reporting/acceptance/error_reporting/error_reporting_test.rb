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


require "error_reporting_helper"

describe Google::Cloud::ErrorReporting, :error_reporting do
  describe "ErrorEvent" do
    let(:error_event1) {
      error_reporting.error_event(
        "test_script.rb:16:in `main': TEST ERROR (RuntimeError)\n" \
           "\tgenerate_error.rb:28:in `<main>'"
      )
    }
    let(:empty_error_event) { error_reporting.error_event ''}

    it "writes" do
      result = error_reporting.report error_event1

      result.to_h.must_be_empty
    end

    it "doesn't write if message is empty" do
      exception = assert_raises ArgumentError do
        error_reporting.report empty_error_event
      end

      exception.message.must_equal "Cannot report empty message"
    end
  end
end