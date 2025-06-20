# Copyright 2024 Google LLC
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
require_relative "../storage_control_create_anywhere_cache"
require 'pry'

describe "Storage Control Anywhere Cache" do
  let(:bucket_name) { random_bucket_name }
  let(:storage_client) { Google::Cloud::Storage.new }
  let(:project_name)   { storage_client.project }

  before :all do
     @bucket = create_bucket_helper bucket_name
  end

  after do
    delete_bucket_helper bucket_name
  end

  it "create Anywhere cache" do
    create_anywhere_cache bucket_name: bucket_name, project_name: project_name, zone: @bucket.location
  end
end
