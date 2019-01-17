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


module Google
  module Protobuf
    # Wrapper message for `int32`.
    #
    # The JSON representation for `Int32Value` is JSON number.
    # @!attribute [rw] value
    #   @return [Integer]
    #     The int32 value.
    class Int32Value; end

    # Wrapper message for `bool`.
    #
    # The JSON representation for `BoolValue` is JSON `true` and `false`.
    # @!attribute [rw] value
    #   @return [true, false]
    #     The bool value.
    class BoolValue; end
  end
end