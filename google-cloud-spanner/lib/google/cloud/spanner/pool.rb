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
        attr_accessor :all_sessions, :session_queue, :transaction_queue

        def initialize client, min: 2, max: 10, keepalive: 1500,
                       write_ratio: 0.5
          @client = client
          @min = min
          @max = max
          @keepalive = keepalive
          @write_ratio = write_ratio
          @write_ratio = 0 if write_ratio < 0
          @write_ratio = 1 if write_ratio > 1

          # initialize pool and availability queue
          init
        end

        def with_session
          session = checkout_session
          begin
            yield session
          ensure
            checkin_session session
          end
        end

        def checkout_session
          read_session = session_queue.shift
          return read_session if read_session
          write_transaction = transaction_queue.shift
          return write_transaction.session if write_transaction

          fail "No available sessions" if all_sessions.size >= @max
          new_session!
        end

        def checkin_session session
          fail "Cannot checkin session" unless all_sessions.include? session

          # Do we ever delete sessions if the queue is *too* full?
          session_queue.push session

          nil
        end

        def with_transaction
          tx = checkout_transaction
          begin
            yield tx
          ensure
            checkin_transaction tx
          end
        end

        def checkout_transaction
          write_transaction = transaction_queue.shift
          return write_transaction if write_transaction
          read_session = session_queue.shift
          return read_session.create_transaction if read_session

          fail "No available sessions" if all_sessions.size >= @max
          new_transaction!
        end

        def checkin_transaction tx
          fail "Cannot checkin session" unless all_sessions.include? tx.session

          # Do we ever delete transactions if the queue is *too* full?
          # Push a *NEW* transaction to the queue...
          transaction_queue.push tx.session.create_transaction

          nil
        end

        def keepalive!
          ensure_keepalive_thread!

          # Call keep alive only on the queue, not all sessions or transactions.
          # If a session or transaction is checked out assume its being used.
          session_queue.each(&:keepalive!)
          transaction_queue.each(&:keepalive!)
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
          @all_sessions.each(&:delete_session)
          @all_sessions = []
          @session_queue = []
          @transaction_queue = []

          true
        end

        private

        def init
          @all_sessions = []
          @session_queue = []
          @transaction_queue = []
          ensure_keepalive_thread!
          # init session queue
          @min.times { session_queue << new_session! }
          # init transaction queue
          (@min * @write_ratio).round.times do
            transaction_queue << checkout_session.create_transaction
          end
        end

        def new_session!
          session = @client.create_new_session
          all_sessions << session
          session
        end

        def new_transaction!
          new_session!.create_transaction
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
