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

require "gcloud/search/document/list"
require "gcloud/search/connection"

module Gcloud
  module Search
    ##
    # = Document
    #
    class Document
      ##
      # The raw data object.
      attr_accessor :raw #:nodoc:

      ##
      # The hash of fields in the document. Each key is a field name and each
      # value is a list of FieldValue objects.
      attr_accessor :fields

      ##
      # Creates a new Document instance.
      #
      def initialize #:nodoc:
        @fields = {}
        @raw = { "fields" => @fields }
      end

      ##
      # The unique identifier of the document.
      #
      # It must contain only visible, printable ASCII characters (ASCII codes 33
      # through 126 inclusive) and be no longer than 500 characters. It cannot
      # begin with an exclamation point <code>!</code>, and it can't begin and
      # end with double underscores <code>__</code>. If missing, it is
      # automatically assigned for the document when saved.
      def doc_id
        @raw["docId"]
      end

      ##
      # Sets the unique identifier of the document.
      def doc_id= new_doc_id
        @raw["docId"] = new_doc_id
      end

      ##
      # A positive integer which determines the default ordering of documents
      # returned from a search.
      #
      # The rank can be set explicitly when the document is created. It is a bad
      # idea to assign the same rank to many documents, and the same rank should
      # never be assigned to more than 10,000 documents. By default (when it is
      # not specified or set to 0), it is set at the time the document is
      # created to the number of seconds since January 1, 2011. The rank can be
      # used in Index#search options +expressions+, +order+, and
      # +return_fields+, where it is referenced as +_rank+.
      def rank
        @raw["rank"]
      end

      ##
      # Sets the rank of the document.
      def rank= new_rank
        @raw["rank"] = new_rank
      end

      def add name, value, options = {}
        @fields[name] ||= []
        @fields[name] << FieldValue.new(name, value, options)
      end

      def []= k, v
        v = Array v
        @fields[k] = v.map do |value|
          value.is_a?(FieldValue) ? value : FieldValue.new(k, value)
        end
      end

      def [] k
        @fields[k].dup.freeze
      end

      def each_pair &block
        @fields.each_pair(&block)
      end

      def delete key, &block
        @fields.delete key, &block
      end

      ##
      # New Document from a raw data object.
      def self.from_hash hash #:nodoc:
        hash["fields"] = Connection.from_raw_fields hash["fields"]
        new.tap do |d|
          d.raw = hash
          d.fields = hash["fields"]
        end
      end

      ##
      # Returns the Document data as a hash
      def to_hash #:nodoc:
        @raw.dup
      end
    end
  end
end
