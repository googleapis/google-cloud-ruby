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

describe "BigQuery Data Transfer Quickstart" do
  parallelize_me!

  it "lists data sources" do
    out, _err = capture_io do
      quickstart project_id: ENV["GOOGLE_CLOUD_PROJECT"]
    end

    assert_match "Supported Data Sources:", out
    assert_match "Data source: ", out
    assert_match "ID: ", out
    assert_match "Full path: ", out
    assert_match "Description: ", out
  end
end
