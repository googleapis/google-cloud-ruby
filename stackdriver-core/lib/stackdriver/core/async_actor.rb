# Copyright 2017 Google LLC
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

require "set"


module Stackdriver
  module Core
    ##
    # # AsyncActor
    #
    # @private An module that provides a class asynchronous capability when
    #   included. It can create a child thread to run background jobs, and
    #   help make sure the child thread terminates properly when process
    #   is interrupted.
    #
    # To use AsyncActor, the classes that are including this module need to
    # define a run_backgrounder method that does the background job. The
    # classes can then control the child thread job through instance methods
    # like async_start, async_stop, etc.
    #
    # @example
    #   class Foo
    #     include AsyncActor
    #
    #     def initialize
    #       super()
    #     end
    #
    #     def run_backgrounder
    #       # run async job
    #     end
    #   end
    #
    #   foo = Foo.new
    #   foo.async_start
    #
    module AsyncActor
      include MonitorMixin

      CLEANUP_TIMEOUT = 10.0
      WAIT_INTERVAL = 1.0

      @cleanup_list = nil
      @exit_lock = Monitor.new

      ##
      # @private The async actor state
      attr_reader :async_state

      ##
      # Starts the child thread and asynchronous job
      def async_start
        ensure_thread
      end

      ##
      # Nicely ask the child thread to stop by setting the state to
      # :stopping if it's not stopped already.
      #
      # @return [Boolean] False if child thread is already stopped. Otherwise
      #   true.
      def async_stop
        ensure_thread
        synchronize do
          if async_state != :stopped
            @async_state = :stopping
            async_state_change
            true
          else
            false
          end
        end
      end

      ##
      # Set the state to :suspend if the current state is :running.
      #
      # @return [Boolean] Returns true if the state has been set to
      #   :suspended. Otherwise return false.
      #
      def async_suspend
        ensure_thread
        synchronize do
          if async_state == :running
            @async_state = :suspended
            async_state_change
            true
          else
            false
          end
        end
      end

      ##
      # Set the state to :running if the current state is :suspended.
      #
      # @return [Boolean] True if the state has been set to :running.
      #   Otherwise return false.
      #
      def async_resume
        ensure_thread
        synchronize do
          if async_state == :suspended
            @async_state = :running
            async_state_change
            true
          else
            false
          end
        end
      end

      ##
      # Check if async job is running
      #
      # @return [Boolean] True if state equals :running. Otherwise false.
      def async_running?
        synchronize do
          async_state == :running
        end
      end

      ##
      # Check if async job is suspended
      #
      # @return [Boolean] True if state equals :suspended. Otherwise false.
      def async_suspended?
        synchronize do
          async_state == :suspended
        end
      end

      ##
      # Check if async job is working.
      #
      # @return [Boolean] True if state is either :running or :suspended.
      #   Otherwise false.
      def async_working?
        synchronize do
          async_state == :suspended || async_state == :running
        end
      end

      ##
      # Check if async job has stopped
      #
      # @return [Boolean] True if state equals :stopped. Otherwise false.
      def async_stopped?
        synchronize do
          async_state == :stopped
        end
      end

      ##
      # Check if async job is stopping
      #
      # @return [Boolean] True if state equals :stopping. Otherwise false.
      def async_stopping?
        synchronize do
          async_state == :stopping
        end
      end

      ##
      # Ask async job to stop. Then forcefully kill thread if it doesn't stop
      # after timeout if needed.
      #
      # @return [Symbol] :stopped if async job already stopped. :waited if
      #   async job terminates within timeout range. :timeout if async job
      #   doesn't terminate after timeout. :forced if thread is killed by
      #   force after timeout.
      def async_stop!
        ensure_thread

        timeout = @cleanup_options[:timeout]
        force = @cleanup_options[:force]

        return :stopped unless async_stop

        return :waited if timeout.to_f > 0 && wait_until_async_stopped(timeout)

        return :timeout unless force

        @thread.kill
        @thread.join
        :forced
      end

      ##
      # Block current thread until the async job is fully stopped.
      #
      # @param [Integer] timeout If given, lift the blocking when the time has
      #   exceeded the timeout. If nil, block indefinitely.
      #
      # @return [Boolean] True if async job is fully stopped. False if timeout.
      #
      def wait_until_async_stopped timeout = nil
        ensure_thread
        deadline = timeout ? ::Time.new.to_f + timeout : nil
        synchronize do
          until async_state == :stopped
            cur_time = ::Time.new.to_f
            return false if deadline && cur_time >= deadline
            max_interval = @cleanup_options[:wait_interval]
            interval = deadline ? deadline - cur_time : max_interval
            interval = max_interval if interval > max_interval
            @lock_cond.wait interval
          end
        end
        true
      end

      ##
      # Abstract method that the inheriting classes should implement.
      #
      # This should be the main task job that will be run asynchronously and
      # repeatly.
      def run_backgrounder
        fail "#{self.class} class should override #run_backgrounder method"
      end

      ##
      # @private Cleanup this async job when process exists
      #
      def self.register_for_cleanup actor
        @exit_lock.synchronize do
          unless @cleanup_list
            @cleanup_list = []
            at_exit { run_cleanup }
          end
          @cleanup_list.push actor
        end
      end

      ##
      # @private Take this async job off exit cleanup list
      #
      def self.unregister_for_cleanup actor
        @exit_lock.synchronize do
          @cleanup_list.delete actor if @cleanup_list
        end
      end

      ##
      # @private Cleanup the async job
      #
      def self.run_cleanup
        @exit_lock.synchronize do
          if @cleanup_list
            @cleanup_list.shift.async_stop! until @cleanup_list.empty?
          end
        end
      end

      private_class_method :run_cleanup

      private

      ##
      # @private Constructor to initialize MonitorMixin
      #
      def initialize
        super()
        @startup_lock = Mutex.new
        @cleanup_options = {
          wait_interval: WAIT_INTERVAL,
          timeout: CLEANUP_TIMEOUT,
          force: true
        }
      end

      ##
      # @private Wrapper method for running the async job. It runs a loop
      # while the condition allows, and it calls the run_backgrounder method.
      # This method also ensures the state variable gets set to :stopped when
      # it exits.
      def async_run_job
        until async_stopped?
          run_backgrounder

          return if async_stopping? && backgrounder_stoppable?
        end
      ensure
        @async_state = :stopped
        async_state_change
      end

      ##
      # @private Ensures the child thread is started and kick off the job
      #   to run async_run_job. Also make calls register_for_cleanup on the
      #   async job to make sure it exits properly.
      def ensure_thread
        fail "async_actor not initialized" if @startup_lock.nil?
        @startup_lock.synchronize do
          if (@thread.nil? || !@thread.alive?) && @async_state != :stopped
            @lock_cond = new_cond
            AsyncActor.register_for_cleanup self

            @async_state = :running
            async_state_change

            @thread = Thread.new do
              async_run_job
              AsyncActor.unregister_for_cleanup self
            end
          end
        end
      end

      ##
      # @private Set cleanup options.
      #
      # @param [Hash] *kwargs Hash of cleanup options. :timeout is the cleanup
      #   wait timeout. :wait_interval is the cleanup wait interval. :force for
      #   forcefully terminate actor when all other options fail.
      def set_cleanup_options **kwargs
        @cleanup_options.merge! kwargs
      end

      ##
      # @private Default backgrounder stop condition when asked to be stopped
      # gracefully. Called from #async_run_job when async actor state changes
      # to :stopping
      def backgrounder_stoppable?
        true
      end

      ##
      # @private Handler when the async actor's state changes. Call
      # the `on_async_state_change` callback function if it's defined.
      def async_state_change
        on_async_state_change

        synchronize do
          @lock_cond.broadcast
        end
      end

      ##
      # @private Default abstract definition of this function that's a no-op.
      # The extending classes can override this method to handle state changing
      # logic.
      def on_async_state_change
      end
    end
  end
end
