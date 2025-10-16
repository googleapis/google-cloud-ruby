# Copyright 2014 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "pathname"
require "digest/md5"
require "digest/crc32c"
require "google/cloud/storage/errors"

module Google
  module Cloud
    module Storage
      class File
        ##
        # @private
        # Verifies downloaded files by creating an MD5 or CRC32c hash digest
        # and comparing the value to the one from the Storage API.
        module Verifier
          def self.verify_md5! gcloud_file, local_file
            gcloud_digest = gcloud_file.md5
            local_digest = md5_for local_file
            return if gcloud_digest == local_digest
            raise FileVerificationError.for_md5(gcloud_digest, local_digest)
          end

          def self.verify_crc32c! gcloud_file, local_file
            gcloud_digest = gcloud_file.crc32c
            local_digest = crc32c_for local_file
            return if gcloud_digest == local_digest
            raise FileVerificationError.for_crc32c(gcloud_digest, local_digest)
          end

          def self.verify_md5 gcloud_file, local_file
            gcloud_file.md5 == md5_for(local_file)
          end

          def self.verify_crc32c gcloud_file, local_file
            gcloud_file.crc32c == crc32c_for(local_file)
          end
          # Calculates MD5 digest using either file path or open stream.
          def self.md5_for(local_file)
            _digest_for(local_file, ::Digest::MD5)
          end

          # Calculates CRC32c digest using either file path or open stream.
          def self.crc32c_for(local_file)
            _digest_for(local_file, ::Digest::CRC32c)
          end

          private

          # @private
          # Computes a base64-encoded digest for a local file or IO stream.
          #
          # This method handles two types of inputs for `local_file`:
          # 1. A file path (String or Pathname): It efficiently streams the file
          #    to compute the digest without loading the entire file into memory.
          # 2. An IO-like stream (e.g., File, StringIO): It reads the stream's
          #    content to compute the digest. The stream is rewound before and after
          #    reading to ensure its position is not permanently changed.
          #
          # @param local_file [String, Pathname, IO] The local file path or IO
          #   stream for which to compute the digest.
          # @param digest_class [Class] The digest class to use for the
          #   calculation (e.g., `Digest::MD5`). It must respond to `.file` and
          #   `.base64digest`.
          #
          # @return [String] The base64-encoded digest of the file's content.
          #
          def self._digest_for(local_file, digest_class)
            if local_file.respond_to?(:to_path)
              # Case 1: Input is a file path (or Pathname). Use the safe block form.
              ::File.open Pathname(local_file).to_path, "rb" do |f|
                digest_class.file(f).base64digest
              end
            else
              # Case 2: Input is an open stream (like File or StringIO).
              file_to_close = nil
              file_to_close = local_file = ::File.open(Pathname(local_file).to_path, "rb") unless local_file.respond_to?(:rewind)
              begin
                local_file.rewind
                digest = digest_class.base64digest local_file.read
                local_file.rewind
                digest
              ensure
                # Only close the stream if we explicitly opened it 
                file_to_close.close if file_to_close.respond_to?(:close) && !file_to_close.closed?
              end
            end
          end
        end
      end
    end
  end
end
