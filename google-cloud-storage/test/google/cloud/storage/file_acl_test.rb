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

describe Google::Cloud::Storage::File, :acl, :mock_storage do
  let(:bucket_name) { "bucket" }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name: bucket_name).to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }
  let(:bucket_user_project) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service, user_project: true }

  let(:file_name) { "file.ext" }
  let(:file_hash) { random_file_hash bucket.name, file_name }
  let(:file_gapi) { Google::Apis::StorageV1::Object.from_json file_hash.to_json }
  let(:file) { Google::Cloud::Storage::File.from_gapi file_gapi, storage.service }
  let(:generation) { 1234567890 }
  let(:metageneration) { 6 }

  it "retrieves the ACL" do
    mock = Minitest::Mock.new
    mock.expect :get_object, file_gapi, [bucket.name, file_name], **get_object_args
    mock.expect :list_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_file_acl_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name], user_project: nil, options: {}

    storage.service.mocked_service = mock

    file = bucket.file file_name
    _(file.name).must_equal file_name
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).wont_be :empty?

    mock.verify
  end

  it "retrieves the ACL with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :get_object, file_gapi, [bucket_name, file_name], **get_object_args(user_project: "test")
    mock.expect :list_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_file_acl_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name], user_project: "test", options: {}

    storage.service.mocked_service = mock

    file = bucket_user_project.file file_name
    _(file.name).must_equal file_name
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).wont_be :empty?

    mock.verify
  end

  it "adds to the ACL without generation" do
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
    mock.expect :get_object, file_gapi, [bucket_name, file_name], **get_object_args
    mock.expect :list_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_file_acl_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name], user_project: nil, options: {}
    mock.expect :insert_object_access_control,
      Google::Apis::StorageV1::BucketAccessControl.from_json(reader_acl.to_json),
      [bucket_name, file_name, Google::Apis::StorageV1::BucketAccessControl.new(entity: reader_entity, role: "READER")], generation: nil, user_project: nil, options: {retries: 0}

    storage.service.mocked_service = mock

    file = bucket.file file_name
    _(file.name).must_equal file_name
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).wont_be :empty?

    file.acl.add_reader reader_entity
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).wont_be :empty?
    _(file.acl.readers).must_include reader_entity

    mock.verify
  end

  it "adds to the ACL with generation" do
    generation = "123"
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
    mock.expect :get_object, file_gapi, [bucket_name, file_name], **get_object_args
    mock.expect :list_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_file_acl_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name], user_project: nil, options: {}
    mock.expect :insert_object_access_control,
      Google::Apis::StorageV1::BucketAccessControl.from_json(reader_acl.to_json),
      [bucket_name, file_name, Google::Apis::StorageV1::BucketAccessControl.new(entity: reader_entity, role: "READER")], generation: generation, user_project: nil, options: {retries: 0}

    storage.service.mocked_service = mock

    file = bucket.file file_name
    _(file.name).must_equal file_name
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).wont_be :empty?

    file.acl.add_reader reader_entity, generation: generation
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).wont_be :empty?
    _(file.acl.readers).must_include reader_entity

    mock.verify
  end

  it "adds to the ACL with user_project set to true" do
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
    mock.expect :get_object, file_gapi, [bucket_name, file_name], **get_object_args(user_project: "test")
    mock.expect :list_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_file_acl_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name], user_project: "test", options: {}
    mock.expect :insert_object_access_control,
      Google::Apis::StorageV1::BucketAccessControl.from_json(reader_acl.to_json),
      [bucket_name, file_name, Google::Apis::StorageV1::BucketAccessControl.new(entity: reader_entity, role: "READER")], generation: nil, user_project: "test", options: {retries: 0}

    storage.service.mocked_service = mock

    file = bucket_user_project.file file_name
    _(file.name).must_equal file_name
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).wont_be :empty?

    file.acl.add_reader reader_entity
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).wont_be :empty?
    _(file.acl.readers).must_include reader_entity

    mock.verify
  end

  it "removes from the ACL without generation" do
    existing_reader_entity = "project-viewers-1234567890"

    mock = Minitest::Mock.new
    mock.expect :get_object, file_gapi, [bucket_name, file_name], **get_object_args
    mock.expect :list_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_file_acl_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name], user_project: nil, options: {}
    mock.expect :delete_object_access_control, nil,
      [bucket_name, file_name, existing_reader_entity], generation: nil, user_project: nil, options: {retries: 0}

    storage.service.mocked_service = mock

    file = bucket.file file_name
    _(file.name).must_equal file_name
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).wont_be :empty?

    reader_entity = file.acl.readers.first
    file.acl.delete reader_entity
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).must_be :empty?

    mock.verify
  end

  it "removes from the ACL with generation" do
    generation = "123"
    existing_reader_entity = "project-viewers-1234567890"

    mock = Minitest::Mock.new
    mock.expect :get_object, file_gapi, [bucket_name, file_name], **get_object_args
    mock.expect :list_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_file_acl_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name], user_project: nil, options: {}
    mock.expect :delete_object_access_control, nil,
      [bucket_name, file_name, existing_reader_entity], generation: generation, user_project: nil, options: {retries: 0}

    storage.service.mocked_service = mock

    file = bucket.file file_name
    _(file.name).must_equal file_name
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).wont_be :empty?

    reader_entity = file.acl.readers.first
    file.acl.delete reader_entity, generation: generation
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).must_be :empty?

    mock.verify
  end

  it "removes from the ACL with user_project set to true" do
    existing_reader_entity = "project-viewers-1234567890"

    mock = Minitest::Mock.new
    mock.expect :get_object, file_gapi, [bucket_name, file_name], **get_object_args(user_project: "test")
    mock.expect :list_object_access_controls,
      Google::Apis::StorageV1::ObjectAccessControls.from_json(random_file_acl_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name], user_project: "test", options: {}
    mock.expect :delete_object_access_control, nil,
      [bucket_name, file_name, existing_reader_entity], generation: nil, user_project: "test", options: {retries: 0}

    storage.service.mocked_service = mock

    file = bucket_user_project.file file_name
    _(file.name).must_equal file_name
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).wont_be :empty?

    reader_entity = file.acl.readers.first
    file.acl.delete reader_entity
    _(file.acl.owners).wont_be  :empty?
    _(file.acl.readers).must_be :empty?

    mock.verify
  end

  it "sets the predefined ACL rule authenticatedRead" do
    predefined_acl_update "authenticatedRead", retries: 0 do |acl|
      acl.authenticatedRead!
    end
  end

  it "sets the predefined ACL rule auth" do
    predefined_acl_update "authenticatedRead", retries: 0 do |acl|
      acl.auth!
    end
  end

  it "sets the predefined ACL rule auth with generation" do
    predefined_acl_update "authenticatedRead", retries: 0, generation: generation do |acl|
      acl.auth! generation: generation
    end
  end

  it "sets the predefined ACL rule auth with if_generation_match" do
    predefined_acl_update "authenticatedRead", retries: 0, if_generation_match: generation do |acl|
      acl.auth! if_generation_match: generation
    end
  end

  it "sets the predefined ACL rule auth with if_generation_not_match" do
    predefined_acl_update "authenticatedRead", retries: 0, if_generation_not_match: generation do |acl|
      acl.auth! if_generation_not_match: generation
    end
  end

  it "sets the predefined ACL rule auth with if_metageneration_match" do
    predefined_acl_update "authenticatedRead", if_metageneration_match: metageneration do |acl|
      acl.auth! if_metageneration_match: metageneration
    end
  end

  it "sets the predefined ACL rule auth with if_metageneration_not_match" do
    predefined_acl_update "authenticatedRead", retries: 0, if_metageneration_not_match: metageneration do |acl|
      acl.auth! if_metageneration_not_match: metageneration
    end
  end

  it "sets the predefined ACL rule auth_read" do
    predefined_acl_update "authenticatedRead", retries: 0 do |acl|
      acl.auth_read!
    end
  end

  it "sets the predefined ACL rule authenticated" do
    predefined_acl_update "authenticatedRead", retries: 0 do |acl|
      acl.authenticated!
    end
  end

  it "sets the predefined ACL rule authenticated_read" do
    predefined_acl_update "authenticatedRead", retries: 0 do |acl|
      acl.authenticated_read!
    end
  end

  it "sets the predefined ACL rule bucketOwnerFullControl" do
    predefined_acl_update "bucketOwnerFullControl", retries: 0 do |acl|
      acl.bucketOwnerFullControl!
    end
  end

  it "sets the predefined ACL rule owner_full" do
    predefined_acl_update "bucketOwnerFullControl", retries: 0 do |acl|
      acl.owner_full!
    end
  end

  it "sets the predefined ACL rule owner_full with generation" do
    predefined_acl_update "bucketOwnerFullControl", retries: 0, generation: generation do |acl|
      acl.owner_full! generation: generation
    end
  end

  it "sets the predefined ACL rule owner_full with if_generation_match" do
    predefined_acl_update "bucketOwnerFullControl", retries: 0, if_generation_match: generation do |acl|
      acl.owner_full! if_generation_match: generation
    end
  end

  it "sets the predefined ACL rule owner_full with if_generation_not_match" do
    predefined_acl_update "bucketOwnerFullControl", retries: 0, if_generation_not_match: generation do |acl|
      acl.owner_full! if_generation_not_match: generation
    end
  end

  it "sets the predefined ACL rule owner_full with if_metageneration_match" do
    predefined_acl_update "bucketOwnerFullControl", if_metageneration_match: metageneration do |acl|
      acl.owner_full! if_metageneration_match: metageneration
    end
  end

  it "sets the predefined ACL rule owner_full with if_metageneration_not_match" do
    predefined_acl_update "bucketOwnerFullControl", retries: 0, if_metageneration_not_match: metageneration do |acl|
      acl.owner_full! if_metageneration_not_match: metageneration
    end
  end

  it "sets the predefined ACL rule bucketOwnerRead" do
    predefined_acl_update "bucketOwnerRead", retries: 0 do |acl|
      acl.bucketOwnerRead!
    end
  end

  it "sets the predefined ACL rule owner_read" do
    predefined_acl_update "bucketOwnerRead", retries: 0 do |acl|
      acl.owner_read!
    end
  end

  it "sets the predefined ACL rule owner_read with generation" do
    predefined_acl_update "bucketOwnerRead", retries: 0, generation: generation do |acl|
      acl.owner_read! generation: generation
    end
  end

  it "sets the predefined ACL rule owner_read with if_generation_match" do
    predefined_acl_update "bucketOwnerRead", retries: 0, if_generation_match: generation do |acl|
      acl.owner_read! if_generation_match: generation
    end
  end

  it "sets the predefined ACL rule owner_read with if_generation_not_match" do
    predefined_acl_update "bucketOwnerRead", retries: 0, if_generation_not_match: generation do |acl|
      acl.owner_read! if_generation_not_match: generation
    end
  end

  it "sets the predefined ACL rule owner_read with if_metageneration_match" do
    predefined_acl_update "bucketOwnerRead", if_metageneration_match: metageneration do |acl|
      acl.owner_read! if_metageneration_match: metageneration
    end
  end

  it "sets the predefined ACL rule owner_read with if_metageneration_not_match" do
    predefined_acl_update "bucketOwnerRead", retries: 0, if_metageneration_not_match: metageneration do |acl|
      acl.owner_read! if_metageneration_not_match: metageneration
    end
  end

  it "sets the predefined ACL rule private" do
    predefined_acl_update "private", retries: 0 do |acl|
      acl.private!
    end
  end

  it "sets the predefined ACL rule private with generation" do
    predefined_acl_update "private", retries: 0, generation: generation do |acl|
      acl.private! generation: generation
    end
  end

  it "sets the predefined ACL rule private with if_generation_match" do
    predefined_acl_update "private", retries: 0, if_generation_match: generation do |acl|
      acl.private! if_generation_match: generation
    end
  end

  it "sets the predefined ACL rule private with if_generation_not_match" do
    predefined_acl_update "private", retries: 0, if_generation_not_match: generation do |acl|
      acl.private! if_generation_not_match: generation
    end
  end

  it "sets the predefined ACL rule private with if_metageneration_match" do
    predefined_acl_update "private", if_metageneration_match: metageneration do |acl|
      acl.private! if_metageneration_match: metageneration
    end
  end

  it "sets the predefined ACL rule private with if_metageneration_not_match" do
    predefined_acl_update "private", retries: 0, if_metageneration_not_match: metageneration do |acl|
      acl.private! if_metageneration_not_match: metageneration
    end
  end

  it "sets the predefined ACL rule projectPrivate" do
    predefined_acl_update "projectPrivate", retries: 0 do |acl|
      acl.projectPrivate!
    end
  end

  it "sets the predefined ACL rule project_private" do
    predefined_acl_update "projectPrivate", retries: 0 do |acl|
      acl.project_private!
    end
  end

  it "sets the predefined ACL rule project_private with generation" do
    predefined_acl_update "projectPrivate", retries: 0, generation: generation do |acl|
      acl.project_private! generation: generation
    end
  end

  it "sets the predefined ACL rule project_private with if_generation_match" do
    predefined_acl_update "projectPrivate", retries: 0, if_generation_match: generation do |acl|
      acl.project_private! if_generation_match: generation
    end
  end

  it "sets the predefined ACL rule project_private with if_generation_not_match" do
    predefined_acl_update "projectPrivate", retries: 0, if_generation_not_match: generation do |acl|
      acl.project_private! if_generation_not_match: generation
    end
  end

  it "sets the predefined ACL rule project_private with if_metageneration_match" do
    predefined_acl_update "projectPrivate", if_metageneration_match: metageneration do |acl|
      acl.project_private! if_metageneration_match: metageneration
    end
  end

  it "sets the predefined ACL rule project_private with if_metageneration_not_match" do
    predefined_acl_update "projectPrivate", retries: 0, if_metageneration_not_match: metageneration do |acl|
      acl.project_private! if_metageneration_not_match: metageneration
    end
  end

  it "sets the predefined ACL rule publicRead" do
    predefined_acl_update "publicRead", retries: 0 do |acl|
      acl.publicRead!
    end
  end

  it "sets the predefined ACL rule public" do
    predefined_acl_update "publicRead", retries: 0 do |acl|
      acl.public!
    end
  end

  it "sets the predefined ACL rule public with generation" do
    predefined_acl_update "publicRead", retries: 0, generation: generation do |acl|
      acl.public! generation: generation
    end
  end

  it "sets the predefined ACL rule public with if_generation_match" do
    predefined_acl_update "publicRead", retries: 0, if_generation_match: generation do |acl|
      acl.public! if_generation_match: generation
    end
  end

  it "sets the predefined ACL rule public with if_generation_not_match" do
    predefined_acl_update "publicRead", retries: 0, if_generation_not_match: generation do |acl|
      acl.public! if_generation_not_match: generation
    end
  end

  it "sets the predefined ACL rule public with if_metageneration_match" do
    predefined_acl_update "publicRead", if_metageneration_match: metageneration do |acl|
      acl.public! if_metageneration_match: metageneration
    end
  end

  it "sets the predefined ACL rule public with if_metageneration_not_match" do
    predefined_acl_update "publicRead", retries: 0, if_metageneration_not_match: metageneration do |acl|
      acl.public! if_metageneration_not_match: metageneration
    end
  end

  it "sets the predefined ACL rule public_read" do
    predefined_acl_update "publicRead", retries: 0 do |acl|
      acl.public_read!
    end
  end

  it "raises when the predefined ACL rule authenticatedRead returns an error" do
    predefined_acl_update_with_error "authenticatedRead" do |acl|
      acl.authenticatedRead!
    end
  end

  it "raises when the predefined ACL rule auth" do
    predefined_acl_update_with_error "authenticatedRead" do |acl|
      acl.auth!
    end
  end

  it "raises when the predefined ACL rule auth_read" do
    predefined_acl_update_with_error "authenticatedRead" do |acl|
      acl.auth_read!
    end
  end

  it "raises when the predefined ACL rule authenticated" do
    predefined_acl_update_with_error "authenticatedRead" do |acl|
      acl.authenticated!
    end
  end

  it "raises when the predefined ACL rule authenticated_read" do
    predefined_acl_update_with_error "authenticatedRead" do |acl|
      acl.authenticated_read!
    end
  end

  it "raises when the predefined ACL rule bucketOwnerFullControl" do
    predefined_acl_update_with_error "bucketOwnerFullControl" do |acl|
      acl.bucketOwnerFullControl!
    end
  end

  it "raises when the predefined ACL rule owner_full" do
    predefined_acl_update_with_error "bucketOwnerFullControl" do |acl|
      acl.owner_full!
    end
  end

  it "raises when the predefined ACL rule bucketOwnerRead" do
    predefined_acl_update_with_error "bucketOwnerRead" do |acl|
      acl.bucketOwnerRead!
    end
  end

  it "raises when the predefined ACL rule owner_read" do
    predefined_acl_update_with_error "bucketOwnerRead" do |acl|
      acl.owner_read!
    end
  end

  it "raises when the predefined ACL rule private" do
    predefined_acl_update_with_error "private" do |acl|
      acl.private!
    end
  end

  it "raises when the predefined ACL rule projectPrivate" do
    predefined_acl_update_with_error "projectPrivate" do |acl|
      acl.projectPrivate!
    end
  end

  it "raises when the predefined ACL rule project_private" do
    predefined_acl_update_with_error "projectPrivate" do |acl|
      acl.project_private!
    end
  end

  it "raises when the predefined ACL rule publicRead" do
    predefined_acl_update_with_error "publicRead" do |acl|
      acl.publicRead!
    end
  end

  it "raises when the predefined ACL rule public" do
    predefined_acl_update_with_error "publicRead" do |acl|
      acl.public!
    end
  end

  it "raises when the predefined ACL rule public_read" do
    predefined_acl_update_with_error "publicRead" do |acl|
      acl.public_read!
    end
  end

  def predefined_acl_update acl_role, retries: nil, **opts
    options = retries.nil? ? {} : {retries: retries}
    mock = Minitest::Mock.new
    mock.expect :patch_object,
      Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_name, file_name).to_json),
      [bucket_name, file_name, Google::Apis::StorageV1::Bucket.new(acl: [])], **patch_object_args(predefined_acl: acl_role, options: options, **opts)

    storage.service.mocked_service = mock

    yield file.acl

    mock.verify
  end

  def predefined_acl_update_with_error acl_role
    stub = Object.new
    def stub.patch_object *args
      raise Google::Apis::ClientError.new("already exists", status_code: 409)
    end
    storage.service.mocked_service = stub

    expect { yield file.acl }.must_raise Google::Cloud::AlreadyExistsError
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
end
