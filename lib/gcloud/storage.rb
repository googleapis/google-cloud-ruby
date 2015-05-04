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
require "gcloud/storage/project"

##
# Google Cloud Storage
module Gcloud
  ##
  # Create a new Storage project.
  #
  #   storage = Gcloud.storage "my-todo-project",
  #                            "/path/to/keyfile.json"
  #   bucket = storage.find_bucket "my-bucket"
  #   file = bucket.find_file "path/to/my-file.ext"
  #
  # @param project [String] the project identifier for the Storage
  # account you are connecting to.
  # @param keyfile [String] the path to the keyfile you downloaded from
  # Google Cloud. The file must readable.
  # @return [Gcloud::Storage::Project] storage project.
  #
  # See Gcloud::Storage::Project
  def self.storage project = nil, keyfile = nil
    project ||= Gcloud::Storage::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Storage::Credentials.default
    else
      credentials = Gcloud::Storage::Credentials.new keyfile
    end
    Gcloud::Storage::Project.new project, credentials
  end

  ##
  # Google Cloud Storage
  #
  #   storage = Gcloud.storage "my-todo-project",
  #                            "/path/to/keyfile.json"
  #   bucket = storage.find_bucket "my-bucket"
  #   file = bucket.find_file "path/to/my-file.ext"
  #
  # See Gcloud::Storage::Project
  module Storage
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
