# Copyright 2018 Google LLC
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

require "google/gax"

require "google/cloud/scheduler"
require "google/cloud/scheduler/v1/helpers"

require "google/cloud/scheduler/v1/cloud_scheduler_client"

class HelperMockSchedulerCredentials_v1 < Google::Cloud::Scheduler::V1::Credentials
  def initialize
  end

  def updater_proc
    proc do
      raise "The client was trying to make a grpc request. This should not " \
          "happen since the grpc layer is being mocked."
    end
  end
end

describe Google::Cloud::Scheduler::V1::CloudSchedulerClient do
  let(:mock_credentials) { HelperMockSchedulerCredentials_v1.new }

  describe "the job_path instance method" do
    it "correctly calls Google::Cloud::Scheduler::V1::CloudSchedulerClient.job_path" do
      Google::Cloud::Scheduler::V1::Credentials.stub(:default, mock_credentials) do
        parameters = Google::Cloud::Scheduler::V1::CloudSchedulerClient.method("job_path").parameters.map { |arg| arg.last.to_s }
        client = Google::Cloud::Scheduler.new version: :v1
        assert_equal(
          client.job_path(*parameters),
          Google::Cloud::Scheduler::V1::CloudSchedulerClient.job_path(*parameters)
        )
      end
    end
  end

  describe "the location_path instance method" do
    it "correctly calls Google::Cloud::Scheduler::V1::CloudSchedulerClient.location_path" do
      Google::Cloud::Scheduler::V1::Credentials.stub(:default, mock_credentials) do
        parameters = Google::Cloud::Scheduler::V1::CloudSchedulerClient.method("location_path").parameters.map { |arg| arg.last.to_s }
        client = Google::Cloud::Scheduler.new version: :v1
        assert_equal(
          client.location_path(*parameters),
          Google::Cloud::Scheduler::V1::CloudSchedulerClient.location_path(*parameters)
        )
      end
    end
  end

  describe "the project_path instance method" do
    it "correctly calls Google::Cloud::Scheduler::V1::CloudSchedulerClient.project_path" do
      Google::Cloud::Scheduler::V1::Credentials.stub(:default, mock_credentials) do
        parameters = Google::Cloud::Scheduler::V1::CloudSchedulerClient.method("project_path").parameters.map { |arg| arg.last.to_s }
        client = Google::Cloud::Scheduler.new version: :v1
        assert_equal(
          client.project_path(*parameters),
          Google::Cloud::Scheduler::V1::CloudSchedulerClient.project_path(*parameters)
        )
      end
    end
  end
end
