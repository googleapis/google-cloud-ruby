# Copyright 2017, Google Inc. All rights reserved.
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


require "google/cloud/firestore/convert"

module Google
  module Cloud
    module Firestore
      module Document
        ##
        # # Document::Snapshot
        #
        # A document snapshot object is an immutable representation for a
        # document in a Cloud Firestore database.
        #
        # The snapshot can reference a non-existing document
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document with data
        #   nyc_snap = firestore.get "cities/NYC"
        #
        #   # Get the document data
        #   nyc_snap[:population] #=> 1000000
        #
        class Snapshot
          ##
          # @private The Google::Firestore::V1beta1::Document object.
          attr_accessor :grpc

          ##
          # The document reference object for the data.
          #
          # @return [Document::Reference] document reference.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a document with data
          #   nyc_snap = firestore.get "cities/NYC"
          #
          #   # Get the document reference
          #   nyc_ref = nyc_snap.ref
          #
          def ref
            @ref
          end
          alias_method :reference, :ref

          ##
          # The project identifier for the Cloud Firestore project that the
          # document with data belongs to.
          #
          # @return [String] project identifier.
          def project_id
            ref.project_id
          end

          ##
          # The database identifier for the Cloud Firestore database that the
          # document with data belongs to.
          #
          # @return [String] database identifier.
          def database_id
            ref.database_id
          end

          ##
          # The document identifier for the document with data.
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
          # A string representing the full path of the document resource.
          #
          # @return [String] document resource path.
          def path
            ref.path
          end

          ##
          # The collection the document with data belongs to.
          #
          # @return [Collection::Reference] parent collection.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a document with data
          #   nyc_snap = firestore.get "cities/NYC"
          #
          #   # Get the document's parent collection
          #   cities_col = nyc_snap.parent
          #
          def parent
            ref.parent
          end

          ##
          # Retrieves a list of collections nested under the document with data.
          #
          # @yield [collections] The block for accessing the collections.
          # @yieldparam [Collection::Reference] collection A collection.
          #
          # @return [Enumerator<Collection::Reference>] collection list.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   nyc_snap = firestore.get "cities/NYC"
          #
          #   nyc_snap.cols.each do |col|
          #     # Print the collection
          #     puts col.collection_id
          #   end
          #
          def cols &block
            ref.cols(&block)
          end
          alias_method :collections, :cols

          ##
          # Retrieves a collection nested under the document with data.
          #
          # @param [String] collection_path A string representing the path of
          #   the collection, relative to the document.
          #
          # @return [Collection::Reference] A collection.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   nyc_snap = firestore.get "cities/NYC"
          #
          #   # Get precincts sub-collection
          #   precincts_col = nyc_snap.col "precincts"
          #
          def col collection_path
            ref.col collection_path
          end
          alias_method :collection, :col

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
          #   nyc_snap = firestore.get "cities/NYC"
          #
          #   # Get the document data
          #   nyc_snap.data[:population] #=> 1000000
          #
          def data
            return nil if missing?
            Convert.fields_to_hash grpc.fields, ref.context
          end
          alias_method :fields, :data

          ##
          # Retrieves the document data.
          #
          # @return [Object] The data at the field path.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   nyc_snap = firestore.get "cities/NYC"
          #
          #   # Get the document data
          #   nyc_snap.get(:population) #=> 1000000
          #
          # @example Accessing data using []:
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   nyc_snap = firestore.get "cities/NYC"
          #
          #   # Get the document data
          #   nyc_snap[:population] #=> 1000000
          #
          def get field_path
            # TODO: Try replacing: Convert.select_field_path data, field_path
            selected_data = data
            field_path.to_s.split(".").each do |field|
              unless selected_data.is_a? Hash
                fail ArgumentError, "#{field_path} is not contained in the data"
              end
              selected_data = selected_data[field.to_sym]
            end
            selected_data
          end
          alias_method :[], :get

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
          #   nyc_snap = firestore.get "cities/NYC"
          #
          #   # Does NYC exist?
          #   nyc_snap.exists? #=> true
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
          #   atlantis_snap = firestore.get "cities/Atlantis"
          #
          #   # Does Atlantis exist?
          #   atlantis_snap.missing? #=> true
          def missing?
            grpc.nil?
          end
        end
      end
    end
  end
end
