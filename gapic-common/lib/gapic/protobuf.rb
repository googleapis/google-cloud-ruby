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

require "google/protobuf/timestamp_pb"

module Gapic
  ##
  # TODO: Describe Protobuf
  module Protobuf
    ##
    # Creates an instance of a protobuf message from a hash that may include nested hashes. `google/protobuf` allows
    # for the instantiation of protobuf messages using hashes but does not allow for nested hashes to instantiate
    # nested submessages.
    #
    # @param hash [Hash, Object] The hash to be converted into a proto message. If an instance of the proto message
    #   class is given, it is returned unchanged.
    # @param to [Class] The corresponding protobuf message class of the given hash.
    #
    # @return [Object] An instance of the given message class.
    def self.coerce hash, to:
      return hash if hash.is_a? to

      # Sanity check: input must be a Hash
      raise ArgumentError, "Value #{hash} must be a Hash or a #{to.name}" unless hash.is_a? Hash

      hash = coerce_submessages hash, to
      to.new hash
    end

    ##
    # Coerces values of the given hash to be acceptable by the instantiation method provided by `google/protobuf`
    #
    # @private
    #
    # @param hash [Hash] The hash whose nested hashes will be coerced.
    # @param message_class [Class] The corresponding protobuf message class of the given hash.
    #
    # @return [Hash] A hash whose nested hashes have been coerced.
    def self.coerce_submessages hash, message_class
      return nil if hash.nil?
      coerced = {}
      message_descriptor = message_class.descriptor
      hash.each do |key, val|
        field_descriptor = message_descriptor.lookup key.to_s
        coerced[key] = if field_descriptor && field_descriptor.type == :message
                         coerce_submessage val, field_descriptor
                       elsif field_descriptor && field_descriptor.type == :bytes &&
                             (val.is_a?(IO) || val.is_a?(StringIO))
                         val.binmode.read
                       else
                         # `google/protobuf` should throw an error if no field descriptor is
                         # found. Simply pass through.
                         val
                       end
      end
      coerced
    end

    ##
    # Coerces the value of a field to be acceptable by the instantiation method of the wrapping message.
    #
    # @private
    #
    # @param val [Object] The value to be coerced.
    # @param field_descriptor [Google::Protobuf::FieldDescriptor] The field descriptor of the value.
    #
    # @return [Object] The coerced version of the given value.
    def self.coerce_submessage val, field_descriptor
      if (field_descriptor.label == :repeated) && !(map_field? field_descriptor)
        coerce_array val, field_descriptor
      elsif field_descriptor.subtype.msgclass == Google::Protobuf::Timestamp && val.is_a?(Time)
        time_to_timestamp val
      else
        coerce_value val, field_descriptor
      end
    end

    ##
    # Coerces the values of an array to be acceptable by the instantiation method the wrapping message.
    #
    # @private
    #
    # @param array [Array<Object>] The values to be coerced.
    # @param field_descriptor [Google::Protobuf::FieldDescriptor] The field descriptor of the values.
    #
    # @return [Array<Object>] The coerced version of the given values.
    def self.coerce_array array, field_descriptor
      raise ArgumentError, "Value #{array} must be an array" unless array.is_a? Array
      array.map do |val|
        coerce_value val, field_descriptor
      end
    end

    ##
    # Hack to determine if field_descriptor is for a map.
    #
    # TODO(geigerj): Remove this once protobuf Ruby supports an official way
    # to determine if a FieldDescriptor represents a map.
    # See: https://github.com/google/protobuf/issues/3425
    def self.map_field? field_descriptor
      (field_descriptor.label == :repeated) &&
        (field_descriptor.subtype.name.include? "_MapEntry_")
    end

    ##
    # Coerces the value of a field to be acceptable by the instantiation method of the wrapping message.
    #
    # @private
    #
    # @param val [Object] The value to be coerced.
    # @param field_descriptor [Google::Protobuf::FieldDescriptor] The field descriptor of the value.
    #
    # @return [Object] The coerced version of the given value.
    def self.coerce_value val, field_descriptor
      return val unless (val.is_a? Hash) && !(map_field? field_descriptor)
      coerce val, to: field_descriptor.subtype.msgclass
    end

    ##
    # Utility for converting a Google::Protobuf::Timestamp instance to a Ruby time.
    #
    # @param timestamp [Google::Protobuf::Timestamp] The timestamp to be converted.
    #
    # @return [Time] The converted Time.
    def self.timestamp_to_time timestamp
      Time.at timestamp.nanos * 10**-9 + timestamp.seconds
    end

    ##
    # Utility for converting a Ruby Time instance to a Google::Protobuf::Timestamp.
    #
    # @param time [Time] The Time to be converted.
    #
    # @return [Google::Protobuf::Timestamp] The converted Google::Protobuf::Timestamp.
    def self.time_to_timestamp time
      Google::Protobuf::Timestamp.new seconds: time.to_i, nanos: time.nsec
    end

    private_class_method :coerce_submessages, :coerce_submessage, :coerce_array, :coerce_value, :map_field?
  end
end
