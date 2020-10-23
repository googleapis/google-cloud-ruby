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

def list_files_with_prefix bucket_name:, prefix:, delimiter: nil
  # [START storage_list_files_with_prefix]
  # Lists all the files in the bucket that begin with the prefix.
  #
  # This can be used to list all files in a "folder", e.g. "public/".
  #
  # The delimiter argument can be used to restrict the results to only the
  # "files" in the given "folder". Without the delimiter, the entire tree under
  # the prefix is returned. For example, given these files:
  #
  #     a/1.txt
  #     a/b/2.txt
  #
  # If you just specify `prefix: "a"`, you will get back:
  #
  #     a/1.txt
  #     a/b/2.txt
  #
  # However, if you specify `prefix: "a"` and `delimiter: "/"`, you will get back:
  #
  #     a/1.txt

  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The directory prefix to search for
  # prefix = "a"

  # The delimiter to be used to restrict the results
  # delimiter = "/"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  files   = bucket.files prefix: prefix, delimiter: delimiter

  files.each do |file|
    puts file.name
  end
  # [END storage_list_files_with_prefix]
end

list_files_with_prefix bucket_name: ARGV.shift, prefix: ARGV.shift, delimiter: ARGV.shift if $PROGRAM_NAME == __FILE__
