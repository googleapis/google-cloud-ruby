# Copyright 2014 Google Inc. All rights reserved.
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


require "gcloud"

module Gcloud
  ##
  # # Upload Settings
  #
  # Upload allows users to configure how files are uploaded to the Google Cloud
  # Service APIs.
  #
  #   require "gcloud/upload"
  #
  #   # Set the default threshold to 10 MiB.
  #   Gcloud::Upload.resumable_threshold = 10_000_000
  module Upload
    ##
    # Retrieve resumable threshold.
    # If uploads are larger in size than this value then
    # resumable uploads are used.
    #
    # The default value is 5 MiB (5,000,000 bytes).
    def self.resumable_threshold
      @@resumable_threshold
    end

    ##
    # Sets a new resumable threshold value.
    def self.resumable_threshold= new_resumable_threshold
      # rubocop:disable Style/ClassVars
      # Disabled rubocop because this is the best option.
      @@resumable_threshold = new_resumable_threshold.to_i
      # rubocop:enable Style/ClassVars
    end

    # Set the default threshold to 5 MiB.
    self.resumable_threshold = 5_000_000
  end
end
