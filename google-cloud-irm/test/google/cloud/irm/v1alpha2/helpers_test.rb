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

require "google/cloud/irm"
require "google/cloud/irm/v1alpha2/helpers"

require "google/cloud/irm/v1alpha2/incident_service_client"

class HelperMockIrmCredentials_v1alpha2 < Google::Cloud::Irm::V1alpha2::Credentials
  def initialize
  end

  def updater_proc
    proc do
      raise "The client was trying to make a grpc request. This should not " \
          "happen since the grpc layer is being mocked."
    end
  end
end

describe Google::Cloud::Irm::V1alpha2::IncidentServiceClient do
  let(:mock_credentials) { HelperMockIrmCredentials_v1alpha2.new }

  describe "the annotation_path instance method" do
    it "correctly calls Google::Cloud::Irm::V1alpha2::IncidentServiceClient.annotation_path" do
      Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
        parameters = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.method("annotation_path").parameters.map { |arg| arg.last.to_s }
        client = Google::Cloud::Irm.new version: :v1alpha2
        assert_equal(
          client.annotation_path(*parameters),
          Google::Cloud::Irm::V1alpha2::IncidentServiceClient.annotation_path(*parameters)
        )
      end
    end
  end

  describe "the artifact_path instance method" do
    it "correctly calls Google::Cloud::Irm::V1alpha2::IncidentServiceClient.artifact_path" do
      Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
        parameters = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.method("artifact_path").parameters.map { |arg| arg.last.to_s }
        client = Google::Cloud::Irm.new version: :v1alpha2
        assert_equal(
          client.artifact_path(*parameters),
          Google::Cloud::Irm::V1alpha2::IncidentServiceClient.artifact_path(*parameters)
        )
      end
    end
  end

  describe "the incident_path instance method" do
    it "correctly calls Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path" do
      Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
        parameters = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.method("incident_path").parameters.map { |arg| arg.last.to_s }
        client = Google::Cloud::Irm.new version: :v1alpha2
        assert_equal(
          client.incident_path(*parameters),
          Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path(*parameters)
        )
      end
    end
  end

  describe "the project_path instance method" do
    it "correctly calls Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path" do
      Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
        parameters = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.method("project_path").parameters.map { |arg| arg.last.to_s }
        client = Google::Cloud::Irm.new version: :v1alpha2
        assert_equal(
          client.project_path(*parameters),
          Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path(*parameters)
        )
      end
    end
  end

  describe "the role_assignment_path instance method" do
    it "correctly calls Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path" do
      Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
        parameters = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.method("role_assignment_path").parameters.map { |arg| arg.last.to_s }
        client = Google::Cloud::Irm.new version: :v1alpha2
        assert_equal(
          client.role_assignment_path(*parameters),
          Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path(*parameters)
        )
      end
    end
  end

  describe "the signal_path instance method" do
    it "correctly calls Google::Cloud::Irm::V1alpha2::IncidentServiceClient.signal_path" do
      Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
        parameters = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.method("signal_path").parameters.map { |arg| arg.last.to_s }
        client = Google::Cloud::Irm.new version: :v1alpha2
        assert_equal(
          client.signal_path(*parameters),
          Google::Cloud::Irm::V1alpha2::IncidentServiceClient.signal_path(*parameters)
        )
      end
    end
  end

  describe "the subscription_path instance method" do
    it "correctly calls Google::Cloud::Irm::V1alpha2::IncidentServiceClient.subscription_path" do
      Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
        parameters = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.method("subscription_path").parameters.map { |arg| arg.last.to_s }
        client = Google::Cloud::Irm.new version: :v1alpha2
        assert_equal(
          client.subscription_path(*parameters),
          Google::Cloud::Irm::V1alpha2::IncidentServiceClient.subscription_path(*parameters)
        )
      end
    end
  end

  describe "the tag_path instance method" do
    it "correctly calls Google::Cloud::Irm::V1alpha2::IncidentServiceClient.tag_path" do
      Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
        parameters = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.method("tag_path").parameters.map { |arg| arg.last.to_s }
        client = Google::Cloud::Irm.new version: :v1alpha2
        assert_equal(
          client.tag_path(*parameters),
          Google::Cloud::Irm::V1alpha2::IncidentServiceClient.tag_path(*parameters)
        )
      end
    end
  end
end
