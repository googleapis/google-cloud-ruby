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

# Sample for storage_set_client_endpoint
class StorageSetClientEndpoint
  def set_client_endpoint api_endpoint:
    # [START storage_set_client_endpoint]
    # api_endpoint = "https://storage.googleapis.com"

    require "google/cloud/storage"

    storage = Google::Cloud::Storage.new(
      endpoint: api_endpoint
    )

    puts "Client initiated with endpoint #{storage.service.service.root_url}"
    # [END storage_set_client_endpoint]
  end
end

if $PROGRAM_NAME == __FILE__
  StorageSetClientEndpoint.new.set_client_endpoint api_endpoint: ARGV.shift
end
