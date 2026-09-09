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

# Sample for storage_stream_file_upload
class StorageStreamFileUpload
  def storage_stream_file_upload bucket_name:, local_file_obj:, file_name:
    # [START storage_stream_file_upload]

    # The ID of your GCS bucket
    # bucket_name = "your-unique-bucket-name"

    # The stream or file (file-like object) from which to read
    # local_file_obj = StringIO.new "This is test data."

    # Name of a file in the Storage bucket
    # file_name   = "some_file.txt"

    require "google/cloud/storage"

    storage = Google::Cloud::Storage.new
    bucket  = storage.bucket bucket_name

    local_file_obj.rewind
    bucket.create_file local_file_obj, file_name

    puts "Stream data uploaded to #{file_name} in bucket #{bucket_name}"
    # [END storage_stream_file_upload]
  end
end

if $PROGRAM_NAME == __FILE__
  StorageStreamFileUpload.new.storage_stream_file_upload bucket_name: arguments.shift,
                                                         local_file_obj: arguments.shift,
                                                         file_name: arguments.shift
end
