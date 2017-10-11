# Copyright 2017, Google Inc. All rights reserved.
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


require "google/cloud/firestore/document/reference"
require "google/cloud/firestore/document/snapshot"

module Google
  module Cloud
    module Firestore
      ##
      # # Document
      #
      module Document
        ##
        # @private New Document::Reference object from a path.
        def self.from_path path, context
          Reference.new.tap do |r|
            r.context = context
            r.instance_variable_set :@path, path
          end
        end

        ##
        # @private New Document::Snapshot from a
        # Google::Firestore::V1beta1::BatchGetDocumentsResponse object.
        def self.from_batch_result result, context
          ref = nil
          grpc = nil
          if result.result == :found
            grpc = result.found
            ref = from_path grpc.name, context
          else
            ref = from_path result.missing, context
          end
          read_at = Convert.timestamp_to_time result.read_time

          Snapshot.new.tap do |s|
            s.grpc = grpc
            s.instance_variable_set :@ref, ref
            s.instance_variable_set :@read_at, read_at
          end
        end
      end
    end
  end
end
