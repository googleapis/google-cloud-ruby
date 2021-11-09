# Copyright 2021 Google LLC
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

require "helper"
require "google/cloud/spanner/admin/database"

describe Google::Cloud::Spanner::Admin::Database do
  let(:project_id) { "project-id" }
  let(:default_timeout) { 15 }
  let(:keyfile_path) { "path/to/keyfile.json" }
  let(:default_credentials) do
    ->(keyfile, scope: nil) {
      _(keyfile).must_equal keyfile_path
      _(scope).wont_be :nil?
      :this_channel_is_insecure
    }
  end
  let(:found_credentials) { "{}" }

  after do
    Google::Cloud.configure.reset!
  end

  it "can override config for itself and sub classes" do
    # Clear all environment variables
    ENV.stub :[], nil do
      # Set new configuration
      Google::Cloud::Spanner.configure do |config|
        config.project_id = project_id
        config.keyfile = keyfile_path
        config.timeout = default_timeout
      end

      # Override configuration
      Google::Cloud::Spanner::Admin::Database.configure do |config|
        config.timeout = 25
      end

      File.stub :file?, true, [keyfile_path] do
        File.stub :read, found_credentials, [keyfile_path] do
          Google::Cloud::Spanner::Credentials.stub :new, default_credentials do
            client = Google::Cloud::Spanner::Admin::Database.database_admin
            _(client.configure.timeout).must_equal 25
          end
        end
      end
    end
  end
end