# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/cloud/automl/v1beta1/service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


module Google
  module Cloud
    module AutoML
      module V1beta1
        class AutoMLClient
          ##
          # Gets the latest state of a long-running operation.  Clients can use this
          # method to poll the operation result at intervals as recommended by the API
          # service.
          #
          # @param name [String]
          #   The name of the operation resource.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   operation_name = "projects/[PROJECT]/locations/[LOCATION]/operations/[OPERATION]"
          #   operation = automl_client.get_operation(operation_name)
          #
          def get_operation name, options: nil
            proto_op = @operations_client.get_operation name, options: options

            Google::Gax::Operation.new(
              proto_op,
              @operations_client,
              nil,
              nil,
              call_options: options
            )
          end

          ##
          # Lists operations that match the specified filter in the request.
          #
          # @param name [String]
          #   The name of the operation collection.
          # @param filter [String]
          #   The standard list filter.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Gax::Operation>]
          #   An enumerable of Google::Gax::Operation instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = automl_client.class.location_path("[PROJECT]", "[LOCATION]")
          #   operations = automl_client.list_operations(formatted_name, "")
          #
          def list_operations name, filter, page_size: nil, options: nil
            paged_operations = @operations_client.list_operations name, filter, page_size: page_size, options: options
            # Monkey-patch PagedEnumerable#each to yield Google::Gax::Operation instead of
            # Google::Longrunning::Operation.
            def paged_operations.each
              return enum_for :each unless block_given?
              super do |proto_op|
                yield Google::Gax::Operation.new(
                  proto_op,
                  @operations_client,
                  nil,
                  nil
                )
              end
            end
            paged_operations
          end
        end
      end
    end
  end
end
