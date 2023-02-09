# Copyright 2014 Google LLC
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

require "simplecov"

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "google/cloud/datastore"

class MockDatastore < Minitest::Spec
  let(:project) { "my-todo-project" }
  let(:default_database) { "" }
  let(:database_sec) { "my-secondary-project" }
  let(:credentials) { OpenStruct.new }
  let(:dataset) { Google::Cloud::Datastore::Dataset.new(Google::Cloud::Datastore::Service.new(project, credentials, default_database)) }
  let(:secondary_dataset) { Google::Cloud::Datastore::Dataset.new(Google::Cloud::Datastore::Service.new(project, credentials, database_sec)) }

  # Register this spec type for when :dns is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_datastore
  end

  def read_time_to_timestamp time
    return nil if time.nil?

    # Force the object to be a Time object.
    time = time.to_time.utc

    Google::Protobuf::Timestamp.new(
      seconds: time.to_i,
      nanos: time.usec * 1000
    )
  end
end
