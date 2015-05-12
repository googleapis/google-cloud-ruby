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

require "json"
require "gcloud/bigquery/errors"
require "gcloud/bigquery/list"

module Gcloud
  module Bigquery
    ##
    # Represents a Dataset.
    class Dataset
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Dataset object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
      end

      ##
      # A unique ID for this dataset, without the project name.
      # The ID must contain only letters (a-z, A-Z), numbers (0-9),
      # or underscores (_). The maximum length is 1,024 characters.
      def dataset_id
        @gapi["datasetReference"]["datasetId"]
      end

      ##
      # The ID of the project containing this dataset.
      def project_id
        @gapi["datasetReference"]["projectId"]
      end

      ##
      # A descriptive name for the dataset.
      def name
        @gapi["friendlyName"]
      end

      ##
      # A user-friendly description of the dataset.
      def description
        @gapi["description"]
      end

      ##
      # The default lifetime of all tables in the dataset, in milliseconds.
      def default_expiration
        @gapi["defaultTableExpirationMs"]
      end

      ##
      # The time when this dataset was created.
      def created_at
        return nil if @gapi["creationTime"].nil?
        Time.at(@gapi["creationTime"] / 1000.0)
      end

      ##
      # The date when this dataset or any of its tables was last modified.
      def modified_at
        return nil if @gapi["lastModifiedTime"].nil?
        Time.at(@gapi["lastModifiedTime"] / 1000.0)
      end

      ##
      # Permenently deletes the dataset.
      # The dataset must be empty.
      #
      #   dataset.delete
      def delete options = {}
        ensure_connection!
        resp = connection.delete_dataset dataset_id, options
        if resp.success?
          true
        else
          ApiError.from_response(resp)
        end
      end

      ##
      # New Dataset from a Google API Client object.
      def self.from_gapi gapi, conn #:nodoc:
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
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
