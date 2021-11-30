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

describe Google::Cloud::Storage::Bucket, :acl, :storage do
  let(:bucket_name) { $bucket_names.first }
  let :bucket do
    storage.bucket(bucket_name) ||
    safe_gcs_execute { storage.create_bucket(bucket_name) }
  end
  let(:user_val) { "user-test@example.com" }

  before do
    # always reset the bucket permissions
    bucket.acl.private!
  end

  it "adds a reader" do
    _(bucket.acl.readers).wont_include user_val
    bucket.acl.add_reader user_val
    _(bucket.acl.readers).must_include user_val
    bucket.acl.refresh!
    _(bucket.acl.readers).must_include user_val
    bucket.refresh!
    _(bucket.acl.readers).must_include user_val
  end

  it "adds a writer" do
    _(bucket.acl.writers).wont_include user_val
    bucket.acl.add_writer user_val
    _(bucket.acl.writers).must_include user_val
    bucket.acl.refresh!
    _(bucket.acl.writers).must_include user_val
    bucket.refresh!
    _(bucket.acl.writers).must_include user_val
  end

  it "adds an owner" do
    _(bucket.acl.owners).wont_include user_val
    bucket.acl.add_owner user_val
    _(bucket.acl.owners).must_include user_val
    bucket.acl.refresh!
    _(bucket.acl.owners).must_include user_val
    bucket.refresh!
    _(bucket.acl.owners).must_include user_val
  end

  it "updates predefined rules" do
    _(bucket.acl.readers).wont_include "allAuthenticatedUsers"
    bucket.acl.auth!
    _(bucket.acl.readers).must_include "allAuthenticatedUsers"
    bucket.acl.refresh!
    _(bucket.acl.readers).must_include "allAuthenticatedUsers"
    bucket.refresh!
    _(bucket.acl.readers).must_include "allAuthenticatedUsers"
  end

  it "deletes rules" do
    bucket.acl.auth!
    _(bucket.acl.readers).must_include "allAuthenticatedUsers"
    bucket.acl.delete "allAuthenticatedUsers"
    _(bucket.acl.readers).wont_include "allAuthenticatedUsers"
    bucket.acl.refresh!
    _(bucket.acl.readers).wont_include "allAuthenticatedUsers"
    bucket.refresh!
    _(bucket.acl.readers).wont_include "allAuthenticatedUsers"
  end

  it "retrieves and modifies the ACL" do
    _(bucket.acl.owners).wont_be  :empty?
    _(bucket.acl.writers).must_be :empty?
    _(bucket.acl.readers).must_be :empty?

    bucket.acl.add_writer user_val

    _(bucket.acl.owners).wont_be  :empty?
    _(bucket.acl.writers).wont_be :empty?
    _(bucket.acl.readers).must_be :empty?

    _(bucket.acl.writers).must_include user_val

    bucket.acl.reload!

    _(bucket.acl.writers).must_include user_val

    bucket.reload!

    _(bucket.acl.writers).must_include user_val

    bucket.acl.delete user_val

    _(bucket.acl.owners).wont_be  :empty?
    _(bucket.acl.writers).must_be :empty?
    _(bucket.acl.readers).must_be :empty?

    _(bucket.acl.writers).wont_include user_val

    bucket.acl.reload!

    _(bucket.acl.writers).wont_include user_val

    bucket.reload!

    _(bucket.acl.writers).wont_include user_val
  end

  it "sets predefined ACL rules" do
    bucket.acl.authenticatedRead!
    bucket.acl.auth!
    bucket.acl.auth_read!
    bucket.acl.authenticated!
    bucket.acl.authenticated_read!
    bucket.acl.private!
    bucket.acl.projectPrivate!
    bucket.acl.project_private!
    bucket.acl.publicRead!
    bucket.acl.public!
    bucket.acl.public_read!
    bucket.acl.publicReadWrite!
    bucket.acl.public_write!
  end
end
