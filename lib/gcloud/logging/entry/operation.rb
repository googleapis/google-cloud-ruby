# Copyright 2016 Google Inc. All rights reserved.
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


require "gcloud/logging/resource/list"

module Gcloud
  module Logging
    class Entry
      ##
      # # Operation
      #
      # Additional information about a potentially long-running operation with
      # which a log entry is associated.
      #
      class Operation
        ##
        # @private Create an empty Operation object.
        def initialize
        end

        ##
        # An arbitrary operation identifier. Log entries with the same
        # identifier are assumed to be part of the same operation.
        attr_accessor :id

        ##
        # An arbitrary producer identifier. The combination of id and producer
        # must be globally unique. Examples for producer:
        # `"MyDivision.MyBigCompany.com"`,
        # `"github.com/MyProject/MyApplication"`.
        attr_accessor :producer

        ##
        # Set this to `true` if this is the first log entry in the operation.
        attr_accessor :first

        ##
        # Set this to `true` if this is the last log entry in the operation.
        attr_accessor :last

        ##
        # @private Exports the Operation to a Google API Client object.
        def to_gapi
          {
            "id" => id,
            "producer" => producer,
            "first" => first,
            "last" => last
          }.delete_if { |_, v| v.nil? }
        end

        ##
        # @private Determines if the Operation has any data.
        def empty?
          to_gapi.empty?
        end

        ##
        # @private New Operation from a Google API Client object.
        def self.from_gapi gapi
          gapi ||= {}
          gapi = gapi.to_hash if gapi.respond_to? :to_hash
          new.tap do |o|
            o.id       = gapi["id"]
            o.producer = gapi["producer"]
            o.first    = gapi["first"]
            o.last     = gapi["last"]
          end
        end
      end
    end
  end
end
