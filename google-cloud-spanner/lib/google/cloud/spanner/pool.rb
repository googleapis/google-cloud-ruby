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


require "google/cloud/spanner/session"

module Google
  module Cloud
    module Spanner
      ##
      # @private
      #
      # # Pool
      #
      # Implements a pool for managing and reusing
      # {Google::Cloud::Spanner::Session} instances.
      #
      class Pool
        attr_accessor :min, :max, :pool, :queue

        def initialize client, min: 2, max: 10, keepalive: 1500
          @client = client
          @min = min
          @max = max
          @keepalive = keepalive
          @pool = []
          @queue = []

          # initialize pool and availability queue
          init
        end

        def with_session
          session = checkout
          yield session
          checkin session
        end

        def checkout
          if queue.empty?
            fail "No available sessions" if pool.size >= @max
            new_session!
          end
          queue.shift
        end

        def checkin session
          fail "Cannot checkin session" unless pool.include? session

          # Do we ever delete sessions if the queue is *too* full?
          queue.push session

          nil
        end

        def keepalive!
          ensure_keepalive_thread!

          # Call keep alive only on the queue, not all sessions.
          # If a session is checked out, we can assume its being used.
          queue.each(&:keepalive!)
        end

        def keepalive_and_sleep!
          ensure_keepalive_thread!

          keepalive!
          sleep @keepalive
        end

        def reset
          close
          init

          true
        end

        def close
          @thread.kill if @thread
          @pool.each(&:delete_session)
          @pool = []
          @queue = []

          true
        end

        private

        def init
          @pool = []
          @queue = []
          ensure_keepalive_thread!
          @min.times { new_session! }
        end

        def new_session!
          session = @client.create_new_session
          pool << session
          queue << session
          session
        end

        def ensure_keepalive_thread!
          @thread ||= Thread.new do
            # before calling keepalive
            sleep @keepalive
            loop do
              keepalive_and_sleep!
            end
          end
        end
      end
    end
  end
end
