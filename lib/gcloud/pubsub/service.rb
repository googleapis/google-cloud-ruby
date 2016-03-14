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


require "google/pubsub/v1/pubsub_services"

module Gcloud
  module Pubsub
    ##
    # @private Represents the gRPC Pub/Sub service, including all the API
    # methods.
    class Service
      attr_accessor :project, :credentials, :host

      ##
      # Creates a new Service instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @host = "pubsub.googleapis.com"
      end

      def creds
        GRPC::Core::ChannelCredentials.new.compose \
          GRPC::Core::CallCredentials.new credentials.client.updater_proc
      end

      def subscriber
        return mocked_subscriber if mocked_subscriber
        @subscriber ||= Google::Pubsub::V1::Subscriber::Stub.new host, creds
      end
      attr_accessor :mocked_subscriber

      def publisher
        return mocked_publisher if mocked_publisher
        @publisher ||= Google::Pubsub::V1::Publisher::Stub.new host, creds
      end
      attr_accessor :mocked_publisher

      def project_path options = {}
        project_name = options[:project] || project
        "projects/#{project_name}"
      end

      def topic_path topic_name, options = {}
        return topic_name if topic_name.to_s.include? "/"
        "#{project_path(options)}/topics/#{topic_name}"
      end

      def subscription_path subscription_name, options = {}
        return subscription_name if subscription_name.to_s.include? "/"
        "#{project_path(options)}/subscriptions/#{subscription_name}"
      end

      def inspect
        "#{self.class}(#{@project})"
      end
    end
  end
end
