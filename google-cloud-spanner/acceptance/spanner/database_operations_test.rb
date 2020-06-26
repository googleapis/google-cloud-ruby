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


require "spanner_helper"

describe "Spanner Database Operations", :spanner do
  let(:instance_id) { $spanner_instance_id }
  let(:database_id) { $spanner_database_id }

  it "list database operations" do
    skip if emulator_enabled?

    instance = spanner.instance instance_id
    _(instance).wont_be :nil?

    # All
    jobs = instance.database_operations.all.to_a
    _(jobs).wont_be :empty?

    jobs.each do |job|
      _(job).must_be_kind_of Google::Cloud::Spanner::Database::Job

      if job.database
        _(job.database).must_be_kind_of Google::Cloud::Spanner::Database
      end
    end

    # Filter completed jobs
    filter = "done:true"
    jobs = instance.database_operations(filter: filter).all.to_a
    _(jobs).wont_be :empty?
    jobs.each do |job|
      _(job).must_be :done?
    end

    # Filter by metdata type
    filter = "metadata.@type:CreateDatabaseMetadata"
    jobs = instance.database_operations(filter: filter).all.to_a
    _(jobs).wont_be :empty?
    jobs.each do |job|
      _(job.grpc.metadata).must_be_kind_of Google::Spanner::Admin::Database::V1::CreateDatabaseMetadata
    end
  end
end
