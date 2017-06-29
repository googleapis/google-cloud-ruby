# Copyright 2017 Google Inc. All rights reserved.
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


require "forwardable"

module Google
  module Cloud
    module Pubsub
      ##
      # # Subscriber
      #
      class Subscriber
        # @private
        class EnumeratorQueue
          extend Forwardable
          def_delegators :@q, :push

          # @private
          def initialize sentinel
            @q = Queue.new
            @sentinel = sentinel
          end

          def unshift request
            new_queue = Queue.new
            new_queue.push request
            while @q.size > 0
              r = @q.pop
              new_queue.push r unless r.equal? @sentinel
            end
            @q = new_queue
          end

          # @private
          def each_item
            return enum_for(:each_item) unless block_given?
            loop do
              r = @q.pop
              break if r.equal? @sentinel
              fail r if r.is_a? Exception
              yield r
            end
          end
        end
      end
    end
  end
end
