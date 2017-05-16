# Copyright 2017 Google Inc. All rights reserved.
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


require "google/cloud/errors"

module Google
  module Cloud
    module Spanner
      ##
      # @private
      # # RollbackError
      #
      # Signal that the Transaction has been rolled back.
      #
      class RollbackError < Google::Cloud::Error
      end

      ##
      # # DuplicateNameError
      #
      # Data accessed by name (typically by calling
      # {Google::Cloud::Spanner::Data#[]} with a key or calling
      # {Google::Cloud::Spanner::Data#to_h}) has more than one occurrence of the
      # same name. Such data should be accessed by position rather than by name.
      #
      class DuplicateNameError < Google::Cloud::Error
      end
    end
  end
end
