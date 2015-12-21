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
# # Google Cloud
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
# [Authentication Guide](AUTHENTICATION).
#
module Gcloud
  ##
  # Creates a new object for connecting to Google Cloud.
  #
  # @param [String] project Project identifier for the Pub/Sub service you are
  #   connecting to.
  # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If file
  #   path the file must be readable.
  #
  # @return [Gcloud]
  #
  # @example
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
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   dataset = gcloud.datastore
  #
  #   entity = dataset.entity "Task" do |t|
  #     t["description"] = "Get started with Google Cloud"
  #     t["completed"] = false
  #   end
  #
  #   dataset.save entity
  #
  # @example You shouldn't need to override the default scope, but you can:
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
  #   dataset = gcloud.datastore scope: platform_scope
  #
  def datastore scope: nil
    require "gcloud/datastore"
    Gcloud.datastore @project, @keyfile, scope: scope
  end

  ##
  # Creates a new object for connecting to the Storage service.
  # Each call creates a new connection.
  #
  # @see https://cloud.google.com/storage/docs/authentication#oauth Storage
  #   OAuth 2.0 Authentication
  #
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scope is:
  #
  #   * `https://www.googleapis.com/auth/devstorage.full_control`
  #
  # @return [Gcloud::Storage::Project]
  #
  # @example
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   storage = gcloud.storage
  #   bucket = storage.bucket "my-bucket"
  #   file = bucket.file "path/to/my-file.ext"
  #
  # @example The default scope can be overridden with the `scope` option:
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   readonly_scope = "https://www.googleapis.com/auth/devstorage.read_only"
  #   readonly_storage = gcloud.storage scope: readonly_scope
  #
  def storage scope: nil
    require "gcloud/storage"
    Gcloud.storage @project, @keyfile, scope: scope
  end

  ##
  # Creates a new object for connecting to the Pub/Sub service.
  # Each call creates a new connection.
  #
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scope is:
  #
  #   * `https://www.googleapis.com/auth/pubsub`
  #
  # @return [Gcloud::Pubsub::Project]
  #
  # @example
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   pubsub = gcloud.pubsub
  #   topic = pubsub.topic "my-topic"
  #   topic.publish "task completed"
  #
  # @example The default scope can be overridden with the `scope` option:
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
  #   pubsub = gcloud.pubsub scope: platform_scope
  #
  def pubsub scope: nil
    require "gcloud/pubsub"
    Gcloud.pubsub @project, @keyfile, scope: scope
  end

  ##
  # Creates a new object for connecting to the BigQuery service.
  # Each call creates a new connection.
  #
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scope is:
  #
  #   * `https://www.googleapis.com/auth/bigquery`
  #
  # @return [Gcloud::Bigquery::Project]
  #
  # @example
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
  # @example The default scope can be overridden with the `scope` option:
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
  #   bigquery = gcloud.bigquery scope: platform_scope
  #
  def bigquery scope: nil
    require "gcloud/bigquery"
    Gcloud.bigquery @project, @keyfile, scope: scope
  end

  ##
  # Creates a new object for connecting to the DNS service.
  # Each call creates a new connection.
  #
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scope is:
  #
  #   * `https://www.googleapis.com/auth/ndev.clouddns.readwrite`
  #
  # @return [Gcloud::Dns::Project]
  #
  # @example
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-zone"
  #   zone.records.each do |record|
  #     puts record.name
  #   end
  #
  # @example The default scope can be overridden with the `scope` option:
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   readonly_scope = "https://www.googleapis.com/auth/ndev.clouddns.readonly"
  #   dns = gcloud.dns scope: readonly_scope
  #
  def dns scope: nil
    require "gcloud/dns"
    Gcloud.dns @project, @keyfile, scope: scope
  end

  # rubocop:disable Metrics/LineLength
  # Disabled because the readonly scope in the example code is long and we can't
  # shorten it.

  ##
  # Creates a new object for connecting to the Resource Manager service.
  # Each call creates a new connection.
  #
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scope is:
  #
  #   * `https://www.googleapis.com/auth/cloud-platform`
  #
  # @return [Gcloud::ResourceManager::Manager]
  #
  # @example
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   resource_manager = gcloud.resource_manager
  #   resource_manager.projects.each do |project|
  #     puts projects.project_id
  #   end
  #
  # @example The default scope can be overridden with the `scope` option:
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   readonly_scope = "https://www.googleapis.com/auth/cloudresourcemanager.readonly"
  #   resource_manager = gcloud.resource_manager scope: readonly_scope
  #
  def resource_manager scope: nil
    require "gcloud/resource_manager"
    Gcloud.resource_manager @keyfile, scope: scope
  end

  # rubocop:enable Metrics/LineLength

  ##
  # Creates a new object for connecting to the Search service.
  # Each call creates a new connection.
  #
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scopes are:
  #
  #   * `https://www.googleapis.com/auth/cloudsearch`
  #   * `https://www.googleapis.com/auth/userinfo.email`
  #
  # @return [Gcloud::Search::Project]
  #
  # @example
  #   require "gcloud"
  #
  def search scope: nil
    require "gcloud/search"
    Gcloud.search @project, @keyfile, scope: scope
  end

  ##
  # Creates a new object for connecting to the Logging service.
  # Each call creates a new connection.
  #
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scope is:
  #
  #   * `https://www.googleapis.com/auth/logging.admin`
  #
  # @return [Gcloud::Logging::Project]
  #
  # @example
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   logging = gcloud.logging
  #   # ...
  #
  # @example The default scope can be overridden with the `scope` option:
  #   require "gcloud"
  #
  #   gcloud  = Gcloud.new
  #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
  #   logging = gcloud.logging scope: platform_scope
  #
  def logging scope: nil
    require "gcloud/logging"
    Gcloud.logging @project, @keyfile, scope: scope
  end
end
