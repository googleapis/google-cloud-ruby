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


module Gcloud
  module ResourceManager
    class Project
      ##
      # Project::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more projects that match
        # the request and this value should be passed to continue.
        attr_accessor :token

        ##
        # Create a new Project::List with an array of Project instances.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of projects.
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of projects.
        def next
          return nil unless next?
          ensure_manager!
          @manager.projects token: token
        end

        ##
        # Retrieves all projects by repeatedly loading pages until #next?
        # returns false. Returns the list instance for method chaining.
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   resource_manager = gcloud.resource_manager
        #   projects = resource_manager.projects.all # Load all projects
        #
        def all
          while next?
            next_projects = self.next
            push(*next_projects)
            self.token = next_projects.token
          end
          self
        end

        ##
        # @private New Projects::List from a response object.
        def self.from_response resp, manager
          projects = new(Array(resp.data["projects"]).map do |gapi_object|
            Project.from_gapi gapi_object, manager.connection
          end)
          projects.instance_variable_set "@token",   resp.data["nextPageToken"]
          projects.instance_variable_set "@manager", manager
          projects
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_manager!
          fail "Must have active connection" unless @manager
        end
      end
    end
  end
end
