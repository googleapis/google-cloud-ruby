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


require "google/cloud/firestore/collection"

module Google
  module Cloud
    module Firestore
      module Document
        ##
        # # Document::Reference
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
        class Reference
          ##
          # @private The connection context object.
          attr_accessor :context

          ##
          # The project identifier for the Cloud Firestore project that the
          # document resource belongs to.
          #
          # @return [String] project identifier.
          def project_id
            path.split("/")[1]
          end

          ##
          # The database identifier for the Cloud Firestore database that the
          # document resource belongs to.
          #
          # @return [String] database identifier.
          def database_id
            path.split("/")[3]
          end

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
          # A string representing the full path of the document resource.
          #
          # @return [String] document resource path.
          def path
            @path
          end

          ##
          # The collection the document reference belongs to.
          #
          # @return [Collection::Reference] parent collection.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a document reference
          #   nyc_ref = firestore.doc "cities/NYC"
          #
          #   # Get the document's parent collection
          #   cities_col = nyc_ref.parent
          #
          def parent
            Collection.from_path parent_path, context
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
          #   # Get a document reference
          #   nyc_ref = firestore.doc "cities/NYC"
          #
          #   nyc_ref.cols.each do |col|
          #     # Print the collection
          #     puts col.collection_id
          #   end
          #
          def cols
            ensure_service!

            return enum_for(:cols) unless block_given?

            collection_ids = service.list_collections path
            collection_ids.each { |collection_id| yield col(collection_id) }
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
          #   # Get a document reference
          #   nyc_ref = firestore.doc "cities/NYC"
          #
          #   # Get precincts sub-collection
          #   precincts_col = nyc_ref.col "precincts"
          #
          def col collection_path
            if collection_path.to_s.split("/").count.even?
              fail ArgumentError, "collection_path must refer to a collection."
            end

            Collection.from_path "#{path}/#{collection_path}", context
          end
          alias_method :collection, :col

          ##
          # Retrieve the document data.
          #
          # @param [Array<String|Symbol>, String|Symbol] mask A list of field
          #   paths to filter the returned document data by.
          #
          # @return [Document::Snapshot] document reference.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a document reference
          #   nyc_ref = firestore.doc "cities/NYC"
          #
          #   # Get the document data
          #   nyc_snap = nyc_ref.get
          #   nyc_snap[:population] #=> 1000000
          #
          def get mask: nil
            ensure_context!

            context.get_all([document_path], mask: mask).first
          end

          ##
          # Create a document with the provided object values.
          #
          # The batch will fail if the document already exists.
          #
          # @param [Hash] data The document's fields and values.
          #
          # @return [Time] The time the changes were committed
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a document reference
          #   nyc_ref = firestore.doc "cities/NYC"
          #
          #   # Create a document
          #   nyc_ref.create({ name: "New York City" })
          #
          def create data
            ensure_context!

            if context.respond_to? :create
              context.create self, data
            else
              context.database.create self, data
            end
          end

          ##
          # Write to document with the provided object values. If the document
          # does not exist, it will be created. By default, the provided data
          # overwrites existing data, but the provided data can be merged into
          # the existing document using the `merge` argument.
          #
          # @param [Hash] data The document's fields and values.
          # @param [true, String|Symbol, Array<String|Symbol>] merge When
          #   provided and `true` all data is merged with the existing docuemnt
          #   data.  When provided only the specified as a list of field paths
          #   are merged with the existing docuemnt data. The default is to
          #   overwrite the existing docuemnt data.
          #
          # @return [Time] The time the changes were committed
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a document reference
          #   nyc_ref = firestore.doc "cities/NYC"
          #
          #   # Set a document
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
          #   # Set a document
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
          #   # Set a document
          #   nyc_ref.set({ name: "New York City" }, merge: [:name])
          #
          def set data, merge: nil
            ensure_context!

            if context.respond_to? :set
              context.set self, data, merge: merge
            else
              context.database.set self, data, merge: merge
            end
          end

          ##
          # Write to document with the provided object values. If the document
          # does not exist, it will be created. By default, the provided data
          # overwrites existing data, but the provided data can be merged into
          # the existing document using the `merge` argument.
          #
          # The batch will fail if the document does not exist.
          #
          # @param [Hash] data The document's fields and values.
          # @param [Time] update_time When set, the document must have been last
          #   updated at that time. Optional.
          #
          # @return [Time] The time the changes were committed
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a document reference
          #   nyc_ref = firestore.doc "cities/NYC"
          #
          #   # Update a document
          #   firestore.update(nyc_ref, { name: "New York City" })
          #
          # @example Update a document using `update_time`:
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a document reference
          #   nyc_ref = firestore.doc "cities/NYC"
          #
          #   last_updated_at = Time.now - 42 # 42 seconds ago
          #
          #   # Update a document
          #   nyc_ref.update({ name: "New York City" },
          #                  update_time: last_updated_at)
          #
          def update data, update_time: nil
            ensure_context!

            if context.respond_to? :update
              context.update self, data, update_time: update_time
            else
              context.database.update self, data, update_time: update_time
            end
          end

          ##
          # Deletes a document from the database.
          #
          # @param [Boolean] exists Whether the document must exist. When `true,
          #   the document must exist or an error is raised. Default is `false`.
          #   Optional.
          # @param [Time] update_time When set, the document must have been last
          #   updated at that time. Optional.
          #
          # @return [Time] The time the changes were committed
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a document reference
          #   nyc_ref = firestore.doc "cities/NYC"
          #
          #   # Delete a document
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
          #   # Delete a document
          #   nyc_ref.delete exists: true
          #
          # @example Delete a document using `update_time`:
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a document reference
          #   nyc_ref = firestore.doc "cities/NYC"
          #
          #   last_updated_at = Time.now - 42 # 42 seconds ago
          #
          #   # Delete a document
          #   nyc_ref.delete update_time: last_updated_at
          #
          def delete exists: nil, update_time: nil
            ensure_context!

            if context.respond_to? :delete
              context.delete self, exists: exists, update_time: update_time
            else
              context.database.delete self, exists: exists,
                                            update_time: update_time
            end
          end

          protected

          ##
          # @private
          def parent_path
            path.split("/")[0...-1].join("/")
          end

          ##
          # @private The context's Service object.
          def service
            ensure_context!

            context.service
          end

          ##
          # @private Raise an error unless an active connection to the service
          # is available.
          def ensure_service!
            fail "Must have active connection to service" unless service
          end

          ##
          # @private Raise an error unless context is available.
          def ensure_context!
            fail "Must have active connection to service" unless context
            return unless context.respond_to? :closed?
            self.context = context.database if context.closed?
          end
        end
      end
    end
  end
end
