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
  # @example
  #   require "gcloud/upload"
  #
  #   # Set the default threshold to 10 MiB.
  #   Gcloud::Upload.resumable_threshold = 10_000_000
  #
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
    # Sets a new resumable threshold value in number of bytes.
    def self.resumable_threshold= new_resumable_threshold
      @@resumable_threshold = new_resumable_threshold.to_i
    end

    ##
    # Default chunk size used on resumable uploads.
    #
    # The default value is 10 MB (10,485,760 bytes).
    def self.default_chunk_size
      @@default_chunk_size
    end

    ##
    # Sets a new default chunk_size value in number of bytes. Must be a multiple
    # of 256KB (262,144).
    def self.default_chunk_size= new_chunk_size
      new_chunk_size = normalize_chunk_size new_chunk_size
      @@default_chunk_size = new_chunk_size if new_chunk_size
    end

    ##
    # @private Determines if a chunk_size is valid. Must be a multiple of 256KB.
    # Returns lowest possible chunk_size if given a very small value.
    def self.normalize_chunk_size chunk_size
      chunk_size = chunk_size.to_i
      chunk_mod = 256 * 1024 # 256KB
      if (chunk_size.to_i % chunk_mod) != 0
        chunk_size = (chunk_size / chunk_mod) * chunk_mod
      end
      return chunk_mod if chunk_size.zero?
      chunk_size
    end

    ##
    # @private Determines if a chunk_size is valid. Must be a multiple of 256KB.
    # Returns the default chunk_size if one is not provided.
    def self.verify_chunk_size chunk_size, file_size
      if chunk_size.to_i.zero?
        return nil if file_size < default_chunk_size
        return default_chunk_size
      else
        chunk_size = normalize_chunk_size chunk_size
        return nil if file_size < chunk_size
        return chunk_size
      end
    end

    # Set the default values for threshold and chunk_size.
    self.resumable_threshold = 5_000_000  # 5 MiB
    self.default_chunk_size  = 10_485_760 # 10 MB
  end
end
