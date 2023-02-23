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

        class Event

          attr_reader :event

          # Creates a new `Event` in the unset state. Threads calling `#wait` on the
          # `Event` will block.
          def initialize event = nil
            @event = event || Concurrent::Event.new
          end

          # Is the object in the set state?
          #
          # @return [Boolean] indicating whether or not the `Event` has been set
          def set?
            @event.set?
          end

          # Trigger the event, setting the state to `set` and releasing all threads
          # waiting on the event. Has no effect if the `Event` has already been set.
          #
          # @return [Boolean] should always return `true`
          def set
            @event.set
          end

          def try?
            @event.try?
          end

          # Reset a previously set event back to the `unset` state.
          # Has no effect if the `Event` has not yet been set.
          #
          # @return [Boolean] should always return `true`
          def reset
            @event.reset
          end

          # Wait a given number of seconds for the `Event` to be set by another
          # thread. Will wait forever when no `timeout` value is given. Returns
          # immediately if the `Event` has already been set.
          #
          # @return [Boolean] true if the `Event` was set before timeout else false
          def wait timeout = nil
            @event.wait timeout
          end
        end
      end
    end
  end
end

