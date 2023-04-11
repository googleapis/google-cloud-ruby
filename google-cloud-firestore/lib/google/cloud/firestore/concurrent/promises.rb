# Copyright 2023 Google LLC
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
    module Firestore
      ##
      # @private
      module Promise
        class Future
          ##
          # Initialize the future object
          #
          def initialize future
            @future = future
          end

          # Is it in fulfilled state?
          #
          # @return [Boolean]
          def fulfilled?
            @future.fulfilled?
          end

          # Is it in rejected state?
          #
          # @return [Boolean]
          def rejected?
            @future.rejected?
          end

          ##
          # Method waits for the timeout duration and return the value of the future if
          # fulfilled, timeout value incase of timeout and nil incase of rejection.
          #
          # @param [Integer] timeout the maximum time in seconds to wait
          # @param [Object] timeout_value a value returned by the method when it times out
          # @return [Object, nil, timeout_value] the value of the Future when fulfilled,
          #  timeout_value on timeout, nil on rejection.
          def value timeout = nil, timeout_value = nil
            @future.value timeout, timeout_value
          end

          # Returns reason of future's rejection.
          #
          # @return [Object, timeout_value] the reason, or timeout_value on timeout, or nil on fulfillment.
          def reason timeout = nil, timeout_value = nil
            @future.reason timeout, timeout_value
          end

          ##
          # Method waits for the timeout duration and raise exception on rejection
          #
          # @param [Integer] timeout the maximum time in seconds to wait
          def wait! timeout = nil
            @future.wait! timeout
          end

          ##
          # Chains the task to be executed synchronously after it fulfills. Does not run
          # the task if it rejects. It will resolve though, triggering any dependent futures.
          #
          # @return [Future]
          # @yield [reason, *args] to the task.
          def then(*args, &task)
            new @future.then(*args, &task)
          end

          # Chains the task to be executed synchronously on executor after it rejects. Does
          # not run the task if it fulfills. It will resolve though, triggering any
          # dependent futures.
          #
          # @return [Future]
          # @yield [reason, *args] to the task.
          def rescue(*args, &task)
            new @future.rescue(*args, &task)
          end
        end
      end
    end
  end
end
