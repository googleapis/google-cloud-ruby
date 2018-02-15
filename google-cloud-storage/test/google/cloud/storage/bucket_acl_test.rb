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

describe Google::Cloud::Storage::Bucket, :acl, :mock_storage do
  let(:bucket_name) { "found-bucket" }
  let(:bucket_hash) { random_bucket_hash bucket_name }
  let(:bucket_json) { bucket_hash.to_json }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }

  it "retrieves the ACL" do
    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: nil}]
    mock.expect :list_bucket_access_controls,
      Google::Apis::StorageV1::BucketAccessControls.from_json(random_bucket_acl_hash(bucket_name).to_json),
      [bucket_name, user_project: nil]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name
    bucket.name.must_equal bucket_name
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.must_be :empty?
    bucket.acl.readers.wont_be :empty?

    mock.verify
  end

  it "retrieves the ACL with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: "test"}]
    mock.expect :list_bucket_access_controls,
      Google::Apis::StorageV1::BucketAccessControls.from_json(random_bucket_acl_hash(bucket_name).to_json),
      [bucket_name, user_project: "test"]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true
    bucket.name.must_equal bucket_name
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.must_be :empty?
    bucket.acl.readers.wont_be :empty?

    mock.verify
  end

  it "adds a writer to the ACL" do
    entity = "user-user@example.net"
    writer_acl = {
       "kind" => "storage#bucketAccessControl",
       "id" => "#{bucket_name}-UUID/#{entity}",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/#{entity}",
       "bucket" => "#{bucket_name}-UUID",
       "entity" => entity,
       "email" => "user@example.net",
       "role" => "WRITER",
       "etag" => "CAE="
      }

    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: nil}]
    mock.expect :list_bucket_access_controls,
      Google::Apis::StorageV1::BucketAccessControls.from_json(random_bucket_acl_hash(bucket_name).to_json),
      [bucket_name, user_project: nil]
    mock.expect :insert_bucket_access_control,
      Google::Apis::StorageV1::BucketAccessControl.from_json(writer_acl.to_json),
      [bucket_name, Google::Apis::StorageV1::BucketAccessControl.new(entity: entity, role: "WRITER"), user_project: nil]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name
    bucket.name.must_equal bucket_name
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.must_be :empty?
    bucket.acl.readers.wont_be :empty?

    bucket.acl.add_writer entity
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.wont_be :empty?
    bucket.acl.readers.wont_be :empty?
    bucket.acl.writers.must_include entity

    mock.verify
  end

  it "adds a reader to the ACL with user_project set to true" do
    entity = "user-user@example.net"
    acl_hash = {
       "kind" => "storage#bucketAccessControl",
       "id" => "#{bucket_name}-UUID/#{entity}",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/#{entity}",
       "bucket" => "#{bucket_name}-UUID",
       "entity" => entity,
       "email" => "user@example.net",
       "role" => "READER",
       "etag" => "CAE="
      }

    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: "test"}]
    mock.expect :insert_bucket_access_control,
      Google::Apis::StorageV1::BucketAccessControl.from_json(acl_hash.to_json),
      [bucket_name, Google::Apis::StorageV1::BucketAccessControl.new(entity: entity, role: "READER"), user_project: "test"]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true

    bucket.acl.add_reader entity

    mock.verify
  end

  it "adds a writer to the ACL with user_project set to true" do
    entity = "user-user@example.net"
    acl_hash = {
       "kind" => "storage#bucketAccessControl",
       "id" => "#{bucket_name}-UUID/#{entity}",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/#{entity}",
       "bucket" => "#{bucket_name}-UUID",
       "entity" => entity,
       "email" => "user@example.net",
       "role" => "WRITER",
       "etag" => "CAE="
      }

    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: "test"}]
    mock.expect :list_bucket_access_controls,
      Google::Apis::StorageV1::BucketAccessControls.from_json(random_bucket_acl_hash(bucket_name).to_json),
      [bucket_name, user_project: "test"]
    mock.expect :insert_bucket_access_control,
      Google::Apis::StorageV1::BucketAccessControl.from_json(acl_hash.to_json),
      [bucket_name, Google::Apis::StorageV1::BucketAccessControl.new(entity: entity, role: "WRITER"), user_project: "test"]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true
    bucket.name.must_equal bucket_name
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.must_be :empty?
    bucket.acl.readers.wont_be :empty?

    bucket.acl.add_writer entity
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.wont_be :empty?
    bucket.acl.readers.wont_be :empty?
    bucket.acl.writers.must_include entity

    mock.verify
  end

  it "adds an owner to the ACL with user_project set to true" do
    entity = "user-user@example.net"
    acl_hash = {
       "kind" => "storage#bucketAccessControl",
       "id" => "#{bucket_name}-UUID/#{entity}",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/#{entity}",
       "bucket" => "#{bucket_name}-UUID",
       "entity" => entity,
       "email" => "user@example.net",
       "role" => "OWNER",
       "etag" => "CAE="
      }

    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: "test"}]
    mock.expect :insert_bucket_access_control,
      Google::Apis::StorageV1::BucketAccessControl.from_json(acl_hash.to_json),
      [bucket_name, Google::Apis::StorageV1::BucketAccessControl.new(entity: entity, role: "OWNER"), user_project: "test"]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true

    bucket.acl.add_owner entity

    mock.verify
  end

  it "removes from the ACL" do
    existing_reader_entity = "project-viewers-1234567890"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: nil}]
    mock.expect :list_bucket_access_controls,
      Google::Apis::StorageV1::BucketAccessControls.from_json(random_bucket_acl_hash(bucket_name).to_json),
      [bucket_name, user_project: nil]
    mock.expect :delete_bucket_access_control, nil,
      [bucket_name, existing_reader_entity, {user_project: nil}]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name
    bucket.name.must_equal bucket_name
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.must_be :empty?
    bucket.acl.readers.wont_be :empty?

    reader_entity = bucket.acl.readers.first
    bucket.acl.delete reader_entity
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.must_be :empty?
    bucket.acl.readers.must_be :empty?

    mock.verify
  end

  it "removes from the ACL with user_project set to true" do
    existing_reader_entity = "project-viewers-1234567890"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: "test"}]
    mock.expect :list_bucket_access_controls,
      Google::Apis::StorageV1::BucketAccessControls.from_json(random_bucket_acl_hash(bucket_name).to_json),
      [bucket_name, user_project: "test"]
    mock.expect :delete_bucket_access_control, nil,
      [bucket_name, existing_reader_entity, {user_project: "test"}]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true
    bucket.name.must_equal bucket_name
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.must_be :empty?
    bucket.acl.readers.wont_be :empty?

    reader_entity = bucket.acl.readers.first
    bucket.acl.delete reader_entity
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.must_be :empty?
    bucket.acl.readers.must_be :empty?

    mock.verify
  end

  it "sets the predefined ACL rule authenticatedRead" do
    predefined_acl_update "authenticatedRead" do |acl|
      acl.authenticatedRead!
    end
  end

  it "sets the predefined ACL rule authenticatedRead with user_project set to true" do

    mock = Minitest::Mock.new
    mock.expect :get_bucket, bucket_gapi, [bucket_name, {user_project: "test"}]
    mock.expect :patch_bucket,
      Google::Apis::StorageV1::Bucket.from_json(random_bucket_hash(bucket_name).to_json),
      [bucket_name, Google::Apis::StorageV1::Bucket.new(acl: []),
       predefined_acl: "authenticatedRead", predefined_default_object_acl: nil, user_project: "test"]

    storage.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true
    bucket.acl.authenticatedRead!

    mock.verify
  end

  it "sets the predefined ACL rule auth" do
    predefined_acl_update "authenticatedRead" do |acl|
      acl.auth!
    end
  end

  it "sets the predefined ACL rule auth_read" do
    predefined_acl_update "authenticatedRead" do |acl|
      acl.auth_read!
    end
  end

  it "sets the predefined ACL rule authenticated" do
    predefined_acl_update "authenticatedRead" do |acl|
      acl.authenticated!
    end
  end

  it "sets the predefined ACL rule authenticated_read" do
    predefined_acl_update "authenticatedRead" do |acl|
      acl.authenticated_read!
    end
  end

  it "sets the predefined ACL rule private" do
    predefined_acl_update "private" do |acl|
      acl.private!
    end
  end

  it "sets the predefined ACL rule projectPrivate" do
    predefined_acl_update "projectPrivate" do |acl|
      acl.projectPrivate!
    end
  end

  it "sets the predefined ACL rule project_private" do
    predefined_acl_update "projectPrivate" do |acl|
      acl.project_private!
    end
  end

  it "sets the predefined ACL rule publicRead" do
    predefined_acl_update "publicRead" do |acl|
      acl.publicRead!
    end
  end

  it "sets the predefined ACL rule public" do
    predefined_acl_update "publicRead" do |acl|
      acl.public!
    end
  end

  it "sets the predefined ACL rule public_read" do
    predefined_acl_update "publicRead" do |acl|
      acl.public_read!
    end
  end

  it "sets the predefined ACL rule publicReadWrite" do
    predefined_acl_update "publicReadWrite" do |acl|
      acl.publicReadWrite!
    end
  end

  it "sets the predefined ACL rule public_write" do
    predefined_acl_update "publicReadWrite" do |acl|
      acl.public_write!
    end
  end

  it "raises when the predefined ACL rule authenticatedRead returns an error" do
    predefined_acl_update_with_error "authenticatedRead" do |acl|
      acl.authenticatedRead!
    end
  end

  it "raises when the predefined ACL rule auth returns an error" do
    predefined_acl_update_with_error "authenticatedRead" do |acl|
      acl.auth!
    end
  end

  it "raises when the predefined ACL rule auth_read returns an error" do
    predefined_acl_update_with_error "authenticatedRead" do |acl|
      acl.auth_read!
    end
  end

  it "raises when the predefined ACL rule authenticated returns an error" do
    predefined_acl_update_with_error "authenticatedRead" do |acl|
      acl.authenticated!
    end
  end

  it "raises when the predefined ACL rule authenticated_read returns an error" do
    predefined_acl_update_with_error "authenticatedRead" do |acl|
      acl.authenticated_read!
    end
  end

  it "raises when the predefined ACL rule private returns an error" do
    predefined_acl_update_with_error "private" do |acl|
      acl.private!
    end
  end

  it "raises when the predefined ACL rule projectPrivate returns an error" do
    predefined_acl_update_with_error "projectPrivate" do |acl|
      acl.projectPrivate!
    end
  end

  it "raises when the predefined ACL rule project_private returns an error" do
    predefined_acl_update_with_error "projectPrivate" do |acl|
      acl.project_private!
    end
  end

  it "raises when the predefined ACL rule publicRead returns an error" do
    predefined_acl_update_with_error "publicRead" do |acl|
      acl.publicRead!
    end
  end

  it "raises when the predefined ACL rule public returns an error" do
    predefined_acl_update_with_error "publicRead" do |acl|
      acl.public!
    end
  end

  it "raises when the predefined ACL rule public_read returns an error" do
    predefined_acl_update_with_error "publicRead" do |acl|
      acl.public_read!
    end
  end

  it "raises when the predefined ACL rule publicReadWrite returns an error" do
    predefined_acl_update_with_error "publicReadWrite" do |acl|
      acl.publicReadWrite!
    end
  end

  it "raises when the predefined ACL rule public_write returns an error" do
    predefined_acl_update_with_error "publicReadWrite" do |acl|
      acl.public_write!
    end
  end

  def predefined_acl_update acl_role
    mock = Minitest::Mock.new
    mock.expect :patch_bucket,
      Google::Apis::StorageV1::Bucket.from_json(random_bucket_hash(bucket.name).to_json),
      [bucket_name, Google::Apis::StorageV1::Bucket.new(acl: []),
       predefined_acl: acl_role, predefined_default_object_acl: nil, user_project: nil]

    storage.service.mocked_service = mock

    yield bucket.acl

    mock.verify
  end

  def predefined_acl_update_with_error acl_role
    stub = Object.new
    def stub.patch_bucket *args
      raise Google::Apis::ClientError.new("already exists", status_code: 409)
    end
    storage.service.mocked_service = stub

    expect { yield bucket.acl }.must_raise Google::Cloud::AlreadyExistsError
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
