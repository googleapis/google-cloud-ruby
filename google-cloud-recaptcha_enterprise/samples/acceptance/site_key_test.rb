# Copyright 2022 Google LLC
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

require_relative "../recaptcha_enterprise_create_site_key"
require_relative "../recaptcha_enterprise_delete_site_key"
require_relative "../recaptcha_enterprise_get_metrics_site_key"
require_relative "../recaptcha_enterprise_get_site_key"
require_relative "../recaptcha_enterprise_list_site_keys"
require_relative "../recaptcha_enterprise_update_site_key"
require "google/cloud/recaptcha_enterprise"
require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"

describe "Site key lifecycle" do
  let(:client) { ::Google::Cloud::RecaptchaEnterprise.recaptcha_enterprise_service }
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] }
  let(:site_keys) { @site_keys }

  before :all do
    @site_keys = []
  end

  after :all do
    @site_keys.each do |site_key|
      client.delete_key name: site_key
    end
  end

  def create_test_site_key
    create_key_request = {
      parent: "projects/#{project_id}",
      key: {
        display_name: "test_key",
        web_settings: {
          integration_type: 1,
          allowed_domains: ["localhost"],
          allow_amp_traffic: false
        }
      }
    }
    key = client.create_key create_key_request
    @site_keys.push key.name
    key
  end

  it "creates site key" do
    out, _err = capture_io do
      create_site_key project_id: project_id,
                      domain: "localhost"
    end
    assert_match(/reCAPTCHA Site key created successfully. Site Key:/, out)
    @site_keys.push "projects/#{project_id}/keys/#{out.split.last}"
  end

  it "updates site key" do
    site_key = create_test_site_key
    assert_output "reCAPTCHA Site key successfully updated with allow_amp_traffic to true!\n" do
      update_site_key project_id: project_id,
                      site_key: site_key.name.split("/").last,
                      domain: "localhost"
    end
  end

  it "lists site key" do
    response = client.list_keys parent: "projects/#{project_id}"
    expected_output = "Listing reCAPTCHA site keys: \n"
    response.each do |key|
      expected_output += "#{key.name}\n"
    end
    assert_output expected_output do
      list_site_keys project_id: project_id
    end
  end

  it "get site key" do
    site_key = create_test_site_key
    assert_output "Successfully obtained the key ! #{site_key.name}\n" do
      get_site_key project_id: project_id,
                   site_key: site_key.name.split("/").last
    end
  end

  it "get metrics for site key" do
    site_key = create_test_site_key

    out, _err = capture_io do
      get_metrics_site_key project_id: project_id,
                           site_key: site_key.name.split("/").last
    end

    assert_match "Retrieved the bucket count for score based key: #{site_key.name.split('/').last}\n", out
  end

  it "deletes site key" do
    site_key = create_test_site_key
    assert_output "reCAPTCHA Site key deleted successfully !\n" do
      delete_site_key project_id: project_id,
                      site_key: site_key.name.split("/").last
    end
    @site_keys.delete site_key.name
  end
end
