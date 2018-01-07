# Copyright 2014 Google LLC
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


require "google-cloud-datastore"
require "google/cloud/datastore/errors"
require "google/cloud/datastore/dataset"
require "google/cloud/datastore/transaction"
require "google/cloud/datastore/credentials"
require "google/cloud/config"
require "google/cloud/env"

module Google
  module Cloud
    ##
    # # Google Cloud Datastore
    #
    # Google Cloud Datastore is a fully managed, schemaless database for storing
    # non-relational data. You should feel at home if you are familiar with
    # relational databases, but there are some key differences to be aware of to
    # make the most of using Datastore.
    #
    # The goal of google-cloud is to provide an API that is comfortable to
    # Rubyists. Your authentication credentials are detected automatically in
    # Google Cloud Platform environments such as Google Compute Engine, Google
    # App Engine and Google Kubernetes Engine. In other environments you can
    # configure authentication easily, either directly in your code or via
    # environment variables. Read more about the options for connecting in the
    # [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new(
    #   project_id: "my-todo-project",
    #   credentials: "/path/to/keyfile.json"
    # )
    #
    # task = datastore.find "Task", "sampleTask"
    # task["priority"] = 5
    # datastore.save task
    # ```
    #
    # You can learn more about various options for connection on the
    # [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # To learn more about Datastore, read the
    # [Google Cloud Datastore Concepts Overview
    # ](https://cloud.google.com/datastore/docs/concepts/overview).
    #
    # ## Retrieving records
    #
    # Records, called "entities" in Datastore, are retrieved by using a key.
    # The key is more than a numeric identifier, it is a complex data structure
    # that can be used to model relationships. The simplest key has a string
    # <tt>kind</tt> value and either a numeric <tt>id</tt> value or a string
    # <tt>name</tt> value. A single record can be retrieved by calling
    # {Google::Cloud::Datastore::Dataset#find} and passing the parts of the key:
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task = datastore.find "Task", "sampleTask"
    # ```
    #
    # Optionally, {Google::Cloud::Datastore::Dataset#find} can be given a key
    # object:
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task_key = datastore.key "Task", 123456
    # task = datastore.find task_key
    # ```
    #
    # See {Google::Cloud::Datastore::Dataset#find}
    #
    # ## Querying records
    #
    # Multiple records can be found that match criteria.
    # (See {Google::Cloud::Datastore::Query#where})
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # query = datastore.query("Task").
    #   where("done", "=", false)
    #
    # tasks = datastore.run query
    # ```
    #
    # Records can also be ordered. (See {Google::Cloud::Datastore::Query#order})
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # query = datastore.query("Task").
    #   order("created")
    #
    # tasks = datastore.run query
    # ```
    #
    # The number of records returned can be specified.
    # (See {Google::Cloud::Datastore::Query#limit})
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # query = datastore.query("Task").
    #   limit(5)
    #
    # tasks = datastore.run query
    # ```
    #
    # When using Datastore in a multitenant application, a query may be run
    # within a namespace using the `namespace` option. (See
    # [Multitenancy](https://cloud.google.com/datastore/docs/concepts/multitenancy))
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # query = datastore.query("Task").
    #   where("done", "=", false)
    #
    # tasks = datastore.run query, namespace: "example-ns"
    # ```
    #
    # Records' key structures can also be queried.
    # (See {Google::Cloud::Datastore::Query#ancestor})
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task_list_key = datastore.key "TaskList", "default"
    #
    # query = datastore.query("Task").
    #   ancestor(task_list_key)
    #
    # tasks = datastore.run query
    # ```
    #
    # See {Google::Cloud::Datastore::Query} and
    # {Google::Cloud::Datastore::Dataset#run}
    #
    # ### Paginating records
    #
    # All records may not return at once, but multiple calls can be made to
    # Datastore to return them all.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # query = datastore.query("Task")
    # tasks = datastore.run query
    # tasks.all do |t|
    #   puts t["description"]
    # end
    # ```
    #
    # See {Google::Cloud::Datastore::Dataset::LookupResults} and
    # {Google::Cloud::Datastore::Dataset::QueryResults}
    #
    # ## Creating records
    #
    # New entities can be created and persisted buy calling
    # {Google::Cloud::Datastore::Dataset#save}. The entity must have a key to be
    # saved. If the key is incomplete then it will be completed when saved.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task = datastore.entity "Task" do |t|
    #   t["type"] = "Personal"
    #   t["done"] = false
    #   t["priority"] = 4
    #   t["description"] = "Learn Cloud Datastore"
    # end
    # task.key.id #=> nil
    # datastore.save task
    # task.key.id #=> 123456
    # ```
    #
    # Multiple new entities may be created in a batch.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task1 = datastore.entity "Task" do |t|
    #   t["type"] = "Personal"
    #   t["done"] = false
    #   t["priority"] = 4
    #   t["description"] = "Learn Cloud Datastore"
    # end
    #
    # task2 = datastore.entity "Task" do |t|
    #   t["type"] = "Personal"
    #   t["done"] = false
    #   t["priority"] = 5
    #   t["description"] = "Integrate Cloud Datastore"
    # end
    #
    # tasks = datastore.save(task1, task2)
    # task_key1 = tasks[0].key
    # task_key2 = tasks[1].key
    # ```
    #
    # Entities in Datastore form a hierarchically structured space similar to
    # the directory structure of a file system. When you create an entity, you
    # can optionally designate another entity as its parent; the new entity is a
    # child of the parent entity.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task_key = datastore.key "Task", "sampleTask"
    # task_key.parent = datastore.key "TaskList", "default"
    #
    # task = datastore.entity task_key do |t|
    #   t["type"] = "Personal"
    #   t["done"] = false
    #   t["priority"] = 5
    #   t["description"] = "Integrate Cloud Datastore"
    # end
    # ```
    #
    # ## Setting properties
    #
    # Entities hold properties. A property has a name that is a string or
    # symbol, and a value that is an object. Most value objects are supported,
    # including `String`, `Integer`, `Date`, `Time`, and even other entity or
    # key objects. Changes to the entity's properties are persisted by calling
    # {Google::Cloud::Datastore::Dataset#save}.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task = datastore.find "Task", "sampleTask"
    # # Read the priority property
    # task["priority"] #=> 4
    # # Write the priority property
    # task["priority"] = 5
    # # Persist the changes
    # datastore.save task
    # ```
    #
    # Array properties can be used to store more than one value.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task = datastore.entity "Task", "sampleTask" do |t|
    #   t["tags"] = ["fun", "programming"]
    #   t["collaborators"] = ["alice", "bob"]
    # end
    # ```
    #
    # ## Deleting records
    #
    # Entities can be removed from Datastore by calling
    # {Google::Cloud::Datastore::Dataset#delete} and passing the entity object
    # or the entity's key object.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task = datastore.find "Task", "sampleTask"
    # datastore.delete task
    # ```
    #
    # Multiple entities may be deleted in a batch.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task_key1 = datastore.key "Task", "sampleTask1"
    # task_key2 = datastore.key "Task", "sampleTask2"
    # datastore.delete task_key1, task_key2
    # ```
    #
    # ## Transactions
    #
    # Complex logic can be wrapped in a transaction. All queries and updates
    # within the {Google::Cloud::Datastore::Dataset#transaction} block are run
    # within the transaction scope, and will be automatically committed when the
    # block completes.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task_key = datastore.key "Task", "sampleTask"
    #
    # datastore.transaction do |tx|
    #   if tx.find(task_key).nil?
    #     task = datastore.entity task_key do |t|
    #       t["type"] = "Personal"
    #       t["done"] = false
    #       t["priority"] = 4
    #       t["description"] = "Learn Cloud Datastore"
    #     end
    #     tx.save task
    #   end
    # end
    # ```
    #
    # Alternatively, if no block is given the transaction object is returned
    # allowing you to commit or rollback manually.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task_key = datastore.key "Task", "sampleTask"
    #
    # tx = datastore.transaction
    # begin
    #   if tx.find(task_key).nil?
    #     task = datastore.entity task_key do |t|
    #       t["type"] = "Personal"
    #       t["done"] = false
    #       t["priority"] = 4
    #       t["description"] = "Learn Cloud Datastore"
    #     end
    #     tx.save task
    #   end
    #   tx.commit
    # rescue
    #   tx.rollback
    # end
    # ```
    #
    # A read-only transaction cannot modify entities; in return they do not
    # contend with other read-write or read-only transactions. Using a read-only
    # transaction for transactions that only read data will potentially improve
    # throughput.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # task_list_key = datastore.key "TaskList", "default"
    # query = datastore.query("Task").
    #   ancestor(task_list_key)
    #
    # tasks = nil
    #
    # datastore.transaction read_only: true do |tx|
    #   task_list = tx.find task_list_key
    #   if task_list
    #     tasks = tx.run query
    #   end
    # end
    # ```
    #
    # See {Google::Cloud::Datastore::Transaction} and
    # {Google::Cloud::Datastore::Dataset#transaction}
    #
    # ## Querying metadata
    #
    # Datastore provides programmatic access to some of its metadata to support
    # meta-programming, implementing backend administrative functions, simplify
    # consistent caching, and similar purposes. The metadata available includes
    # information about the entity groups, namespaces, entity kinds, and
    # properties your application uses, as well as the property representations
    # for each property.
    #
    # The special entity kind `__namespace__` can be used to find all the
    # namespaces used in your application entities.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # query = datastore.query("__namespace__").
    #   select("__key__").
    #   where("__key__", ">=", datastore.key("__namespace__", "g")).
    #   where("__key__", "<", datastore.key("__namespace__", "h"))
    #
    # namespaces = datastore.run(query).map do |entity|
    #   entity.key.name
    # end
    # ```
    #
    # The special entity kind `__kind__` can be used to return all the
    # kinds used in your application.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # query = datastore.query("__kind__").
    #   select("__key__")
    #
    # kinds = datastore.run(query).map do |entity|
    #   entity.key.name
    # end
    # ```
    #
    # Property queries return entities of kind `__property__` denoting the
    # indexed properties associated with an entity kind. (Unindexed properties
    # are not included.)
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # query = datastore.query("__property__").
    #   select("__key__")
    #
    # entities = datastore.run(query)
    # properties_by_kind = entities.each_with_object({}) do |entity, memo|
    #   kind = entity.key.parent.name
    #   prop = entity.key.name
    #   memo[kind] ||= []
    #   memo[kind] << prop
    # end
    # ```
    #
    # Property queries support ancestor filtering on a `__kind__` or
    # `__property__` key, to limit the query results to a single kind or
    # property. The `property_representation` property in the entity
    # representing property `p` of kind `k` is an array containing all
    # representations of `p`'s value in any entity of kind `k`.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # ancestor_key = datastore.key "__kind__", "Task"
    # query = datastore.query("__property__").
    #   ancestor(ancestor_key)
    #
    # entities = datastore.run(query)
    # representations = entities.each_with_object({}) do |entity, memo|
    #   property_name = entity.key.name
    #   property_types = entity["property_representation"]
    #   memo[property_name] = property_types
    # end
    # ```
    #
    # Property queries can also be filtered with a range over the
    # pseudo-property `__key__`, where the keys denote either `__kind__` or
    # `__property__` entities.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new
    #
    # start_key = datastore.key "__property__", "priority"
    # start_key.parent = datastore.key "__kind__", "Task"
    # query = datastore.query("__property__").
    #   select("__key__").
    #   where("__key__", ">=", start_key)
    #
    # entities = datastore.run(query)
    # properties_by_kind = entities.each_with_object({}) do |entity, memo|
    #   kind = entity.key.parent.name
    #   prop = entity.key.name
    #   memo[kind] ||= []
    #   memo[kind] << prop
    # end
    # ```
    #
    # ## Configuring timeout
    #
    # You can configure the request `timeout` value in seconds.
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # datastore = Google::Cloud::Datastore.new timeout: 120
    # ```
    #
    # ## The Cloud Datastore Emulator
    #
    # As of this release, the Cloud Datastore emulator that is part of the
    # gcloud SDK is no longer compatible with google-cloud. This is because the
    # gcloud SDK's Cloud Datastore emulator does not yet support gRPC as a
    # transport layer.
    #
    # A gRPC-compatible emulator is available until the gcloud SDK Cloud
    # Datastore emulator supports gRPC. To use it you must [download the gRPC
    # emulator](https://storage.googleapis.com/gcd/tools/cloud-datastore-emulator-1.1.1.zip)
    # and use the `cloud_datastore_emulator` script.
    #
    # When you run the Cloud Datastore emulator you will see a message similar
    # to the following printed:
    #
    # ```
    # If you are using a library that supports the DATASTORE_EMULATOR_HOST
    # environment variable, run:
    #
    # export DATASTORE_EMULATOR_HOST=localhost:8978
    # ```
    #
    # Now you can connect to the emulator using the `DATASTORE_EMULATOR_HOST`
    # environment variable:
    #
    # ```ruby
    # require "google/cloud/datastore"
    #
    # # Make Datastore use the emulator
    # ENV["DATASTORE_EMULATOR_HOST"] = "localhost:8978"
    #
    # datastore = Google::Cloud::Datastore.new project: "emulator-project-id"
    #
    # task = datastore.entity "Task", "emulatorTask" do |t|
    #   t["type"] = "Testing"
    #   t["done"] = false
    #   t["priority"] = 5
    #   t["description"] = "Use Datastore Emulator"
    # end
    #
    # datastore.save task
    # ```
    #
    module Datastore
      ##
      # Creates a new object for connecting to the Datastore service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String] project_id Identifier for a Datastore project. If not
      #   present, the default project for the credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Datastore::Credentials})
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
      #   behavior of the API client. See Google::Gax::CallSettings. Optional.
      # @param [String] emulator_host Datastore emulator host. Optional.
      #   If the param is nil, uses the value of the `emulator_host` config.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Datastore::Dataset]
      #
      # @example
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new(
      #     project_id: "my-todo-project",
      #     credentials: "/path/to/keyfile.json"
      #   )
      #
      #   task = datastore.entity "Task", "sampleTask" do |t|
      #     t["type"] = "Personal"
      #     t["done"] = false
      #     t["priority"] = 4
      #     t["description"] = "Learn Cloud Datastore"
      #   end
      #
      #   datastore.save task
      #
      def self.new project_id: nil, credentials: nil, scope: nil, timeout: nil,
                   client_config: nil, emulator_host: nil, project: nil,
                   keyfile: nil
        project_id ||= (project || default_project_id)
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        scope ||= configure.scope
        timeout ||= configure.timeout
        client_config ||= configure.client_config
        emulator_host ||= configure.emulator_host
        if emulator_host
          return Datastore::Dataset.new(
            Datastore::Service.new(
              project_id, :this_channel_is_insecure,
              host: emulator_host, client_config: client_config
            )
          )
        end

        credentials ||= (keyfile || default_credentials(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Datastore::Credentials.new credentials, scope: scope
        end

        Datastore::Dataset.new(
          Datastore::Service.new(
            project_id, credentials,
            timeout: timeout, client_config: client_config
          )
        )
      end

      ##
      # Reload datastore configuration from defaults. For testing.
      # @private
      #
      def self.reload_configuration!
        Google::Cloud.configure.delete! :datastore
        Google::Cloud.configure.add_config! :datastore do |config|
          config.add_field! :project_id,
                            (ENV["DATASTORE_DATASET"] ||
                             ENV["DATASTORE_PROJECT"]),
                            match: String
          config.add_alias! :project, :project_id
          config.add_field! :credentials, nil,
                            match: [String, Hash, Google::Auth::Credentials]
          config.add_alias! :keyfile, :credentials
          config.add_field! :scope, nil, match: [String, Array]
          config.add_field! :timeout, nil, match: Integer
          config.add_field! :client_config, nil, match: Hash
          config.add_field! :emulator_host, ENV["DATASTORE_EMULATOR_HOST"],
                            match: String
        end
      end

      reload_configuration! unless Google::Cloud.configure.subconfig? :datastore

      ##
      # Configure the Google Cloud Datastore library.
      #
      # The following Datastore configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a Datastore project. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Datastore::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `client_config` - (Hash) A hash of values to override the default
      #   behavior of the API client.
      # * `emulator_host` - (String) Host name of the emulator. Defaults to
      #   `ENV["DATASTORE_EMULATOR_HOST"]`
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Bigquery library uses.
      #
      def self.configure
        yield Google::Cloud.configure.datastore if block_given?

        Google::Cloud.configure.datastore
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.datastore.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.datastore.credentials ||
          Google::Cloud.configure.credentials ||
          Datastore::Credentials.default(scope: scope)
      end
    end
  end
end
