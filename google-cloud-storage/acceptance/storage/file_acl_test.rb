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

require "storage_helper"

describe Google::Cloud::Storage::File, :acl, :storage do
  let :bucket do
    storage.bucket(bucket_name) ||
    safe_gcs_execute { storage.create_bucket(bucket_name) }
  end
  let(:bucket_name) { $bucket_names.first }

  let(:files) do
    { logo: { path: "acceptance/data/CloudPlatform_128px_Retina.png" },
      big:  { path: "acceptance/data/three-mb-file.tif" } }
  end
  let(:local_file) { File.new files[:logo][:path] }

  let(:user_val) { "user-blowmage@gmail.com" }

  before do
    # always create the bucket and set default acl to auth
    bucket.default_acl.auth!
  end

  after do
    bucket.files.all { |f| f.delete rescue nil }
  end

  it "adds a reader" do
    file = bucket.create_file local_file, "ReaderTest.png"
    user_val = "user-blowmage@gmail.com"
    file.acl.readers.wont_include user_val
    file.acl.add_reader user_val
    file.acl.readers.must_include user_val
    file.acl.refresh!
    file.acl.readers.must_include user_val
    file.refresh!
    file.acl.readers.must_include user_val
  end

  it "adds an owner" do
    file = bucket.create_file local_file, "OwnerTest.png"
    user_val = "user-blowmage@gmail.com"
    file.acl.owners.wont_include user_val
    file.acl.add_owner user_val
    file.acl.owners.must_include user_val
    file.acl.refresh!
    file.acl.owners.must_include user_val
    file.refresh!
    file.acl.owners.must_include user_val
  end

  it "updates predefined rules" do
    file = bucket.create_file local_file, "AclTest.png"
    file.acl.readers.must_include "allAuthenticatedUsers"
    file.acl.private!
    file.acl.readers.must_be :empty?
    file.acl.refresh!
    file.acl.readers.must_be :empty?
    file.refresh!
    file.acl.readers.must_be :empty?
  end

  it "deletes rules" do
    file = bucket.create_file local_file, "DeleteTest.png"
    file.acl.readers.must_include "allAuthenticatedUsers"
    file.acl.delete "allAuthenticatedUsers"
    file.acl.readers.must_be :empty?
    file.acl.refresh!
    file.acl.readers.must_be :empty?
    file.refresh!
    file.acl.readers.must_be :empty?
  end

  it "retrieves and modifies the ACL" do
    bucket.default_acl.private!
    file = bucket.create_file local_file, "CRUDTest.png"
    bucket.default_acl.owners.must_be  :empty?
    bucket.default_acl.readers.must_be :empty?

    bucket.default_acl.add_reader user_val

    bucket.default_acl.owners.must_be  :empty?
    bucket.default_acl.readers.wont_be :empty?

    bucket.default_acl.readers.must_include user_val

    bucket.default_acl.reload!

    bucket.default_acl.readers.must_include user_val

    bucket.reload!

    bucket.default_acl.readers.must_include user_val

    bucket.default_acl.delete user_val

    bucket.default_acl.owners.must_be  :empty?
    bucket.default_acl.readers.must_be :empty?

    bucket.default_acl.readers.wont_include user_val

    bucket.default_acl.reload!

    bucket.default_acl.readers.wont_include user_val

    bucket.reload!

    bucket.default_acl.readers.wont_include user_val
  end

  it "sets predefined ACL rules" do
    file = bucket.create_file local_file, "PredefinedTest.png"
    file.acl.authenticatedRead!
    file.acl.auth!
    file.acl.auth_read!
    file.acl.authenticated!
    file.acl.authenticated_read!
    file.acl.bucketOwnerFullControl!
    file.acl.owner_full!
    file.acl.bucketOwnerRead!
    file.acl.owner_read!
    file.acl.private!
    file.acl.projectPrivate!
    file.acl.project_private!
    file.acl.publicRead!
    file.acl.public!
    file.acl.public_read!
  end
end
