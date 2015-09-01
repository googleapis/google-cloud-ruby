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
  # === Parameters
  #
  # +options+::
  #   An optional Hash for controlling additional behavior. (+Hash+)
  # <code>options[:scope]</code>::
  #   The OAuth 2.0 scopes controlling the set of resources and operations that
  #   the connection can access. See {Using OAuth 2.0 to Access Google
  #   APIs}[https://developers.google.com/identity/protocols/OAuth2]. (+String+
  #   or +Array+)
  #
  #   The default scopes are:
  #
  #   * +https://www.googleapis.com/auth/datastore+
  #   * +https://www.googleapis.com/auth/userinfo.email+
  #
  # === Returns
  #
  # Gcloud::Datastore::Dataset
  #
  # === Examples
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
  # You shouldn't need to override the default scope, but it is possible to do
  # so with the +scope+ option:
  #
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
  #   dataset = gcloud.datastore scope: platform_scope
  #
  def datastore options = {}
    require "gcloud/datastore"
    Gcloud.datastore @project, @keyfile, options
  end

  ##
  # Creates a new object for connecting to the Storage service.
  # Each call creates a new connection.
  #
  # === Parameters
  #
  # +options+::
  #   An optional Hash for controlling additional behavior. (+Hash+)
  # <code>options[:scope]</code>::
  #   The OAuth 2.0 scopes controlling the set of resources and operations that
  #   the connection can access. See {Using OAuth 2.0 to Access Google
  #   APIs}[https://developers.google.com/identity/protocols/OAuth2]. (+String+
  #   or +Array+)
  #
  #   The default scope is:
  #
  #   * +https://www.googleapis.com/auth/devstorage.full_control+
  #
  # === Returns
  #
  # Gcloud::Storage::Project
  #
  # === Examples
  #
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   storage = gcloud.storage
  #   bucket = storage.bucket "my-bucket"
  #   file = bucket.file "path/to/my-file.ext"
  #
  # The default scope can be overridden with the +scope+ option. For more
  # information see {Storage OAuth 2.0
  # Authentication}[https://cloud.google.com/storage/docs/authentication#oauth].
  #
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   readonly_scope = "https://www.googleapis.com/auth/devstorage.read_only"
  #   readonly_storage = gcloud.storage scope: readonly_scope
  #
  def storage options = {}
    require "gcloud/storage"
    Gcloud.storage @project, @keyfile, options
  end

  ##
  # Creates a new object for connecting to the Pub/Sub service.
  # Each call creates a new connection.
  #
  # === Parameters
  #
  # +options+::
  #   An optional Hash for controlling additional behavior. (+Hash+)
  # <code>options[:scope]</code>::
  #   The OAuth 2.0 scopes controlling the set of resources and operations that
  #   the connection can access. See {Using OAuth 2.0 to Access Google
  #   APIs}[https://developers.google.com/identity/protocols/OAuth2]. (+String+
  #   or +Array+)
  #
  #   The default scope is:
  #
  #   * +https://www.googleapis.com/auth/pubsub+
  #
  # === Returns
  #
  # Gcloud::Pubsub::Project
  #
  # === Examples
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   pubsub = gcloud.pubsub
  #   topic = pubsub.topic "my-topic"
  #   topic.publish "task completed"
  #
  # The default scope can be overridden with the +scope+ option:
  #
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
  #   pubsub = gcloud.pubsub scope: platform_scope
  #
  def pubsub options = {}
    require "gcloud/pubsub"
    Gcloud.pubsub @project, @keyfile, options
  end

  ##
  # Creates a new object for connecting to the BigQuery service.
  # Each call creates a new connection.
  #
  # === Parameters
  #
  # +options+::
  #   An optional Hash for controlling additional behavior. (+Hash+)
  # <code>options[:scope]</code>::
  #   The OAuth 2.0 scopes controlling the set of resources and operations that
  #   the connection can access. See {Using OAuth 2.0 to Access Google
  #   APIs}[https://developers.google.com/identity/protocols/OAuth2]. (+String+
  #   or +Array+)
  #
  #   The default scope is:
  #
  #   * +https://www.googleapis.com/auth/bigquery+
  #
  # === Returns
  #
  # Gcloud::Bigquery::Project
  #
  # === Examples
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
  # The default scope can be overridden with the +scope+ option:
  #
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
  #   bigquery = gcloud.bigquery scope: platform_scope
  #
  def bigquery options = {}
    require "gcloud/bigquery"
    Gcloud.bigquery @project, @keyfile, options
  end
end
