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


require "google/cloud/firestore/document"
require "google/cloud/firestore/generate"

module Google
  module Cloud
    module Firestore
      ##
      # # Collection
      #
      module Collection
        ##
        # @private New Collection reference object from a path.
        def self.from_path path, context
          Reference.new.tap do |c|
            c.context = context
            c.instance_variable_set :@path, path
          end
        end

        class Reference
          ##
          # @private The connection context object.
          attr_accessor :context

          def project_id
            path.split("/")[1]
          end

          def database_id
            path.split("/")[3]
          end

          def collection_id
            path.split("/").last
          end

          def collection_path
            path.split("/", 6).last
          end

          def path
            @path
          end

          # Document OR Database
          def parent
            if collection_path.include? "/"
              return Document.from_path parent_path, context
            end
            return context.database if context.respond_to? :database
            context
          end

          def doc document_path = nil
            document_path ||= random_document_id

            ensure_context!
            context.doc "#{collection_path}/#{document_path}"
          end
          alias_method :document, :doc

          protected

          def parent_path
            path.split("/")[0...-1].join("/")
          end

          def random_document_id
            Generate.unique_id
          end

          ##
          # @private Raise an error unless context is available.
          def ensure_context!
            fail "Must have active connection to service" unless context
            return unless context.respond_to? :closed?
            self.context = context.database if context.closed?
          end
        end
      end
    end
  end
end
