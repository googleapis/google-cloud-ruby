# Copyright 2015 Google LLC
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

describe Google::Cloud::Storage::Bucket, :default_acl, :mock_storage do
  let(:bucket_name) { "found-bucket" }
  let(:bucket_hash) { random_bucket_hash bucket_name }
  let(:bucket_json) { bucket_hash.to_json }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }

  it "retrieves the default ACL" do
    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: nil}]
    mock.expect :list_default_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_default_acl_hash(bucket_name).to_json),
      [bucket_name, user_project: nil]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name
    bucket.name.must_equal bucket_name
    bucket.default_acl.owners.wont_be  :empty?
    bucket.default_acl.readers.wont_be :empty?

    mock.verify
  end

  it "retrieves the default ACL with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: "test"}]
    mock.expect :list_default_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_default_acl_hash(bucket_name).to_json),
      [bucket_name, user_project: "test"]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true
    bucket.name.must_equal bucket_name
    bucket.default_acl.owners.wont_be  :empty?
    bucket.default_acl.readers.wont_be :empty?

    mock.verify
  end

  it "adds to the default ACL" do
    reader_entity = "user-user@example.net"
    reader_acl = {
       "kind" => "storage#bucketAccessControl",
       "id" => "#{bucket_name}-UUID/#{reader_entity}",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/#{reader_entity}",
       "bucket" => "#{bucket_name}-UUID",
       "entity" => reader_entity,
       "email" => "user@example.net",
       "role" => "READER",
       "etag" => "CAE="
      }

    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: nil}]
    mock.expect :list_default_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_default_acl_hash(bucket_name).to_json),
      [bucket_name, user_project: nil]
    mock.expect :insert_default_object_access_control,
      Google::Apis::StorageV1::BucketAccessControl.from_json(reader_acl.to_json),
      [bucket_name, Google::Apis::StorageV1::BucketAccessControl.new(entity: reader_entity, role: "READER"), user_project: nil]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name
    bucket.name.must_equal bucket_name
    bucket.default_acl.owners.wont_be  :empty?
    bucket.default_acl.readers.wont_be :empty?

    bucket.default_acl.add_reader reader_entity
    bucket.default_acl.owners.wont_be  :empty?
    bucket.default_acl.readers.wont_be :empty?
    bucket.default_acl.readers.must_include reader_entity

    mock.verify
  end

  it "adds to the default ACL with user_project set to true" do
    reader_entity = "user-user@example.net"
    reader_acl = {
       "kind" => "storage#bucketAccessControl",
       "id" => "#{bucket_name}-UUID/#{reader_entity}",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/#{reader_entity}",
       "bucket" => "#{bucket_name}-UUID",
       "entity" => reader_entity,
       "email" => "user@example.net",
       "role" => "READER",
       "etag" => "CAE="
      }

    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: "test"}]
    mock.expect :list_default_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_default_acl_hash(bucket_name).to_json),
      [bucket_name, user_project: "test"]
    mock.expect :insert_default_object_access_control,
      Google::Apis::StorageV1::BucketAccessControl.from_json(reader_acl.to_json),
      [bucket_name, Google::Apis::StorageV1::BucketAccessControl.new(entity: reader_entity, role: "READER"), user_project: "test"]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true
    bucket.name.must_equal bucket_name
    bucket.default_acl.owners.wont_be  :empty?
    bucket.default_acl.readers.wont_be :empty?

    bucket.default_acl.add_reader reader_entity
    bucket.default_acl.owners.wont_be  :empty?
    bucket.default_acl.readers.wont_be :empty?
    bucket.default_acl.readers.must_include reader_entity

    mock.verify
  end

  it "removes from the default ACL" do
    existing_reader_entity = "project-viewers-1234567890"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: nil}]
    mock.expect :list_default_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_default_acl_hash(bucket_name).to_json),
      [bucket_name, user_project: nil]
    mock.expect :delete_default_object_access_control, nil,
      [bucket_name, existing_reader_entity, user_project: nil]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name
    bucket.name.must_equal bucket_name
    bucket.default_acl.owners.wont_be  :empty?
    bucket.default_acl.readers.wont_be :empty?

    reader_entity = bucket.default_acl.readers.first
    bucket.default_acl.delete reader_entity
    bucket.default_acl.owners.wont_be  :empty?
    bucket.default_acl.readers.must_be :empty?

    mock.verify
  end

  it "removes from the default ACL with user_project set to true" do
    existing_reader_entity = "project-viewers-1234567890"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: "test"}]
    mock.expect :list_default_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_default_acl_hash(bucket_name).to_json),
      [bucket_name, user_project: "test"]
    mock.expect :delete_default_object_access_control, nil,
      [bucket_name, existing_reader_entity, user_project: "test"]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true
    bucket.name.must_equal bucket_name
    bucket.default_acl.owners.wont_be  :empty?
    bucket.default_acl.readers.wont_be :empty?

    reader_entity = bucket.default_acl.readers.first
    bucket.default_acl.delete reader_entity
    bucket.default_acl.owners.wont_be  :empty?
    bucket.default_acl.readers.must_be :empty?

    mock.verify
  end

  it "sets the predefined ACL rule authenticatedRead" do
    predefined_default_acl_update "authenticatedRead" do |acl|
      acl.authenticatedRead!
    end
  end

  it "sets the predefined ACL rule auth" do
    predefined_default_acl_update "authenticatedRead" do |acl|
      acl.auth!
    end
  end

  it "sets the predefined ACL rule auth_read" do
    predefined_default_acl_update "authenticatedRead" do |acl|
      acl.auth_read!
    end
  end

  it "sets the predefined ACL rule authenticated" do
    predefined_default_acl_update "authenticatedRead" do |acl|
      acl.authenticated!
    end
  end

  it "sets the predefined ACL rule authenticated_read" do
    predefined_default_acl_update "authenticatedRead" do |acl|
      acl.authenticated_read!
    end
  end

  it "sets the predefined ACL rule bucketOwnerFullControl" do
    predefined_default_acl_update "bucketOwnerFullControl" do |acl|
      acl.bucketOwnerFullControl!
    end
  end

  it "sets the predefined ACL rule owner_full" do
    predefined_default_acl_update "bucketOwnerFullControl" do |acl|
      acl.owner_full!
    end
  end

  it "sets the predefined ACL rule bucketOwnerRead" do
    predefined_default_acl_update "bucketOwnerRead" do |acl|
      acl.bucketOwnerRead!
    end
  end

  it "sets the predefined ACL rule owner_read" do
    predefined_default_acl_update "bucketOwnerRead" do |acl|
      acl.owner_read!
    end
  end

  it "sets the predefined ACL rule private" do
    predefined_default_acl_update "private" do |acl|
      acl.private!
    end
  end

  it "sets the predefined ACL rule projectPrivate" do
    predefined_default_acl_update "projectPrivate" do |acl|
      acl.projectPrivate!
    end
  end

  it "sets the predefined ACL rule project_private" do
    predefined_default_acl_update "projectPrivate" do |acl|
      acl.project_private!
    end
  end

  it "sets the predefined ACL rule publicRead" do
    predefined_default_acl_update "publicRead" do |acl|
      acl.publicRead!
    end
  end

  it "sets the predefined ACL rule public" do
    predefined_default_acl_update "publicRead" do |acl|
      acl.public!
    end
  end

  it "sets the predefined ACL rule public_read" do
    predefined_default_acl_update "publicRead" do |acl|
      acl.public_read!
    end
  end

  it "raises when the predefined ACL rule authenticatedRead returns an error" do
    predefined_default_acl_update_with_error "authenticatedRead" do |acl|
      acl.authenticatedRead!
    end
  end

  it "raises when the predefined ACL rule auth returns an error" do
    predefined_default_acl_update_with_error "authenticatedRead" do |acl|
      acl.auth!
    end
  end

  it "raises when the predefined ACL rule auth_read returns an error" do
    predefined_default_acl_update_with_error "authenticatedRead" do |acl|
      acl.auth_read!
    end
  end

  it "raises when the predefined ACL rule authenticated returns an error" do
    predefined_default_acl_update_with_error "authenticatedRead" do |acl|
      acl.authenticated!
    end
  end

  it "raises when the predefined ACL rule authenticated_read returns an error" do
    predefined_default_acl_update_with_error "authenticatedRead" do |acl|
      acl.authenticated_read!
    end
  end

  it "raises when the predefined ACL rule bucketOwnerFullControl returns an error" do
    predefined_default_acl_update_with_error "bucketOwnerFullControl" do |acl|
      acl.bucketOwnerFullControl!
    end
  end

  it "raises when the predefined ACL rule owner_full returns an error" do
    predefined_default_acl_update_with_error "bucketOwnerFullControl" do |acl|
      acl.owner_full!
    end
  end

  it "raises when the predefined ACL rule bucketOwnerRead returns an error" do
    predefined_default_acl_update_with_error "bucketOwnerRead" do |acl|
      acl.bucketOwnerRead!
    end
  end

  it "raises when the predefined ACL rule owner_read returns an error" do
    predefined_default_acl_update_with_error "bucketOwnerRead" do |acl|
      acl.owner_read!
    end
  end

  it "raises when the predefined ACL rule private returns an error" do
    predefined_default_acl_update_with_error "private" do |acl|
      acl.private!
    end
  end

  it "raises when the predefined ACL rule projectPrivate returns an error" do
    predefined_default_acl_update_with_error "projectPrivate" do |acl|
      acl.projectPrivate!
    end
  end

  it "raises when the predefined ACL rule project_private returns an error" do
    predefined_default_acl_update_with_error "projectPrivate" do |acl|
      acl.project_private!
    end
  end

  it "raises when the predefined ACL rule publicRead returns an error" do
    predefined_default_acl_update_with_error "publicRead" do |acl|
      acl.publicRead!
    end
  end

  it "raises when the predefined ACL rule public returns an error" do
    predefined_default_acl_update_with_error "publicRead" do |acl|
      acl.public!
    end
  end

  it "raises when the predefined ACL rule public_read returns an error" do
    predefined_default_acl_update_with_error "publicRead" do |acl|
      acl.public_read!
    end
  end

  def predefined_default_acl_update acl_role
    mock = Minitest::Mock.new
    mock.expect :patch_bucket,
      Google::Apis::StorageV1::Bucket.from_json(random_bucket_hash(bucket.name).to_json),
      [bucket_name, Google::Apis::StorageV1::Bucket.new(default_object_acl: []),
       predefined_acl: nil, predefined_default_object_acl: acl_role, user_project: nil]

    storage.service.mocked_service = mock

    yield bucket.default_acl

    mock.verify
  end

  def predefined_default_acl_update_with_error acl_role
    stub = Object.new
    def stub.patch_bucket *args
      raise Google::Apis::ClientError.new("already exists", status_code: 409)
    end
    storage.service.mocked_service = stub

    expect { yield bucket.default_acl }.must_raise Google::Cloud::AlreadyExistsError
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

  def acl_error_json
    {
      "error" => {
        "errors" => [ {
          "domain" => "global",
          "reason" => "conflict",
          "message" => "Cannot provide both a predefinedAcl and access controls."
        } ],
        "code" => 409,
        "message" => "Cannot provide both a predefinedAcl and access controls."
      }
    }.to_json
  end
end
