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


require "google/cloud/firestore/convert"

module Google
  module Cloud
    module Firestore
      module Document
        ##
        # # Document::Snapshot
        #
        class Snapshot
          ##
          # @private The Google::Firestore::V1beta1::Document object.
          attr_accessor :grpc

          def ref
            @ref
          end
          alias_method :reference, :ref

          def project_id
            ref.project_id
          end

          def database_id
            ref.database_id
          end

          def document_id
            ref.document_id
          end

          def document_path
            ref.document_path
          end

          def path
            ref.path
          end

          def parent
            ref.parent
          end

          ##
          # Retrieves a list of collections
          def cols &block
            ref.cols(&block)
          end
          alias_method :collections, :cols

          def col collection_path
            ref.col collection_path
          end
          alias_method :collection, :col

          def doc document_path
            ref.doc document_path
          end
          alias_method :document, :doc

          def data
            return nil if missing?
            Convert.fields_to_hash grpc.fields, ref.context
          end
          alias_method :fields, :data

          def get fieldpath
            selected_data = data
            fieldpath.to_s.split(".").each do |field|
              unless selected_data.is_a? Hash
                fail ArgumentError, "#{fieldpath} is not contained in the data"
              end
              selected_data = selected_data[field.to_sym]
            end
            selected_data
          end
          alias_method :[], :get

          def created_at
            return nil if missing?
            Convert.timestamp_to_time grpc.create_time
          end
          alias_method :create_time, :created_at

          def updated_at
            return nil if missing?
            Convert.timestamp_to_time grpc.update_time
          end
          alias_method :update_time, :updated_at

          def read_at
            @read_at
          end
          alias_method :read_time, :read_at

          def exists?
            !missing?
          end

          def missing?
            grpc.nil?
          end
        end
      end
    end
  end
end
