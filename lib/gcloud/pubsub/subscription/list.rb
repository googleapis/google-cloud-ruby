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
    class Subscription
      ##
      # Subscription::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more subscriptions
        # that match the request and this value should be passed to
        # the next {Gcloud::Pubsub::Topic#subscriptions} to continue.
        attr_accessor :token

        ##
        # Create a new Subscription::List with an array of values.
        def initialize arr = [], token = nil
          super arr
          @token = token
          @token = nil if @token == ""
        end

        ##
        # @private New Subscriptions::List from a
        # Google::Pubsub::V1::ListSubscriptionsRequest object.
        def self.from_grpc grpc_list, conn, service
          subs = Array(grpc_list.subscriptions).map do |grpc|
            if grpc.is_a? String
              Subscription.new_lazy grpc, conn, service
            else
              Subscription.from_grpc grpc, conn, service
            end
          end
          new subs, grpc_list.next_page_token
        end
      end
    end
  end
end
