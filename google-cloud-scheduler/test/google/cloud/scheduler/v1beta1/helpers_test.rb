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

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/scheduler"
require "google/cloud/scheduler/v1beta1/helpers"

require "google/cloud/scheduler/v1beta1/cloud_scheduler_client"

class MockSchedulerCredentials_v1beta1 < Google::Cloud::Scheduler::V1beta1::Credentials
  def initialize
  end

  def updater_proc
    proc do
      raise "The method was trying to make a grpc request. This should not " \
          "happen since the grpc layer is being mocked."
    end
  end
end

describe Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient do
  let(:mock_credentials) { MockSchedulerCredentials_v1beta1.new }

  describe "the location_path instance method" do
    it "correctly calls Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.location_path" do
      Google::Cloud::Scheduler::V1beta1::Credentials.stub(:default, mock_credentials) do
        num_args = Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.method("location_path").arity
        client = Google::Cloud::Scheduler.new version: :v1beta1
        args = (0...num_args).map { "argument" }
        assert_equal(
          client.location_path(*args),
          Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.location_path(*args)
        )
      end
    end
  end

  describe "the job_path instance method" do
    it "correctly calls Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.job_path" do
      Google::Cloud::Scheduler::V1beta1::Credentials.stub(:default, mock_credentials) do
        num_args = Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.method("job_path").arity
        client = Google::Cloud::Scheduler.new version: :v1beta1
        args = (0...num_args).map { "argument" }
        assert_equal(
          client.job_path(*args),
          Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.job_path(*args)
        )
      end
    end
  end

  describe "the project_path instance method" do
    it "correctly calls Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.project_path" do
      Google::Cloud::Scheduler::V1beta1::Credentials.stub(:default, mock_credentials) do
        num_args = Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.method("project_path").arity
        client = Google::Cloud::Scheduler.new version: :v1beta1
        args = (0...num_args).map { "argument" }
        assert_equal(
          client.project_path(*args),
          Google::Cloud::Scheduler::V1beta1::CloudSchedulerClient.project_path(*args)
        )
      end
    end
  end
end
