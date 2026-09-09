# frozen_string_literal: true

# Copyright 2020 Google LLC
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
require "google/cloud/container_analysis/v1/container_analysis"

class ::Google::Cloud::ContainerAnalysis::V1::ContainerAnalysis::GrafeasTest < Minitest::Test
  class MockCredentials < Google::Cloud::ContainerAnalysis::V1::ContainerAnalysis::Credentials
    def initialize
    end

    def updater_proc
      proc do
        raise "Unexpected grpc request."
      end
    end

    def universe_domain
      "googleapis.com"
    end
  end

  def test_get_default_grafeas_client
    quota_project = "my-quota-project"
    creds = MockCredentials.new

    ca_client = Google::Cloud::ContainerAnalysis::V1::ContainerAnalysis::Client.new do |config|
      config.credentials = creds
      config.quota_project = quota_project
    end

    grafeas_client = ca_client.grafeas_client
    assert_kind_of Grafeas::V1::Grafeas::Client, grafeas_client
    assert_equal quota_project, grafeas_client.instance_variable_get(:@quota_project_id)

    grafeas_client_2 = ca_client.grafeas_client
    assert_same grafeas_client, grafeas_client_2
  end

  def test_get_custom_grafeas_client
    quota_project = "my-quota-project"
    quota_project_2 = "another-quota-project"
    creds = MockCredentials.new

    ca_client = Google::Cloud::ContainerAnalysis::V1::ContainerAnalysis::Client.new do |config|
      config.credentials = creds
      config.quota_project = "base-quota-project"
    end

    grafeas_client = ca_client.grafeas_client do |config|
      config.quota_project = quota_project
    end
    assert_kind_of Grafeas::V1::Grafeas::Client, grafeas_client
    assert_equal quota_project, grafeas_client.instance_variable_get(:@quota_project_id)

    grafeas_client_2 = ca_client.grafeas_client do |config|
      config.quota_project = quota_project_2
    end
    assert_kind_of Grafeas::V1::Grafeas::Client, grafeas_client_2
    assert_equal quota_project_2, grafeas_client_2.instance_variable_get(:@quota_project_id)
  end
end
