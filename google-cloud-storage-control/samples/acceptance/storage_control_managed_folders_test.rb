# Copyright 2024 Google LLC
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

require_relative "helper"
require_relative "../storage_control_managed_folder_create"
require_relative "../storage_control_managed_folder_get"
require_relative "../storage_control_managed_folder_list"
require_relative "../storage_control_managed_folder_delete"

describe "Storage Control Managed Folders" do
  let(:bucket_name) { random_bucket_name }
  let(:managed_folder_name) { random_folder_name prefix: "ruby-storage-control-managed-folder-samples-test-" }

  before :all do
    create_bucket_helper bucket_name, uniform_bucket_level_access: true,
                         hierarchical_namespace: { enabled: true }
  end

  after do
    delete_bucket_helper bucket_name
  end

  it "create_managed_folder, get_managed_folder, list_managed_folders, delete_managed_folder" do
    # create_managed_folder
    out, _err = capture_io do
      create_managed_folder bucket_name: bucket_name, managed_folder_id: managed_folder_name
    end

    assert_includes out, managed_folder_name

    # list_managed_folders
    out, _err = capture_io do
      list_managed_folders bucket_name: bucket_name
    end

    assert_includes out, "ruby-storage-control-managed-folder-samples-test"

    # get_managed_folder
    out, _err = capture_io do
      get_managed_folder bucket_name: bucket_name, managed_folder_id: managed_folder_name
    end

    assert_includes out, managed_folder_name

    # delete_managed_folder
    assert_output "Deleted managed folder: #{managed_folder_name}\n" do
      delete_managed_folder bucket_name: bucket_name, managed_folder_id: managed_folder_name
    end
  end
end
