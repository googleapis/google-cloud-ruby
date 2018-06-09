# frozen_string_literal: true

# Copyright 2017 Google LLC
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


require "thread"

module Google
  module Cloud
    module Pubsub
      class Subscriber
        # @private
        class EnumeratorQueue
          def initialize sentinel = nil
            @queue    = Queue.new
            @sentinel = sentinel
          end

          def push obj
            @queue.push obj
          end

          def quit_and_dump_queue
            objs = []
            objs << @queue.pop until @queue.empty?
            # Signal that the enumerator is ready to end
            @queue.push @sentinel
            objs
          end

          def each
            return enum_for(:each) unless block_given?

            loop do
              obj = @queue.pop
              break if obj.equal? @sentinel
              yield obj
            end
          end
        end
      end
    end
  end
end
