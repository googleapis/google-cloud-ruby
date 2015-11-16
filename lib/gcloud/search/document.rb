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
require "gcloud/search/fields"

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
      # Creates a new Document instance.
      #
      def initialize #:nodoc:
        @raw = {}
        @fields = Fields.new
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

      ##
      # The fields in the document.
      #
      # The fields is a Hash that must conform to the following structure:
      #
      #   {
      #     "title" => {
      #       "values" => [
      #         {
      #           "stringFormat" => "TEXT",
      #           "lang" => "en",
      #           "stringValue" => "Hello World!"
      #         }
      #       ]
      #     },
      #     "body" => {
      #       "values" => [
      #         {
      #           "stringFormat" => "HTML",
      #           "lang" => "en",
      #           "stringValue" => "<p>Greetings...</p>"
      #         }
      #       ]
      #     }
      #   }
      #
      # Each field has a name and a list of values. The field name is unique to
      # a document and is case sensitive. The name can only contain ASCII
      # characters. It must start with a letter and can contain letters, digits,
      # or underscore. It cannot be longer than 500 characters and cannot be the
      # empty string. A field can have multiple values with same or different
      # types, however, it cannot have multiple Timestamp or number values.
      def fields
        @fields.to_raw
      end

      ##
      # Sets the fields in the document.
      def fields= new_fields
        @fields = Fields.new new_fields
      end

      def [] key
        @fields[key]
      end

      def []= key, value
        @fields[key] = value
      end

      ##
      # New Document from a raw data object.
      def self.from_hash hash #:nodoc:
        new.tap do |d|
          d.raw = hash
          d.instance_variable_set "@fields", Fields.new(hash["fields"])
        end
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
