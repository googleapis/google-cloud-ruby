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
require "gcloud/search/fields"

module Gcloud
  module Search
    ##
    # = Document
    #
    class Document
      ##
      # Creates a new Document instance.
      #
      def initialize #:nodoc:
        @fields = Fields.new
        @raw = {}
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

      def [] k
        @fields[k]
      end

      # rubocop:disable Style/TrivialAccessors
      # Disable rubocop because we want .fields to be listed with the other
      # methods on the class.

      ##
      # The fields in the document. Each key is a field name and each
      # value is a FieldValues. See Fields.
      def fields
        @fields
      end

      # rubocop:enable Style/TrivialAccessors

      def add name, value, options = {}
        @fields[name].add value, options
      end

      def delete key, &block
        @fields.delete key, &block
      end

      def each &block
        @fields.each(&block)
      end

      def each_pair &block
        @fields.each_pair(&block)
      end

      def keys
        @fields.keys
      end

      ##
      # New Document from a raw data object.
      def self.from_hash hash #:nodoc:
        doc = new
        doc.instance_variable_set "@raw", hash
        doc.instance_variable_set "@fields", Fields.from_raw(hash["fields"])
        doc
      end

      ##
      # Returns the Document data as a hash
      def to_hash #:nodoc:
        hash = @raw.dup
        hash["fields"] = @fields.to_raw
        hash
      end
    end
  end
end
