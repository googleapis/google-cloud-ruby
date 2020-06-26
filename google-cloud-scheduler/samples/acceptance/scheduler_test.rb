# frozen_string_literal: true

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../create_job"
require_relative "../delete_job"

require "minitest/autorun"
require "rack/test"
require "google/cloud/scheduler"

# Test the Cloud Scheduler sample calls.
class SchedulerSampleServerTest < Minitest::Test
  include Rack::Test::Methods

  parallelize_me!

  def setup
    @project = ENV["GOOGLE_CLOUD_PROJECT"]
    @location_id = ENV["LOCATION_ID"] || "us-central1"

    client = Google::Cloud::Scheduler.cloud_scheduler
    location_path = "projects/#{@project}/locations/#{@location_id}"

    begin
      client.list_jobs parent: location_path
    rescue Google::Cloud::Error
      @location_id = "us-east4"
    end
  end

  def test_create_and_delete_a_job
    response = create_job project_id: @project, location_id: @location_id, service_id: "my-service"
    assert_match "projects/", response

    job_name = response.split("/")[-1]

    assert_output(/Job deleted/) do
      delete_job project_id: @project, location_id: @location_id, job_name: job_name
    end
  end
end
