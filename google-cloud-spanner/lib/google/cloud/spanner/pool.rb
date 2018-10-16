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


require "concurrent"
require "google/cloud/spanner/errors"
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

        def initialize client, min: 10, max: 100, keepalive: 1800,
                       write_ratio: 0.3, fail: true, threads: nil
          @client = client
          @min = min
          @max = max
          @keepalive = keepalive
          @write_ratio = write_ratio
          @write_ratio = 0 if write_ratio < 0
          @write_ratio = 1 if write_ratio > 1
          @fail = fail
          @threads = threads || [2, Concurrent.processor_count * 2].max

          @mutex = Mutex.new
          @resource = ConditionVariable.new

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
          action = nil
          @mutex.synchronize do
            loop do
              raise ClientClosedError if @closed

              read_session = session_queue.shift
              return read_session if read_session
              write_transaction = transaction_queue.shift
              return write_transaction.session if write_transaction

              if can_allocate_more_sessions?
                @new_sessions_in_process += 1
                action = :new
                break
              end

              raise SessionLimitError if @fail

              @resource.wait @mutex
            end
          end

          return new_session! if action == :new
        end

        def checkin_session session
          @mutex.synchronize do
            unless all_sessions.include? session
              raise ArgumentError, "Cannot checkin session"
            end

            session_queue.push session

            @resource.signal
          end

          nil
        end

        def with_transaction
          tx = checkout_transaction
          begin
            yield tx
          ensure
            future do
              # Create and checkin a new transaction
              tx = tx.session.create_transaction
              checkin_transaction tx
            end
          end
        end

        def checkout_transaction
          action = nil
          @mutex.synchronize do
            loop do
              raise ClientClosedError if @closed

              write_transaction = transaction_queue.shift
              return write_transaction if write_transaction
              read_session = session_queue.shift
              if read_session
                action = read_session
                break
              end

              if can_allocate_more_sessions?
                @new_sessions_in_process += 1
                action = :new
                break
              end

              raise SessionLimitError if @fail

              @resource.wait @mutex
            end
          end
          if action.is_a? Google::Cloud::Spanner::Session
            return action.create_transaction
          end
          return new_transaction! if action == :new
        end

        def checkin_transaction tx
          @mutex.synchronize do
            unless all_sessions.include? tx.session
              raise ArgumentError, "Cannot checkin session"
            end

            transaction_queue.push tx

            @resource.signal
          end

          nil
        end

        def reset
          close
          init

          true
        end

        def close
          @mutex.synchronize do
            @closed = true
          end
          @keepalive_task.shutdown
          # Unblock all waiting threads
          @resource.broadcast
          # Delete all sessions
          @mutex.synchronize do
            @all_sessions.each { |s| future { s.release! } }
            @all_sessions = []
            @session_queue = []
            @transaction_queue = []
          end
          # shutdown existing thread pool
          @thread_pool.shutdown

          true
        end

        def keepalive_or_release!
          to_keepalive = []
          to_release = []

          @mutex.synchronize do
            available_count = session_queue.count + transaction_queue.count
            release_count = @min - available_count
            release_count = 0 if release_count < 0

            to_keepalive += (session_queue + transaction_queue).select do |x|
              x.idle_since? @keepalive
            end

            # Remove a random portion of the sessions and transactions
            to_release = to_keepalive.sample release_count
            to_keepalive -= to_release

            # Remove those to be released from circulation
            @all_sessions -= to_release.map(&:session)
            @session_queue -= to_release
            @transaction_queue -= to_release
          end

          to_release.each { |x| future { x.release! } }
          to_keepalive.each { |x| future { x.keepalive! } }
        end

        private

        def init
          # init the thread pool
          @thread_pool = Concurrent::FixedThreadPool.new @threads
          # init the queues
          @new_sessions_in_process = @min.to_i
          @all_sessions = []
          @session_queue = []
          @transaction_queue = []
          # init the keepalive task
          create_keepalive_task!
          # init session queue
          num_transactions = (@min * @write_ratio).round
          num_sessions = @min.to_i - num_transactions
          num_sessions.times.each do
            future { checkin_session new_session! }
          end
          # init transaction queue
          num_transactions.times.each do
            future { checkin_transaction new_transaction! }
          end
        end

        def new_session!
          session = @client.create_new_session

          @mutex.synchronize do
            # don't add if the pool is closed
            return session.release! if @closed

            @new_sessions_in_process -= 1
            all_sessions << session
          end
          session
        end

        def new_transaction!
          new_session!.create_transaction
        end

        def can_allocate_more_sessions?
          # This is expected to be called from within a synchronize block
          all_sessions.size + @new_sessions_in_process < @max
        end

        def create_keepalive_task!
          @keepalive_task = Concurrent::TimerTask.new(execution_interval: 300,
                                                      timeout_interval: 60) do
            keepalive_or_release!
          end
          @keepalive_task.execute
        end

        def future
          Concurrent::Future.new(executor: @thread_pool) do
            yield
          end.execute
        end
      end
    end
  end
end
