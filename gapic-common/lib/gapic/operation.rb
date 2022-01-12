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

require "gapic/operation/retry_policy"
require "google/protobuf/well_known_types"
require "gapic/generic_lro/operation"

module Gapic
  # A class used to wrap Google::Longrunning::Operation objects. This class provides helper methods to check the
  # status of an Operation
  #
  # @example Checking Operation status
  #   # this example assumes both api_client and operations_client
  #   # already exist.
  #   require "gapic/operation"
  #
  #   op = Gapic::Operation.new(
  #     api_client.method_that_returns_longrunning_operation(),
  #     operations_client,
  #     Google::Example::ResultType,
  #     Google::Example::MetadataType
  #   )
  #
  #   op.done? # => false
  #   op.reload! # => operation completed
  #
  #   if op.done?
  #     results = op.results
  #     handle_error(results) if op.error?
  #     # Handle results.
  #   end
  #
  # @example Working with callbacks
  #   # this example assumes both api_client and operations_client
  #   # already exist.
  #   require "gapic/operation"
  #
  #   op = Gapic::Operation.new(
  #     api_client.method_that_returns_longrunning_operation(),
  #     operations_client,
  #     Google::Example::ResultType,
  #     Google::Example::MetadataType
  #   )
  #
  #   # Register a callback to be run when an operation is done.
  #   op.on_done do |operation|
  #     raise operation.results.message if operation.error?
  #     # process(operation.results)
  #     # process(operation.metadata)
  #   end
  #
  #   # Reload the operation running callbacks if operation completed.
  #   op.reload!
  #
  #   # Or block until the operation completes, passing a block to be called
  #   # on completion.
  #   op.wait_until_done do |operation|
  #     raise operation.results.message if operation.error?
  #     # process(operation.results)
  #     # process(operation.rmetadata)
  #   end
  #
  class Operation < Gapic::GenericLRO::Operation
    ##
    # @param grpc_op [Google::Longrunning::Operation] The inital longrunning operation.
    # @param client [Google::Longrunning::OperationsClient] The client that handles the grpc operations.
    # @param result_type [Class] The class type to be unpacked from the result. If not provided the class type will be
    #   looked up. Optional.
    # @param metadata_type [Class] The class type to be unpacked from the metadata. If not provided the class type
    #   will be looked up. Optional.
    # @param options [Gapic::CallOptions] call options for this operation
    #
    def initialize grpc_op, client, result_type: nil, metadata_type: nil, options: {}
      super(
        grpc_op,
        client: client,
        polling_method_name: "get_operation",
        operation_status_field: "done",
        operation_name_field: "name",
        operation_err_field: "error",
        operation_copy_fields: { "name" => "name" },
        options: options
      )

      @result_type = result_type
      @metadata_type = metadata_type
    end

    ##
    # @return [Google::Longrunning::Operation] The wrapped grpc operation object.
    #
    def grpc_op
      operation
    end

    ##
    # Returns the metadata of an operation. If a type is provided, the metadata will be unpacked using the type
    # provided; returning nil if the metadata is not of the type provided. If the type is not of provided, the
    # metadata will be unpacked using the metadata's type_url if the type_url is found in the
    # {Google::Protobuf::DescriptorPool.generated_pool}. If the type cannot be found the raw metadata is retuned.
    #
    # @return [Object, nil] The metadata of the operation. Can be nil.
    #
    def metadata
      return if grpc_op.metadata.nil?

      return grpc_op.metadata.unpack @metadata_type if @metadata_type

      descriptor = Google::Protobuf::DescriptorPool.generated_pool.lookup grpc_op.metadata.type_name

      return grpc_op.metadata.unpack descriptor.msgclass if descriptor

      grpc_op.metadata
    end

    ##
    # If the operation is done, returns the response, otherwise returns nil.
    #
    # @return [Object, nil] The response of the operation.
    def response
      return unless response?

      return grpc_op.response.unpack @result_type if @result_type

      descriptor = Google::Protobuf::DescriptorPool.generated_pool.lookup grpc_op.response.type_name

      return grpc_op.response.unpack descriptor.msgclass if descriptor

      grpc_op.response
    end

    ##
    # Checks if the operation is done and the result is an error. If the operation is not finished then this will
    # return false.
    #
    # @return [Boolean] Whether an error has been returned.
    #
    def error?
      done? ? grpc_op.result == :error : false
    end

    ##
    # Cancels the operation.
    #
    # @param options [Gapic::CallOptions, Hash] The options for making the RPC call. A Hash can be provided to customize
    #   the options object, using keys that match the arguments for {Gapic::CallOptions.new}.
    #
    def cancel options: nil
      # Converts hash and nil to an options object
      options = Gapic::CallOptions.new(**options.to_h) if options.respond_to? :to_h

      client.cancel_operation({ name: grpc_op.name }, options)
    end

    ##
    # Deletes the operation.
    #
    # @param options [Gapic::CallOptions, Hash] The options for making the RPC call. A Hash can be provided to customize
    #   the options object, using keys that match the arguments for {Gapic::CallOptions.new}.
    #
    def delete options: nil
      # Converts hash and nil to an options object
      options = Gapic::CallOptions.new(**options.to_h) if options.respond_to? :to_h

      client.delete_operation({ name: grpc_op.name }, options)
    end
  end
end
