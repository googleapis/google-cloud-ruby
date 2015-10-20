# Copyright 2015 Google Inc. All rights reserved.
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

require "helper"
require "json"
require "uri"

describe Gcloud::Storage::File, :acl, :mock_storage do
  # Create a bucket object with the project's mocked connection object
  let(:bucket_name) { "bucket" }
  let(:bucket) { Gcloud::Storage::Bucket.from_gapi random_bucket_hash(bucket_name),
                                                   storage.connection }

  # Create a file object with the project's mocked connection object
  let(:file_name) { "file.ext" }
  let(:file) { Gcloud::Storage::File.from_gapi random_file_hash(bucket_name, file_name),
                                               storage.connection }

  it "retrieves the ACL" do
    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}" do |env|
      URI(env.url).query.must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       random_file_hash(bucket_name, file_name).to_json]
    end

    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_file_acl_hash(bucket_name, file_name).to_json]
    end

    file = bucket.file file_name
    file.name.must_equal file_name
    file.acl.owners.wont_be  :empty?
    file.acl.writers.must_be :empty?
    file.acl.readers.wont_be :empty?
  end

  it "adds to the ACL without generation" do
    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_file_hash(bucket_name, file_name).to_json]
    end

    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_file_acl_hash(bucket_name, file_name).to_json]
    end

    file = bucket.file file_name
    file.name.must_equal file_name
    file.acl.owners.wont_be  :empty?
    file.acl.writers.must_be :empty?
    file.acl.readers.wont_be :empty?

    writer_entity = "user-user@example.net"
    writer_acl = {
       "kind" => "storage#objectAccessControl",
       "id" => "#{bucket_name}/#{file_name}/123/user-12345678901234567890",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/#{writer_entity}",
       "bucket" => "#{bucket_name}",
       "object" => "#{file_name}",
       "generation" => "123",
       "entity" => writer_entity,
       "role" => "WRITER",
       "entityId" => "12345678901234567890",
       "etag" => "abcDEF123="
      }

    mock_connection.post "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl" do |env|
      URI(env.url).query.must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       writer_acl.to_json]
    end

    file.acl.add_writer writer_entity
    file.acl.owners.wont_be  :empty?
    file.acl.writers.wont_be :empty?
    file.acl.readers.wont_be :empty?
    file.acl.writers.must_include writer_entity
  end

  it "adds to the ACL with generation" do
    generation = "123"

    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_file_hash(bucket_name, file_name).to_json]
    end

    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_file_acl_hash(bucket_name, file_name).to_json]
    end

    file = bucket.file file_name
    file.name.must_equal file_name
    file.acl.owners.wont_be  :empty?
    file.acl.writers.must_be :empty?
    file.acl.readers.wont_be :empty?

    writer_entity = "user-user@example.net"
    writer_acl = {
       "kind" => "storage#objectAccessControl",
       "id" => "#{bucket_name}/#{file_name}/123/user-12345678901234567890",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/#{writer_entity}",
       "bucket" => "#{bucket_name}",
       "object" => "#{file_name}",
       "generation" => "123",
       "entity" => writer_entity,
       "role" => "WRITER",
       "entityId" => "12345678901234567890",
       "etag" => "abcDEF123="
      }

    mock_connection.post "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl" do |env|
      URI(env.url).query.must_equal "generation=#{generation}"
      [200, {"Content-Type"=>"application/json"},
       writer_acl.to_json]
    end

    file.acl.add_writer writer_entity, generation: generation
    file.acl.owners.wont_be  :empty?
    file.acl.writers.wont_be :empty?
    file.acl.readers.wont_be :empty?
    file.acl.writers.must_include writer_entity
  end

  it "removes from the ACL without generation" do
    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_file_hash(bucket_name, file_name).to_json]
    end

    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_file_acl_hash(bucket_name, file_name).to_json]
    end

    file = bucket.file file_name
    file.name.must_equal file_name
    file.acl.owners.wont_be  :empty?
    file.acl.writers.must_be :empty?
    file.acl.readers.wont_be :empty?

    reader_entity = file.acl.readers.first

    mock_connection.delete "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/#{reader_entity}" do |env|
      URI(env.url).query.must_be :nil?
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    file.acl.delete reader_entity

    file.acl.owners.wont_be  :empty?
    file.acl.writers.must_be :empty?
    file.acl.readers.must_be :empty?
  end

  it "removes from the ACL with generation" do
    generation = "123"

    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_file_hash(bucket_name, file_name).to_json]
    end

    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_file_acl_hash(bucket_name, file_name).to_json]
    end

    file = bucket.file file_name
    file.name.must_equal file_name
    file.acl.owners.wont_be  :empty?
    file.acl.writers.must_be :empty?
    file.acl.readers.wont_be :empty?

    reader_entity = file.acl.readers.first

    mock_connection.delete "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/#{reader_entity}" do |env|
      URI(env.url).query.must_equal "generation=#{generation}"
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    file.acl.delete reader_entity, generation: generation

    file.acl.owners.wont_be  :empty?
    file.acl.writers.must_be :empty?
    file.acl.readers.must_be :empty?
  end

  it "sets the predefined ACL rule authenticatedRead" do
    predefined_acl_update "authenticatedRead" do |acl|
      acl.authenticatedRead!
    end
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

  it "sets the predefined ACL rule bucketOwnerFullControl" do
    predefined_acl_update "bucketOwnerFullControl" do |acl|
      acl.bucketOwnerFullControl!
    end
  end

  it "sets the predefined ACL rule owner_full" do
    predefined_acl_update "bucketOwnerFullControl" do |acl|
      acl.owner_full!
    end
  end

  it "sets the predefined ACL rule bucketOwnerRead" do
    predefined_acl_update "bucketOwnerRead" do |acl|
      acl.bucketOwnerRead!
    end
  end

  it "sets the predefined ACL rule owner_read" do
    predefined_acl_update "bucketOwnerRead" do |acl|
      acl.owner_read!
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

  def predefined_acl_update acl_role
    mock_connection.patch "/storage/v1/b/#{bucket_name}/o/#{file_name}" do |env|
      env.params["predefinedAcl"].must_equal acl_role
      [200, {"Content-Type"=>"application/json"},
       random_file_hash(bucket_name, file_name).to_json]
    end

    yield file.acl
  end

  def predefined_acl_update_with_error acl_role
    mock_connection.patch "/storage/v1/b/#{bucket_name}/o/#{file_name}" do |env|
      env.params["predefinedAcl"].must_equal acl_role
      [409, {"Content-Type"=>"application/json"},
       acl_error_json]
    end

    expect { yield file.acl }.must_raise Gcloud::Storage::ApiError
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
