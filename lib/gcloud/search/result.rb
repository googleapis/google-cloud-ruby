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

require "gcloud/search/result/list"
require "gcloud/search/fields"

module Gcloud
  module Search
    ##
    # = Result
    #
    # See Gcloud#search
    class Result
      ##
      # Creates a new Result instance.
      def initialize #:nodoc:
        @fields = Fields.new
        @raw = {}
      end

      ##
      # The unique identifier of the document referenced in the search result.
      def doc_id
        @raw["docId"]
      end

      ##
      # The token for the next page of results.
      def token
        @raw["nextPageToken"]
      end

      ##
      # Retrieve the field values associated to a field name.
      #
      # === Parameters
      #
      # +name+::
      #   The name of the field. New values will be configured with this name.
      #   (+String+)
      #
      # === Returns
      #
      # FieldValue
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   documents = index.search "best T-shirt ever"
      #   document = documents.first
      #   puts "The best match for your search is:"
      #   document["description"].each do |value|
      #     puts "* #{value.value} (#{value.type}) [#{value.lang}]"
      #   end
      #
      def [] k
        @fields[k]
      end

      # rubocop:disable Style/TrivialAccessors
      # Disable rubocop because we want .fields to be listed with the other
      # methods on the class.

      ##
      # The fields in the search result. Each key is a field name and each
      # value is a FieldValues. See Fields.
      def fields
        @fields
      end

      # rubocop:enable Style/TrivialAccessors

      ##
      # Calls block once for each key, passing the field name and values pair as
      # parameters. If no block is given an enumerator is returned instead.
      # (See Fields#each)
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   documents = index.search "best T-shirt ever"
      #   document = documents.first
      #   puts "The best match for your search is:"
      #   document.each do |key, values|
      #     puts "* #{key}:"
      #     values.each do |value|
      #       puts "  * #{value.value} (#{value.type})"
      #     end
      #   end
      #
      def each &block
        @fields.each(&block)
      end

      ##
      # Calls block once for each key, passing the field name and values pair as
      # parameters. If no block is given an enumerator is returned instead.
      # (See Fields#each_pair)
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   documents = index.search "best T-shirt ever"
      #   document = documents.first
      #   puts "The best match for your search is:"
      #   document.each_pair do |key, values|
      #     puts "* #{key}:"
      #     values.each do |value|
      #       puts "  * #{value.value} (#{value.type})"
      #     end
      #   end
      #
      def each_pair &block
        @fields.each_pair(&block)
      end

      ##
      # Returns a new array populated with all the field names.
      # (See Fields#keys)
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #   index = search.index "products"
      #
      #   documents = index.search "best T-shirt ever"
      #   document = documents.first
      #   puts "The best match has the following fields:"
      #   document.keys.each do |key|
      #     puts "* #{key}:"
      #   end
      #
      def keys
        @fields.keys
      end

      ##
      # Override to keep working in interactive shells manageable.
      def inspect #:nodoc:
        insp_token = ""
        if token
          trunc_token = "#{token[0, 8]}...#{token[-5..-1]}"
          trunc_token = token if token.length < 20
          insp_token = ", token: #{trunc_token}..."
        end
        insp_fields = ", fields: (#{fields.keys.join ', '})"
        "#{self.class}(doc_id: #{doc_id.inspect}#{insp_token}#{insp_fields})"
      end

      ##
      # New Result from a raw data object.
      def self.from_hash hash #:nodoc:
        result = new
        result.instance_variable_set "@raw", hash
        result.instance_variable_set "@fields", Fields.from_raw(hash["fields"])
        result
      end

      ##
      # Returns the Result data as a hash
      def to_hash #:nodoc:
        hash = @raw.dup
        hash["fields"] = @fields.to_raw
        hash
      end
    end
  end
end
