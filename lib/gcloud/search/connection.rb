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

require "gcloud/version"
require "gcloud/search/api_client"
require "gcloud/search/field_value"

module Gcloud
  module Search
    ##
    # Represents the connection to Search,
    # as well as expose the API calls.
    class Connection #:nodoc:
      API_VERSION = "v1"

      attr_accessor :project
      attr_accessor :credentials #:nodoc:
      attr_accessor :client #:nodoc:
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize project, credentials #:nodoc:
        @project = project
        @credentials = credentials
        client_config = {
          application_name: "gcloud-ruby",
          application_version: Gcloud::VERSION
        }
        @client = Gcloud::Search::APIClient.new client_config
        @client.authorization = @credentials.client
        @search = @client.discovered_api "cloudsearch", API_VERSION
      end

      def list_indexes options = {}
        params = { projectId: @project,
                   all: options.delete(:all),
                   indexNamePrefix: options.delete(:prefix),
                   pageSize: options.delete(:max),
                   pageToken: options.delete(:token)
        }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @search.indexes.list,
          parameters: params
        )
      end

      def delete_index index_id
        @client.execute(
          api_method: @search.indexes.delete,
          parameters: { projectId: @project,
                        indexId: index_id }
        )
      end

      def get_doc index_id, doc_id
        @client.execute(
          api_method: @search.documents.get,
          parameters: { projectId: @project,
                        indexId: index_id,
                        docId: doc_id }
        )
      end

      def list_docs index_id, options = {}
        params = { projectId: @project,
                   indexId: index_id,
                   view: "FULL",
                   pageSize: options[:max],
                   pageToken: options[:token]
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @search.documents.list,
          parameters: params
        )
      end

      def create_doc index_id, document_hash
        fields = document_hash["fields"]
        fields.each_pair do |name, values|
          fields[name] = field_values values
        end
        @client.execute(
          api_method: @search.documents.create,
          parameters: { projectId: @project,
                        indexId: index_id },
          body_object: document_hash
        )
      end

      def delete_doc index_id, doc_id
        @client.execute(
          api_method: @search.documents.delete,
          parameters: { projectId: @project,
                        indexId: index_id,
                        docId: doc_id }
        )
      end

      def search index_id, query, options = {}
        @client.execute(
          api_method: @search.indexes.search,
          parameters: search_request(index_id, query, options)
        )
      end

      def inspect #:nodoc:
        "#{self.class}(#{@project})"
      end

      def self.from_raw_fields raw
        hsh = {}
        raw.each_pair do |k, v|
          hsh[k] = from_raw_field_values(k, v)
        end
        hsh
      end

      # rubocop:disable all
      # Disabled because there is a long if/else chain.

      def self.from_raw_field_values name, raw_field
        raw_field["values"].map do |v|
          if v["stringValue"]
            type = v["stringFormat"].downcase.to_sym
            FieldValue.new name, v["stringValue"], type: type, lang: v["lang"]
          elsif v["timestampValue"]
            FieldValue.new name, DateTime.rfc3339(v["timestampValue"])
          elsif v["geoValue"]
            FieldValue.new name, v["geoValue"], type: :geo
          elsif v["numberValue"]
            FieldValue.new name, Float(v["numberValue"])
          else
            fail "No value found in #{raw_field.inspect}"
          end
        end
      end

      # rubocop:enable all

      protected

      def field_values values
        {
          "values" => values.map { |v| field_value v }
        }
      end

      def field_value value
        case value.type
        when :atom, :default, :html, :text
          string_field_value value
        when :geo
          geo_field_value value
        when :number
          number_field_value value
        when :timestamp
          timestamp_field_value value
        end
      end

      def string_field_value value
        {
          "stringFormat" => value.type.to_s.upcase,
          "lang" => value.lang,
          "stringValue" => value.value.to_s
        }.delete_if { |_, v| v.nil? }
      end

      def geo_field_value value
        {
          "geoValue" => value.value.to_s
        }
      end

      def number_field_value value
        {
          "numberValue" => value.value.to_f
        }
      end

      def timestamp_field_value value
        {
          "timestampValue" => value.value.rfc3339
        }
      end

      def search_request index_id, query, options = {}
        { projectId: @project,
          indexId: index_id,
          query: query,
          fieldExpressions: options[:expressions],
          matchedCountAccuracy: options[:matched_count_accuracy],
          offset: options[:offset],
          orderBy: options[:order],
          pageSize: options[:max],
          pageToken: options[:token],
          returnFields: options[:return_fields],
          scorerSize: options[:scorer_size],
          scorer: options[:scorer]
        }.delete_if { |_, v| v.nil? }
      end
    end
  end
end
