# Copyright 2016 Google LLC
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

require "minitest/focus"

require "google/cloud/storage"
require "google/cloud/pubsub"

class File
  def self.file? f
    true
  end
  def self.readable? f
    true
  end
  def self.read *args
    "fake file data"
  end
end

class OpenSSL::PKey::RSA
  def self.new *args
    "rsa key"
  end
end

module Google
  module Cloud
    module Storage
      class Project
        # no-op stub, but ensures that calls match this copied signature
        def signed_url bucket,
                       path,
                       method: "GET",
                       expires: nil,
                       content_type: nil,
                       content_md5: nil,
                       headers: nil,
                       issuer: nil,
                       client_email: nil,
                       signing_key: nil,
                       private_key: nil,
                       signer: nil,
                       query: nil,
                       scheme: "HTTPS",
                       virtual_hosted_style: nil,
                       bucket_bound_hostname: nil,
                       version: nil
        end
      end
      class Bucket
        # no-op stub, but ensures that calls match this copied signature
        def signed_url path = nil,
                       method: "GET",
                       expires: nil,
                       content_type: nil,
                       content_md5: nil,
                       headers: nil,
                       issuer: nil,
                       client_email: nil,
                       signing_key: nil,
                       private_key: nil,
                       signer: nil,
                       query: nil,
                       scheme: "HTTPS",
                       virtual_hosted_style: nil,
                       bucket_bound_hostname: nil,
                       version: nil
        end

        def post_object path,
                        policy: nil,
                        issuer: nil,
                        client_email: nil,
                        signing_key: nil,
                        private_key: nil,
                        signer: nil
          Google::Cloud::Storage::PostObject.new "https://storage.googleapis.com",
            { key: "my-todo-app/avatars/heidi/400x400.png",
              GoogleAccessId: "0123456789@gserviceaccount.com",
              signature: "ABC...XYZ=",
              policy: "ABC...XYZ=" }
        end

        def generate_signed_post_policy_v4 path,
                                           issuer: nil,
                                           client_email: nil,
                                           signing_key: nil,
                                           private_key: nil,
                                           signer: nil,
                                           expires: nil,
                                           fields: nil,
                                           conditions: nil,
                                           scheme: "https",
                                           virtual_hosted_style: nil,
                                           bucket_bound_hostname: nil
          fields = {
            "key" => "my-todo-app/avatars/heidi/400x400.png",
            "policy" => "ABC...XYZ",
            "x-goog-algorithm" => "GOOG4-RSA-SHA256",
            "x-goog-credential" => "cred@pid.iam.gserviceaccount.com/20200123/auto/storage/goog4_request",
            "x-goog-date" => "20200128T000000Z",
            "x-goog-signature" => "4893a0e...cd82",
          }
          Google::Cloud::Storage::PostObject.new "https://storage.googleapis.com/my-todo-app/", fields
        end
      end
      class File
        def download path = nil, verify: :md5, encryption_key: nil,
                     range: 0..-1, skip_decompress: nil
          StringIO.new("Hello world!"[range]) if path.nil?
        end

        def signed_url method: nil, expires: nil, content_type: nil,
                       content_md5: nil, headers: nil, issuer: nil,
                       client_email: nil, signing_key: nil, private_key: nil,
                       signer: nil, version: nil
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
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
      class Credentials
        # Override the default constructor
        def self.new *args
          OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
        end
      end
    end
  end
end

module Google
  module Cloud
    module Pubsub
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
    end
  end
end

def mock_storage
  Google::Cloud::Storage.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    storage = Google::Cloud::Storage::Project.new(Google::Cloud::Storage::Service.new("my-project", credentials))

    storage.service.mocked_service = Minitest::Mock.new

    yield storage.service.mocked_service if block_given?

    storage
  end
end

def mock_pubsub
  Google::Cloud::Pubsub.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    pubsub = Google::Cloud::Pubsub::Project.new(Google::Cloud::Pubsub::Service.new("my-project", credentials))

    pubsub.service.mocked_publisher = Minitest::Mock.new
    pubsub.service.mocked_subscriber = Minitest::Mock.new
    pubsub.service.mocked_iam = Minitest::Mock.new
    if block_given?
      yield pubsub.service.mocked_publisher, pubsub.service.mocked_subscriber, pubsub.service.mocked_iam
    end

    pubsub
  end
end

YARD::Doctest.configure do |doctest|
  # Current mocking does not support testing GAPIC layer. (Auth failures occur.)
  doctest.skip "Google::Cloud::Storage::V1beta1::SpeechClient"

  # Skip all aliases, since tests would be exact duplicates
  doctest.skip "Google::Cloud::Storage::Bucket#new_file"
  doctest.skip "Google::Cloud::Storage::Bucket#upload_file"
  doctest.skip "Google::Cloud::Storage::Bucket#find_files"
  doctest.skip "Google::Cloud::Storage::Bucket#combine"
  doctest.skip "Google::Cloud::Storage::Bucket#compose_file"
  doctest.skip "Google::Cloud::Storage::Bucket#new_notification"
  doctest.skip "Google::Cloud::Storage::Bucket#find_notification"
  doctest.skip "Google::Cloud::Storage::Bucket#find_notifications"
  doctest.skip "Google::Cloud::Storage::HmacKey#delete"
  doctest.skip "Google::Cloud::Storage::Project#find_bucket"
  doctest.skip "Google::Cloud::Storage::Project#find_buckets"

  doctest.before "Google::Cloud.storage" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud#storage" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage.new" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.skip "Google::Cloud::Storage::Credentials" # occasionally getting "This code example is not yet mocked"

  # Bucket

  doctest.before "Google::Cloud::Storage::Bucket" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#cors" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#compose" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :compose_object, file_gapi, ["my-bucket", "path/to/new-file.ext", Google::Apis::StorageV1::ComposeRequest, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#update" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#delete" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :delete_bucket, nil, ["my-bucket", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#files" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :list_objects, list_files_gapi, ["my-bucket", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#create_file" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :insert_object, file_gapi, ["my-bucket", Google::Apis::StorageV1::Object, Hash]
      # Following expectation is only used in last example
      mock.expect :get_object, file_gapi, ["my-bucket", "destination/path/file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#create_file@Create a file with gzip-encoded data." do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :insert_object, file_gapi, ["my-bucket", Google::Apis::StorageV1::Object, Hash]
      # Following expectation is only used in last example
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/gzipped.txt", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#create_notification" do
    mock_pubsub do |mock_publisher, mock_subscriber, mock_iam|
      mock_publisher.expect :create_topic, topic_gapi, [Hash]
      mock_iam.expect :get_iam_policy, policy_gapi_v1, [Hash]
      mock_iam.expect :set_iam_policy, policy_gapi_v1, [Hash]
    end
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_project_service_account, OpenStruct.new(email_address: "my_service_account@gs-project-accounts.iam.gserviceaccount.com"), ["my-project"]
      mock.expect :insert_notification, notification_gapi, ["my-bucket", Google::Apis::StorageV1::Notification, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#signed_url" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#generate_signed_post_policy_v4" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#acl" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
      mock.expect :insert_bucket_access_control, object_access_control_gapi, ["my-todo-app", Google::Apis::StorageV1::BucketAccessControl, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#acl@Or, grant access via a predefined permissions list:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-todo-app", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#default_acl" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
      mock.expect :insert_default_object_access_control, object_access_control_gapi, ["my-todo-app", Google::Apis::StorageV1::ObjectAccessControl, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#default_acl@Or, grant access via a predefined permissions list:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-todo-app", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#lifecycle" do
    mock_storage do |mock|
      mock.expect :insert_bucket, bucket_gapi, ["my-project", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#notification" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_notification, notification_gapi, ["my-bucket", "1", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#notifications" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :list_notifications, list_notifications_gapi, ["my-bucket", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#policy" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-bucket"), ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :get_bucket_iam_policy, policy_gapi_v1, ["my-bucket", Hash]
      mock.expect :set_bucket_iam_policy, new_policy_gapi, ["my-bucket", Google::Apis::StorageV1::Policy, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#policy_only" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#public_access_prevention" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end


  doctest.before "Google::Cloud::Storage::Bucket#public_access_prevention=@Set Public Access Prevention to enforced:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket", public_access_prevention: "enforced"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#public_access_prevention=@Set Public Access Prevention to inherited:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket", public_access_prevention: "inherited"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#rpo" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end  

  doctest.before "Google::Cloud::Storage::Bucket#rpo=@Set RPO to DEFAULT:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket", rpo: "DEFAULT"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#rpo=@Set RPO to ASYNC_TURBO:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket", rpo: "ASYNC_TURBO"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#uniform_bucket_level_access" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end
  doctest.before "Google::Cloud::Storage::Bucket#update_policy" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-bucket"), ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :get_bucket_iam_policy, policy_gapi_v1, ["my-bucket", Hash]
      mock.expect :set_bucket_iam_policy, new_policy_gapi, ["my-bucket", Google::Apis::StorageV1::Policy, Hash]
    end
  end
  doctest.skip "Google::Cloud::Storage::Bucket#policy="

  doctest.before "Google::Cloud::Storage::Bucket#requester_pays" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#default_kms_key" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#user_project" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["other-project-bucket", Hash]
      mock.expect :list_objects, list_files_gapi, ["my-bucket", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#retention_period" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :insert_object, file_gapi, ["my-bucket", Google::Apis::StorageV1::Object, Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#retention_policy_locked?" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :lock_bucket_retention_policy, bucket_gapi("my-bucket"), ["my-bucket", 1, Hash]
      mock.expect :insert_object, file_gapi, ["my-bucket", Google::Apis::StorageV1::Object, Hash]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#default_event_based_hold" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :insert_object, file_gapi, ["my-bucket", Google::Apis::StorageV1::Object, Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#lock_retention_policy!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :lock_bucket_retention_policy, bucket_gapi("my-bucket"), ["my-bucket", 1, Hash]
      mock.expect :insert_object, file_gapi, ["my-bucket", Google::Apis::StorageV1::Object, Hash]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#test_permissions" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-bucket"), ["my-bucket", Hash]
      mock.expect :get_bucket_iam_policy, policy_gapi_v1, ["my-bucket", Hash]
      mock.expect :test_bucket_iam_permissions, permissions_gapi, ["my-bucket", ["storage.buckets.get", "storage.buckets.delete"], Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket#user_project" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["other-project-bucket", Hash]
      mock.expect :list_objects, list_files_gapi, ["my-bucket", Hash]
      mock.expect :list_objects, list_files_gapi, ["my-bucket", Hash]
    end
  end

  # Bucket::Acl

  doctest.before "Google::Cloud::Storage::Bucket::Acl#reload!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      access_controls = Google::Apis::StorageV1::BucketAccessControls.from_json(random_bucket_acl_hash("my-bucket").to_json)
      mock.expect :list_bucket_access_controls, access_controls, ["my-bucket", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      access_controls = Google::Apis::StorageV1::BucketAccessControls.from_json(random_bucket_acl_hash("my-bucket").to_json)
      mock.expect :list_bucket_access_controls, access_controls, ["my-bucket", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#add_owner" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :insert_bucket_access_control, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::BucketAccessControl, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#add_writer" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :insert_bucket_access_control, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::BucketAccessControl, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#add_reader" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :insert_bucket_access_control, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::BucketAccessControl, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#delete" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :delete_bucket_access_control, true, ["my-bucket", "user-heidi@example.net", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#auth" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#private" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#project_private!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#projectPrivate!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#public" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#public_write!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Acl#publicReadWrite!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  # Bucket::DefaultAcl

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      access_controls = Google::Apis::StorageV1::ObjectAccessControls.from_json(random_default_acl_hash("my-bucket").to_json)
      mock.expect :list_default_object_access_controls, access_controls, ["my-bucket", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#add_" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :insert_default_object_access_control, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::ObjectAccessControl, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#delete" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :delete_default_object_access_control, true, ["my-bucket", "user-heidi@example.net", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#auth" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#owner_full!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#bucketOwnerFullControl!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#owner_read!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#bucketOwnerRead!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#private" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#project" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::DefaultAcl#public" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, object_access_control_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  # Bucket::Cors

  doctest.before "Google::Cloud::Storage::Bucket::Cors" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Bucket::Cors#add_rule" do
    mock_storage do |mock|
      mock.expect :insert_bucket, bucket_gapi, ["my-project", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  # Bucket::Lifecycle

  doctest.before "Google::Cloud::Storage::Bucket::Lifecycle" do
    mock_storage do |mock|
      mock.expect :insert_bucket, bucket_gapi, ["my-project", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi, ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  # Bucket::List

  doctest.before "Google::Cloud::Storage::Bucket::List" do
    mock_storage do |mock|
      mock.expect :list_buckets, list_buckets_gapi, ["my-project", Hash]
    end
  end

  # Bucket::Policy

  doctest.before "Google::Cloud::Storage::Policy" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-bucket"), ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :get_bucket_iam_policy, policy_gapi_v1, ["my-bucket", Hash]
      mock.expect :set_bucket_iam_policy, new_policy_gapi, ["my-bucket", Google::Apis::StorageV1::Policy, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Policy#role" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-bucket"), ["my-bucket", Hash]
      mock.expect :get_bucket_iam_policy, policy_gapi_v1, ["my-bucket", Hash]
      mock.expect :set_bucket_iam_policy, new_policy_gapi, ["my-bucket", Google::Apis::StorageV1::Policy, Hash]
    end
  end

  # File

  doctest.before "Google::Cloud::Storage::File" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#generations" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :list_objects, list_files_gapi, ["my-bucket", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#temporary_hold?" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#set_temporary_hold!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#release_temporary_hold!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#event_based_hold?" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#set_event_based_hold!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#release_event_based_hold!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :patch_bucket, bucket_gapi("my-bucket"), ["my-bucket", Google::Apis::StorageV1::Bucket, Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#update" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#copy" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :rewrite_object, done_rewrite(file_gapi), ["my-bucket", "path/to/my-file.ext", "new-destination-bucket", "path/to/destination/file.ext", nil, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#copy@The file can be copied to a new path in the current bucket:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :rewrite_object, done_rewrite(file_gapi), ["my-bucket", "path/to/my-file.ext", "my-bucket", "path/to/destination/file.ext", nil, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#copy@The file can also be copied by specifying a generation:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :rewrite_object, done_rewrite(file_gapi), ["my-bucket", "path/to/my-file.ext", "my-bucket", "copy/of/previous/generation/file.ext", nil, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#copy@The file can be modified during copying:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :rewrite_object, done_rewrite(file_gapi), ["my-bucket", "path/to/my-file.ext", "new-destination-bucket", "path/to/destination/file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#rewrite" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :rewrite_object, done_rewrite(file_gapi), ["my-bucket", "path/to/my-file.ext", "new-destination-bucket", "path/to/destination/file.ext", nil, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#rewrite@The file can be rewritten to a new path in the bucket:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :rewrite_object, done_rewrite(file_gapi), ["my-bucket", "path/to/my-file.ext", "my-bucket", "path/to/destination/file.ext", nil, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#rewrite@The file can also be rewritten by specifying a generation:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :rewrite_object, done_rewrite(file_gapi), ["my-bucket", "path/to/my-file.ext", "my-bucket", "copy/of/previous/generation/file.ext", nil, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#rewrite@The file can be modified during rewriting:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :rewrite_object, done_rewrite(file_gapi), ["my-bucket", "path/to/my-file.ext", "new-destination-bucket", "path/to/destination/file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#rewrite@Rewriting with a customer-supplied encryption key:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :rewrite_object, done_rewrite(file_gapi), ["my-bucket", "path/to/my-file.ext", "new-destination-bucket", "path/to/destination/file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#rewrite@Rewriting with a customer-managed Cloud KMS encryption key:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :rewrite_object, done_rewrite(file_gapi), ["my-bucket", "path/to/my-file.ext", "new-destination-bucket", "path/to/destination/file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#rotate" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :rewrite_object, OpenStruct.new(done: true, resource: file_gapi), ["my-bucket", "path/to/my-file.ext", "my-bucket", "path/to/my-file.ext", nil, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#delete" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :delete_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#download@Download to an in-memory StringIO object." do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#download@Upload and download gzip-encoded file data." do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :insert_object, file_gapi, ["my-bucket", Google::Apis::StorageV1::Object, Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/gzipped.txt", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#public_url" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
      mock.expect :get_object, file_gapi, ["my-todo-app", "avatars/heidi/400x400.png", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#url" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
      mock.expect :get_object, file_gapi, ["my-todo-app", "avatars/heidi/400x400.png", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#user_project" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["other-project-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/file.ext", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#acl" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
      mock.expect :get_object, file_gapi, ["my-todo-app", "avatars/heidi/400x400.png", Hash]
      mock.expect :insert_object_access_control, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::ObjectAccessControl, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#acl@Or, grant access via a predefined permissions list:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
      mock.expect :get_object, file_gapi, ["my-todo-app", "avatars/heidi/400x400.png", Hash]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File#signed_url" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
      mock.expect :get_object, file_gapi, ["my-todo-app", "avatars/heidi/400x400.png", Hash]
    end
  end

  # File::Acl

  doctest.before "Google::Cloud::Storage::File::Acl" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      access_controls = Google::Apis::StorageV1::ObjectAccessControls.from_json(random_file_acl_hash("my-bucket", "path/to/my-file.ext").to_json)
      mock.expect :list_object_access_controls, access_controls, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#add_owner" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :insert_object_access_control, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::ObjectAccessControl, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#add_reader" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :insert_object_access_control, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::ObjectAccessControl, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#delete" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :delete_object_access_control, true, ["my-bucket", "path/to/my-file.ext", "user-heidi@example.net", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#auth" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#owner_full!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#bucketOwnerFullControl!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#owner_read!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#bucketOwnerRead!" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#private" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#project" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::File::Acl#public" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :patch_object, object_access_control_gapi, ["my-bucket", "path/to/my-file.ext", Google::Apis::StorageV1::Object, Hash]
    end
  end

  # File::List

  doctest.before "Google::Cloud::Storage::File::List" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :list_objects, list_files_gapi, ["my-bucket", Hash]
    end
  end

  # HmacKey

  doctest.before "Google::Cloud::Storage::HmacKey" do
    mock_storage do |mock|
      mock.expect :create_project_hmac_key, hmac_key_gapi, ["my-project", "my_account@developer.gserviceaccount.com", Hash]
      mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, ["my-project", "my-access-id", Hash]
      mock.expect :update_project_hmac_key, hmac_key_metadata_gapi, ["my-project", "my-access-id", Google::Apis::StorageV1::HmacKeyMetadata, Hash]
      mock.expect :delete_project_hmac_key, hmac_key_metadata_gapi, ["my-project", "my-access-id", Hash]
      mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, ["my-project", "my-access-id", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::HmacKey#active!" do
    mock_storage do |mock|
      mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi, ["my-project", Hash]
      mock.expect :update_project_hmac_key, hmac_key_metadata_gapi, ["my-project", "my-access-id", Google::Apis::StorageV1::HmacKeyMetadata, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::HmacKey#inactive!" do
    mock_storage do |mock|
      mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi, ["my-project", Hash]
      mock.expect :update_project_hmac_key, hmac_key_metadata_gapi, ["my-project", "my-access-id", Google::Apis::StorageV1::HmacKeyMetadata, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::HmacKey#delete!" do
    mock_storage do |mock|
      mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi, ["my-project", Hash]
      mock.expect :update_project_hmac_key, hmac_key_metadata_gapi, ["my-project", "my-access-id", Google::Apis::StorageV1::HmacKeyMetadata, Hash]
      mock.expect :delete_project_hmac_key, hmac_key_metadata_gapi, ["my-project", "my-access-id", Hash]
      mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, ["my-project", "my-access-id", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::HmacKey::List" do
    mock_storage do |mock|
      mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi, ["my-project", Hash]
    end
  end

  # Notification

  doctest.before "Google::Cloud::Storage::Notification" do
    mock_pubsub do |mock_publisher, mock_subscriber, mock_iam|
      mock_publisher.expect :create_topic, topic_gapi, [Hash]
      mock_iam.expect :get_iam_policy, policy_gapi_v1, [Hash]
      mock_iam.expect :set_iam_policy, policy_gapi_v1, [Hash]
    end
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_project_service_account, OpenStruct.new(email_address: "my_service_account@gs-project-accounts.iam.gserviceaccount.com"), ["my-project"]
      mock.expect :insert_notification, notification_gapi, ["my-bucket", Google::Apis::StorageV1::Notification, Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Notification#delete" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_notification, notification_gapi, ["my-bucket", "1", Hash]
      mock.expect :delete_notification, nil, ["my-bucket", nil, Hash]
    end
  end

  # Project

  doctest.before "Google::Cloud::Storage::Project" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Project#bucket@With `user_project` set to bill costs to the default project:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["other-project-bucket", Hash]
      mock.expect :list_objects, list_files_gapi, ["my-bucket", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Project#bucket@With `user_project` set to a project other than the default:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["other-project-bucket", Hash]
      mock.expect :list_objects, list_files_gapi, ["my-bucket", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Project#buckets" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :list_buckets, list_buckets_gapi, ["my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Project#buckets@Retrieve buckets with names that begin with a given prefix:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :list_buckets, list_buckets_gapi, ["my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::Storage::Project#create_bucket" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi, ["my-bucket", Hash]
      mock.expect :get_object, file_gapi, ["my-bucket", "path/to/my-file.ext", Hash]
      mock.expect :insert_bucket, bucket_gapi, ["my-project", Google::Apis::StorageV1::Bucket, Hash]
    end
  end

  # PostObject

  doctest.before "Google::Cloud::Storage::Bucket#post_object" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
    end
  end
  doctest.before "Google::Cloud::Storage::Bucket#post_object@Using a policy to define the upload authorization:" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
    end
  end
  doctest.before "Google::Cloud::Storage::Bucket#post_object@Using the issuer and signing_key options:" do
    mock_storage do |mock|
      OpenSSL::PKey::RSA.stub :new, "key" do
        mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
      end
    end
  end

  doctest.before "Google::Cloud::Storage::PostObject" do
    mock_storage do |mock|
      mock.expect :get_bucket, bucket_gapi("my-todo-app"), ["my-todo-app", Hash]
    end
  end

end

# stubbed methods for use in examples

def kms_key_name
  "projects/a/locations/b/keyRings/c/cryptoKeys/d"
end


# Fixture helpers

def bucket_gapi name = "my-bucket", public_access_prevention: "enforced", rpo: "DEFAULT"
  Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name: name, public_access_prevention: public_access_prevention, rpo: rpo).to_json
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

def done_rewrite gapi
  Google::Apis::StorageV1::RewriteResponse.new done: true, resource: gapi
end

def random_bucket_hash name: "my-bucket",
                       url_root: "https://www.googleapis.com/storage/v1",
                       location: "US",
                       storage_class: "STANDARD",
                       versioning: nil,
                       logging_bucket: nil,
                       logging_prefix: nil,
                       website_main: nil,
                       website_404: nil,
                       public_access_prevention: nil,
                       rpo: "DEFAULT"
  versioning_config = { "enabled" => versioning } if versioning
  iam_configuration = { "publicAccessPrevention" => public_access_prevention } if public_access_prevention
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
    "lifecycle" => lifecycle_hash,
    "logging" => logging_hash(logging_bucket, logging_prefix),
    "storageClass" => storage_class,
    "versioning" => versioning_config,
    "website" => website_hash(website_main, website_404),
    "encryption" => { "defaultKmsKeyName" => kms_key_name },
    "iamConfiguration" => iam_configuration,
    "rpo" => rpo,
    "etag" => "CAE=" }.delete_if { |_, v| v.nil? }
end

def lifecycle_hash
  {
    "rule" => [
      {
        "action" => {
          "type" => "SetStorageClass",
          "storageClass" => "COLDLINE"
        },
        "condition" => {
          "age" => 10,
          "matchesStorageClass" => ["STANDARD", "NEARLINE"]
        }
      },
      {
        "action" => {
          "type" => "Delete"
        },
        "condition" => {
          "age" => 10
        }
      }
    ]
  }
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
    "etag" => "CKih16GjycICEAE=",
    "kmsKeyName" => kms_key_name }
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

def hmac_key_metadata_gapi
  Google::Apis::StorageV1::HmacKeyMetadata.new(
    access_id: "my-access-id"
  )
end

def hmac_key_gapi
  Google::Apis::StorageV1::HmacKey.new(
    secret: "0123456789012345678901234567890123456789",
    metadata: hmac_key_metadata_gapi
  )
end

def hmac_keys_metadata_gapi
  Google::Apis::StorageV1::HmacKeysMetadata.new(
    items: [hmac_key_metadata_gapi]
  )
end

def policy_gapi
  Google::Apis::StorageV1::Policy.new(
    etag: "CAE=",
    bindings: [
      Google::Apis::StorageV1::Policy::Binding.new(
        role: "roles/storage.objectViewer",
        members: [
          "user:viewer@example.com"
        ]
      )
    ]
  )
end

def new_policy_gapi
  Google::Apis::StorageV1::Policy.new(
    etag: "CAE=",
    bindings: [
      Google::Apis::StorageV1::Policy::Binding.new(
        role: "roles/storage.objectViewer",
        members: [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
        ]
      )
    ]
  )
end

def permissions_gapi
  Google::Apis::StorageV1::TestIamPermissionsResponse.new(
    permissions: ["storage.buckets.get"]
  )
end

def notification_gapi
  Google::Apis::StorageV1::Notification.new(
    payload_format: "JSON_API_V1",
    topic: "my-topic"
  )
end

def list_notifications_gapi count = 2
  notifications = count.times.map { notification_gapi }
  Google::Apis::StorageV1::Notifications.new kind: "storage#notifications", items: notifications
end

def topic_gapi topic_name = "my-topic"
  Google::Pubsub::V1::Topic.new name: topic_path(topic_name)
end

def policy_gapi_v1
  policy_gapi(
    version: 1,
    bindings: [
      Google::Apis::StorageV1::Policy::Binding.new(
        role: "roles/storage.objectViewer",
        members: [
          "user:viewer@example.com"
        ]
      )
    ]
  )
end

def policy_gapi_v3
  policy_gapi(
    version: 3,
    bindings: [
      Google::Apis::StorageV1::Policy::Binding.new(
        role: "roles/storage.objectViewer",
        members: [
          "user:viewer@example.com"
        ]
      ),
      Google::Apis::StorageV1::Policy::Binding.new(
        role: "roles/storage.objectViewer",
        members: [
          "serviceAccount:1234567890@developer.gserviceaccount.com"
        ],
        condition: {
          title: "always-true",
          description: "test condition always-true",
          expression: "true"
        }
      )
    ]
  )
end

def policy_gapi etag: "CAE=", version: 1, bindings: []
  Google::Apis::StorageV1::Policy.new etag: etag, version: version, bindings: bindings
end

def project_path
  "projects/my-project"
end

def topic_path topic_name
  "#{project_path}/topics/#{topic_name}"
end
