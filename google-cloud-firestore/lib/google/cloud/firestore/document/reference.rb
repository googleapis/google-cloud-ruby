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

module Google
  module Cloud
    module Firestore
      module Document
        ##
        # # Document::Reference
        #
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

          def document_id
            path.split("/").last
          end

          def document_path
            path.split("/", 6).last
          end

          def path
            @path
          end

          def parent
            Collection.from_path parent_path, context
          end

          protected

          def parent_path
            path.split("/")[0...-1].join("/")
          end

          ##
          # @private The context's Service object.
          def service
            ensure_context!

            context.service
          end

          ##
          # @private Raise an error unless an active connection to the service
          # is available.
          def ensure_service!
            fail "Must have active connection to service" unless service
          end

          ##
          # @private Raise an error unless context is available.
          def ensure_context!
            fail "Must have active connection to service" unless context
          end
        end
      end
    end
  end
end
