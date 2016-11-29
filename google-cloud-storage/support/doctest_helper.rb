# Copyright 2016 Google Inc. All rights reserved.
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

require "google/cloud/storage"

class File
  def self.file? f
    true
  end
  def self.readable? f
    true
  end
  def self.read f, opts
    "fake file data"
  end
end

module Google
  module Cloud
    module Storage
      class Bucket
        def signed_url path, method: nil, expires: nil, content_type: nil,
                       content_md5: nil, issuer: nil, client_email: nil,
                       signing_key: nil, private_key: nil
          # no-op stub, but ensures that calls match this copied signature
        end
      end
    end
  end
end

module Google
  module Cloud
    module Storage
      class File
        def download path, verify: :md5, encryption_key: nil,
                     encryption_key_sha256: nil
          # no-op stub, but ensures that calls match this copied signature
        end
        def signed_url method: nil, expires: nil, content_type: nil,
                       content_md5: nil, issuer: nil, client_email: nil,
                       signing_key: nil, private_key: nil
          # no-op stub, but ensures that calls match this copied signature
        end
      end
    end
  end
end

module Google
  module Cloud
    module Storage
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
    end
  end
end

def mock_storage
  Google::Cloud::Storage.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    storage = Google::Cloud::Storage::Project.new(Google::Cloud::Storage::Service.new("my-todo-project", credentials))

    storage.service.mocked_service = Minitest::Mock.new

    yield storage.service.mocked_service if block_given?

    storage
  end
end

YARD::Doctest.configure do |doctest|
  # Current mocking does not support testing GAPIC layer. (Auth failures occur.)
  doctest.skip "Google::Cloud::Storage::V1beta1::SpeechApi"

  doctest.before "Google::Cloud.storage" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
    end
  end

  doctest.before "Google::Cloud#storage" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
    end
  end

  doctest.before "Google::Cloud::Storage" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
    end
  end

  doctest.before "Google::Cloud::Storage.new" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
    end
  end

  # Bucket

  doctest.before "Google::Cloud::Storage::Bucket" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#cors" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app"]
      mock.expect :patch_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#update" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app"]
      mock.expect :patch_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#delete" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :delete_bucket, nil, ["my-bucket"]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#files" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :list_objects, list_files_gapi, ["my-bucket", {:delimiter=>nil, :max_results=>nil, :page_token=>nil, :prefix=>nil, :versions=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#find_files" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :list_objects, list_files_gapi, ["my-bucket", {:delimiter=>nil, :max_results=>nil, :page_token=>nil, :prefix=>nil, :versions=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#create_file" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :insert_object, file_gapi, ["my-bucket", Google::Apis::StorageV1::Object, Hash]
      # Following expectation is only used in last example
      mock.expect :get_object, file_gapi, ["my-bucket", "destination/path/file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#new_file" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :insert_object, file_gapi, ["my-bucket", Google::Apis::StorageV1::Object, Hash]
      # Following expectation is only used in last example
      mock.expect :get_object, file_gapi, ["my-bucket", "destination/path/file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#upload_file" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :insert_object, file_gapi, ["my-bucket", Google::Apis::StorageV1::Object, Hash]
      # Following expectation is only used in last example
      mock.expect :get_object, file_gapi, ["my-bucket", "destination/path/file.ext", Hash]
    end
  end

  # Due to failing line in example: key = OpenSSL::PKey::RSA.new "-----BEGIN PRIVATE KEY-----\n..."
  doctest.skip "Google::Cloud::Storage::Bucket#signed_url"
  # doctest.before "Google::Cloud::Storage::Bucket#signed_url" do
  #   mock_storage do |mock|
  #     mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app"]
  #   end
  # end

  doctest.before "Google::Cloud::Storage::Bucket#acl" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app"]
      mock.expect :insert_bucket_access_control, object_access_control_gapi, ["my-todo-app", Google::Apis::StorageV1::BucketAccessControl]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#acl@Or, grant access via a predefined permissions list:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-todo-app", Google::Apis::StorageV1::Bucket, {:predefined_acl=>"publicRead", :predefined_default_object_acl=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#default_acl" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app"]
      mock.expect :insert_default_object_access_control, object_access_control_gapi, ["my-todo-app", Google::Apis::StorageV1::ObjectAccessControl]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#default_acl@Or, grant access via a predefined permissions list:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-todo-app", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>"publicRead"}]
    end
  end

  # Bucket::Acl

  doctest.before "Google::Cloud::Storage::Bucket::Acl#reload!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      access_controls = Google::Apis::StorageV1::BucketAccessControls.from_json(random_bucket_acl_hash("my-bucket").to_json)
      mock.expect :list_bucket_access_controls, access_controls, ["my-bucket"]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      access_controls = Google::Apis::StorageV1::BucketAccessControls.from_json(random_bucket_acl_hash("my-bucket").to_json)
      mock.expect :list_bucket_access_controls, access_controls, ["my-bucket"]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#add_owner" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :insert_bucket_access_control, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::BucketAccessControl]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#add_writer" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :insert_bucket_access_control, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::BucketAccessControl]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#add_reader" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :insert_bucket_access_control, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::BucketAccessControl]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#delete" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :delete_bucket_access_control, true, ["my-bucket", "user-heidi@example.net"]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#auth" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>"authenticatedRead", :predefined_default_object_acl=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#private" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>"private", :predefined_default_object_acl=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#project_private!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>"projectPrivate", :predefined_default_object_acl=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#projectPrivate!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>"projectPrivate", :predefined_default_object_acl=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#public" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>"publicRead", :predefined_default_object_acl=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#public_write!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>"publicReadWrite", :predefined_default_object_acl=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#publicReadWrite!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>"publicReadWrite", :predefined_default_object_acl=>nil}]
    end
  end

  # Bucket::DefaultAcl

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      access_controls = Google::Apis::StorageV1::ObjectAccessControls.from_json(random_default_acl_hash("my-bucket").to_json)
      mock.expect :list_default_object_access_controls, access_controls, ["my-bucket"]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#add_" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :insert_default_object_access_control, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::ObjectAccessControl]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#delete" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :delete_default_object_access_control, true, ["my-bucket", "user-heidi@example.net"]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#auth" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>"authenticatedRead"}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#owner_full!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>"bucketOwnerFullControl"}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#bucketOwnerFullControl!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>"bucketOwnerFullControl"}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#owner_read!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>"bucketOwnerRead"}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#bucketOwnerRead!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>"bucketOwnerRead"}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#private" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>"private"}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#project" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>"projectPrivate"}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#public" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>"publicRead"}]
    end
  end

  # Bucket::Cors

  doctest.before "Google::Cloud::Storage::Bucket::Cors" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :patch_bucket, bucket_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Cors#add_rule" do
    mock_storage do |mock|
      mock.expect :insert_bucket, bucket_gapi, ["my-todo-project", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>nil}]
    end
  end

  # Bucket::List

  doctest.before "Google::Cloud::Storage::Bucket::List" do
    mock_storage do |mock|
      mock.expect :list_buckets, list_buckets_gapi, ["my-todo-project", {:prefix=>nil, :page_token=>nil, :max_results=>nil}]
    end
  end

  # File

  doctest.before "Google::Cloud::Storage::File" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:download_dest=>"path/to/downloaded/file.ext", :generation=>nil, :options=>{}}]
    end
  end

  doctest.before "Google::Cloud::Storage::File#update" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, {:predefined_acl=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::File#copy" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :copy_object, file_gapi, ["my-bucket", "path/to/my-file.ext", "new-destination-bucket", "path/to/destination/file.ext", {:destination_predefined_acl=>nil, :source_generation=>nil, :options=>{}}]
    end
  end

  doctest.before "Google::Cloud::Storage::File#copy@The file can be copied to a new path in the current bucket:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :copy_object, file_gapi, ["my-bucket", "path/to/my-file.ext", "my-bucket", "path/to/destination/file.ext", {:destination_predefined_acl=>nil, :source_generation=>nil, :options=>{}}]
    end
  end

  doctest.before "Google::Cloud::Storage::File#copy@The file can also be copied by specifying a generation:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :copy_object, file_gapi, ["my-bucket", "path/to/my-file.ext", "my-bucket", "copy/of/previous/generation/file.ext", {:destination_predefined_acl=>nil, :source_generation=>123456, :options=>{}}]
    end
  end

  doctest.before "Google::Cloud::Storage::File#delete" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext"]
    end
  end

  doctest.before "Google::Cloud::Storage::File#public_url" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app"]
      mock.expect :get_object, file_gapi, ["my-todo-app", "avatars/heidi/400x400.png", {:generation=>nil, :options=>{}}]
    end
  end

  doctest.before "Google::Cloud::Storage::File#url" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app"]
      mock.expect :get_object, file_gapi, ["my-todo-app", "avatars/heidi/400x400.png", {:generation=>nil, :options=>{}}]
    end
  end

  doctest.before "Google::Cloud::Storage::File#acl" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app"]
      mock.expect :get_object, file_gapi, ["my-todo-app", "avatars/heidi/400x400.png", {:generation=>nil, :options=>{}}]
      mock.expect :insert_object_access_control, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::ObjectAccessControl, {:generation=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::File#acl@Or, grant access via a predefined permissions list:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app"]
      mock.expect :get_object, file_gapi, ["my-todo-app", "avatars/heidi/400x400.png", {:generation=>nil, :options=>{}}]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, {:predefined_acl=>"publicRead"}]
    end
  end


  # Due to failing line in example: key = OpenSSL::PKey::RSA.new "-----BEGIN PRIVATE KEY-----\n..."
  doctest.skip "Google::Cloud::Storage::File#signed_url"

  # doctest.before "Google::Cloud::Storage::File#signed_url" do
  #   mock_storage do |mock|
  #     mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app"]
  #     mock.expect :get_object, file_gapi, ["my-todo-app", "avatars/heidi/400x400.png", {:generation=>nil, :options=>{}}]
  #   end
  # end

  # File::Acl

  doctest.before "Google::Cloud::Storage::File::Acl" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      access_controls = Google::Apis::StorageV1::ObjectAccessControls.from_json(random_file_acl_hash("my-bucket", "path/to/my-file.ext").to_json)
      mock.expect :list_object_access_controls, access_controls, ["my-bucket", "path/to/my-file.ext"]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#add_owner" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :insert_object_access_control, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::ObjectAccessControl, {:generation=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#add_reader" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :insert_object_access_control, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::ObjectAccessControl, {:generation=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#delete" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :delete_object_access_control, true, ["my-bucket", "path/to/my-file.ext", "user-heidi@example.net", {:generation=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#auth" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, {:predefined_acl=>"authenticatedRead"}]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#owner_full!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, {:predefined_acl=>"bucketOwnerFullControl"}]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#bucketOwnerFullControl!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, {:predefined_acl=>"bucketOwnerFullControl"}]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#owner_read!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, {:predefined_acl=>"bucketOwnerRead"}]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#bucketOwnerRead!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, {:predefined_acl=>"bucketOwnerRead"}]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#private" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, {:predefined_acl=>"private"}]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#project" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, {:predefined_acl=>"projectPrivate"}]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#public" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, {:predefined_acl=>"publicRead"}]
    end
  end

  # File::List

  doctest.before "Google::Cloud::Storage::File::List" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :list_objects, list_files_gapi, ["my-bucket", {:delimiter=>nil, :max_results=>nil, :page_token=>nil, :prefix=>nil, :versions=>nil}]
    end
  end

  # Project

  doctest.before "Google::Cloud::Storage::Project" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
    end
  end

  doctest.before "Google::Cloud::Storage::Project#buckets" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :list_buckets, list_buckets_gapi, ["my-todo-project", {:prefix=>nil, :page_token=>nil, :max_results=>nil}]
    end
  end

  doctest.before "Google::Cloud::Storage::Project#buckets@Retrieve buckets with names that begin with a given prefix:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :list_buckets, list_buckets_gapi, ["my-todo-project", {:prefix=>"user-", :page_token=>nil, :max_results=>nil}]
    end
  end

  doctest.skip "Google::Cloud::Storage::Project#find_buckets" # alias for #buckets

  doctest.before "Google::Cloud::Storage::Project#create_bucket" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket"]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", {:generation=>nil, :options=>{}}]
      mock.expect :insert_bucket, bucket_gapi, ["my-todo-project", Google::Apis::StorageV1::Bucket, {:predefined_acl=>nil, :predefined_default_object_acl=>nil}]
    end
  end

end

# Fixture helpers



def bucket_gapi name = "my-bucket"
  Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name).to_json
end

def list_buckets_gapi count = 2, token = nil
  buckets = count.times.map { bucket_gapi }
  Google::Apis::StorageV1::Buckets.new(
    kind: "storage#buckets", items: buckets, next_page_token: token
  )
end

def file_gapi bucket_name = "my-bucket", name = "path/to/my-file.ext"
  Google::Apis::StorageV1::Object.from_json random_file_hash(bucket_name, name).to_json
end

def list_files_gapi count = 2, token = nil, prefixes = nil
  files = count.times.map { file_gapi }
  Google::Apis::StorageV1::Objects.new kind: "storage#objects", items: files, next_page_token: token, prefixes: prefixes
end

def object_access_control_gapi
  entity = "project-owners-1234567890"
  Google::Apis::StorageV1::ObjectAccessControl.new entity: entity
end



def random_bucket_hash(name = "my-bucket",
  url_root="https://www.googleapis.com/storage/v1", location="US",
  storage_class="STANDARD", versioning=nil, logging_bucket=nil,
  logging_prefix=nil, website_main=nil, website_404=nil)
  versioning_config = { "enabled" => versioning } if versioning
  { "kind" => "storage#bucket",
    "id" => name,
    "selfLink" => "#{url_root}/b/#{name}",
    "projectNumber" => "1234567890",
    "name" => name,
    "timeCreated" => Time.now,
    "metageneration" => "1",
    "owner" => { "entity" => "project-owners-1234567890" },
    "location" => location,
    "cors" => [{"origin"=>["http://example.org"], "method"=>["GET","POST","DELETE"], "responseHeader"=>["X-My-Custom-Header"], "maxAgeSeconds"=>3600},{"origin"=>["http://example.org"], "method"=>["GET","POST","DELETE"], "responseHeader"=>["X-My-Custom-Header"], "maxAgeSeconds"=>3600}],
    "logging" => logging_hash(logging_bucket, logging_prefix),
    "storageClass" => storage_class,
    "versioning" => versioning_config,
    "website" => website_hash(website_main, website_404),
    "etag" => "CAE=" }.delete_if { |_, v| v.nil? }
end

def logging_hash(bucket, prefix)
  { "logBucket"       => bucket,
    "logObjectPrefix" => prefix,
  }.delete_if { |_, v| v.nil? } if bucket || prefix
end

def website_hash(website_main, website_404)
  { "mainPageSuffix" => website_main,
    "notFoundPage"   => website_404,
  }.delete_if { |_, v| v.nil? } if website_main || website_404
end

def random_file_hash bucket, name, generation="1234567890"
  { "kind" => "storage#object",
    "id" => "#{bucket}/#{name}/1234567890",
    "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket}/o/#{name}",
    "name" => "#{name}",
    "timeCreated" => Time.now,
    "bucket" => "#{bucket}",
    "generation" => generation,
    "metageneration" => "1",
    "cacheControl" => "public, max-age=3600",
    "contentDisposition" => "attachment; filename=filename.ext",
    "contentEncoding" => "gzip",
    "contentLanguage" => "en",
    "contentType" => "text/plain",
    "updated" => Time.now,
    "storageClass" => "STANDARD",
    "size" => rand(10_000),
    "md5Hash" => "HXB937GQDFxDFqUGi//weQ==",
    "mediaLink" => "https://www.googleapis.com/download/storage/v1/b/#{bucket}/o/#{name}?generation=1234567890&alt=media",
    "metadata" => { "player" => "Alice", "score" => "101" },
    "owner" => { "entity" => "user-1234567890", "entityId" => "abc123" },
    "crc32c" => "Lm1F3g==",
    "etag" => "CKih16GjycICEAE=" }
end

def random_bucket_acl_hash bucket_name
  {
   "kind" => "storage#bucketAccessControls",
   "items" => [
    {
     "kind" => "storage#bucketAccessControl",
     "id" => "#{bucket_name}-UUID/project-owners-1234567890",
     "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/project-owners-1234567890",
     "bucket" => "#{bucket_name}-UUID",
     "entity" => "project-owners-1234567890",
     "role" => "OWNER",
     "projectTeam" => {
      "projectNumber" => "1234567890",
      "team" => "owners"
     },
     "etag" => "CAE="
    },
    {
     "kind" => "storage#bucketAccessControl",
     "id" => "#{bucket_name}-UUID/project-editors-1234567890",
     "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/project-editors-1234567890",
     "bucket" => "#{bucket_name}-UUID",
     "entity" => "project-editors-1234567890",
     "role" => "OWNER",
     "projectTeam" => {
      "projectNumber" => "1234567890",
      "team" => "editors"
     },
     "etag" => "CAE="
    },
    {
     "kind" => "storage#bucketAccessControl",
     "id" => "#{bucket_name}-UUID/project-viewers-1234567890",
     "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/project-viewers-1234567890",
     "bucket" => "#{bucket_name}-UUID",
     "entity" => "project-viewers-1234567890",
     "role" => "READER",
     "projectTeam" => {
      "projectNumber" => "1234567890",
      "team" => "viewers"
     },
     "etag" => "CAE="
    }
   ]
  }
end

def random_default_acl_hash bucket_name
  {
   "kind" => "storage#objectAccessControls",
   "items" => [
    {
     "kind" => "storage#objectAccessControl",
     "entity" => "project-owners-1234567890",
     "role" => "OWNER",
     "projectTeam" => {
      "projectNumber" => "1234567890",
      "team" => "owners"
     },
     "etag" => "CAE="
    },
    {
     "kind" => "storage#objectAccessControl",
     "entity" => "project-editors-1234567890",
     "role" => "OWNER",
     "projectTeam" => {
      "projectNumber" => "1234567890",
      "team" => "editors"
     },
     "etag" => "CAE="
    },
    {
     "kind" => "storage#objectAccessControl",
     "entity" => "project-viewers-1234567890",
     "role" => "READER",
     "projectTeam" => {
      "projectNumber" => "1234567890",
      "team" => "viewers"
     },
     "etag" => "CAE="
    }
   ]
  }
end

def random_file_acl_hash bucket_name, file_name
  {
   "kind" => "storage#objectAccessControls",
   "items" => [
    {
     "kind" => "storage#objectAccessControl",
     "id" => "#{bucket_name}/#{file_name}/123/project-owners-1234567890",
     "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/project-owners-1234567890",
     "bucket" => "#{bucket_name}",
     "object" => "#{file_name}",
     "generation" => "123",
     "entity" => "project-owners-1234567890",
     "role" => "OWNER",
     "projectTeam" => {
      "projectNumber" => "1234567890",
      "team" => "owners"
     },
     "etag" => "abcDEF123="
    },
    {
     "kind" => "storage#objectAccessControl",
     "id" => "#{bucket_name}/#{file_name}/123/project-editors-1234567890",
     "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/project-editors-1234567890",
     "bucket" => "#{bucket_name}",
     "object" => "#{file_name}",
     "generation" => "123",
     "entity" => "project-editors-1234567890",
     "role" => "OWNER",
     "projectTeam" => {
      "projectNumber" => "1234567890",
      "team" => "editors"
     },
     "etag" => "abcDEF123="
    },
    {
     "kind" => "storage#objectAccessControl",
     "id" => "#{bucket_name}/#{file_name}/123/project-viewers-1234567890",
     "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/project-viewers-1234567890",
     "bucket" => "#{bucket_name}",
     "object" => "#{file_name}",
     "generation" => "123",
     "entity" => "project-viewers-1234567890",
     "role" => "READER",
     "projectTeam" => {
      "projectNumber" => "1234567890",
      "team" => "viewers"
     },
     "etag" => "abcDEF123="
    },
    {
     "kind" => "storage#objectAccessControl",
     "id" => "#{bucket_name}/#{file_name}/123/user-12345678901234567890",
     "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/user-12345678901234567890",
     "bucket" => "#{bucket_name}",
     "object" => "#{file_name}",
     "generation" => "123",
     "entity" => "user-12345678901234567890",
     "role" => "OWNER",
     "entityId" => "12345678901234567890",
     "etag" => "abcDEF123="
    }
   ]
  }
end



