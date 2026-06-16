# Copyright 2026 Google LLC
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
require "signet/oauth_2/client"

describe Google::Cloud::ErrorReporting::Service do # rubocop:disable Metrics/BlockLength
  let(:project) { "test-project" }
  let :credentials do
    creds = Signet::OAuth2::Client.new
    def creds.quota_project_id
      "credentials-quota-project"
    end

    def creds.disable_universe_domain_check
      true
    end
    creds
  end

  describe ".new" do
    it "sets project and credentials" do
      service = Google::Cloud::ErrorReporting::Service.new project, credentials
      _(service.project).must_equal project
      _(service.credentials).must_equal credentials
    end

    it "accepts quota_project" do
      quota_project = "test-quota-project"
      service = Google::Cloud::ErrorReporting::Service.new project, credentials, quota_project: quota_project
      _(service.quota_project).must_equal quota_project
    end

    it "falls back to credentials quota_project_id if not explicitly passed" do
      service = Google::Cloud::ErrorReporting::Service.new project, credentials
      _(service.quota_project).must_equal "credentials-quota-project"
    end
  end

  describe "#error_reporting" do
    it "configures the gRPC client with quota_project" do
      quota_project = "test-quota-project"
      service = Google::Cloud::ErrorReporting::Service.new project, credentials, quota_project: quota_project

      client = service.error_reporting
      _(client.configure.quota_project).must_equal quota_project
    end

    it "configures the gRPC client with credentials quota_project" do
      service = Google::Cloud::ErrorReporting::Service.new project, credentials

      client = service.error_reporting
      _(client.configure.quota_project).must_equal "credentials-quota-project"
    end
  end
end
