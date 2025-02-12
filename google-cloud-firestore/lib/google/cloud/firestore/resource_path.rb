# Copyright 2021 Google LLC
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
    module Firestore
      ##
      # @private
      #
      # Represents a resource path to the Firestore API.
      #
      class ResourcePath
        include Comparable

        RESOURCE_PATH_RE = %r{^projects/([^/]*)/databases/([^/]*)(?:/documents/)?([\s\S]*)$}

        attr_reader :project_id
        attr_reader :database_id
        attr_reader :segments

        ##
        # Creates a resource path object.
        #
        # @param [Array<String>] segments One or more strings representing the resource path.
        #
        # @return [ResourcePath] The resource path object.
        #
        def initialize project_id, database_id, segments
          @project_id = project_id
          @database_id = database_id
          @segments = segments.split "/"
        end

        def <=> other
          return nil unless other.is_a? ResourcePath
          [project_id, database_id, segments] <=> [other.project_id, other.database_id, other.segments]
        end

        def self.from_path path
          data = RESOURCE_PATH_RE.match path
          new data[1], data[2], data[3]
        end
      end
    end
  end
end
