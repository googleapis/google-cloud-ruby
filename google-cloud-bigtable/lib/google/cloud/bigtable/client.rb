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

module Google
  module Cloud
    module BigTable
      class Client 
        
        def initialize(project_id)
          @project_id = project_id 
        end

        # Returns an instance of Instance Enumerable.
        # This is the entrypoint for all Intances related operations.
        #
        # @return [InstaceEnum]
        # 
        # @example
        #   require 'google/cloud/bigtable'
        #   
        #   client = Google::Cloud::BigTable::Client.new 'project_id'
        #   bigtable_instances = client.instances
        #
        #   # Print the display names of each instances.
        #   bigtable_instances.each do |instance|
        #     print instance.display_name
        #   end
        #
        #   # Print comma separated instance names
        #   instance_names = bigtable_instances.map(&:display_name)
        #   print instance_names.join ', '
        #
        #   # create a new instance
        #   instance = bigtable_instances.create 'myinstance', 
        #                                name: 'My First Instance'
        def instances
        end
      end
      
      # InstanceEnum is an Enumerable which encapsulates all the actions that
      # can be performed on BigTable Instances.
      class InstanceEnum
        include Enumerable
        
        # Fetches instance information from BigTable admin api and yields
        # objects of +Instance+ type. This method is provided to be used for
        # Enumerable module. 
        #
        # each takes care of pagination from source api.
        # 
        # @yield [Instance]
        def each
        end

        # Creates an instance for BigTable.
        #
        # @return [Instance]
        #
        # @param [String] id Unique id for a BigTable Instance
        # @param [String] name Display Name for the BigTable Instance
        # @param [enum] type The type of instance to create. The type can
        #   be one of [:PRODUCTION, :DEVELOPMENT, :TYPE_UNSPECIFIED]. Default
        #   value id :PRODUCTION
        # @param [Hash] labels The key: value labels for the instance
        # @param [Hash] clusters The clusters to created in the instance.
        def create(id, name: nil, type: :PRODUCTION, labels: nil, clusters: nil)
        end

        # Return the instance corresponding to the given id.
        #
        # @return [Instance]
        #
        # @param [String] id This is the unique name or id for the instance. This
        #  is not the display name.
        def find(id)
        end
      end

      class Instance

        # delete the current instance
        def delete
        end
      end
    end
  end
end
      