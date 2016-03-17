# Copyright 2016 Google Inc. All rights reserved.
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


require "gcloud/datastore/credentials"
require "google/datastore/v1beta3/datastore_services"

module Gcloud
  module Datastore
    ##
    # @private Represents the gRPC Datastore service, including all the API
    # methods.
    class Service
      API_URL = "https://www.googleapis.com"
      attr_accessor :project, :credentials

      ##
      # Creates a new Service instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
      end

      def creds
        GRPC::Core::ChannelCredentials.new.compose \
          GRPC::Core::CallCredentials.new credentials.client.updater_proc
      end

      ##
      # The Datastore API URL.
      def host
        @host || ENV["DATASTORE_HOST"] || DEFAULT_HOST
      end

      ##
      # Update the Datastore API URL.
      def host= new_host
        @datastore = nil # Reset the GRPC object when host is set
        @host = new_host
      end

      def datastore
        return mocked_datastore if mocked_datastore
        @datastore ||= Google::Datastore::V1beta3::Datastore::Stub.new(
          host, creds)
      end
      attr_accessor :mocked_datastore

      def inspect
        "#{self.class}(#{@dataset_id})"
      end
    end
  end
end
