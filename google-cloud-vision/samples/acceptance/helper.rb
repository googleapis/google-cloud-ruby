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

require "minitest/autorun"
require "minitest/focus"

require "google/cloud/vision"
require "google/cloud/vision/v1"

def storage_bucket_name
  ENV["GOOGLE_CLOUD_STORAGE_BUCKET"] || "ruby-vision-samples-test"
end

# Returns URL to sample image in the fixtures storage bucket
def gs_url filename
  "gs://#{storage_bucket_name}/#{filename}"
end

# Returns full path to sample image included in repository for testing
def image_path filename
  File.expand_path "../resources/#{filename}", __dir__
end
