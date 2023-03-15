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
      module Concurrent
        module Promise
          class Future
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
            #
            #
            # @return [Object, nil, timeout_value] the value of the Future when fulfilled,
            #   timeout_value on timeout,
            #   nil on rejection.
            def value timeout = nil, timeout_value = nil
              @future.value timeout, timeout_value
            end

            # Returns reason of future's rejection.
            #
            # @return [Object, timeout_value] the reason, or timeout_value on timeout, or nil on fulfillment.
            def reason timeout = nil, timeout_value = nil
              @future.reason timeout, timeout_value
            end

            # Returns triplet fulfilled?, value, reason.
            #
            # @return [Array(Boolean, Object, Object), nil] triplet of fulfilled?, value, reason, or nil
            #   on timeout.
            def result(timeout = nil)
              internal_state.result if wait_until_resolved timeout
            end

            # @!macro promises.method.wait
            # @raise [Exception] {#reason} on rejection
            def wait! timeout = nil
              @future.wait! timeout
            end

            ##
            #
            # @return [Object, nil, timeout_value] the value of the Future when fulfilled,
            #   or nil on rejection,
            #   or timeout_value on timeout.
            # @raise [Exception] {#reason} on rejection
            def value!(timeout = nil, timeout_value = nil)
              @future.value! timeout, timeout_value
            end

            # Allows rejected Future to be risen with `raise` method.
            # If the reason is not an exception `Runtime.new(reason)` is returned.
            #
            # @example
            #   raise Promises.rejected_future(StandardError.new("boom"))
            #   raise Promises.rejected_future("or just boom")
            # @raise [Concurrent::Error] when raising not rejected future
            # @return [Exception]
            def exception(*args)
              raise Concurrent::Error, 'it is not rejected' unless rejected?
              raise ArgumentError unless args.size <= 1
              reason = Array(internal_state.reason).flatten.compact
              if reason.size > 1
                ex = Concurrent::MultipleErrors.new reason
                ex.set_backtrace(caller)
                ex
              else
                ex = if reason[0].respond_to? :exception
                       reason[0].exception(*args)
                     else
                       RuntimeError.new(reason[0]).exception(*args)
                     end
                ex.set_backtrace Array(ex.backtrace) + caller
                ex
              end
            end

            # @!macro promises.shortcut.on
            # @return [Future]
            def then(*args, &task)
              new @future.then(*args, &task)
            end

            ##
            # Chains the task to be executed asynchronously on executor after it fulfills. Does not run
            # the task if it rejects. It will resolve though, triggering any dependent futures.
            #
            # @return [Future]
            # @yield [value, *args] to the task.
            def then_on(executor, *args, &task)
              new @future.then_on(executor, *args, &task)
            end

          end
end
      end
    end
  end
end
