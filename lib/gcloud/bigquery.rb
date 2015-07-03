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

require "gcloud"
require "gcloud/bigquery/project"

#--
# Google Cloud BigQuery
module Gcloud
  ##
  # Creates a new object for connecting to the BigQuery service.
  # Each call creates a new connection.
  #
  # === Parameters
  #
  # +project+::
  #   Project identifier for the BigQuery service you are connecting to.
  #   (+String+)
  # +keyfile+::
  #   Keyfile downloaded from Google Cloud. If file path the file must be
  #   readable. (+String+ or +Hash+)
  #
  # === Returns
  #
  # Gcloud::Bigquery::Project
  #
  # === Example
  #
  #   require "glcoud/bigquery"
  #
  #   bigquery = Gcloud.bigquery
  #   dataset = bigquery.dataset "my-dataset"
  #   table = dataset.table "my-table"
  #
  def self.bigquery project = nil, keyfile = nil
    project ||= Gcloud::Bigquery::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Bigquery::Credentials.default
    else
      credentials = Gcloud::Bigquery::Credentials.new keyfile
    end
    Gcloud::Bigquery::Project.new project, credentials
  end

  ##
  # = Google Cloud BigQuery
  #
  # Google BigQuery enables you to query massive datasets without the time and
  # expense of building hardware and infrastructure. BigQuery enables
  # super-fast, SQL-like queries against append-only tables, using the
  # processing power of Google's infrastructure.
  #
  # == Basic Concepts
  # === Project
  # === Dataset
  # === Table
  # === Job
  # == Loading Data into BigQuery
  # === Uploading a file
  # === Streaming records individually
  # === Importing from Google Cloud Storage
  # === Loading from Datastore Backup
  # === CSV vs. JSON
  # == Querying Data
  # === Synchronous queries
  # === Asynchronous queries
  # === Interactive vs. batch queries
  # === Query Caching
  # == Using Views
  # === Creating a view
  # === Listing view vs. tables
  # === Querying from a view
  # == Copying Data
  # == Exporting Data
  # === One file
  # === Multiple files
  # === CSV vs. JSON
  #
  module Bigquery
  end
end
