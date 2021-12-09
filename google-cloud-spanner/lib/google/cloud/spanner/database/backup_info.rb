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


module Google
  module Cloud
    module Spanner
      class Database
        # @deprecated Use
        # {Google::Cloud::Spanner::Admin::Database::V1::BackupInfo} instead.
        class BackupInfo
          ##
          # @private Creates a new Database::BackupInfo instance.
          def initialize grpc
            @grpc = grpc
          end

          ##
          # The unique identifier for the project.
          # @return [String]
          def project_id
            @grpc.backup.split("/")[1]
          end

          ##
          # The unique identifier for the instance.
          # @return [String]
          def instance_id
            @grpc.backup.split("/")[3]
          end

          ##
          # The unique identifier for the backup.
          # @return [String]
          def backup_id
            @grpc.backup.split("/")[5]
          end

          ##
          # The full path for the backup. Values are of the form
          # `projects/<project>/instances/<instance>/backups/<backup_id>`.
          # @return [String]
          def path
            @grpc.backup
          end

          ##
          # Name of the database the backup was created from.
          # @return [String]
          def source_database_id
            @grpc.source_database.split("/")[5]
          end

          ##
          # The unique identifier for the source database project.
          # @return [String]
          def source_database_project_id
            @grpc.backup.split("/")[1]
          end

          ##
          # The unique identifier for the source database instance.
          # @return [String]
          def source_database_instance_id
            @grpc.backup.split("/")[3]
          end

          ##
          # The full path for the source database the backup was created from.
          # Values are of the form
          # `projects/<project>/instances/<instance>/database/<database_id>`.
          # @return [String]
          def source_database_path
            @grpc.source_database
          end

          ##
          # The timestamp indicating the creation of the backup.
          # @return [Time]
          def create_time
            Convert.timestamp_to_time @grpc.create_time
          end

          ##
          # The backup contains an externally consistent copy of
          # `source_database` at the timestamp specified by
          # the `version_time` received. If no `version_time` was
          # given during the creation of the backup, the `version_time`
          # will be the same as the `create_time`.
          # @return [Time]
          def version_time
            Convert.timestamp_to_time @grpc.version_time
          end

          ##
          # @private Creates a new Database::BackupInfo instance from a
          # `Google::Cloud::Spanner::Admin::Database::V1::BackupInfo`.
          def self.from_grpc grpc
            new grpc
          end
        end
      end
    end
  end
end
