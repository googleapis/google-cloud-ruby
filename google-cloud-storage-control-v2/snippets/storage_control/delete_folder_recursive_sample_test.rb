# Copyright 2026 Google LLC
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

require "minitest/autorun"
require "google/cloud/storage"
require "google/cloud/storage/control/v2"
require "securerandom"

require_relative "delete_folder_recursive_sample"

class DeleteFolderRecursiveSampleTest < Minitest::Test
  def setup
    @storage = Google::Cloud::Storage.new
    @bucket_name = "ruby-storage-control-samples-hn-#{SecureRandom.hex 8}"
    
    # Create an HN bucket
    @bucket = @storage.create_bucket @bucket_name do |b|
      b.hierarchical_namespace.enabled = true
      b.uniform_bucket_level_access = true
    end

    @control_client = Google::Cloud::Storage::Control::V2::StorageControl::Client.new
  end

  def teardown
    # Clean up any resources created
    if @bucket
      # Ensure everything is deleted before deleting bucket
      @bucket.files.each(&:delete)
      @bucket.delete
    end
  end

  def test_delete_folder_recursive
    folder_name = "test-folder-#{SecureRandom.hex 4}"
    
    # Create a folder
    formatted_bucket_name = @control_client.bucket_path project: "_", bucket: @bucket_name
    @control_client.create_folder parent: formatted_bucket_name, folder_id: folder_name
    
    # Create a subfolder
    formatted_folder_name = @control_client.folder_path project: "_", bucket: @bucket_name, folder: folder_name
    @control_client.create_folder parent: formatted_folder_name, folder_id: "subfolder"

    assert_output "Deleted folder #{folder_name} recursively.\n" do
      delete_folder_recursive bucket_name: @bucket_name, folder_name: folder_name
    end

    # Verify the folder is gone
    begin
      @control_client.get_folder name: formatted_folder_name
      flunk "Folder should have been deleted"
    rescue Google::Cloud::NotFoundError
      # Expected behavior
      pass
    end
  end
end
