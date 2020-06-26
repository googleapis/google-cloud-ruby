# Copyright 2020 Google LLC
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

require_relative "helper"
require_relative "../uptime_check"

describe "Monitoring uptime check" do
  before :all do
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    raise "Set the environment variable GOOGLE_CLOUD_PROJECT." if @project_id.nil?

    capture_io do
      @configs = [create_uptime_check_config(project_id: @project_id),
                  create_uptime_check_config(project_id: @project_id)]
    end
  end

  after :all do
    @configs.each do |config|
      capture_io do
        delete_uptime_check_config config.name
      end
    end
  end

  it "list_ips" do
    assert_output(/Singapore/) do
      list_ips
    end
  end

  it "list_uptime_checks" do
    assert_output(Regexp.new(@configs[0].name)) do
      list_uptime_check_configs @project_id
    end
  end

  it "update_uptime_checks" do
    update_uptime_check_config config_name: @configs[0].name, new_display_name: "Chicago"
    assert_output(/Chicago/) do
      get_uptime_check_config @configs[0].name
    end
    update_uptime_check_config config_name: @configs[1].name, new_http_check_path: "https://example.appspot.com/"
    assert_output(/example\.appspot\.com/) do
      get_uptime_check_config @configs[1].name
    end
  end
end
