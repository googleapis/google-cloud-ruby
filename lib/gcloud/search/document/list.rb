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


module Gcloud
  module Search
    class Document
      ##
      # Document::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more records that match
        # the request and this value should be passed to continue.
        attr_accessor :token

        ##
        # Create a new Document::List with an array of {Document} instances.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of documents.
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of documents.
        def next
          return nil unless next?
          ensure_index!
          @index.documents token: token
        end

        ##
        # Retrieves all documents by repeatedly loading pages until {#next?}
        # returns false. Returns the list instance for method chaining.
        def all
          while next?
            next_documents = self.next
            push(*next_documents)
            self.token = next_documents.token
          end
          self
        end

        ##
        # @private New Documents::List from a response object.
        def self.from_response resp, index
          data = JSON.parse resp.body
          documents = new(Array(data["documents"]).map do |doc_hash|
            Document.from_hash doc_hash
          end)
          documents.instance_eval do
            @token = data["nextPageToken"]
            @index = index
          end
          documents
        rescue JSON::ParserError
          raise ApiError.from_response(resp)
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_index!
          fail "Must have active connection" unless @index
        end
      end
    end
  end
end
