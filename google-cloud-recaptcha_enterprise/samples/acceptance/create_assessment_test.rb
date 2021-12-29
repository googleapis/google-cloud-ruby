# Copyright 2021 Google LLC
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

require_relative "../recaptcha_enterprise_create_assessment"
require "google/cloud/recaptcha_enterprise"
require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"
require "selenium-webdriver"
require "webrick"

describe "Create Assessment" do
  let(:client) { ::Google::Cloud::RecaptchaEnterprise.recaptcha_enterprise_service }
  let(:template_file) { File.expand_path "data/test_template.html", __dir__ }
  let(:html_file) { File.expand_path "data/test.html", __dir__ }
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] }
  let(:server)  { @server }
  let(:driver)  { @driver }
  let(:pid)  { @pid }
  let(:key)  { @key }

  before :all do
    site_key = get_site_key
    update_html_with_site_key site_key
    serve_page_with_recaptcha
    @driver = Selenium::WebDriver.for :chrome
  end

  after :all do
    shutdown_server
    @driver.close
    File.delete html_file if File.exist? html_file
    client.delete_key name: @key.name
  end

  def get_site_key
    create_key_request = { parent: "projects/#{project_id}",
        key:
         { display_name: "test_key",
          web_settings: { integration_type: 1, allowed_domains: ["localhost"] } } }
    @key = client.create_key create_key_request
    @key.name.split("/").last
  end

  def update_html_with_site_key site_key
    text = File.read template_file
    content = text.gsub(/<site_key>/, site_key)
    File.open(html_file, "w") { |file| file << content }
  end

  def serve_page_with_recaptcha
    @server = WEBrick::HTTPServer.new Port: 8000, DocumentRoot: File.expand_path("data", __dir__)
    @pid = Process.fork do
      @server.start
    end
  end

  def shutdown_server
    @server.stop
    @server.shutdown
    Process.kill "KILL", @pid
    Process.wait2 @pid
  end

  it "gives score for assessment with valid token" do
    @driver.navigate.to "http://localhost:8000/test.html"
    sleep 2
    token = @driver.execute_script "return window.gcp_recaptcha_test_token"

    assert_output(/The reCAPTCHA score for this token is: \d/) do
      create_assessment site_key:  @key.name.split("/").last,
                        token: token,
                        project_id: project_id,
                        recaptcha_action: "homepage"
    end
  end

  it "gives error message for assessment with invalid token" do
    token = "random_token"

    assert_output "The create_assessment() call failed because the token was invalid with the following reason:" \
                  "MALFORMED\n" do
      create_assessment site_key:  @key.name.split("/").last,
                        token: token,
                        project_id: project_id,
                        recaptcha_action: "homepage"
    end
  end

  it "gives message for assessment with unmatched action" do
    @driver.navigate.to "http://localhost:8000/test.html"
    sleep 2
    token = @driver.execute_script "return window.gcp_recaptcha_test_token"

    assert_output "The action attribute in your reCAPTCHA tag does not match the action you are expecting to score\n" do
      create_assessment site_key:  @key.name.split("/").last,
                        token: token,
                        project_id: project_id,
                        recaptcha_action: "click"
    end
  end
end
