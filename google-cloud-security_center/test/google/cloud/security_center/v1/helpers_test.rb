# Copyright 2019 Google LLC
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

require "google/cloud/security_center"
require "google/cloud/security_center/v1/helpers"

require "google/cloud/security_center/v1/security_center_client"

class HelperMockSecurityCenterCredentials_v1 < Google::Cloud::SecurityCenter::V1::Credentials
  def initialize
  end

  def updater_proc
    proc do
      raise "The client was trying to make a grpc request. This should not " \
          "happen since the grpc layer is being mocked."
    end
  end
end

describe Google::Cloud::SecurityCenter::V1::SecurityCenterClient do
  let(:mock_credentials) { HelperMockSecurityCenterCredentials_v1.new }

  describe "the asset_path instance method" do
    it "correctly calls Google::Cloud::SecurityCenter::V1::SecurityCenterClient.asset_path" do
      Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::SecurityCenter.new version: :v1
        parameters = client.method("asset_path").parameters.map { |arg| arg.last.to_s }
        assert_equal(
          client.asset_path(*parameters),
          Google::Cloud::SecurityCenter::V1::SecurityCenterClient.asset_path(*parameters)
        )
      end
    end
  end

  describe "the asset_security_marks_path instance method" do
    it "correctly calls Google::Cloud::SecurityCenter::V1::SecurityCenterClient.asset_security_marks_path" do
      Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::SecurityCenter.new version: :v1
        parameters = client.method("asset_security_marks_path").parameters.map { |arg| arg.last.to_s }
        assert_equal(
          client.asset_security_marks_path(*parameters),
          Google::Cloud::SecurityCenter::V1::SecurityCenterClient.asset_security_marks_path(*parameters)
        )
      end
    end
  end

  describe "the finding_path instance method" do
    it "correctly calls Google::Cloud::SecurityCenter::V1::SecurityCenterClient.finding_path" do
      Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::SecurityCenter.new version: :v1
        parameters = client.method("finding_path").parameters.map { |arg| arg.last.to_s }
        assert_equal(
          client.finding_path(*parameters),
          Google::Cloud::SecurityCenter::V1::SecurityCenterClient.finding_path(*parameters)
        )
      end
    end
  end

  describe "the finding_security_marks_path instance method" do
    it "correctly calls Google::Cloud::SecurityCenter::V1::SecurityCenterClient.finding_security_marks_path" do
      Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::SecurityCenter.new version: :v1
        parameters = client.method("finding_security_marks_path").parameters.map { |arg| arg.last.to_s }
        assert_equal(
          client.finding_security_marks_path(*parameters),
          Google::Cloud::SecurityCenter::V1::SecurityCenterClient.finding_security_marks_path(*parameters)
        )
      end
    end
  end

  describe "the organization_path instance method" do
    it "correctly calls Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path" do
      Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::SecurityCenter.new version: :v1
        parameters = client.method("organization_path").parameters.map { |arg| arg.last.to_s }
        assert_equal(
          client.organization_path(*parameters),
          Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path(*parameters)
        )
      end
    end
  end

  describe "the organization_settings_path instance method" do
    it "correctly calls Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_settings_path" do
      Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::SecurityCenter.new version: :v1
        parameters = client.method("organization_settings_path").parameters.map { |arg| arg.last.to_s }
        assert_equal(
          client.organization_settings_path(*parameters),
          Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_settings_path(*parameters)
        )
      end
    end
  end

  describe "the organization_sources_path instance method" do
    it "correctly calls Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_sources_path" do
      Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::SecurityCenter.new version: :v1
        parameters = client.method("organization_sources_path").parameters.map { |arg| arg.last.to_s }
        assert_equal(
          client.organization_sources_path(*parameters),
          Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_sources_path(*parameters)
        )
      end
    end
  end

  describe "the source_path instance method" do
    it "correctly calls Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path" do
      Google::Cloud::SecurityCenter::V1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::SecurityCenter.new version: :v1
        parameters = client.method("source_path").parameters.map { |arg| arg.last.to_s }
        assert_equal(
          client.source_path(*parameters),
          Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path(*parameters)
        )
      end
    end
  end
end
