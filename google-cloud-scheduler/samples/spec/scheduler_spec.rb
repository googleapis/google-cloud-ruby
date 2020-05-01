# Copyright 2018 Google LLC
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

require_relative "../app"
require_relative "../create_job"
require_relative "../delete_job"
require "rspec"
require "rack/test"
require "google/cloud/scheduler"

describe "CloudScheduler", type: :feature do
  include Rack::Test::Methods

  before(:all) do
    GOOGLE_CLOUD_PROJECT = ENV["GOOGLE_CLOUD_PROJECT"]
    LOCATION_ID          = "us-east1"

    client = Google::Cloud::Scheduler.new
    location_path = "projects/#{GOOGLE_CLOUD_PROJECT}/locations/#{LOCATION_ID}"

    begin
      client.list_jobs(location_path)
    rescue
      LOCATION_ID = "us-east4"
    end
  end

  def app
    Sinatra::Application
  end

  it "returns Hello World" do
    get "/"
    expect(last_response.body).to include("Hello World!")
  end

  it "posts to /log_payload" do
    post "/log_payload", "Hello"
    expect(last_response.body).to include("Printed job payload")
  end
  
  it "can create and delete a job" do
    response = create_job(GOOGLE_CLOUD_PROJECT, LOCATION_ID, "my-service")
    expect(response).to include('projects/')

    job_name = response.split('/')[-1]

    expect {
      delete_job(GOOGLE_CLOUD_PROJECT, LOCATION_ID, job_name)
    }.to output(/Job deleted/).to_stdout
  end
end
