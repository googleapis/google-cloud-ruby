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
require_relative "../storage_control_quickstart_sample"

describe "Storage Control Quickstart" do
  let(:bucket_name) { random_bucket_name }

  before :all do
    create_bucket_helper bucket_name
  end

  after do
    delete_bucket_helper bucket_name
  end

  it "Gets the storage layout" do
    layout_name = "projects/_/buckets/#{bucket_name}/storageLayout"

    assert_output "Performed get_storage_layout request for #{layout_name}\n" do
      retry_resource_exhaustion do
        quickstart bucket_name: bucket_name
      end
    end
  end
end
