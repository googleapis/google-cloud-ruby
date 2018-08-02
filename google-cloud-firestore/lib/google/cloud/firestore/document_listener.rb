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
      # An ongoing listen operation on a document reference. This is returned by
      # calling {DocumentReference#listen}.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   # Get a document reference
      #   nyc_ref = firestore.doc "cities/NYC"
      #
      #   listener = nyc_ref.listen do |snapshot|
      #     puts "The population of #{snapshot[:name]} "
      #     puts "is #{snapshot[:population]}."
      #   end
      #
      #   # When ready, stop the listen operation and close the stream.
      #   listener.stop
      #
      class DocumentListener
        ##
        # @private
        # Creates the watch stream and listener object.
        def initialize doc_ref, &callback
          @doc_ref = doc_ref
          raise ArgumentError if @doc_ref.nil?

          @callback = callback
          raise ArgumentError if @callback.nil?

          @listener = Watch::Listener.for_doc_ref doc_ref do |query_snp|
            doc_snp = query_snp.docs.find { |doc| doc.path == @doc_ref.path }

            if doc_snp.nil?
              doc_snp = DocumentSnapshot.missing \
                @doc_ref, read_at: query_snp.read_at
            end

            @callback.call doc_snp
          end
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
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   listener = nyc_ref.listen do |snapshot|
        #     puts "The population of #{snapshot[:name]} "
        #     puts "is #{snapshot[:population]}."
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
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   listener = nyc_ref.listen do |snapshot|
        #     puts "The population of #{snapshot[:name]} "
        #     puts "is #{snapshot[:population]}."
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
