# Copyright 2020 Google LLC
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
    # Wrapper message for `string`.
    #
    # The JSON representation for `StringValue` is JSON string.
    # @!attribute [rw] value
    #   @return [String]
    #     The string value.
    class StringValue; end

    # Wrapper message for `bytes`.
    #
    # The JSON representation for `BytesValue` is JSON string.
    # @!attribute [rw] value
    #   @return [String]
    #     The bytes value.
    class BytesValue; end
  end
end