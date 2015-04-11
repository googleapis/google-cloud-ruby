#--
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
  # Create a new Gcloud::Datastore::Dataset.
  #
  #   entity = Gcloud::Datastore::Entity.new
  #   entity.key = Gcloud::Datastore::Key.new "Task"
  #   entity["description"] = "Get started with Google Cloud"
  #   entity["completed"] = false
  #
  #   dataset = Gcloud.datastore "my-todo-project",
  #                              "/path/to/keyfile.json"
  #   dataset.save entity
  #
  # @param dataset_id [String] the dataset identifier for the Datastore
  # you are connecting to.
  # @param keyfile [String] the path to the keyfile you downloaded from
  # Google Cloud. The file must readable.
  # @return [Gcloud::Datastore::Dataset] new dataset.
  #
  # See Gcloud::Datastore::Dataset
  def self.datastore project = nil, keyfile = nil
    project ||= Gcloud::Datastore::Dataset.default_project
    if keyfile.nil?
      credentials = Gcloud::Datastore::Credentials.default
    else
      credentials = Gcloud::Datastore::Credentials.new keyfile
    end
    Gcloud::Datastore::Dataset.new project, credentials
  end

  ##
  # Google Cloud Datastore
  #
  #   dataset = Gcloud.datastore "my-todo-project",
  #                              "/path/to/keyfile.json"
  #   entity = dataset.find "Task", "start"
  #   entity["completed"] = true
  #   dataset.save entity
  #
  #
  # See Gcloud::Datastore::Dataset
  module Datastore
  end
end
