# Copyright 2017 Google LLC
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


require "securerandom"

module Google
  module Cloud
    module Firestore
      ##
      # @private Helper module for generating random values
      module Generate
        CHARS = [*"a".."z", *"A".."Z", *"0".."9"]

        def self.unique_id length: 20, chars: CHARS
          size = chars.size
          length.times.map do
            chars[SecureRandom.random_number(size)]
          end.join
        end
      end
    end
  end
end
