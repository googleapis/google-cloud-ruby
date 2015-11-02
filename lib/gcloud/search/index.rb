#--
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

require "gcloud/search/index/list"

module Gcloud
  module Search
    ##
    # = Index
    #
    # See Gcloud#search
    class Index
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The raw data object.
      attr_accessor :raw #:nodoc:

      ##
      # Creates a new Index instance.
      #
      def initialize #:nodoc:
        @connection = nil
        @raw = nil
      end

      def index_id
        @raw["indexId"]
      end

      ##
      # New Index from a raw data object.
      def self.from_raw raw, conn #:nodoc:
        new.tap do |f|
          f.raw = raw
          f.connection = conn
        end
      end
    end
  end
end
