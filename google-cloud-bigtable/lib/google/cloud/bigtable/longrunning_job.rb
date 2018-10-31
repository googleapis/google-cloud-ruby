# frozen_string_literal: true

# Copyright 2018 Google LLC
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


module Google
  module Cloud
    module Bigtable
      # # LongrunningJob
      #
      # A resource representing the long-running, asynchronous processing operation.
      # The job can be refreshed to retrieve the result object once the operation has been completed.
      #
      # @see https://cloud.google.com/bigtable/docs/reference/admin/rpc/google.longrunning#google.longrunning.Operation
      #   Long-running Operation
      #
      class LongrunningJob
        # @private
        # The Google::Gax::Operation gRPC object.
        attr_accessor :grpc

        # @private
        # The gRPC Service object.
        attr_accessor :service

        # Get result object of the operation.
        #
        # @return [Object, nil]
        #   `nil` if the operation is not complete.
        #
        def results
          return nil unless done?
          return nil unless @grpc.grpc_op.result == :response
          @grpc.results
        end

        # Checks if the processing of the instance operation is complete.
        #
        # @return [boolean] `true` when complete, `false` otherwise.
        #
        def done?
          @grpc.done?
        end

        # Checks if the processing of the instance operation has errored.
        #
        # @return [boolean] `true` when errored, `false` otherwise.
        #
        def error?
          @grpc.error?
        end

        ##
        # The status when the operation associated with this job produced an
        # error.
        #
        # @return [Object, Google::Rpc::Status, nil] A status object with
        #   the status code and message, or `nil` if no error occurred.
        #
        def error
          return nil unless error?
          @grpc.error
        end

        # Reloads the job with current data from the long-running,
        # asynchronous processing of an operation.
        #
        # @return [Google::Cloud::Bigtable::Instance::Job] The same job instance.
        #
        def reload!
          @grpc.reload!
          self
        end

        # Reloads the job until the operation is complete. The delay between
        # reloads will incrementally increase.
        #
        def wait_until_done!
          @grpc.wait_until_done!
        end

        # @private
        # New BasicJob from a Google::Gax::Operation object.
        def self.from_grpc grpc, service
          new.tap do |job|
            job.grpc =  grpc
            job.service = service
          end
        end
      end
    end
  end
end
