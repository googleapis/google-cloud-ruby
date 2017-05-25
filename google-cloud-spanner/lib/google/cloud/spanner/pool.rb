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


require "thread"
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
                       write_ratio: 0.3, fail: true, block_on_init: nil,
                       skip_background_thread: nil
          @client = client
          @min = min
          @max = max
          @keepalive = keepalive
          @write_ratio = write_ratio
          @write_ratio = 0 if write_ratio < 0
          @write_ratio = 1 if write_ratio > 1
          @fail = fail

          @mutex = Mutex.new
          @resource = ConditionVariable.new

          # initialize pool and availability queue
          init block_on_init: block_on_init,
               skip_background_thread: skip_background_thread
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
              fail ClientClosedError if @closed

              read_session = session_queue.shift
              return read_session if read_session
              write_transaction = transaction_queue.shift
              return write_transaction.session if write_transaction

              if can_allocate_more_sessions?
                action = :new
                break
              end

              fail SessionLimitError if @fail

              @resource.wait @mutex
            end
          end

          return new_session! if action == :new
        end

        def checkin_session session
          unless all_sessions.include? session
            fail ArgumentError, "Cannot checkin session"
          end

          session.reload!
          @mutex.synchronize do
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
            checkin_transaction tx
          end
        end

        def checkout_transaction
          action = nil
          @mutex.synchronize do
            loop do
              fail ClientClosedError if @closed

              write_transaction = transaction_queue.shift
              return write_transaction if write_transaction
              read_session = session_queue.shift
              if read_session
                action = read_session
                break
              end

              if can_allocate_more_sessions?
                action = :new
                break
              end

              fail SessionLimitError if @fail

              @resource.wait @mutex
            end
          end
          if action.is_a? Google::Cloud::Spanner::Session
            return action.create_transaction
          end
          return new_transaction! if action == :new
        end

        def checkin_transaction tx
          unless all_sessions.include? tx.session
            fail ArgumentError, "Cannot checkin session"
          end

          tx = tx.session.reload!.create_transaction
          @mutex.synchronize do
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
          @thread.kill if @thread
          # Unblock all waiting threads
          @closed = true
          @resource.broadcast
          # Delete all sessions
          @mutex.synchronize do
            @all_sessions.map do |s|
              Thread.new do
                s.release!
              end
            end.map(&:join)
            @all_sessions = []
            @session_queue = []
            @transaction_queue = []
          end

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

          to_release.map! { |x| Thread.new { x.release! } }
          to_keepalive.map! { |x| Thread.new { x.keepalive! } }

          # join all the threads before returning
          (to_release + to_keepalive).map(&:join)
        end

        private

        def init block_on_init: nil, skip_background_thread: nil
          @all_sessions = []
          @session_queue = []
          @transaction_queue = []
          ensure_background_thread! unless skip_background_thread
          # init session queue
          num_transactions = (@min * @write_ratio).round
          num_sessions = @min.to_i - num_transactions
          init_session_threads = num_sessions.times.map do
            Thread.new do
              s = new_session!
              @mutex.synchronize do
                session_queue << s
              end
            end
          end
          init_session_threads.map(&:join) if block_on_init
          # init transaction queue
          init_transaction_threads = num_transactions.times.map do
            Thread.new do
              tx = new_transaction!
              @mutex.synchronize do
                transaction_queue << tx
              end
            end
          end
          init_transaction_threads.map(&:join) if block_on_init
          # Do not block on calling Thread#join on the threads by default
        end

        def new_session!
          session = @client.create_new_session
          @mutex.synchronize do
            all_sessions << session
          end
          session
        end

        def new_transaction!
          new_session!.create_transaction
        end

        def can_allocate_more_sessions?
          # This is expected to be called from within a synchronize block
          all_sessions.size < @max
        end

        def ensure_background_thread!
          @thread ||= Thread.new do
            # before calling keepalive
            loop do
              keepalive_or_release!
              sleep 300
            end
          end
        end
      end
    end
  end
end
