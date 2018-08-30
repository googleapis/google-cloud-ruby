# Copyright 2018 Google LLC
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
  module Spanner
    module V1
      # A modification to one or more Cloud Spanner rows.  Mutations can be
      # applied to a Cloud Spanner database by sending them in a
      # {Google::Spanner::V1::Spanner::Commit Commit} call.
      # @!attribute [rw] insert
      #   @return [Google::Spanner::V1::Mutation::Write]
      #     Insert new rows in a table. If any of the rows already exist,
      #     the write or transaction fails with error +ALREADY_EXISTS+.
      # @!attribute [rw] update
      #   @return [Google::Spanner::V1::Mutation::Write]
      #     Update existing rows in a table. If any of the rows does not
      #     already exist, the transaction fails with error +NOT_FOUND+.
      # @!attribute [rw] insert_or_update
      #   @return [Google::Spanner::V1::Mutation::Write]
      #     Like {Google::Spanner::V1::Mutation#insert insert}, except that if the row already exists, then
      #     its column values are overwritten with the ones provided. Any
      #     column values not explicitly written are preserved.
      # @!attribute [rw] replace
      #   @return [Google::Spanner::V1::Mutation::Write]
      #     Like {Google::Spanner::V1::Mutation#insert insert}, except that if the row already exists, it is
      #     deleted, and the column values provided are inserted
      #     instead. Unlike {Google::Spanner::V1::Mutation#insert_or_update insert_or_update}, this means any values not
      #     explicitly written become +NULL+.
      # @!attribute [rw] delete
      #   @return [Google::Spanner::V1::Mutation::Delete]
      #     Delete rows from a table. Succeeds whether or not the named
      #     rows were present.
      class Mutation
        # Arguments to {Google::Spanner::V1::Mutation#insert insert}, {Google::Spanner::V1::Mutation#update update}, {Google::Spanner::V1::Mutation#insert_or_update insert_or_update}, and
        # {Google::Spanner::V1::Mutation#replace replace} operations.
        # @!attribute [rw] table
        #   @return [String]
        #     Required. The table whose rows will be written.
        # @!attribute [rw] columns
        #   @return [Array<String>]
        #     The names of the columns in {Google::Spanner::V1::Mutation::Write#table table} to be written.
        #
        #     The list of columns must contain enough columns to allow
        #     Cloud Spanner to derive values for all primary key columns in the
        #     row(s) to be modified.
        # @!attribute [rw] values
        #   @return [Array<Google::Protobuf::ListValue>]
        #     The values to be written. +values+ can contain more than one
        #     list of values. If it does, then multiple rows are written, one
        #     for each entry in +values+. Each list in +values+ must have
        #     exactly as many entries as there are entries in {Google::Spanner::V1::Mutation::Write#columns columns}
        #     above. Sending multiple lists is equivalent to sending multiple
        #     +Mutation+s, each containing one +values+ entry and repeating
        #     {Google::Spanner::V1::Mutation::Write#table table} and {Google::Spanner::V1::Mutation::Write#columns columns}. Individual values in each list are
        #     encoded as described {Google::Spanner::V1::TypeCode here}.
        class Write; end

        # Arguments to {Google::Spanner::V1::Mutation#delete delete} operations.
        # @!attribute [rw] table
        #   @return [String]
        #     Required. The table whose rows will be deleted.
        # @!attribute [rw] key_set
        #   @return [Google::Spanner::V1::KeySet]
        #     Required. The primary keys of the rows within {Google::Spanner::V1::Mutation::Delete#table table} to delete.
        #     Delete is idempotent. The transaction will succeed even if some or all
        #     rows do not exist.
        class Delete; end
      end
    end
  end
end