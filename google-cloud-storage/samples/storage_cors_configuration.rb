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

def cors_configuration bucket_name:
  # [START storage_cors_configuration]
  # bucket_name = "your-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  bucket.cors do |c|
    c.add_rule ["*"],
               ["PUT", "POST"],
               headers: [
                 "Content-Type",
                 "x-goog-resumable"
               ],
               max_age: 3600
  end

  puts "Set CORS policies for bucket #{bucket_name}"
  # [END storage_cors_configuration]
end

if $PROGRAM_NAME == __FILE__
  cors_configuration bucket_name: ARGV.shift
end
