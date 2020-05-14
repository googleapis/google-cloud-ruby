# Copyright 2020 Google LLC
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
require "google/cloud/tasks"
require_relative "../create_http_task.rb"

describe "CloudTasks" do
  include Rack::Test::Methods

  before do
    @project    = ENV["GOOGLE_CLOUD_PROJECT"]
    location_id = ENV["LOCATION_ID"] || "us-central1"
    @queue_id   = "my-queue".freeze

    client = Google::Cloud::Tasks.cloud_tasks

    queue_name = client.queue_path(project:  @project,
                                   location: location_id,
                                   queue:    @queue_id)

    begin
      client.get_queue name: queue_name
    rescue StandardError
      location_id = "us-central1"
    end
    @location = location_id.freeze
  end

  it "can create an HTTP task" do
    out, _err = capture_io do
      create_http_task @project, @location, @queue_id, "http://example.com/taskhandler"
    end

    assert_match "Created task", out
  end
end
