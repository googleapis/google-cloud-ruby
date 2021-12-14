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

# DO NOT EDIT: Unless you're fixing a P0/P1 and/or a security issue. This class
# is frozen to all new features from `google-cloud-spanner/v2.11.0` onwards.


require "google/cloud/spanner/database/backup_info"

module Google
  module Cloud
    module Spanner
      class Database
        # @deprecated Use
        # {Google::Cloud::Spanner::Admin::Database::V1::RestoreInfo} instead.
        class RestoreInfo
          ##
          # @private Creates a new Database::RestoreInfo instance.
          def initialize grpc
            @grpc = grpc
          end

          ##
          # The database restored from source type `:BACKUP`.
          # @return [Symbol]
          def source_type
            @grpc.source_type
          end

          ##
          # Database restored from backup.
          #
          # @return [Boolean]
          def source_backup?
            @grpc.source_type == :BACKUP
          end

          # Information about the backup used to restore the database.
          # The backup may no longer exist.
          #
          # @return [Google::Cloud::Spanner::Database::BackupInfo, nil]
          def backup_info
            return nil unless @grpc.backup_info
            BackupInfo.from_grpc @grpc.backup_info
          end

          ##
          # @private Creates a new Database::RestoreInfo instance from a
          # `Google::Cloud::Spanner::Admin::Database::V1::RestoreInfo`
          def self.from_grpc grpc
            new grpc
          end
        end
      end
    end
  end
end
