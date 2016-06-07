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
        # @private Create a new Project::List with an array of Project
        # instances.
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
          @manager.projects token: token, filter: @filter, max: @max
        end

        ##
        # Retrieves all project by repeatedly loading {#next} until {#next?}
        # returns `false`. Calls the given block once for each project, which is
        # passed as the parameter.
        #
        # An Enumerator is returned if no block is given.
        #
        # This method may make several API calls until all projects are
        # retrieved. Be sure to use as narrow a search criteria as possible.
        # Please use with caution.
        #
        # @example Iterating each project by passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   resource_manager = gcloud.resource_manager
        #   projects = resource_manager.projects
        #
        #   projects.all do |project|
        #     puts project.project_id
        #   end
        #
        # @example Using the enumerator by not passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   resource_manager = gcloud.resource_manager
        #   projects = resource_manager.projects
        #
        #   all_project_ids = projects.all.map do |project|
        #     project.project_id
        #   end
        #
        # @example Limit the number of API calls made:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   resource_manager = gcloud.resource_manager
        #   projects = resource_manager.projects
        #
        #   projects.all(max_api_calls: 10) do |project|
        #     puts project.project_id
        #   end
        #
        def all max_api_calls: nil
          max_api_calls = max_api_calls.to_i if max_api_calls
          unless block_given?
            return enum_for(:all, max_api_calls: max_api_calls)
          end
          results = self
          loop do
            results.each { |r| yield r }
            if max_api_calls
              max_api_calls -= 1
              break if max_api_calls < 0
            end
            break unless results.next?
            results = results.next
          end
        end

        ##
        # @private New Projects::List from a response object.
        def self.from_response resp, manager, filter = nil, max = nil
          projects = new(Array(resp.data["projects"]).map do |gapi_object|
            Project.from_gapi gapi_object, manager.connection
          end)
          projects.instance_variable_set "@token",   resp.data["nextPageToken"]
          projects.instance_variable_set "@manager", manager
          projects.instance_variable_set "@filter",  filter
          projects.instance_variable_set "@max",     max
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
