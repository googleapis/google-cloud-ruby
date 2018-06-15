# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "google/cloud/bigtable/instance_set"

module Google
  module Cloud
    module Bigtable
      class Client
        # initializer for Google::Cloud::Bigtable::Client
        # @param config [Google::Cloud::Bigtable::Config]
        def initialize config
          @config = config
        end

        # returns an instance of InstanceSet. This is the handle to perform
        # any instance related operations.
        # @return [Google::Cloud::Bigtable::InstanceSet]
        # @example
        #   client = Google::Cloud::Bigtable::Client.new 'project_id'
        #   instances = client.instances
        def instances
          InstanceSet.new @config
        end
      end
    end
  end
end
