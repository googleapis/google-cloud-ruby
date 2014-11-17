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
require "gcloud/datastore/dataset"
require "gcloud/datastore/transaction"
require "gcloud/datastore/credentials"

module Gcloud
  ##
  # Google Cloud Datastore
  #
  #   dataset = Gcloud::Datastore.dataset "my-todo-project",
  #                                       "/path/to/keyfile.json"
  #   entity = dataset.find "Task", "start"
  #   entity["completed"] = true
  #   dataset.save entity
  #
  module Datastore
    ##
    # Create a new Dataset.
    #
    #   entity = Gcloud::Datastore::Entity.new
    #   entity.key = Gcloud::Datastore::Key.new "Task"
    #   entity["description"] = "Get started with Google Cloud"
    #   entity["completed"] = false
    #
    #   dataset = Gcloud::Datastore.dataset "my-todo-project",
    #                                       "/path/to/keyfile.json"
    #   dataset.save entity
    #
    # @param dataset_id [String] the dataset identifier for the Datastore
    # you are connecting to.
    # @param keyfile [String] the path to the keyfile you downloaded from
    # Google Cloud. The file must readable.
    # @return [Gcloud::Datastore::Connection] new connection
    #
    def self.dataset project = ENV["DATASTORE_PROJECT"],
                     keyfile = ENV["DATASTORE_KEYFILE"]
      credentials = Gcloud::Datastore::Credentials.new keyfile
      Gcloud::Datastore::Dataset.new project, credentials
    end

    ##
    # Special dataset for connecting to a Local Development Server.
    #
    #   dataset = Gcloud::Datastore.dataset "my-todo-project",
    #                                       "/path/to/keyfile.json"
    #   entity = dataset.find "Task", "start"
    #
    #   devserver = Gcloud::Datastore.devserver "my-todo-project"
    #   devserver.save entity
    #
    # The URL of the devserver should be set in the DATASTORE_HOST
    # environment variable.
    #
    # See https://cloud.google.com/datastore/docs/tools/devserver
    def self.devserver project = ENV["DEVSERVER_PROJECT"],
                       host    = ENV["DEVSERVER_HOST"]
      credentials = Gcloud::Datastore::Credentials::Empty.new
      devserver = Gcloud::Datastore::Dataset.new project, credentials
      devserver.connection.http_host = (host || "http://localhost:8080")
      devserver
    end
  end
end
