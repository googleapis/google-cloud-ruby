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
require "google/api_client"

module Gcloud
  module Bigquery
    ##
    # Represents the connection to Bigquery,
    # as well as expose the API calls.
    class Connection #:nodoc:
      API_VERSION = "v2"

      attr_accessor :project
      attr_accessor :credentials #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @client = Google::APIClient.new application_name:    "gcloud-ruby",
                                        application_version: Gcloud::VERSION
        @client.authorization = @credentials.client
        @bigquery = @client.discovered_api "bigquery", API_VERSION
      end

      ##
      # Lists all datasets in the specified project to which you have
      # been granted the READER dataset role.
      def list_datasets options = {}
        params = { projectId: @project,
                   all: options.delete(:all),
                   pageToken: options.delete(:token),
                   maxResults: options.delete(:max)
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @bigquery.datasets.list,
          parameters: params
        )
      end

      ##
      # Returns the dataset specified by datasetID.
      def get_dataset dataset_id
        @client.execute(
          api_method: @bigquery.datasets.get,
          parameters: { projectId: @project, datasetId: dataset_id }
        )
      end

      ##
      # Creates a new empty dataset.
      def insert_dataset options = {}
        @client.execute(
          api_method: @bigquery.datasets.insert,
          parameters: { projectId: @project },
          body_object: insert_dataset_request(options)
        )
      end

      ##
      # Updates information in an existing dataset, only replacing
      # fields that are provided in the submitted dataset resource.
      def patch_dataset project_id, dataset_id, options = {}
        body = { friendlyName: options[:name],
                 description: options[:description],
                 defaultTableExpirationMs: options[:table_expiration]
               }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @bigquery.datasets.patch,
          parameters: { projectId: project_id, datasetId: dataset_id },
          body_object: body
        )
      end

      ##
      # Deletes the dataset specified by the datasetId value.
      # Before you can delete a dataset, you must delete all its tables,
      # either manually or by specifying force: true in options.
      # Immediately after deletion, you can create another dataset with
      # the same name.
      def delete_dataset dataset_id, options = {}
        @client.execute(
          api_method: @bigquery.datasets.delete,
          parameters: { projectId: @project, datasetId: dataset_id,
                        deleteContents: options[:force]
                      }.delete_if { |_, v| v.nil? }
        )
      end

      protected

      ##
      # Make sure the object is converted to a hash
      # Ruby 1.9.3 doesn't support to_h, so here we are.
      def hashify hash
        if hash.respond_to? :to_h
          hash.to_h
        else
          Hash.try_convert(hash) || {}
        end
      end

      ##
      # Create the HTTP body for insert dataset
      def insert_dataset_request options = {}
        {
          "kind" => "bigquery#dataset",
          "friendlyName" => options[:name],
          "description" => options[:description],
          "defaultTableExpirationMs" => options[:default_expiration]
        }
      end
    end
  end
end
