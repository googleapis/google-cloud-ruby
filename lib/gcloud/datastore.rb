# Copyright 2014 Google Inc. All rights reserved.
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


require "gcloud"
require "gcloud/datastore/errors"
require "gcloud/datastore/dataset"
require "gcloud/datastore/transaction"
require "gcloud/datastore/credentials"

module Gcloud
  ##
  # Creates a new object for connecting to the Datastore service.
  # Each call creates a new connection.
  #
  # For more information on connecting to Google Cloud see the [Authentication
  # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
  #
  # @param [String] project Dataset identifier for the Datastore you are
  #   connecting to.
  # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If file
  #   path the file must be readable.
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scope is:
  #
  #   * `https://www.googleapis.com/auth/datastore`
  #
  # @return [Gcloud::Datastore::Dataset]
  #
  # @example
  #   require "gcloud/datastore"
  #
  #   datastore = Gcloud.datastore "my-todo-project",
  #                              "/path/to/keyfile.json"
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
  def self.datastore project = nil, keyfile = nil, scope: nil
    project ||= Gcloud::Datastore::Dataset.default_project
    if ENV["DATASTORE_EMULATOR_HOST"]
      ds = Gcloud::Datastore::Dataset.new project, :this_channel_is_insecure
      ds.service.host = ENV["DATASTORE_EMULATOR_HOST"]
      return ds
    end
    if keyfile.nil?
      credentials = Gcloud::Datastore::Credentials.default scope: scope
    else
      credentials = Gcloud::Datastore::Credentials.new keyfile, scope: scope
    end
    Gcloud::Datastore::Dataset.new project, credentials
  end

  ##
  # # Google Cloud Datastore
  #
  # Google Cloud Datastore is a fully managed, schemaless database for storing
  # non-relational data. You should feel at home if you are familiar with
  # relational databases, but there are some key differences to be aware of to
  # make the most of using Datastore.
  #
  # Gcloud's goal is to provide a API that is familiar and comfortable to
  # Rubyists. Authentication is handled by {Gcloud#datastore}. You can provide
  # the project and credential information to connect to the Datastore service,
  # or if you are running on Google Compute Engine this configuration is taken
  # care of for you.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new "my-todo-project",
  #                     "/path/to/keyfile.json"
  # datastore = gcloud.datastore
  #
  # task = datastore.find "Task", "sampleTask"
  # task["priority"] = 5
  # datastore.save task
  # ```
  #
  # You can learn more about various options for connection on the
  # [Authentication
  # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
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
  # <tt>kind</tt> value, and either a numeric <tt>id</tt> value, or a string
  # <tt>name</tt> value. A single record can be retrieved by calling
  # {Gcloud::Datastore::Dataset#find} and passing the parts of the key:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
  #
  # task = datastore.find "Task", "sampleTask"
  # ```
  #
  # Optionally, {Gcloud::Datastore::Dataset#find} can be given a key object:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
  #
  # task_key = datastore.key "Task", 123456
  # task = datastore.find task_key
  # ```
  #
  # See {Gcloud::Datastore::Dataset#find}
  #
  # ## Querying records
  #
  # Multiple records can be found that match criteria.
  # (See {Gcloud::Datastore::Query#where})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
  #
  # query = datastore.query("Task").
  #   where("done", "=", false)
  #
  # tasks = datastore.run query
  # ```
  #
  # Records can also be ordered. (See {Gcloud::Datastore::Query#order})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
  #
  # query = datastore.query("Task").
  #   order("created")
  #
  # tasks = datastore.run query
  # ```
  #
  # The number of records returned can be specified.
  # (See {Gcloud::Datastore::Query#limit})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
  #
  # query = datastore.query("Task").
  #   limit(5)
  #
  # tasks = datastore.run query
  # ```
  #
  # Records' key structures can also be queried.
  # (See {Gcloud::Datastore::Query#ancestor})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
  #
  # task_list_key = datastore.key "TaskList", "default"
  #
  # query = datastore.query("Task").
  #   ancestor(task_list_key)
  #
  # tasks = datastore.run query
  # ```
  #
  # See {Gcloud::Datastore::Query} and {Gcloud::Datastore::Dataset#run}
  #
  # ### Paginating records
  #
  # All records may not return at once, requiring multiple calls to Datastore
  # to return them all. The returned records will have a <tt>cursor</tt> if
  # there are more available.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
  #
  # task_list_key = datastore.key "TaskList", "default"
  #
  # query = datastore.query("Task").
  #   ancestor(task_list_key)
  # all_tasks = []
  # tmp_tasks = datastore.run query
  # while tmp_tasks.any? do
  #   tmp_tasks.each do |task|
  #     all_tasks << task
  #   end
  #   # break loop if no more tasks available
  #   break if tmp_tasks.cursor.nil?
  #   # set cursor on the query
  #   query = query.cursor tmp_tasks.cursor
  #   # query for more records
  #   tmp_tasks = datastore.run query
  # end
  # ```
  #
  # See {Gcloud::Datastore::Dataset::LookupResults} and
  # {Gcloud::Datastore::Dataset::QueryResults}
  #
  # ## Creating records
  #
  # New entities can be created and persisted buy calling
  # {Gcloud::Datastore::Dataset#save}. The entity must have a key to be saved.
  # If the key is incomplete then it will be completed when saved.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
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
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
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
  # Entities in Datastore form a hierarchically structured space similar to the
  # directory structure of a file system. When you create an entity, you can
  # optionally designate another entity as its parent; the new entity is a child
  # of the parent entity.
  #
  # ```ruby
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
  # Entities hold properties. A property has a name that is a string or symbol,
  # and a value that is an object. Most value objects are supported, including
  # String, Integer, Date, Time, and even other entity or key objects. Changes
  # to the entity's properties are persisted by calling
  # {Gcloud::Datastore::Dataset#save}.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
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
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
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
  # {Gcloud::Datastore::Dataset#delete} and passing the entity object or the
  # entity's key object.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
  #
  # task = datastore.find "Task", "sampleTask"
  # datastore.delete task
  # ```
  #
  # Multiple entities may be deleted in a batch.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
  #
  # task_key1 = datastore.key "Task", "sampleTask1"
  # task_key2 = datastore.key "Task", "sampleTask2"
  # datastore.delete task_key1, task_key2
  # ```
  #
  # ## Transactions
  #
  # Complex logic can be wrapped in a Transaction. All queries and updates
  # within the {Gcloud::Datastore::Dataset#transaction} block are run within the
  # transaction scope, and will be automatically committed when the block
  # completes.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
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
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # datastore = gcloud.datastore
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
  # See {Gcloud::Datastore::Transaction} and
  # {Gcloud::Datastore::Dataset#transaction}
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
  # query = datastore.query("__kind__").
  #   select("__key__")
  #
  # kinds = datastore.run(query).map do |entity|
  #   entity.key.name
  # end
  # ```
  #
  # Property queries return entities of kind `__property__` denoting the indexed
  # properties associated with an entity kind. (Unindexed properties are not
  # included.)
  #
  # ```ruby
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
  # `__property__` key, to limit the query results to a single kind or property.
  # The `property_representation` property in the entity representing property
  # `p` of kind `k` is an array containing all representations of `p`'s value in
  # any entity of kind `k`.
  #
  # ```ruby
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
  # Property queries can also be filtered with a range over the pseudo-property
  # `__key__`, where the keys denote either `__kind__` or `__property__`
  # entities.
  #
  # ```ruby
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
  # ## The Datastore Emulator
  #
  # As of this release, the Datastore emulator that is part of the gcloud SDK is
  # no longer compatible with gcloud-ruby. This is because the gcloud SDK's
  # Datastore emulator does not yet support gRPC as a transport layer.
  #
  # A gRPC-compatible emulator is available until the gcloud SDK Datastore
  # emulator supports gRPC. To use it you must [download the gRPC
  # emulator](https://storage.googleapis.com/gcd/tools/gcd-grpc-1.0.0.zip) and
  # use the `gcd.sh` script.
  #
  # When you run the gRPC emulator you will see a message similar to the
  # following printed:
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
  # require "gcloud"
  #
  # # Make Datastore use the emulator
  # ENV["DATASTORE_EMULATOR_HOST"] = "localhost:8978"
  #
  # gcloud = Gcloud.new "emulator-project-id"
  # datastore = gcloud.datastore
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
  end
end
