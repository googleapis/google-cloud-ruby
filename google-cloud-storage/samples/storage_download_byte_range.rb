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

# Sample for storage_download_byte_range
class StorageDownloadByteRange
  def storage_download_byte_range bucket_name:, file_name:, start_byte:, end_byte:, local_file_path:
    # [START storage_download_byte_range]
    # The ID of your GCS bucket
    # bucket_name = "your-unique-bucket-name"

    # file_name = "Name of a file in the Storage bucket"

    # The starting byte at which to begin the download
    # start_byte = 0

    # The ending byte at which to end the download
    # end_byte = 20

    # The path to which the file should be downloaded
    # local_file_path = "/local/path/to/file.txt"

    require "google/cloud/storage"

    storage = Google::Cloud::Storage.new
    bucket  = storage.bucket bucket_name
    file    = bucket.file file_name

    file.download local_file_path, range: start_byte..end_byte

    puts "Downloaded bytes #{start_byte} to #{end_byte} of object #{file_name} from bucket #{bucket_name}" \
         + " to local file #{local_file_path}."
    # [END storage_download_byte_range]
  end
end

if $PROGRAM_NAME == __FILE__
  StorageDownloadByteRange.new.storage_download_byte_range bucket_name: arguments.shift,
                                                           file_name: arguments.shift,
                                                           start_byte: arguments.shift,
                                                           end_byte: arguments.shift,
                                                           local_file_path: arguments.shift
end
