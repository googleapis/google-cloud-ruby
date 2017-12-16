# Copyright 2016 Google LLC
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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "google/cloud/resource_manager"

##
# Monkey-Patch Google API Client to support Mocks
module Google::Apis::Core::Hashable
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, the Google API Client objects do not match with ===.
  # Therefore, we must add this capability.
  # This module seems like as good a place as any...
  def === other
    return(to_h === other.to_h) if other.respond_to? :to_h
    super
  end
end

class MockResourceManager < Minitest::Spec
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:resource_manager) { Google::Cloud::ResourceManager::Manager.new(Google::Cloud::ResourceManager::Service.new(credentials)) }

  # Register this spec type for when :mock_res_man is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_res_man
  end

  def random_project_gapi seed = nil, name = nil, labels = nil
    seed ||= rand(9999)
    name ||= "Example Project #{seed}"
    labels = { "env" => "production" } if labels.nil?
    Google::Apis::CloudresourcemanagerV1::Project.new(
      project_number: "123456789#{seed}",
      project_id:     "example-project-#{seed}",
      name:           name,
      labels:         labels,
      create_time:    "2015-09-01T12:00:00.00Z",
      lifecycle_state: "ACTIVE")
  end
end
