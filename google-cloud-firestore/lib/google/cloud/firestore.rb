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


require "google-cloud-firestore"
require "google/cloud/firestore/client"
require "google/cloud/config"
require "google/cloud/env"

module Google
  module Cloud
    ##
    # # Cloud Firestore
    #
    # Cloud Firestore is a NoSQL document database built for automatic scaling,
    # high performance, and ease of application development. While the Cloud
    # Firestore interface has many of the same features as traditional
    # databases, as a NoSQL database it differs from them in the way it
    # describes relationships between data objects.
    #
    # For more information about Cloud Firestore, read the [Cloud
    # Firestore Documentation](https://cloud.google.com/firestore/docs/).
    #
    # The goal of google-cloud is to provide an API that is comfortable to
    # Rubyists. Authentication is handled by {Google::Cloud#firestore}. You can
    # provide the project and credential information to connect to the Cloud
    # Firestore service, or if you are running on Google Compute Engine this
    # configuration is taken care of for you. You can read more about the
    # options for connecting in the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # ## Adding data
    #
    # Cloud Firestore stores data in Documents, which are stored in Collections.
    # Cloud Firestore creates collections and documents implicitly the first
    # time you add data to the document. (For more information, see [Adding Data
    # to Cloud Firestore](https://cloud.google.com/firestore/docs/manage-data/add-data).
    #
    # To create or overwrite a single document, use {Firestore::Client#doc} to
    # obtain a document reference. (This does not create a document in Cloud
    # Firestore.) Then, call {Firestore::DocumentReference#set} to create the
    # document or overwrite an existing document:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a document reference
    # nyc_ref = firestore.doc "cities/NYC"
    #
    # nyc_ref.set({ name: "New York City" }) # Document created
    # ```
    #
    # When you use this combination of `doc` and `set` to create a new document,
    # you must specify an ID for the document. (In the example above, the ID is
    # "NYC".) However, if you do not have a meaningful ID for the document, you
    # may omit the ID from a call to {Firestore::CollectionReference#doc}, and
    # Cloud Firestore will auto-generate an ID for you.
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a collection reference
    # cities_col = firestore.col "cities"
    #
    # # Get a document reference with data
    # random_ref = cities_col.doc
    # random_ref.set({ name: "New York City" })
    #
    # # The document ID is randomly generated
    # random_ref.document_id #=> "RANDOMID123XYZ"
    # ```
    #
    # You can perform both of the operations shown above, auto-generating
    # an ID and creating the document, in a single call to
    # {Firestore::CollectionReference#add}.
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a collection reference
    # cities_col = firestore.col "cities"
    #
    # # Get a document reference with data
    # random_ref = cities_col.add({ name: "New York City" })
    #
    # # The document ID is randomly generated
    # random_ref.document_id #=> "RANDOMID123XYZ"
    # ```
    #
    # You can also use `add` to create an empty document:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a collection reference
    # cities_col = firestore.col "cities"
    #
    # # Create a document without data
    # random_ref = cities_col.add
    #
    # # The document ID is randomly generated
    # random_ref.document_id #=> "RANDOMID123XYZ"
    # ```
    #
    # ## Retrieving collection references
    #
    # Collections are simply named containers for documents. A collection
    # contains documents and nothing else. It can't directly contain raw fields
    # with values, and it can't contain other collections. You do not need to
    # "create" or "delete" collections. After you create the first document in a
    # collection, the collection exists. If you delete all of the documents in a
    # collection, it no longer exists. (For more information, see [Cloud
    # Firestore Data Model](https://cloud.google.com/firestore/docs/data-model).
    #
    # Use {Firestore::Client#cols} to list the root-level collections:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get the root collections
    # firestore.cols.each do |col|
    #   puts col.collection_id
    # end
    # ```
    #
    # Retrieving a reference to a single root-level collection is similar:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get the cities collection
    # cities_col = firestore.col "cities"
    # ```
    #
    # To list the collections in a document, first get the document reference,
    # then use {Firestore::DocumentReference#cols}:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a document reference
    # nyc_ref = firestore.doc "cities/NYC"
    #
    # nyc_ref.cols.each do |col|
    #   puts col.collection_id
    # end
    # ```
    #
    # Again, retrieving a reference to a single collection is similar::
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a document reference
    # nyc_ref = firestore.doc "cities/NYC"
    #
    # # Get precincts sub-collection
    # precincts_col = nyc_ref.col "precincts"
    # ```
    #
    # ## Reading data
    #
    # You can retrieve a snapshot of the data in a single document with
    # {Firestore::DocumentReference#get}, which returns an instance of
    # {Firestore::DocumentSnapshot}:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a document reference
    # nyc_ref = firestore.doc "cities/NYC"
    #
    # nyc_snap = nyc_ref.get
    # nyc_snap[:population] #=> 1000000
    # ```
    # In the example above, {Firestore::DocumentSnapshot#[]} is used to access a
    # top-level field. To access nested fields, use {Firestore::FieldPath}:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # user_snap = firestore.doc("users/frank").get
    #
    # nested_field_path = Google::Cloud::Firestore::FieldPath.new(
    #   :favorites, :food
    # )
    # user_snap.get(nested_field_path) #=> "Pizza"
    # ```
    #
    # Or, use {Firestore::Client#get_all} to retrieve a list of document
    # snapshots (data):
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get and print city documents
    # cities = ["cities/NYC", "cities/SF", "cities/LA"]
    # firestore.get_all(cities).each do |city|
    #   puts "#{city.document_id} has #{city[:population]} residents."
    # end
    # ```
    #
    # To retrieve all of the document snapshots in a collection, use
    # {Firestore::CollectionReference#get}:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a collection reference
    # cities_col = firestore.col "cities"
    #
    # # Get and print all city documents
    # cities_col.get do |city|
    #   puts "#{city.document_id} has #{city[:population]} residents."
    # end
    # ```
    #
    # The example above is actually a simple query without filters. Let's look
    # at some other queries for Cloud Firestore.
    #
    # ## Querying data
    #
    # Use {Firestore::Query#where} to filter queries on a field:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a collection reference
    # cities_col = firestore.col "cities"
    #
    # # Create a query
    # query = cities_col.where(:population, :>=, 1000000)
    #
    # query.get do |city|
    #   puts "#{city.document_id} has #{city[:population]} residents."
    # end
    # ```
    #
    # You can order the query results with {Firestore::Query#order}:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a collection reference
    # cities_col = firestore.col "cities"
    #
    # # Create a query
    # query = cities_col.order(:name, :desc)
    #
    # query.get do |city|
    #   puts "#{city.document_id} has #{city[:population]} residents."
    # end
    # ```
    #
    # Query methods may be chained, as in this example using
    # {Firestore::Query#limit} and  {Firestore::Query#offset} to perform
    # pagination:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a collection reference
    # cities_col = firestore.col "cities"
    #
    # # Create a query
    # query = cities_col.limit(5).offset(10)
    #
    # query.get do |city|
    #   puts "#{city.document_id} has #{city[:population]} residents."
    # end
    # ```
    #
    # See [Managing Indexes in Cloud
    # Firestore](https://cloud.google.com/firestore/docs/query-data/indexing) to
    # ensure the best performance for your queries.
    #
    # ## Updating data
    #
    # You can use {Firestore::DocumentReference#set} to completely overwrite an
    # existing document:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a document reference
    # nyc_ref = firestore.doc "cities/NYC"
    #
    # nyc_ref.set({ name: "New York City" })
    # ```
    #
    # Or, to selectively update only the fields appearing in your `data`
    # argument, set the `merge` option to `true`:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a document reference
    # nyc_ref = firestore.doc "cities/NYC"
    #
    # nyc_ref.set({ name: "New York City" }, merge: true)
    # ```
    #
    # Use {Firestore::DocumentReference#update} to directly update a
    # deeply-nested field with a {Firestore::FieldPath}:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # user_ref = firestore.doc "users/frank"
    #
    # nested_field_path = Google::Cloud::Firestore::FieldPath.new(
    #   :favorites, :food
    # )
    # user_ref.update({ nested_field_path: "Pasta" })
    # ```
    #
    # ## Using transactions and batched writes
    #
    # Cloud Firestore supports atomic operations for reading and writing data.
    # In a set of atomic operations, either all of the operations succeed, or
    # none of them are applied. There are two types of atomic operations in
    # Cloud Firestore: A transaction is a set of read and write operations on
    # one or more documents, while a batched write is a set of only write
    # operations on one or more documents. (For more information, see
    # [Transactions and Batched Writes](https://cloud.google.com/firestore/docs/manage-data/transactions).
    #
    # ### Transactions
    #
    # A transaction consists of any number of read operations followed by any
    # number of write operations. (Read operations must always come before write
    # operations.) In the case of a concurrent update by another client, Cloud
    # Firestore runs the entire transaction again. Therefore, transaction blocks
    # should be idempotent and should not not directly modify application state.
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # city = firestore.col("cities").doc("SF")
    # city.set({ name: "San Francisco",
    #            state: "CA",
    #            country: "USA",
    #            capital: false,
    #            population: 860000 })
    #
    # firestore.transaction do |tx|
    #   new_population = tx.get(city).data[:population] + 1
    #   tx.update(city, { population: new_population })
    # end
    # ```
    #
    # ### Batched writes
    #
    # If you do not need to read any documents in your operation set, you can
    # execute multiple write operations as a single batch. A batch of writes
    # completes atomically and can write to multiple documents. Batched writes
    # are also useful for migrating large data sets to Cloud Firestore.
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # firestore.batch do |b|
    #   # Set the data for NYC
    #   b.set("cities/NYC", { name: "New York City" })
    #
    #   # Update the population for SF
    #   b.update("cities/SF", { population: 1000000 })
    #
    #   # Delete LA
    #   b.delete("cities/LA")
    # end
    # ```
    #
    # ## Deleting data
    #
    # Use {Firestore::DocumentReference#delete} to delete a document from Cloud
    # Firestore:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a document reference
    # nyc_ref = firestore.doc "cities/NYC"
    #
    # nyc_ref.delete
    # ```
    #
    # To delete specific fields from a document, use the
    # {Firestore::Client.field_delete} method when you update a document:
    #
    # ```ruby
    # require "google/cloud/firestore"
    #
    # firestore = Google::Cloud::Firestore.new
    #
    # # Get a document reference
    # nyc_ref = firestore.doc "cities/NYC"
    #
    # nyc_ref.update({ name: "New York City",
    #                  trash: firestore.field_delete })
    # ```
    #
    # To delete an entire collection or sub-collection in Cloud Firestore,
    # retrieve all the documents within the collection or sub-collection and
    # delete them. If you have larger collections, you may want to delete the
    # documents in smaller batches to avoid out-of-memory errors. Repeat the
    # process until you've deleted the entire collection or sub-collection.
    #
    module Firestore
      ##
      # Creates a new object for connecting to the Firestore service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String] project_id Identifier for a Firestore project. If not
      #   present, the default project for the credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Firestore::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/datastore`
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [Hash] client_config A hash of values to override the default
      #   behavior of the API client. Optional.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Firestore::Client]
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      def self.new project_id: nil, credentials: nil, scope: nil, timeout: nil,
                   client_config: nil, project: nil, keyfile: nil
        project_id ||= (project || default_project_id)
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        scope ||= configure.scope
        timeout ||= configure.timeout
        client_config ||= configure.client_config

        credentials ||= (keyfile || default_credentials(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Firestore::Credentials.new credentials, scope: scope
        end

        Firestore::Client.new(
          Firestore::Service.new(
            project_id, credentials, timeout: timeout,
                                     client_config: client_config
          )
        )
      end

      ##
      # Reload firestore configuration from defaults. For testing.
      # @private
      #
      def self.reload_configuration!
        default_creds = Google::Cloud.credentials_from_env(
          "FIRESTORE_CREDENTIALS", "FIRESTORE_CREDENTIALS_JSON",
          "FIRESTORE_KEYFILE", "FIRESTORE_KEYFILE_JSON"
        )

        Google::Cloud.configure.delete! :firestore
        Google::Cloud.configure.add_config! :firestore do |config|
          config.add_field! :project_id, ENV["FIRESTORE_PROJECT"], match: String
          config.add_alias! :project, :project_id
          config.add_field! :credentials, default_creds,
                            match: [String, Hash, Google::Auth::Credentials]
          config.add_alias! :keyfile, :credentials
          config.add_field! :scope, nil, match: [String, Array]
          config.add_field! :timeout, nil, match: Integer
          config.add_field! :client_config, nil, match: Hash
        end
      end

      reload_configuration! unless Google::Cloud.configure.subconfig? :firestore

      ##
      # Configure the Google Cloud Firestore library.
      #
      # The following Firestore configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a Firestore project. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Firestore::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `client_config` - (Hash) A hash of values to override the default
      #   behavior of the API client.
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Firestore library uses.
      #
      def self.configure
        yield Google::Cloud.configure.firestore if block_given?

        Google::Cloud.configure.firestore
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.firestore.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.firestore.credentials ||
          Google::Cloud.configure.credentials ||
          Firestore::Credentials.default(scope: scope)
      end
    end
  end
end
