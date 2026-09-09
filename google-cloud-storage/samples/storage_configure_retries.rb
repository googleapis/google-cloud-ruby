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

  # Creates a client
  storage = Google::Cloud::Storage.new(

    # The maximum number of automatic retries attempted before returning
    # the error.
    #
    # Customize retry configuration with the maximum retry attempt of 5.
    retries: 5,

    # The total time in seconds that requests are allowed to keep being retried.
    # After max_elapsed_time, an error will be returned regardless of any
    # retry attempts made during this time period.
    #
    # Customize retry configuration with maximum elapsed time of 500 seconds.
    max_elapsed_time: 500,

    # The initial interval between the completion of failed requests, and the
    # initiation of the subsequent retrying request.
    #
    # Customize retry configuration with an initial interval of 1.5 seconds.
    base_interval: 1.5,

    # The maximum interval between requests. When this value is reached,
    # multiplier will no longer be used to increase the interval.
    #
    # Customize retry configuration with maximum interval of 45.0 seconds.
    max_interval: 45,

    # The multiplier by which to increase the interval between the completion
    # of failed requests, and the initiation of the subsequent retrying request.
    #
    # Customize retry configuration with an interval multiplier per iteration of 1.2.
    multiplier: 1.2
  )

  # Uses the retry configuration set during the client initialization above with 5 retries
  file = storage.service.get_file bucket_name, file_name

  # Maximum retry attempt can be overridden for each operation using options parameter.
  storage.service.delete_file bucket_name, file_name, options: { retries: 4 }
  puts "File #{file.name} deleted with a customized retry strategy."
end
# [END storage_configure_retries]

if $PROGRAM_NAME == __FILE__
  configure_retries bucket_name: ARGV.shift,
                    file_name: ARGV.shift
end
