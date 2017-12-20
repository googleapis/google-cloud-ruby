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


require "google/cloud/firestore/document"
require "google/cloud/firestore/query"
require "google/cloud/firestore/generate"

module Google
  module Cloud
    module Firestore
      ##
      # # Collection
      #
      # (See {Collection::Reference}).
      #
      module Collection
        ##
        # @private New Collection reference object from a path.
        def self.from_path path, context
          Reference.new.tap do |c|
            c.context = context
            c.instance_variable_set :@path, path
          end
        end

        ##
        # # Collection::Reference
        #
        # A collection reference object ise used for adding documents, getting
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
        #   cities_col.docs do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        class Reference
          ##
          # @private The connection context object.
          attr_accessor :context

          ##
          # The project identifier for the Cloud Firestore project that the
          # collection resource belongs to.
          #
          # @return [String] project identifier.
          def project_id
            path.split("/")[1]
          end

          ##
          # The database identifier for the Cloud Firestore database that the
          # collection resource belongs to.
          #
          # @return [String] database identifier.
          def database_id
            path.split("/")[3]
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
          # A string representing the full path of the collection resource.
          #
          # @return [String] collection resource path.
          def path
            @path
          end

          ##
          # The document reference or database the collection reference belongs
          # to. If the collection is a root collection, it will return the
          # database object. If the collection is nested under a document, it
          # will return the document reference object.
          #
          # @return [Database, Collection::Reference] parent object.
          #
          # @example Returns database object for root collections:
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
              return Document.from_path parent_path, context
            end
            return context.database if context.respond_to? :database
            context
          end

          ##
          # Retrieves a list of documents.
          #
          # @yield [documents] The block for accessing the documents with data.
          # @yieldparam [Document::Snapshot] document A document with data.
          #
          # @return [Enumerator<Document::Snapshot>] documents with data list.
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
          #   cities_col.docs do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def docs &block
            query.run(&block)
          end
          alias_method :documents, :docs
          alias_method :get, :docs
          alias_method :run, :docs

          ##
          # Retrieves a document.
          #
          # @param [String, nil] document_path A string representing the path of
          #   the document, relative to the document root of the database. If a
          #   string is not provided, and random document identifier will be
          #   generated. Optional.
          #
          # @return [Document::Reference] A document.
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
          # @example Create a document refernce with a random ID:
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

            ensure_context!
            context.doc "#{collection_path}/#{document_path}"
          end
          alias_method :document, :doc

          ##
          # Create a document with random document identifier.
          #
          # The operation will fail if the document already exists.
          #
          # @param [Hash] data The document's fields and values. Optional.
          #
          # @return [Document::Reference] A created document.
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
          # @example Create a document with data:
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Get a document reference with data
          #   random_ref = cities_col.add({ name: "New York City" })
          #
          #   # The document ID is randomly generated
          #   random_ref.document_id #=> "RANDOMID123XYZ"
          #
          def add data = nil
            data ||= {}
            doc.tap { |d| d.create data }
          end

          ##
          # Retrieves a list of documents with data.
          #
          # @param [String, Document::Reference] docs One or more strings
          #   representing the path of the document, or document reference
          #   objects.
          # @param [Array<String|Symbol>, String|Symbol] mask A list of field
          #   paths to filter the returned document data by.
          #
          # @yield [documents] The block for accessing the documents with data.
          # @yieldparam [Document::Snapshot] document A document with data.
          #
          # @return [Enumerator<Document::Snapshot>] documents with data list.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Get and print city documents
          #   cities = ["cities/NYC", "cities/SF", "cities/LA"]
          #   cities_col.get_all(cities).each do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def get_all *docs, mask: nil, &block
            ensure_context!

            # Get document_path, not path
            doc_paths = Array(docs).flatten.map do |doc_path|
              if doc_path.respond_to? :document_path
                doc_path.document_path
              else
                doc(doc_path).document_path
              end
            end

            context.get_all(doc_paths, mask: mask, &block)
          end
          alias_method :get_docs, :get_all
          alias_method :get_documents, :get_all
          alias_method :find, :get_all

          ##
          # Creates a query object.
          #
          # @return [Query] A query.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Create a query
          #   query = cities_col.query.select(:population).from(:cities)
          #
          #   # Get/run a query
          #   query.get do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def query
            ensure_context!

            Query.start(parent_path, context).from(collection_id)
          end
          alias_method :q, :query

          ##
          # Creates a query object with method `select` called on it. (See
          # {Query#select}.)
          #
          # @param [String, Symbol] fields A field mask to filter results with
          #   and return only the specified fields. One or more field paths can
          #   be specified.
          #
          # @return [Query] A query with `select` called on it.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Create a query
          #   query = cities_col.select(:population).from(:cities)
          #
          #   # Get/run a query
          #   firestore.get(query).each do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def select *fields
            query.select fields
          end

          ##
          # Creates a query object with method `from` called on it. (See
          # {Query#from}.)
          #
          # @param [String] collection_path A string representing the path of
          #   the collection, relative to the document root of the database, to
          #   query results from.
          #
          # @return [Query] A query with `from` called on it.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Create a query
          #   query = cities_col.from(:cities).select(:population)
          #
          #   # Get/run a query
          #   firestore.get(query).each do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def from collection_path
            query.from collection_path
          end

          ##
          # Creates a query object with method `where` called on it. (See
          # {Query#where}.)
          #
          # @param [String, Symbol] field A field mask to filter results with
          #   and return only the specified fields. One or more field paths can
          #   be specified.
          # @param [String, Symbol] operator The operation to compare the field
          #   to. Acceptable values include:
          #
          #   * less than: `<`, `lt`
          #   * less than or equal: `<=`, `lte`
          #   * greater than: `>`, `gt`
          #   * greater than or equal: `>=`, `gte`
          #   * equal: `=`, `==`, `eq`, `eql`, `is`
          # @param [Object] value A value the field is compared to.
          #
          # @return [Query] A query with `where` called on it.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Create a query
          #   query = cities_col.where(:population, :>=, 1000000).
          #                      select(:population).from(:cities)
          #
          #   # Get/run a query
          #   firestore.get(query).each do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def where field, operator, value
            query.where field, operator, value
          end

          ##
          # Creates a query object with method `order` called on it. (See
          # {Query#order}.)
          #
          # @param [String, Symbol] field A field mask to order results with.
          # @param [String, Symbol] direction The direction to order the results
          #   by. Optional. Default is ascending.
          #
          # @return [Query] A query with `order` called on it.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Create a query
          #   query = cities_col.order(:name).
          #                      select(:population).from(:cities)
          #
          #   # Get/run a query
          #   firestore.get(query).each do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def order field, direction = :asc
            query.order field, direction
          end

          ##
          # Creates a query object with method `offset` called on it. (See
          # {Query#offset}.)
          #
          # @param [Integer] num The number of results to skip.
          #
          # @return [Query] A query with `offset` called on it.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Create a query
          #   query = cities_col.limit(5).offset(10).
          #                      select(:population).from(:cities)
          #
          #   # Get/run a query
          #   firestore.get(query).each do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def offset num
            query.offset num
          end

          ##
          # Creates a query object with method `limit` called on it. (See
          # {Query#limit}.)
          #
          # @param [Integer] num The maximum number of results to return.
          #
          # @return [Query] A query with `limit` called on it.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Create a query
          #   query = cities_col.offset(10).limit(5).
          #                      select(:population).from(:cities)
          #
          #   # Get/run a query
          #   firestore.get(query).each do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def limit num
            query.limit num
          end

          ##
          # Creates a query object with method `start_at` called on it. (See
          # {Query#start_at}.)
          #
          # @param [Object] values The field value to start the query at.
          #
          # @return [Query] A query with `start_at` called on it.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Create a query
          #   query = cities_col.start_at("NYC").
          #                      select(:population).from(:cities)
          #
          #   # Get/run a query
          #   firestore.get(query).each do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def start_at *values
            query.start_at values
          end

          ##
          # Creates a query object with method `start_after` called on it. (See
          # {Query#start_after}.)
          #
          # @param [Object] values The field value to start the query after.
          #
          # @return [Query] A query with `start_after` called on it.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Create a query
          #   query = cities_col.start_after("NYC").
          #                      select(:population).from(:cities)
          #
          #   # Get/run a query
          #   firestore.get(query).each do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def start_after *values
            query.start_after values
          end

          ##
          # Creates a query object with method `end_before` called on it. (See
          # {Query#end_before}.)
          #
          # @param [Object] values The field value to end the query before.
          #
          # @return [Query] A query with `end_before` called on it.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Create a query
          #   query = cities_col.end_before("NYC").
          #                      select(:population).from(:cities)
          #
          #   # Get/run a query
          #   firestore.get(query).each do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def end_before *values
            query.end_before values
          end

          ##
          # Creates a query object with method `end_at` called on it. (See
          # {Query#end_at}.)
          #
          # @param [Object] values The field value to end the query at.
          #
          # @return [Query] A query with `end_at` called on it.
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #
          #   # Get a collection reference
          #   cities_col = firestore.col "cities"
          #
          #   # Create a query
          #   query = cities_col.end_at("NYC").
          #                      select(:population).from(:cities)
          #
          #   # Get/run a query
          #   firestore.get(query).each do |city|
          #     puts "#{city.document_id} has #{city[:population]} residents."
          #   end
          #
          def end_at *values
            query.end_at values
          end

          protected

          ##
          # @private
          def parent_path
            path.split("/")[0...-1].join("/")
          end

          ##
          # @private
          def random_document_id
            Generate.unique_id
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
