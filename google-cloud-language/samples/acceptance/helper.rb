# Copyright 2020 Google, LLC
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

require "google/cloud/errors"
require "google/cloud/storage"
require "minitest/autorun"
require "securerandom"

def create_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new

  retry_resource_exhaustion do
    return storage_client.create_bucket bucket_name
  end
end

def delete_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new

  retry_resource_exhaustion do
    bucket = storage_client.bucket bucket_name
    return unless bucket

    bucket.files.each(&:delete)
    bucket.delete
  end
end

def create_file_and_upload bucket_name, file_name, text_content
  storage_client = Google::Cloud::Storage.new
  bucket         = storage_client.bucket bucket_name
  return unless bucket

  local_file = Tempfile.new "language-sample-test-file"
  File.write local_file.path, text_content

  bucket.create_file local_file.path, file_name
ensure
  local_file.close
  local_file.unlink
end

def retry_resource_exhaustion
  5.times do
    begin
      yield
      return
    rescue Google::Cloud::ResourceExhaustedError => e
      puts "\n#{e} Gonna try again"
      sleep rand(1..3)
    rescue StandardError => e
      puts "\n#{e}"
      return
    end
  end
  raise Google::Cloud::ResourceExhaustedError("Maybe take a break from creating and deleting buckets for a bit")
end
