# Copyright 2026 Google LLC
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

require "google/cloud/storage"

# [START storage_delete_object_contexts]
def delete_object_contexts bucket_name:, file_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The ID of your GCS object
  # file_name = "your-file-name"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  # To delete all custom contexts, set the object's contexts to nil.
  # This sends a null contexts value in the update request, which clears
  # every custom context on the object.
  #
  # Optional: set a metageneration-match precondition to avoid potential race
  # conditions and data corruptions. The request to update is aborted if the
  # object's metageneration does not match your precondition.
  file.update if_metageneration_match: file.metageneration do |file|
    file.contexts = nil
  end

  puts "Deleted object contexts for object #{file_name} in bucket #{bucket_name}."
end
# [END storage_delete_object_contexts]

if $PROGRAM_NAME == __FILE__
  delete_object_contexts bucket_name: ARGV.shift, file_name: ARGV.shift
end
