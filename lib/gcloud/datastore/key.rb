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
      attr_accessor :kind, :id, :name, :dataset_id, :namespace, :parent
      def initialize kind = nil, id_or_name = nil
        @kind = kind
        if id_or_name.is_a? Integer
          @id = id_or_name
        else
          @name = id_or_name
        end
      end

      def id= new_id #:nodoc:
        @name = nil if new_id
        @id = new_id
      end

      def name= new_name #:nodoc:
        @id = nil if new_name
        @name = new_name
      end

      def parent= new_parent #:nodoc:
        # store key if given an entity
        new_parent = new_parent.key if new_parent.respond_to? :key
        @parent = new_parent
      end

      ##
      # A representation of the Key's path as an array of arrays.
      # Each inner array contains two values, the kind and the id
      # (if there is a numeric id) or name (if there is a name).
      # If neither an id or name exist then nil will be returned.
      #
      #   puts key.path #=> [["Person", "username"], ["Task", 123456]]
      def path
        new_path = parent ? parent.path : []
        new_path << [kind, (id || name)]
      end

      ##
      # Return an new protocol buffer object populated with
      # the data contained in the Key.
      def to_proto #:nodoc:
        Proto::Key.new.tap do |k|
          k.path_element = path.map do |pe_kind, pe_id_or_name|
            new_path_element pe_kind, pe_id_or_name
          end
          k.partition_id = new_partition_id dataset_id, namespace
        end
      end

      # rubocop:disable all

      ##
      # Return an new Key populated with the data contained
      # in the protocol buffer object.
      def self.from_proto proto #:nodoc:
        # Disable rules because the complexity here is neccessary.
        key = Key.new
        proto_path_element = Array(proto.path_element).pop
        if proto_path_element
          key = Key.new proto_path_element.kind,
                        proto_path_element.id || proto_path_element.name
        end
        if proto.partition_id
          key.dataset_id = proto.partition_id.dataset_id
          key.namespace  = proto.partition_id.namespace
        end
        if Array(proto.path_element).count > 0
          key.parent = Key.from_proto(proto)
        end
        key
      end
      # rubocop:enable all

      protected

      def new_path_element new_kind, new_id_or_name
        Proto::Key::PathElement.new.tap do |pe|
          pe.kind = new_kind
          if new_id_or_name.is_a? Integer
            pe.id = new_id_or_name
          else
            pe.name = new_id_or_name
          end
        end
      end

      def new_partition_id new_dataset_id, new_namespace
        Proto::PartitionId.new.tap do |pi|
          pi.dataset_id = new_dataset_id
          pi.namespace  = new_namespace
        end
      end
    end
  end
end
