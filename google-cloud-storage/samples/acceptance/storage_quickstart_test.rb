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
require_relative "../storage_quickstart.rb"

describe "Storage Quickstart" do
  let(:storage_client) { Google::Cloud::Storage.new }
  let(:bucket_name)    { random_bucket_name }

  after do
    delete_bucket_helper bucket_name
  end

  it "creates a new bucket" do
    assert_output "Bucket #{bucket_name} was created.\n" do
      retry_resource_exhaustion do
        quickstart bucket_name: bucket_name
      end
    end

    assert storage_client.bucket bucket_name
  end
end
