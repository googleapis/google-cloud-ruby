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


require "google/cloud/errors"

module Google
  module Cloud
    module Spanner
      ##
      # # Rollback
      #
      # Used to rollback a transaction without passing on the exception. See
      # {Client#transaction}.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #   db = spanner.client "my-instance", "my-database"
      #
      #   db.transaction do |tx|
      #     tx.update "users", [{ id: 1, name: "Charlie", active: false }]
      #     tx.insert "users", [{ id: 2, name: "Harvey",  active: true }]
      #
      #     if something_wrong?
      #       # Rollback the transaction without passing on the error
      #       # outside of the transaction method.
      #       raise Google::Cloud::Spanner::Rollback
      #     end
      #   end
      #
      class Rollback < Google::Cloud::Error
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

      ##
      # # SessionLimitError
      #
      # More sessions have been allocated than configured for.
      class SessionLimitError < Google::Cloud::Error
      end

      ##
      # # ClientClosedError
      #
      # The client is closed and can no longer be used.
      class ClientClosedError < Google::Cloud::Error
      end
    end
  end
end
