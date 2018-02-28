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

module Bigtable
  class Cluster
    attr_reader :name, :location, :serve_nodes, :default_storage_type, :cluster_id
    def initialize cluster_id:, location:, serve_nodes: nil, 
                   name: nil,
                   storage: :STORAGE_TYPE_UNSPECIFIED
      @name = name
      @cluster_id = cluster_id
      @location = location
      @serve_nodes = serve_nodes
      @default_storage_type = storage
    end

    def to_proto_ob
      cluster = Google::Bigtable::Admin::V2::Cluster.new location: location
      cluster.serve_nodes = serve_nodes unless serve_nodes.nil?
      cluster.default_storage_type = default_storage_type
      cluster
    end
  end
end
