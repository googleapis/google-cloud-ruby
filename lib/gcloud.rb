#--
# Copyright 2015 Google Inc. All rights reserved.
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

require "gcloud/version"

##
# = Google Cloud
#
# Gcloud is the official library for interacting with the Google Cloud Platform.
# Google Cloud Platform is a set of modular cloud-based services that allow
# you to create anything from simple websites to complex applications.
#
# Gcloud's goal is to provide a API that is familiar and comfortable to
# Rubyists. Authentication is handled by providing project and credential
# information, or if you are running on Google Compute Engine this configuration
# is taken care of for you.
#
# You can learn more about various options for connection on the
# {Authentication Guide}[AUTHENTICATION.md].
#
module Gcloud
  ##
  # Creates a new object for connecting to Google Cloud.
  #
  # === Parameters
  #
  # +project+::
  #   Project identifier for the Pub/Sub service you are connecting to.
  #   (+String+)
  # +keyfile+::
  #   Keyfile downloaded from Google Cloud. If file path the file must be
  #   readable. (+String+ or +Hash+)
  #
  # === Returns
  #
  # Gcloud
  #
  # === Example
  #
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   dataset = gcloud.datastore
  #   pubsub  = gcloud.pubsub
  #   storage = gcloud.storage
  #
  def self.new project = nil, keyfile = nil
    gcloud = Object.new
    gcloud.instance_eval do
      @project = project
      @keyfile = keyfile
    end
    gcloud.extend Gcloud
    gcloud
  end

  ##
  # Creates a new object for connecting to the Datastore service.
  # Each call creates a new connection.
  #
  # === Returns
  #
  # Gcloud::Datastore::Dataset
  #
  # === Example
  #
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   dataset = gcloud.datastore
  #
  #   entity = Gcloud::Datastore::Entity.new
  #   entity.key = Gcloud::Datastore::Key.new "Task"
  #   entity["description"] = "Get started with Google Cloud"
  #   entity["completed"] = false
  #
  #   dataset.save entity
  #
  def datastore
    require "gcloud/datastore"
    Gcloud.datastore @project, @keyfile
  end

  ##
  # Creates a new object for connecting to the Storage service.
  # Each call creates a new connection.
  #
  # === Returns
  #
  # Gcloud::Storage::Project
  #
  # === Example
  #
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   storage = gcloud.storage
  #   bucket = storage.bucket "my-bucket"
  #   file = bucket.file "path/to/my-file.ext"
  #
  def storage
    require "gcloud/storage"
    Gcloud.storage @project, @keyfile
  end

  ##
  # Creates a new object for connecting to the Pub/Sub service.
  # Each call creates a new connection.
  #
  # === Returns
  #
  # Gcloud::Pubsub::Project
  #
  # === Example
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   pubsub = gcloud.pubsub
  #   topic = pubsub.topic "my-topic"
  #   topic.publish "task completed"
  #
  def pubsub
    require "gcloud/pubsub"
    Gcloud.pubsub @project, @keyfile
  end

  ##
  # Creates a new object for connecting to the BigQuery service.
  # Each call creates a new connection.
  #
  # === Returns
  #
  # Gcloud::Bigquery::Project
  #
  # === Example
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   bigquery = gcloud.bigquery
  #   dataset = bigquery.dataset "my-dataset"
  #   table = dataset.table "my-table"
  #   table.data.each do |row|
  #     puts row
  #   end
  #
  def bigquery
    require "gcloud/bigquery"
    Gcloud.bigquery @project, @keyfile
  end

  ##
  # Base Gcloud exception class.
  class Error < StandardError
  end
end
