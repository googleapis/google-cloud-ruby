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

require "gcloud/bigquery/connection"
require "gcloud/bigquery/credentials"
require "gcloud/bigquery/errors"
require "gcloud/bigquery/dataset"
require "gcloud/bigquery/job"

module Gcloud
  module Bigquery
    ##
    # Represents the Project that the Datasets and Files belong to.
    class Project
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize project, credentials
        @connection = Connection.new project, credentials
      end

      ##
      # The project identifier.
      def project
        connection.project
      end

      ##
      # Default project.
      def self.default_project #:nodoc:
        ENV["PUBSUB_PROJECT"] || ENV["GOOGLE_CLOUD_PROJECT"]
      end

      ##
      # Retrieves dataset by name.
      def dataset dataset_name
        ensure_connection!
        resp = connection.get_dataset dataset_name
        if resp.success?
          Dataset.from_gapi resp.data, connection
        else
          return nil if resp.data["error"]["code"] == 404
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Creates a new dataset.
      #
      #   dataset = project.create_dataset "my-dataset"
      def create_dataset options = {}
        ensure_connection!
        resp = connection.insert_dataset options
        if resp.success?
          Dataset.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves a list of datasets for the given project.
      def datasets options = {}
        ensure_connection!
        resp = connection.list_datasets options
        if resp.success?
          List.datasets_from_resp resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves job by name.
      def job job_id
        ensure_connection!
        resp = connection.get_job job_id
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          return nil if resp.data["error"]["code"] == 404
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves a list of jobs for the given project.
      def jobs options = {}
        ensure_connection!
        resp = connection.list_jobs options
        if resp.success?
          Job::List.from_resp resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end
    end
  end
end
