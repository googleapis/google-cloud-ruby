# Copyright 2018 Google LLC
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


require "google/cloud/firestore/watch/listener"

module Google
  module Cloud
    module Firestore
      ##
      # # QueryListener
      #
      # An ongoing listen operation on a query. This is returned by calling
      # {Query#listen}.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   # Create a query
      #   query = firestore.col(:cities).order(:population, :desc)
      #
      #   listener = query.listen do |snapshot|
      #     puts "The query snapshot has #{snapshot.docs.count} documents "
      #     puts "and has #{snapshot.changes.count} changes."
      #   end
      #
      #   # When ready, stop the listen operation and close the stream.
      #   listener.stop
      #
      class QueryListener
        include MonitorMixin
        ##
        # @private
        # Creates the watch stream and listener object.
        def initialize query, &callback
          super() # to init MonitorMixin

          @query = query
          raise ArgumentError if @query.nil?

          @callback = callback
          raise ArgumentError if @callback.nil?
          @error_callbacks = []

          @listener = Watch::Listener.for_query self, query, &callback
        end

        ##
        # @private
        def start
          @listener.start
          self
        end

        ##
        # Stops the client listening for changes.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.col(:cities).order(:population, :desc)
        #
        #   listener = query.listen do |snapshot|
        #     puts "The query snapshot has #{snapshot.docs.count} documents "
        #     puts "and has #{snapshot.changes.count} changes."
        #   end
        #
        #   # When ready, stop the listen operation and close the stream.
        #   listener.stop
        #
        def stop
          @listener.stop
        end

        ##
        # Whether the client has stopped listening for changes.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.col(:cities).order(:population, :desc)
        #
        #   listener = query.listen do |snapshot|
        #     puts "The query snapshot has #{snapshot.docs.count} documents "
        #     puts "and has #{snapshot.changes.count} changes."
        #   end
        #
        #   # Checks if the listener is stopped.
        #   listener.stopped? #=> false
        #
        #   # When ready, stop the listen operation and close the stream.
        #   listener.stop
        #
        #   # Checks if the listener is stopped.
        #   listener.stopped? #=> true
        #
        def stopped?
          @listener.stopped?
        end

        ##
        # Register to be notified of errors when raised.
        #
        # If an unhandled error has occurred the listener will attempt to
        # recover from the error and resume listening.
        #
        # Multiple error handlers can be added.
        #
        # @yield [callback] The block to be called when an error is raised.
        # @yieldparam [Exception] error The error raised.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.col(:cities).order(:population, :desc)
        #
        #   listener = query.listen do |snapshot|
        #     puts "The query snapshot has #{snapshot.docs.count} documents "
        #     puts "and has #{snapshot.changes.count} changes."
        #   end
        #
        #   # Register to be notified when unhandled errors occur.
        #   listener.on_error do |error|
        #     puts error
        #   end
        #
        #   # When ready, stop the listen operation and close the stream.
        #   listener.stop
        #
        def on_error &block
          raise ArgumentError, "on_error must be called with a block" unless block_given?
          synchronize { @error_callbacks << block }
        end

        ##
        # The most recent unhandled error to occur while listening for changes.
        #
        # If an unhandled error has occurred the listener will attempt to
        # recover from the error and resume listening.
        #
        # @return [Exception, nil] error The most recent error raised.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.col(:cities).order(:population, :desc)
        #
        #   listener = query.listen do |snapshot|
        #     puts "The query snapshot has #{snapshot.docs.count} documents "
        #     puts "and has #{snapshot.changes.count} changes."
        #   end
        #
        #   # If an error was raised, it can be retrieved here:
        #   listener.last_error #=> nil
        #
        #   # When ready, stop the listen operation and close the stream.
        #   listener.stop
        #
        def last_error
          synchronize { @last_error }
        end

        # @private Pass the error to user-provided error callbacks.
        def error! error
          error_callbacks = synchronize do
            @last_error = error
            @error_callbacks.dup
          end
          error_callbacks.each { |error_callback| error_callback.call error }
        end
      end
    end
  end
end
