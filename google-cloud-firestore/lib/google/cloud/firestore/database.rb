# Copyright 2017, Google Inc. All rights reserved.
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


require "google/cloud/firestore/collection"
require "google/cloud/firestore/document"

module Google
  module Cloud
    module Firestore
      ##
      # # Database
      #
      class Database
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private Creates a new Firestore Database instance.
        def initialize service
          @service = service
        end

        def project
          @project ||= Project.new service
        end

        def project_id
          service.project
        end

        def database_id
          "(default)"
        end

        def path
          service.database_path
        end

        ##
        # Retrieves a list of collections
        def cols
          ensure_service!

          return enum_for(:cols) unless block_given?

          collection_ids = service.list_collections "#{path}/documents"
          collection_ids.each { |collection_id| yield col(collection_id) }
        end
        alias_method :collections, :cols

        def col collection_path
          if collection_path.to_s.split("/").count.even?
            fail ArgumentError, "collection_path must refer to a collection."
          end

          Collection.from_path "#{path}/documents/#{collection_path}", self
        end
        alias_method :collection, :col

        def doc document_path
          if document_path.to_s.split("/").count.odd?
            fail ArgumentError, "document_path must refer to a document."
          end

          doc_path = "#{path}/documents/#{document_path}"

          Document.from_path doc_path, self
        end
        alias_method :document, :doc

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
