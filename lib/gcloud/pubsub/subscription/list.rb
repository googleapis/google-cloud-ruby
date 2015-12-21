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
        # the next {Gcloud::PubSub::Topic#subscriptions} to continue.
        attr_accessor :token

        ##
        # Create a new Subscription::List with an array of values.
        def initialize arr = [], token = nil
          super arr
          @token = token
        end

        ##
        # @private New Subscription::List from a response object.
        def self.from_response resp, conn
          subs = Array(resp.data["subscriptions"]).map do |gapi_object|
            if gapi_object.is_a? String
              Subscription.new_lazy gapi_object, conn
            else
              Subscription.from_gapi gapi_object, conn
            end
          end
          new subs, resp.data["nextPageToken"]
        end
      end
    end
  end
end
