# Copyright 2016 Google Inc. All rights reserved.
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


require "google/cloud/speech/v1beta1"

module Google
  module Cloud
    module Speech
      ##
      # # Job
      #
      class Job
        ##
        # @private The Google::Longrunning::Operation gRPC object.
        attr_accessor :grpc

        ##
        # @private The gRPC Service object.
        attr_accessor :service

        ##
        # @private Creates a new Annotation instance.
        def initialize
          @grpc = nil
          @service = nil
        end

        def results
          return nil unless done?
          return nil unless @grpc.result == :response
          resp = V1beta1::AsyncRecognizeResponse.decode(@grpc.response.value)
          resp.results.map do |result_grpc|
            Result.from_grpc result_grpc
          end
          # TODO: Ensure we are raising the proper error
          # TODO: Ensure GRPC behavior here, is an error already raised?
          # raise @grpc.error
        end

        def done?
          @grpc.done
        end

        def reload!
          @grpc = @service.get_op @grpc.name
          self
        end
        alias_method :refresh!, :reload!

        def wait_until_done!
          backoff = ->(retries) { sleep 2 * retries + 5 }
          retries = 0
          until done?
            backoff.call retries
            retries += 1
            reload!
          end
        end

        ##
        # @private New Result::Job from a Google::Longrunning::Operation
        # object.
        def self.from_grpc grpc, service
          new.tap do |job|
            job.instance_variable_set :@grpc, grpc
            job.instance_variable_set :@service, service
          end
        end
      end
    end
  end
end
