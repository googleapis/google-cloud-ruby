# Copyright 2018 Google, Inc
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

require "minitest/autorun"
require "rack/test"
require "google/cloud/tasks/v2"
require_relative "../create_http_task.rb"
require "cgi"

describe "CloudTasks" do
  include Rack::Test::Methods

  before do
    GOOGLE_CLOUD_PROJECT = ENV["GOOGLE_CLOUD_PROJECT"]
    location_id          = ENV["LOCATION_ID"] || "us-east1"
    QUEUE_ID             = "my-queue".freeze

    client = Google::Cloud::Tasks::V2.new
    parent = client.queue_path GOOGLE_CLOUD_PROJECT, location_id, QUEUE_ID

    begin
      client.get_queue parent
    rescue StandardError
      location_id = "us-east4"
    end
    LOCATION_ID = location_id.freeze
  end

  it "can create an HTTP task" do

    out, err = capture_io do
      create_http_task GOOGLE_CLOUD_PROJECT, LOCATION_ID, QUEUE_ID, "http://example.com/taskhandler"
    end

    assert_match "Created task", out
  end
end
