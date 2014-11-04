# Copyright 2014 Google Inc. All rights reserved.
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

require "gcloud/proto/datastore_v1.pb"

module Gcloud
  module Datastore
    ##
    # Datastore Key
    #
    # Every Datastore record has an identifying key, which includes the record's
    # entity kind and a unique identifier. The identifier may be either a key
    # name string, assigned explicitly by the application, or an integer numeric
    # ID, assigned automatically by Datastore.
    #
    #   key = Gcloud::Datastore::Key.new "User", "username"
    class Key
      def initialize kind = nil, id_or_name = nil
        @_key = Proto::Key.new
        path = Proto::Key::PathElement.new
        path.kind = kind
        if id_or_name.is_a? Integer
          path.id = id_or_name
        else
          path.name = id_or_name
        end
        @_key.path_element = [path]
      end

      def kind
        @_key.path_element.last.kind
      end

      def id
        @_key.path_element.last.id
      end

      def name
        @_key.path_element.last.name
      end

      def partition_id
        @_key.partition_id
      end

      # rubocop:disable Style/TrivialAccessors
      def to_proto #:nodoc:
        # Disabled rubocop because this implementation will most likely change.
        @_key
      end
      # rubocop:enable Style/TrivialAccessors

      def self.from_proto proto #:nodoc:
        key = Key.new
        key.instance_variable_set :@_key, proto
        key
      end
    end
  end
end
