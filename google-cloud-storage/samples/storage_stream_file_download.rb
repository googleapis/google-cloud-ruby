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

# Sample for storage_stream_file_download
class StorageStreamFileDownload
  def storage_stream_file_download bucket_name:, file_name:, local_file_obj:
    # [START storage_stream_file_download]
    # Downloads a blob to a stream or other file-like object.

    # The ID of your GCS bucket
    # bucket_name = "your-unique-bucket-name"

    # Name of a file in the Storage bucket
    # file_name   = "some_file.txt"

    # The stream or file (file-like object) to which the contents will be written
    # local_file_obj = StringIO.new

    require "google/cloud/storage"

    storage = Google::Cloud::Storage.new
    bucket  = storage.bucket bucket_name
    file    = bucket.file file_name

    file.download local_file_obj, verify: :none

    # rewind the object before starting to read the downloaded contents
    local_file_obj.rewind
    puts "The full downloaded file contents are: #{local_file_obj.read.inspect}"
    # [END storage_stream_file_download]
  end
end

if $PROGRAM_NAME == __FILE__
  StorageStreamFileDownload.new.storage_stream_file_download bucket_name: arguments.shift,
                                                             file_name: arguments.shift,
                                                             local_file_obj: arguments.shift
end
