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
  # @param [String] project Dataset identifier for the Datastore you are
  #   connecting to.
  # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If file
  #   path the file must be readable.
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scopes are:
  #
  #   * `https://www.googleapis.com/auth/datastore`
  #   * `https://www.googleapis.com/auth/userinfo.email`
  #
  # @return [Gcloud::Datastore::Dataset]
  #
  # @example
  #   require "gcloud/datastore"
  #
  #   dataset = Gcloud.datastore "my-todo-project",
  #                              "/path/to/keyfile.json"
  #
  #   entity = dataset.entity "Task" do |t|
  #     t["description"] = "Get started with Google Cloud"
  #     t["completed"] = false
  #   end
  #
  #   dataset.save entity
  #
  def self.datastore project = nil, keyfile = nil, scope: nil
    project ||= Gcloud::Datastore::Dataset.default_project
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
  # Rubyists. Authentication is handled by Gcloud#datastore. You can provide
  # the project and credential information to connect to the Datastore service,
  # or if you are running on Google Compute Engine this configuration is taken
  # care of for you.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new "my-todo-project",
  #                     "/path/to/keyfile.json"
  # dataset = gcloud.datastore
  # entity = dataset.find "Task", "start"
  # entity["completed"] = true
  # dataset.save entity
  # ```
  #
  # You can learn more about various options for connection on the
  # [Authentication Guide](../AUTHENTICATION).
  #
  # To learn more about Datastore, read the
  # [Google Cloud Datastore Concepts Overview
  # ](https://cloud.google.com/datastore/docs/concepts/overview).
  #
  # ## Retrieving Records
  #
  # Records, called "entities" in Datastore, are retrieved by using a Key.
  # The Key is more than a numeric identifier, it is a complex data structure
  # that can be used to model relationships. The simplest Key has a string
  # <tt>kind</tt> value, and either a numeric <tt>id</tt> value, or a string
  # <tt>name</tt> value. A single record can be retrieved by calling
  # Gcloud::Datastore::Dataset#find and passing the parts of the key:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dataset = gcloud.datastore
  # entity = dataset.find "Task", "start"
  # ```
  #
  # Optionally, Gcloud::Datastore::Dataset#find can be given a Key object:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dataset = gcloud.datastore
  # key = dataset.key "Task", 12345
  # entity = dataset.find key
  # ```
  #
  # See Gcloud::Datastore::Dataset#find
  #
  # ## Querying Records
  #
  # Multiple records can be found that match criteria.
  # (See Gcloud::Datastore::Query#where)
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dataset = gcloud.datastore
  # query = dataset.query("List").
  #   where("active", "=", true)
  # active_lists = dataset.run query
  # ```
  #
  # Records can also be ordered. (See Gcloud::Datastore::Query#order)
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dataset = gcloud.datastore
  # query = dataset.query("List").
  #   where("active", "=", true).
  #   order("name")
  # active_lists = dataset.run query
  # ```
  #
  # The number of records returned can be specified.
  # (See Gcloud::Datastore::Query#limit)
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dataset = gcloud.datastore
  # query = dataset.query("List").
  #   where("active", "=", true).
  #   order("name").
  #   limit(5)
  # active_lists = dataset.run query
  # ```
  #
  # Records' Key structures can also be queried.
  # (See Gcloud::Datastore::Query#ancestor)
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dataset = gcloud.datastore
  #
  # list = dataset.find "List", "todos"
  # query = dataset.query("Task").
  #   ancestor(list.key)
  # items = dataset.run query
  # ```
  #
  # See Gcloud::Datastore::Query and Gcloud::Datastore::Dataset#run
  #
  # ## Paginating Records
  #
  # All Records may not return at once, requiring multiple calls to Datastore
  # to return them all. The returned records will have a <tt>cursor</tt> if
  # there are more available.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dataset = gcloud.datastore
  #
  # list = dataset.find "List", "todos"
  # query = dataset.query("Task").
  #   ancestor(list.key)
  # all_tasks = []
  # tmp_tasks = dataset.run query
  # while tmp_tasks.any? do
  #   tmp_tasks.each do |task|
  #     all_tasks << task
  #   end
  #   # break loop if no more tasks available
  #   break if tmp_tasks.cursor.nil?
  #   # set cursor on the query
  #   query = query.cursor tmp_tasks.cursor
  #   # query for more records
  #   tmp_tasks = dataset.run query
  # end
  # ```
  #
  # See Gcloud::Datastore::Dataset::LookupResults and
  # Gcloud::Datastore::Dataset::QueryResults
  #
  # ## Creating Records
  #
  # New entities can be created and persisted buy calling Dataset#save.
  # The entity must have a Key to be saved. If the Key is incomplete then
  # it will be completed when saved.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dataset = gcloud.datastore
  # entity = dataset.entity "User" do |e|
  #   e["name"] = "Heidi Henderson"
  # end
  # entity.key.id #=> nil
  # dataset.save entity
  # entity.key.id #=> 123456789
  # ```
  #
  # ## Updating Records
  #
  # Entities hold properties. A property has a name that is a string or symbol,
  # and a value that is an object. Most value objects are supported, including
  # String, Integer, Date, Time, and even other Entity or Key objects. Changes
  # to the Entity's properties are persisted by calling Dataset#save.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dataset = gcloud.datastore
  # entity = dataset.find "User", "heidi"
  # # Read the status property
  # entity["status"] #=> "inactive"
  # # Write the status property
  # entity["status"] = "active"
  # # Persist the changes
  # dataset.save entity
  # ```
  #
  # ## Deleting Records
  #
  # Entities can be removed from Datastore by calling Dataset#delete and passing
  # the Entity object or the entity's Key object.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dataset = gcloud.datastore
  # entity = dataset.find "User", "heidi"
  # dataset.delete entity
  # ```
  #
  # ## Transactions
  #
  # Complex logic can be wrapped in a Transaction. All queries and updates
  # within the Dataset#transaction block are run within the transaction scope,
  # and will be automatically committed when the block completes.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dataset = gcloud.datastore
  #
  # key = dataset.key "User", "heidi"
  #
  # user = dataset.entity key do |u|
  #   u["name"] = "Heidi Henderson"
  #   u["email"] = "heidi@example.net"
  # end
  #
  # dataset.transaction do |tx|
  #   if tx.find(user.key).nil?
  #     tx.save user
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
  # dataset = gcloud.datastore
  #
  # key = dataset.key "User", "heidi"
  #
  # user = dataset.entity key do |u|
  #   u["name"] = "Heidi Henderson"
  #   u["email"] = "heidi@example.net"
  # end
  #
  # tx = dataset.transaction
  # begin
  #   if tx.find(user.key).nil?
  #     tx.save user
  #   end
  #   tx.commit
  # rescue
  #   tx.rollback
  # end
  # ```
  #
  # See Gcloud::Datastore::Transaction and
  # Gcloud::Datastore::Dataset#transaction
  module Datastore
  end
end
