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


require "delegate"

module Gcloud
  module Pubsub
    class Topic
      ##
      # Topic::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more topics
        # that match the request and this value should be passed to
        # the next {Gcloud::Pubsub::Project#topics} to continue.
        attr_accessor :token

        ##
        # @private Create a new Topic::List with an array of values.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of topics.
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of topics.
        def next
          return nil unless next?
          ensure_service!
          options = { token: token, max: @max }
          grpc = @service.list_topics options
          self.class.from_grpc grpc, @service, @max
        rescue GRPC::BadStatus => e
          raise Error.from_error(e)
        end

        ##
        # @private New Topic::List from a Google::Pubsub::V1::ListTopicsResponse
        # object.
        def self.from_grpc grpc_list, service, max = nil
          topics = new(Array(grpc_list.topics).map do |grpc|
            Topic.from_grpc grpc, service
          end, grpc_list.next_page_token)
          topics.instance_variable_set "@service", service
          topics.instance_variable_set "@max",     max
          topics
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless @service
        end
      end
    end
  end
end
