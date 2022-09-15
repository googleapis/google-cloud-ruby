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

# [START storage_configure_retries]
def configure_retries bucket_name: nil, file_name: nil
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The ID of your GCS object
  # file_name = "your-file-name"

  require "google/cloud/storage"

  # Customize retry with the maximum retry attempt of 5 (default=3).
  # Customize retry with a deadline of 500 seconds (default=900 seconds).
  # Customize retry with an initial wait time of 1.5 (default=1.0).
  # Customize retry with a wait time multiplier per iteration of 1.2 (default=2.0).
  # Customize retry with a maximum wait time of 45.0 (default=60.0).
  storage = Google::Cloud::Storage.new(
    retries: 5,
    max_elapsed_time: 500,
    base_interval: 1.5,
    max_interval: 45,
    multiplier: 1.2
  )

  # Use the default retry configuration set during the client initialization above with 5 retries
  file = storage.service.get_file bucket_name, file_name

  # Maximum retry attempt can be overridden for each operation using options parameter.
  # We can disable the retry by setting the retries to 0.
  storage.service.delete_file bucket_name, file_name, options: { retries: 0 }
  puts "Deleted #{file.name} from bucket #{bucket_name}"
end
# [END storage_configure_retries]

if $PROGRAM_NAME == __FILE__
  configure_retries bucket_name: ARGV.shift,
                    file_name: ARGV.shift
end
