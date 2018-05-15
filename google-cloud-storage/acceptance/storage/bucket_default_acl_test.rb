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

describe Google::Cloud::Storage::Bucket, :default_acl, :storage do
  let(:bucket_name) { $bucket_names.first }
  let :bucket do
    storage.bucket(bucket_name) ||
    safe_gcs_execute { storage.create_bucket(bucket_name) }
  end
  let(:user_val) { "user-blowmage@gmail.com" }

  before do
    # always reset the bucket permissions
    bucket.default_acl.private!
  end

  it "adds a reader" do
    user_val = "user-blowmage@gmail.com"
    bucket.default_acl.readers.wont_include user_val
    bucket.default_acl.add_reader user_val
    bucket.default_acl.readers.must_include user_val
    bucket.default_acl.refresh!
    bucket.default_acl.readers.must_include user_val
    bucket.refresh!
    bucket.default_acl.readers.must_include user_val
  end

  it "adds an owner" do
    user_val = "user-blowmage@gmail.com"
    bucket.default_acl.owners.wont_include user_val
    bucket.default_acl.add_owner user_val
    bucket.default_acl.owners.must_include user_val
    bucket.default_acl.refresh!
    bucket.default_acl.owners.must_include user_val
    bucket.refresh!
    bucket.default_acl.owners.must_include user_val
  end

  it "updates predefined rules" do
    bucket.default_acl.readers.wont_include "allAuthenticatedUsers"
    bucket.default_acl.auth!
    bucket.default_acl.readers.must_include "allAuthenticatedUsers"
    bucket.default_acl.refresh!
    bucket.default_acl.readers.must_include "allAuthenticatedUsers"
    bucket.refresh!
    bucket.default_acl.readers.must_include "allAuthenticatedUsers"
  end

  it "deletes rules" do
    bucket.default_acl.auth!
    bucket.default_acl.readers.must_include "allAuthenticatedUsers"
    bucket.default_acl.delete "allAuthenticatedUsers"
    bucket.default_acl.readers.wont_include "allAuthenticatedUsers"
    bucket.default_acl.refresh!
    bucket.default_acl.readers.wont_include "allAuthenticatedUsers"
    bucket.refresh!
    bucket.default_acl.readers.wont_include "allAuthenticatedUsers"
  end

  it "retrieves and modifies the ACL" do
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
    bucket.default_acl.authenticatedRead!
    bucket.default_acl.auth!
    bucket.default_acl.auth_read!
    bucket.default_acl.authenticated!
    bucket.default_acl.authenticated_read!
    bucket.default_acl.bucketOwnerFullControl!
    bucket.default_acl.owner_full!
    bucket.default_acl.bucketOwnerRead!
    bucket.default_acl.owner_read!
    bucket.default_acl.private!
    bucket.default_acl.projectPrivate!
    bucket.default_acl.project_private!
    bucket.default_acl.publicRead!
    bucket.default_acl.public!
    bucket.default_acl.public_read!
  end
end
