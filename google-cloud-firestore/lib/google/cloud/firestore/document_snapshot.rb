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


require "google/cloud/firestore/v1"
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/collection_reference"
require "google/cloud/firestore/convert"
require "google/cloud/firestore/watch/order"

module Google
  module Cloud
    module Firestore
      ##
      # # DocumentSnapshot
      #
      # A document snapshot object is an immutable representation for a
      # document in a Cloud Firestore database.
      #
      # The snapshot can reference a non-existing document.
      #
      # See {DocumentReference#get}, {DocumentReference#listen},
      # {Query#get}, {Query#listen}, and {QuerySnapshot#docs}.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   # Get a document snapshot
      #   nyc_snap = firestore.doc("cities/NYC").get
      #
      #   # Get the document data
      #   nyc_snap[:population] #=> 1000000
      #
      # @example Listen to a document reference for changes:
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   # Get a document reference
      #   nyc_ref = firestore.doc "cities/NYC"
      #
      #   listener = nyc_ref.listen do |snapshot|
      #     puts "The population of #{snapshot[:name]} is #{snapshot[:population]}."
      #   end
      #
      #   # When ready, stop the listen operation and close the stream.
      #   listener.stop
      #
      class DocumentSnapshot
        ##
        # @private The Google::Cloud::Firestore::V1::Document object.
        attr_accessor :grpc

        ##
        # The document identifier for the document snapshot.
        #
        # @return [String] document identifier.
        def document_id
          ref.document_id
        end

        ##
        # A string representing the path of the document, relative to the
        # document root of the database.
        #
        # @return [String] document path.
        def document_path
          ref.document_path
        end

        ##
        # @private A string representing the full path of the document resource.
        #
        # @return [String] document resource path.
        def path
          ref.path
        end

        # @!group Access

        ##
        # The document reference object for the data.
        #
        # @return [DocumentReference] document reference.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document snapshot
        #   nyc_snap = firestore.doc("cities/NYC").get
        #
        #   # Get the document reference
        #   nyc_ref = nyc_snap.ref
        #
        def ref
          @ref
        end
        alias reference ref

        ##
        # The collection the document snapshot belongs to.
        #
        # @return [CollectionReference] parent collection.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document snapshot
        #   nyc_snap = firestore.doc("cities/NYC").get
        #
        #   # Get the document's parent collection
        #   cities_col = nyc_snap.parent
        #
        def parent
          ref.parent
        end

        # @!endgroup

        # @!group Data

        ##
        # Retrieves the document data. When the document exists the data hash is
        # frozen and will not allow any changes. When the document does not
        # exist `nil` will be returned.
        #
        # @return [Hash, nil] The document data.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   nyc_snap = firestore.doc("cities/NYC").get
        #
        #   # Get the document data
        #   nyc_snap.data[:population] #=> 1000000
        #
        def data
          return nil if missing?
          @data ||= Convert.fields_to_hash(grpc.fields, ref.client).freeze
        end
        alias fields data

        ##
        # Retrieves the document data.
        #
        # @param [FieldPath, String, Symbol] field_path A field path
        #   representing the path of the data to select. A field path can
        #   represent as a string of individual fields joined by ".". Fields
        #   containing `~`, `*`, `/`, `[`, `]`, and `.` cannot be in a dotted
        #   string, and should provided using a {FieldPath} object instead.
        #
        # @return [Object] The data at the field path.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   nyc_snap = firestore.doc("cities/NYC").get
        #
        #   nyc_snap.get(:population) #=> 1000000
        #
        # @example Accessing data using []:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   nyc_snap = firestore.doc("cities/NYC").get
        #
        #   nyc_snap[:population] #=> 1000000
        #
        # @example Nested data can be accessing with field path:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   frank_snap = firestore.doc("users/frank").get
        #
        #   frank_snap.get("favorites.food") #=> "Pizza"
        #
        # @example Nested data can be accessing with FieldPath object:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   user_snap = firestore.doc("users/frank").get
        #
        #   nested_field_path = firestore.field_path :favorites, :food
        #   user_snap.get(nested_field_path) #=> "Pizza"
        #
        def get field_path
          unless field_path.is_a? FieldPath
            field_path = FieldPath.parse field_path
          end

          nodes = field_path.fields.map(&:to_sym)
          return ref if nodes == [:__name__]

          selected_data = data
          nodes.each do |node|
            unless selected_data.is_a? Hash
              err_msg = "#{field_path.formatted_string} is not " \
                        "contained in the data"
              raise ArgumentError, err_msg
            end
            selected_data = selected_data[node]
          end
          selected_data
        end
        alias [] get

        # @!endgroup

        ##
        # The time at which the document was created.
        #
        # This value increases when a document is deleted then recreated.
        #
        # @return [Time] The time the document was was created
        #
        def created_at
          return nil if missing?
          Convert.timestamp_to_time grpc.create_time
        end
        alias create_time created_at

        ##
        # The time at which the document was last changed.
        #
        # This value is initally set to the `created_at` on document creation,
        # and increases each time the document is updated.
        #
        # @return [Time] The time the document was was last changed
        #
        def updated_at
          return nil if missing?
          Convert.timestamp_to_time grpc.update_time
        end
        alias update_time updated_at

        ##
        # The time at which the document was read.
        #
        # This value is set even if the document does not exist.
        #
        # @return [Time] The time the document was read
        #
        def read_at
          @read_at
        end
        alias read_time read_at

        ##
        # Determines whether the document exists.
        #
        # @return [Boolean] Whether the document exists.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   nyc_snap = firestore.doc("cities/NYC").get
        #
        #   # Does NYC exist?
        #   nyc_snap.exists? #=> true
        #
        def exists?
          !missing?
        end

        ##
        # Determines whether the document is missing.
        #
        # @return [Boolean] Whether the document is missing.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   atlantis_snap = firestore.doc("cities/Atlantis").get
        #
        #   # Does Atlantis exist?
        #   atlantis_snap.missing? #=> true
        #
        def missing?
          grpc.nil?
        end

        ##
        # @private
        def <=> other
          return nil unless other.is_a? DocumentSnapshot
          return data <=> other.data if path == other.path
          path <=> other.path
        end

        ##
        # @private
        def eql? other
          return false unless other.is_a? DocumentSnapshot
          return data.eql? other.data if path == other.path
          path.eql? other.path
        end

        ##
        # @private
        def hash
          @hash ||= [path, data].hash
        end

        ##
        # @private
        def query_comparisons_for query_grpc
          @memoized_comps ||= {}
          if @memoized_comps.key? query_grpc.hash
            return @memoized_comps[query_grpc.hash]
          end

          @memoized_comps[query_grpc.hash] = query_grpc.order_by.map do |order|
            Watch::Order.field_comparison get(order.field.field_path)
          end
        end

        ##
        # @private New DocumentSnapshot from a
        # Google::Cloud::Firestore::V1::RunQueryResponse object.
        def self.from_query_result result, client
          ref = DocumentReference.from_path result.document.name, client
          read_at = Convert.timestamp_to_time result.read_time

          new.tap do |s|
            s.grpc = result.document
            s.instance_variable_set :@ref, ref
            s.instance_variable_set :@read_at, read_at
          end
        end

        ##
        # @private New DocumentSnapshot from a
        # Google::Cloud::Firestore::V1::DocumentChange object.
        def self.from_document document, client, read_at: nil
          ref = DocumentReference.from_path document.name, client

          new.tap do |s|
            s.grpc = document
            s.instance_variable_set :@ref, ref
            s.instance_variable_set :@read_at, read_at
          end
        end

        ##
        # @private New DocumentSnapshot from a
        # Google::Cloud::Firestore::V1::BatchGetDocumentsResponse object.
        def self.from_batch_result result, client
          ref = nil
          grpc = nil
          if result.result == :found
            grpc = result.found
            ref = DocumentReference.from_path grpc.name, client
          else
            ref = DocumentReference.from_path result.missing, client
          end
          read_at = Convert.timestamp_to_time result.read_time

          new.tap do |s|
            s.grpc = grpc
            s.instance_variable_set :@ref, ref
            s.instance_variable_set :@read_at, read_at
          end
        end

        ##
        # @private New non-existant DocumentSnapshot from a
        # DocumentReference object.
        def self.missing doc_ref, read_at: nil
          new.tap do |s|
            s.grpc = nil
            s.instance_variable_set :@ref, doc_ref
            s.instance_variable_set :@read_at, read_at
          end
        end
      end
    end
  end
end
