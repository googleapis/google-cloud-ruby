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
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/collection_reference"
require "google/cloud/firestore/document_listener"

module Google
  module Cloud
    module Firestore
      ##
      # # DocumentReference
      #
      # A document reference object refers to a document location in a Cloud
      # Firestore database and can be used to write or read data. A document
      # resource at the referenced location may or may not exist.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   # Get a document reference
      #   nyc_ref = firestore.doc "cities/NYC"
      #
      class DocumentReference
        ##
        # @private The firestore client object.
        attr_accessor :client

        ##
        # The document identifier for the document resource.
        #
        # @return [String] document identifier.
        def document_id
          path.split("/").last
        end

        ##
        # A string representing the path of the document, relative to the
        # document root of the database.
        #
        # @return [String] document path.
        def document_path
          path.split("/", 6).last
        end

        ##
        # @private A string representing the full path of the document resource.
        #
        # @return [String] document resource path.
        def path
          @path
        end

        # @!group Access

        ##
        # Retrieves a list of collections nested under the document snapshot.
        #
        # @yield [collections] The block for accessing the collections.
        # @yieldparam [CollectionReference] collection A collection.
        #
        # @return [Enumerator<CollectionReference>] collection list.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.cols.each do |col|
        #     puts col.collection_id
        #   end
        #
        def cols
          ensure_service!

          return enum_for(:cols) unless block_given?

          collection_ids = service.list_collections path
          collection_ids.each { |collection_id| yield col(collection_id) }
        end
        alias collections cols

        ##
        # Retrieves a collection nested under the document snapshot.
        #
        # @param [String] collection_path A string representing the path of
        #   the collection, relative to the document.
        #
        # @return [CollectionReference] A collection.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   # Get precincts sub-collection
        #   precincts_col = nyc_ref.col "precincts"
        #
        def col collection_path
          if collection_path.to_s.split("/").count.even?
            raise ArgumentError, "collection_path must refer to a collection."
          end

          CollectionReference.from_path "#{path}/#{collection_path}", client
        end
        alias collection col

        ##
        # Retrieve the document data.
        #
        # @return [DocumentSnapshot] document snapshot.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_snap = nyc_ref.get
        #   nyc_snap[:population] #=> 1000000
        #
        def get
          ensure_client!

          client.get_all([self]).first
        end

        ##
        # Listen to this document reference for changes.
        #
        # @yield [callback] The block for accessing the document snapshot.
        # @yieldparam [DocumentSnapshot] snapshot A document snapshot.
        #
        # @return [DocumentListener] The ongoing listen operation on the
        #   document reference.
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
        def listen &callback
          raise ArgumentError, "callback required" if callback.nil?

          ensure_client!

          DocumentListener.new(self, &callback).start
        end
        alias on_snapshot listen

        ##
        # The collection the document reference belongs to.
        #
        # @return [CollectionReference] parent collection.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   cities_col = nyc_ref.parent
        #
        def parent
          CollectionReference.from_path parent_path, client
        end

        # @!endgroup

        # @!group Modifications

        ##
        # Create a document with the provided data (fields and values).
        #
        # The operation will fail if the document already exists.
        #
        # @param [Hash] data The document's fields and values.
        #
        # @return [CommitResponse::WriteResult] The result of the change.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.create({ name: "New York City" })
        #
        # @example Create a document and set a field to server_time:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.create({ name: "New York City",
        #                    updated_at: firestore.field_server_time })
        #
        def create data
          ensure_client!

          resp = client.batch { |b| b.create self, data }
          resp.write_results.first
        end

        ##
        # Write the provided data (fields and values) to the document. If the
        # document does not exist, it will be created. By default, the provided
        # data overwrites existing data, but the provided data can be merged
        # into the existing document using the `merge` argument.
        #
        # If you're not sure whether the document exists, use the `merge`
        # argument to merge the new data with any existing document data to
        # avoid overwriting entire documents.
        #
        # @param [Hash] data The document's fields and values.
        # @param [Boolean, FieldPath, String, Symbol] merge When
        #   `true`, all provided data is merged with the existing document data.
        #   When the argument is one or more field path, only the data for
        #   fields in this argument is merged with the existing document data.
        #   The default is to not merge, but to instead overwrite the existing
        #   document data.
        #
        # @return [CommitResponse::WriteResult] The result of the change.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.set({ name: "New York City" })
        #
        # @example Set a document and merge all data:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.set({ name: "New York City" }, merge: true)
        #
        # @example Set a document and merge only name:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.set({ name: "New York City" }, merge: :name)
        #
        # @example Set a document and deleting a field using merge:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.set({ name: "New York City",
        #                 trash: firestore.field_delete }, merge: true)
        #
        # @example Set a document and set a field to server_time:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.set({ name: "New York City",
        #                 updated_at: firestore.field_server_time })
        #
        def set data, merge: nil
          ensure_client!

          resp = client.batch { |b| b.set self, data, merge: merge }
          resp.write_results.first
        end

        ##
        # Update the document with the provided data (fields and values). The
        # provided data is merged into the existing document data.
        #
        # The operation will fail if the document does not exist.
        #
        # @param [Hash<FieldPath|String|Symbol, Object>] data The document's
        #   fields and values.
        #
        #   The top-level keys in the data hash are considered field paths, and
        #   can either be a FieldPath object, or a string representing the
        #   nested fields. In other words the string represents individual
        #   fields joined by ".". Fields containing `~`, `*`, `/`, `[`, `]`, and
        #   `.` cannot be in a dotted string, and should provided using a
        #   {FieldPath} object instead.
        # @param [Time] update_time When set, the document must have been last
        #   updated at that time. Optional.
        #
        # @return [CommitResponse::WriteResult] The result of the change.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.update({ name: "New York City" })
        #
        # @example Directly update a deeply-nested field with a `FieldPath`:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   user_ref = firestore.doc "users/frank"
        #
        #   nested_field_path = firestore.field_path :favorites, :food
        #   user_ref.update({ nested_field_path => "Pasta" })
        #
        # @example Update a document using the `update_time` precondition:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   last_updated_at = Time.now - 42 # 42 seconds ago
        #
        #   nyc_ref.update({ name: "New York City" },
        #                    update_time: last_updated_at)
        #
        # @example Update a document and deleting a field:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.update({ name: "New York City",
        #                    trash: firestore.field_delete })
        #
        # @example Update a document and set a field to server_time:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.update({ name: "New York City",
        #                    updated_at: firestore.field_server_time })
        #
        def update data, update_time: nil
          ensure_client!

          resp = client.batch do |b|
            b.update self, data, update_time: update_time
          end
          resp.write_results.first
        end

        ##
        # Deletes a document from the database.
        #
        # @param [Boolean] exists Whether the document must exist. When `true`,
        #   the document must exist or an error is raised. Default is `false`.
        #   Optional.
        # @param [Time] update_time When set, the document must have been last
        #   updated at that time. Optional.
        #
        # @return [CommitResponse::WriteResult] The result of the change.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.delete
        #
        # @example Delete a document using `exists`:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   nyc_ref.delete exists: true
        #
        # @example Delete a document using the `update_time` precondition:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   last_updated_at = Time.now - 42 # 42 seconds ago
        #   nyc_ref.delete update_time: last_updated_at
        #
        def delete exists: nil, update_time: nil
          ensure_client!

          resp = client.batch do |b|
            b.delete self, exists: exists, update_time: update_time
          end
          resp.write_results.first
        end

        # @!endgroup

        ##
        # @private New DocumentReference object from a path.
        def self.from_path path, client
          new.tap do |r|
            r.client = client
            r.instance_variable_set :@path, path
          end
        end

        protected

        ##
        # @private
        def parent_path
          path.split("/")[0...-1].join("/")
        end

        ##
        # @private The client's Service object.
        def service
          ensure_client!

          client.service
        end

        ##
        # @private Raise an error unless an database available.
        def ensure_client!
          raise "Must have active connection to service" unless client
        end

        ##
        # @private Raise an error unless an active connection to the service
        # is available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
