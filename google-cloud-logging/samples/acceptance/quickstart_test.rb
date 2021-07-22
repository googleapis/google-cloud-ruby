# Copyright 2020 Google, LLC
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

require_relative "helper"
require_relative "../quickstart"

describe "Logging Quickstart" do
  parallelize_me!

  let(:log_name) { "logging_samples_test_#{SecureRandom.hex}" }
  let(:payload) { "logging sample test payload" }

  after do
    logging.delete_log log_name
  end

  it "creates a new log entry" do
    assert_output "Logged #{payload}\n" do
      quickstart payload: payload, log_name: log_name
    end

    entries = get_entries_helper log_name
    assert_equal entries.first.payload, payload
  end
end
