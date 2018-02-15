# Copyright 2017 Google LLC
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

require "spanner_helper"

describe "Spanner Instance Configs", :spanner do
  it "lists and gets instance configs" do
    all_configs = spanner.instance_configs.all.to_a
    all_configs.wont_be :empty?
    all_configs.each do |config|
      config.must_be_kind_of Google::Cloud::Spanner::Instance::Config
    end

    first_configs = spanner.instance_config all_configs.first.instance_config_id
    first_configs.must_be_kind_of Google::Cloud::Spanner::Instance::Config
  end
end
