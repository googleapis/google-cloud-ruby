# Copyright 2017 Google LLC
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

module Google
  module Protobuf
    # Wrapper message for +double+.
    #
    # The JSON representation for +DoubleValue+ is JSON number.
    # @!attribute [rw] value
    #   @return [Float]
    #     The double value.
    class DoubleValue; end

    # Wrapper message for +float+.
    #
    # The JSON representation for +FloatValue+ is JSON number.
    # @!attribute [rw] value
    #   @return [Float]
    #     The float value.
    class FloatValue; end

    # Wrapper message for +int64+.
    #
    # The JSON representation for +Int64Value+ is JSON string.
    # @!attribute [rw] value
    #   @return [Integer]
    #     The int64 value.
    class Int64Value; end

    # Wrapper message for +uint64+.
    #
    # The JSON representation for +UInt64Value+ is JSON string.
    # @!attribute [rw] value
    #   @return [Integer]
    #     The uint64 value.
    class UInt64Value; end

    # Wrapper message for +int32+.
    #
    # The JSON representation for +Int32Value+ is JSON number.
    # @!attribute [rw] value
    #   @return [Integer]
    #     The int32 value.
    class Int32Value; end

    # Wrapper message for +uint32+.
    #
    # The JSON representation for +UInt32Value+ is JSON number.
    # @!attribute [rw] value
    #   @return [Integer]
    #     The uint32 value.
    class UInt32Value; end

    # Wrapper message for +bool+.
    #
    # The JSON representation for +BoolValue+ is JSON +true+ and +false+.
    # @!attribute [rw] value
    #   @return [true, false]
    #     The bool value.
    class BoolValue; end

    # Wrapper message for +string+.
    #
    # The JSON representation for +StringValue+ is JSON string.
    # @!attribute [rw] value
    #   @return [String]
    #     The string value.
    class StringValue; end

    # Wrapper message for +bytes+.
    #
    # The JSON representation for +BytesValue+ is JSON string.
    # @!attribute [rw] value
    #   @return [String]
    #     The bytes value.
    class BytesValue; end
  end
end