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
require "google/cloud/firestore/query"
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/generate"
require "google/cloud/firestore/collection_reference_list"

module Google
  module Cloud
    module Firestore
      ##
      # # CollectionReference
      #
      # A collection reference object is used for adding documents, getting
      # document references, and querying for documents (See {Query}).
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   # Get a collection reference
      #   cities_col = firestore.col "cities"
      #
      #   # Get and print all city documents
      #   cities_col.get do |city|
      #     puts "#{city.document_id} has #{city[:population]} residents."
      #   end
      #
      class CollectionReference < Query
        ##
        # @private The firestore client object.
        attr_accessor :client

        ##
        # @private Creates a new CollectionReference.
        def initialize query, path, client
          super query, nil, client # Pass nil parent_path arg since this class implements #parent_path
          @path = path
        end

        ##
        # The collection identifier for the collection resource.
        #
        # @return [String] collection identifier.
        def collection_id
          path.split("/").last
        end

        ##
        # A string representing the path of the collection, relative to the
        # document root of the database.
        #
        # @return [String] collection path.
        def collection_path
          path.split("/", 6).last
        end

        ##
        # @private A string representing the full path of the collection
        # resource.
        #
        # @return [String] collection resource path.
        def path
          @path
        end

        ##
        # @private The parent path for the collection.
        def parent_path
          path.split("/")[0...-1].join "/"
        end

        # @!group Access

        ##
        # Retrieves a document reference.
        #
        # @param [String, nil] document_path A string representing the path of
        #   the document, relative to the document root of the database. If a
        #   string is not provided, and random document identifier will be
        #   generated. Optional.
        #
        # @return [DocumentReference] A document.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Get a document reference
        #   nyc_ref = cities_col.doc "NYC"
        #
        #   # The document ID is what was provided
        #   nyc_ref.document_id #=> "NYC"
        #
        # @example Create a document reference with a random ID:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Get a document reference without specifying path
        #   random_ref = cities_col.doc
        #
        #   # The document ID is randomly generated
        #   random_ref.document_id #=> "RANDOMID123XYZ"
        #
        def doc document_path = nil
          document_path ||= random_document_id

          ensure_client!
          client.doc "#{collection_path}/#{document_path}"
        end
        alias document doc

        ##
        # Retrieves a list of document references for the documents in this
        # collection.
        #
        # The document references returned may include references to "missing
        # documents", i.e. document locations that have no document present but
        # which contain subcollections with documents. Attempting to read such a
        # document reference (e.g. via {DocumentReference#get}) will return
        # a {DocumentSnapshot} whose `exists?` method returns false.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of results to return.
        # @param [Time] read_time Reads documents as they were at the given time.
        #   This may not be older than 270 seconds. Optional
        #
        # @return [Array<DocumentReference>] An array of document references.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   col = firestore.col "cities"
        #
        #   col.list_documents.each do |doc_ref|
        #     puts doc_ref.document_id
        #   end
        #
        # @example List documents with read time
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   read_time = Time.now
        #
        #   col = firestore.col "cities"
        #
        #   col.list_documents(read_time: read_time).each do |doc_ref|
        #     puts doc_ref.document_id
        #   end
        #
        def list_documents token: nil, max: nil, read_time: nil
          ensure_client!
          client.list_documents \
            parent_path, collection_id, token: token, max: max, read_time: read_time
        end

        ##
        # The document reference or database the collection reference belongs
        # to. If the collection is a root collection, it will return the client
        # object. If the collection is nested under a document, it will return
        # the document reference object.
        #
        # @return [Client, DocumentReference] parent object.
        #
        # @example Returns client object for root collections:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Get the document's parent collection
        #   database = cities_col.parent
        #
        # @example Returns document object for nested collections:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   precincts_ref = firestore.col "cities/NYC/precincts"
        #
        #   # Get the document's parent collection
        #   nyc_ref = precincts_ref.parent
        #
        def parent
          if collection_path.include? "/"
            return DocumentReference.from_path parent_path, client
          end
          client
        end

        # @!endgroup

        # @!group Modifications

        ##
        # Create a document with random document identifier.
        #
        # The operation will fail if the document already exists.
        #
        # @param [Hash] data The document's fields and values. Optional.
        #
        # @return [DocumentReference] A created document.
        #
        # @example Create a document with a random ID:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Get a document reference without data
        #   random_ref = cities_col.add
        #
        #   # The document ID is randomly generated
        #   random_ref.document_id #=> "RANDOMID123XYZ"
        #
        # @example Create a document snapshot:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Get a document snapshot
        #   random_ref = cities_col.add({ name: "New York City" })
        #
        #   # The document ID is randomly generated
        #   random_ref.document_id #=> "RANDOMID123XYZ"
        #
        def add data = nil
          data ||= {}
          doc.tap { |d| d.create data }
        end

        # @!endgroup

        ##
        # @private New Collection reference object from a path.
        def self.from_path path, client
          # Very important to correctly set @query on a collection object
          query = StructuredQuery.new(
            from: [
              StructuredQuery::CollectionSelector.new(
                collection_id: path.split("/").last
              )
            ]
          )

          CollectionReference.new query, path, client
        end

        protected

        ##
        # @private
        def random_document_id
          Generate.unique_id
        end

        ##
        # @private Raise an error unless an database available.
        def ensure_client!
          raise "Must have active connection to service" unless client
        end
      end
    end
  end
end
