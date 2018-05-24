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


require "test_helper"
require "google/cloud/bigtable/instance_admin_client"
require "google/cloud/bigtable/table_admin_client"
require "google/cloud/bigtable/data_client"

describe Google::Cloud do
  describe "#bigtable" do
    let(:found_credentials) { "{}" }
    let(:default_credentials) { "{}" }

    def self.it_create_new_client_and_validate(client_type, client_class, keyfile: nil, instance_id: nil)
      it "passes #{keyfile && "keyfile"} to Google::Cloud.bigtable to get #{client_class.name}" do
        gcloud = Google::Cloud.new("project-id", keyfile)
        credentials_class = if client_type == :data
                              Google::Cloud::Bigtable::Credentials
                            else
                              Google::Cloud::Bigtable::Admin::Credentials
                            end
        ENV.stub :[], nil do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              credentials_class.stub :default, default_credentials do
                client = gcloud.bigtable(client_type: client_type, instance_id: instance_id)
                assert_instance_of(client_class, client)
                assert_equal("project-id", client.project_id)
                assert_nil(client.options[:scopes])
                assert_nil(client.options[:client_config])
                assert_nil(client.options[:timeout])

                yield self, client if block_given?
              end
            end
          end
        end
      end
    end

    it_create_new_client_and_validate(
      :instance,
      Google::Cloud::Bigtable::InstanceAdminClient
    ) do |t, client|
      t.assert_equal("{}", client.options[:credentials])
    end

    it_create_new_client_and_validate(
      :instance,
      Google::Cloud::Bigtable::InstanceAdminClient,
      keyfile: "keyfile-path"
    ) do |t, client|
      t.assert_equal("keyfile-path", client.options[:credentials])
    end

    it_create_new_client_and_validate(
      :table,
      Google::Cloud::Bigtable::TableAdminClient,
      instance_id: "instance-id"
    ) do |t, client|
      t.assert_equal("{}", client.options[:credentials])
      t.assert_equal("instance-id", client.instance_id)
    end

    it_create_new_client_and_validate(
      :table,
      Google::Cloud::Bigtable::TableAdminClient,
      keyfile: "keyfile-path",
      instance_id: "instance-id"
    ) do |t, client|
      t.assert_equal("keyfile-path", client.options[:credentials])
      t.assert_equal("instance-id", client.instance_id)
    end

    it_create_new_client_and_validate(
      :data,
      Google::Cloud::Bigtable::DataClient,
      instance_id: "instance-id"
    ) do |t, client|
      t.assert_equal("{}", client.options[:credentials])
      t.assert_equal("instance-id", client.instance_id)
    end

    it_create_new_client_and_validate(
      :data,
      Google::Cloud::Bigtable::DataClient,
      keyfile: "keyfile-path",
      instance_id: "instance-id"
    ) do |t, client|
      t.assert_equal("keyfile-path", client.options[:credentials])
      t.assert_equal("instance-id", client.instance_id)
    end
  end
end
