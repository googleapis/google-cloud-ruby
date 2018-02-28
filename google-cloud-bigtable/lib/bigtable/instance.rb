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
  class Instance
    attr_reader :name, :display_name, :type, :labels, :state
    attr_writer :display_name, :type
    def initialize name:, display_name:, type: :DEVELOPMENT, labels: {}
      @name = name
      @display_name = display_name
      @type = type
      @labels = labels
    end

    def self.from_proto_ob proto_ob, client
      instance = Instance.new name: proto_ob.name,
                              display_name: proto_ob.display_name,
                              type: proto_ob.type,
                              labels: proto_ob.labels.to_h
      instance.send :client=, client
      instance.send :state=, proto_ob.state
      instance
    end

    # Deletes the bigtable instance
    # @param options [Google::Gax::CallOptions]
    #   Overrides the default settings for this call, e.g, timeout,
    #   retries, etc.
    def delete! **options
      @client.delete_instance name, options
    end

    def save! **options
      @client.update_instance name, display_name, type, labels, options
    end

    private

    attr_writer :client, :state
  end
end
