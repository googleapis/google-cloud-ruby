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
        ##
        # @private
        # Creates the watch stream and listener object.
        def initialize query, &callback
          @query = query
          raise ArgumentError if @query.nil?

          @callback = callback
          raise ArgumentError if @callback.nil?

          @listener = Watch::Listener.for_query query, &callback
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
      end
    end
  end
end
