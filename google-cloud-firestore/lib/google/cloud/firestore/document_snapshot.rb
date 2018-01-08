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


require "google/cloud/firestore/v1beta1"
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/collection_reference"
require "google/cloud/firestore/convert"

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
      class DocumentSnapshot
        ##
        # @private The Google::Firestore::V1beta1::Document object.
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
        alias_method :reference, :ref

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
        # Retrieves the document data.
        #
        # @return [Hash] The document data.
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
          Convert.fields_to_hash grpc.fields, ref.client
        end
        alias_method :fields, :data

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
          selected_data = data

          nodes.each do |node|
            unless selected_data.is_a? Hash
              fail ArgumentError,
                   "#{field_path.formatted_string} is not contained in the data"
            end
            selected_data = selected_data[node]
          end
          selected_data
        end
        alias_method :[], :get

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
        alias_method :create_time, :created_at

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
        alias_method :update_time, :updated_at

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
        alias_method :read_time, :read_at

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
        # @private New DocumentSnapshot from a
        # Google::Firestore::V1beta1::RunQueryResponse object.
        def self.from_query_result result, context
          ref = DocumentReference.from_path result.document.name, context
          read_at = Convert.timestamp_to_time result.read_time

          new.tap do |s|
            s.grpc = result.document
            s.instance_variable_set :@ref, ref
            s.instance_variable_set :@read_at, read_at
          end
        end

        ##
        # @private New DocumentSnapshot from a
        # Google::Firestore::V1beta1::BatchGetDocumentsResponse object.
        def self.from_batch_result result, context
          ref = nil
          grpc = nil
          if result.result == :found
            grpc = result.found
            ref = DocumentReference.from_path grpc.name, context
          else
            ref = DocumentReference.from_path result.missing, context
          end
          read_at = Convert.timestamp_to_time result.read_time

          new.tap do |s|
            s.grpc = grpc
            s.instance_variable_set :@ref, ref
            s.instance_variable_set :@read_at, read_at
          end
        end
      end
    end
  end
end
