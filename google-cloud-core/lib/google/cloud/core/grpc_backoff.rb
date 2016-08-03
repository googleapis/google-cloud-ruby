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


module Google
  module Cloud
    module Core
      ##
      # @private
      # Backoff allows users to control how Google API calls are retried.
      # If an API call fails the response will be checked to see if the
      # call can be retried. If the response matches the criteria, then it
      # will be retried with an incremental backoff. This means that an
      # increasing delay will be added between each retried call. The first
      # retry will be delayed one second, the second retry will be delayed
      # two seconds, and so on.
      class GrpcBackoff
        class << self
          ##
          # The number of times a retriable API call should be retried.
          #
          # The default value is `3`.
          attr_reader :retries
          def retries= new_retries
            @retries = new_retries
          end

          ##
          # The GRPC Status Codes that should be retried.
          #
          # The default values are `14`.
          attr_accessor :grpc_codes

          ##
          # The code to run when a backoff is handled.
          # This must be a Proc and must take the number of
          # retries as an argument.
          #
          # Note: This method is undocumented and may change.
          attr_accessor :backoff # :nodoc:
        end
        # Set the default values
        self.retries = 3
        self.grpc_codes = [14]
        self.backoff = ->(retries) { sleep retries.to_i }

        ##
        # @private
        # Creates a new Backoff object to catch common errors when calling
        # the Google API and handle the error by retrying the call.
        #
        #   Google::Cloud::Core::GrpcBackoff.new(options).execute do
        #     datastore.lookup lookup_ref
        #   end
        def initialize options = {}
          @retries    = (options[:retries]    || GrpcBackoff.retries).to_i
          @grpc_codes = (options[:grpc_codes] || GrpcBackoff.grpc_codes).to_a
          @backoff    =  options[:backoff]    || GrpcBackoff.backoff
        end

        # @private
        def execute
          current_retries = 0
          loop do
            begin
              return yield
            rescue GRPC::BadStatus => e
              raise e unless @grpc_codes.include?(e.code) &&
                             (current_retries < @retries)
              current_retries += 1
              @backoff.call current_retries
            end
          end
        end
      end
    end
  end
end
