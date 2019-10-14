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

require "google/cloud/recaptcha_enterprise"
require "google/cloud/recaptcha_enterprise/v1beta1/helpers"

require "google/cloud/recaptcha_enterprise/v1beta1/recaptcha_enterprise_client"

class HelperMockRecaptchaEnterpriseCredentials_v1beta1 < Google::Cloud::RecaptchaEnterprise::V1beta1::Credentials
  def initialize
  end

  def updater_proc
    proc do
      raise "The client was trying to make a grpc request. This should not " \
          "happen since the grpc layer is being mocked."
    end
  end
end

describe Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient do
  let(:mock_credentials) { HelperMockRecaptchaEnterpriseCredentials_v1beta1.new }

  describe "the assessment_path instance method" do
    it "correctly calls Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.assessment_path" do
      Google::Cloud::RecaptchaEnterprise::V1beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::RecaptchaEnterprise.new version: :v1beta1
        parameters = client.method("assessment_path").parameters.map { |arg| arg.last.to_s }
        assert_equal(
          client.assessment_path(*parameters),
          Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.assessment_path(*parameters)
        )
      end
    end
  end

  describe "the project_path instance method" do
    it "correctly calls Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.project_path" do
      Google::Cloud::RecaptchaEnterprise::V1beta1::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::RecaptchaEnterprise.new version: :v1beta1
        parameters = client.method("project_path").parameters.map { |arg| arg.last.to_s }
        assert_equal(
          client.project_path(*parameters),
          Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.project_path(*parameters)
        )
      end
    end
  end
end
