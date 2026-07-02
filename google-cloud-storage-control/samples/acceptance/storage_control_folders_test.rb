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
require_relative "../storage_control_create_folder"
require_relative "../storage_control_get_folder"
require_relative "../storage_control_list_folders"
require_relative "../storage_control_rename_folder"
require_relative "../storage_control_delete_folder"
require_relative "../storage_control_delete_folder_recursive"

describe "Storage Control Folders" do
  let(:bucket_name) { random_bucket_name }
  let(:folder_name) { random_folder_name }

  before :all do
    create_bucket_helper bucket_name, uniform_bucket_level_access: true,
                         hierarchical_namespace: { enabled: true }
  end

  after do
    delete_bucket_helper bucket_name
  end

  it "create_folder, get_folder, list_folders, rename_folder, delete_folder" do
    # create_folder
    out, _err = capture_io do
      create_folder bucket_name: bucket_name, folder_name: folder_name
    end

    assert_includes out, folder_name

    # list_folders
    out, _err = capture_io do
      list_folders bucket_name: bucket_name
    end

    assert_includes out, "ruby-storage-control-folder-samples-test"

    # get_folder
    out, _err = capture_io do
      get_folder bucket_name: bucket_name, folder_name: folder_name
    end

    assert_includes out, folder_name

    # rename_folder
    new_folder_name = "#{folder_name}_new"
    assert_output "Renamed folder #{folder_name} to #{new_folder_name}\n" do
      rename_folder bucket_name: bucket_name, source_folder_id: folder_name, destination_folder_id: new_folder_name
    end

    # delete_folder
    assert_output "Deleted folder: #{new_folder_name}\n" do
      delete_folder bucket_name: bucket_name, folder_name: new_folder_name
    end

    # create parent folder for recursive delete
    capture_io do
      create_folder bucket_name: bucket_name, folder_name: folder_name
    end

    # create a child folder inside parent folder
    child_folder_name = "#{folder_name}/child-folder"
    capture_io do
      create_folder bucket_name: bucket_name, folder_name: child_folder_name
    end

    # delete parent folder recursively
    begin
      assert_output "Deleted folder recursively: #{folder_name}\n" do
        delete_folder_recursive bucket_name: bucket_name, folder_name: folder_name
      end
    rescue Minitest::UnexpectedError => e
      is_invalid_arg = e.error.is_a? Google::Cloud::InvalidArgumentError
      is_not_enabled = e.error.message.include? "Recursive folder delete is not enabled for this bucket"
      raise e unless is_invalid_arg && is_not_enabled

      skip "Skipping recursive delete test because the feature is not enabled for this bucket."
    rescue Google::Cloud::InvalidArgumentError => e
      raise e unless e.message.include? "Recursive folder delete is not enabled for this bucket"

      skip "Skipping recursive delete test because the feature is not enabled for this bucket."
    end
  end
end
