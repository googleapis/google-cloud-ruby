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

require "gcloud/datastore/connection"

module Gcloud
  ##
  # Google Cloud Datastore
  #
  #   conn = Gcloud::Datastore.new "my-todo-project", "/path/to/keyfile.json"
  #   entity = prod.find "Task", "start"
  #   entity["completed"] = true
  #   conn.save entity
  #
  module Datastore
    ##
    # Returns the default connection.
    def self.connection
      @@connection ||= new
    end

    ##
    # Sets the default connection.
    def self.connection= new_connection
      @@connection = new_connection
    end

    ##
    # Create a new Connection
    #
    #   entity = Gcloud::Datastore::Entity.new
    #   entity.key = Gcloud::Datastore::Key.new "Task"
    #   entity["description"] = "Get started with Google Cloud"
    #   entity["completed"] = false
    #
    #   conn = Gcloud::Datastore.new "my-todo-project", "/path/to/keyfile.json"
    #   conn.save entity
    #
    # @param dataset_id [String] the dataset identifier for the Datastore
    # you are connecting to.
    # @param keyfile [String] the path to the keyfile you downloaded from
    # Google Cloud. The file must readable.
    # @return [Gcloud::Datastore::Connection] new connection
    #
    def self.new dataset_id = ENV["DATASTORE_PROJECT"],
                 keyfile    = ENV["DATASTORE_KEYFILE"]
      conn = Gcloud::Datastore::Connection.new dataset_id, keyfile
      # Store in connection if empty
      @@connection ||= conn
      conn
    end

    ##
    # Special connection for Local Development Server
    #
    #   prod = Gcloud::Datastore.new "my-todo-project", "/path/to/keyfile.json"
    #   entity = prod.find "Task", "start"
    #
    #   local = Gcloud::Datastore.devserver "my-todo-project"
    #   local.save entity
    #
    # See https://cloud.google.com/datastore/docs/tools/devserver
    def self.devserver dataset_id = ENV["DEVSERVER_PROJECT"],
                       host = "localhost", port = 8080
      conn = Gcloud::Datastore::Devserver.new dataset_id, host, port
      # Store in connection if empty
      @@connection ||= conn
      conn
    end
  end
end
