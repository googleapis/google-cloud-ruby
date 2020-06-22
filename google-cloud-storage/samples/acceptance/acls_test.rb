# Copyright 2020 Google LLC
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

require_relative "helper"
require_relative "../acls.rb"

describe "ACL Snippets" do
  let :bucket do
    create_bucket_helper "ruby_storage_sample_#{SecureRandom.hex}"
  end

  let(:storage_client)   { Google::Cloud::Storage.new }
  let(:local_file)       { File.expand_path "data/file.txt", __dir__ }
  let(:email)            { "user-test@test.com" }
  let(:remote_file_name) { "path/file_name.txt" }

  after do
    delete_bucket_helper bucket.name
  end

  describe "print_bucket_acl" do
    it "prints a bucket's acl" do
      bucket.acl.add_owner email

      out, _err = capture_io do
        print_bucket_acl bucket_name: bucket.name
      end

      assert_includes out, "ACL for #{bucket.name}:"
      assert_includes out, "OWNER #{email}"
    end
  end

  describe "print_bucket_acl_for_user" do
    it "prints a bucket's acl for a user" do
      bucket.acl.add_owner email

      expected_output = <<~OUTPUT
        Permissions for #{email}:
        OWNER
      OUTPUT

      assert_output expected_output do
        print_bucket_acl_for_user bucket_name: bucket.name,
                                  email:       email
      end
    end
  end

  describe "add_bucket_owner" do
    it "adds owner permissions to a user for a bucket" do
      assert_output "Added OWNER permission for #{email} to #{bucket.name}\n" do
        add_bucket_owner bucket_name: bucket.name,
                         email:       email
      end
      assert_includes bucket.acl.owners, email
    end
  end

  describe "remove_bucket_acl" do
    it "removes a user from a bucket's acl" do
      bucket.acl.add_owner email
      assert_output "Removed ACL permissions for #{email} from #{bucket.name}\n" do
        remove_bucket_acl bucket_name: bucket.name,
                          email:       email
      end
      refute_includes bucket.acl.owners, email
    end
  end

  describe "add_bucket_default_owner" do
    it "adds a user as default owner for a bucket" do
      assert_output "Added default OWNER permission for #{email} to #{bucket.name}\n" do
        add_bucket_default_owner bucket_name: bucket.name,
                                 email:       email
      end
      assert_includes bucket.default_acl.owners, email
    end
  end

  describe "remove_bucket_default_acl" do
    it "adds a user as default owner for a bucket" do
      bucket.default_acl.add_owner email
      assert_output "Removed default ACL permissions for #{email} from #{bucket.name}\n" do
        remove_bucket_default_acl bucket_name: bucket.name,
                                  email:       email
      end
      refute_includes bucket.default_acl.owners, email
    end
  end

  describe "print_file_acl" do
    it "prints the acl for a file in a bucket" do
      bucket.create_file local_file, remote_file_name
      owners  = bucket.file(remote_file_name).acl.owners
      readers = bucket.file(remote_file_name).acl.readers

      out, _err = capture_io do
        print_file_acl bucket_name: bucket.name,
                       file_name:   remote_file_name
      end

      assert owners.all? do |owner|
        out.includes? "OWNER #{owner}"
      end

      assert readers.all? do |reader|
        out.includes? "READER #{reader}"
      end
    end
  end

  describe "print_file_acl_for_user" do
    it "prints the permissions of a given user for a file in a bucket" do
      bucket.create_file local_file, remote_file_name
      bucket.file(remote_file_name).acl.add_owner email

      assert_output "Permissions for #{email}:\nOWNER\n" do
        print_file_acl_for_user bucket_name: bucket.name,
                                file_name:   remote_file_name,
                                email:       email
      end
    end
  end

  describe "add_file_owner" do
    it "adds a user as an owner of for a file in a bucket" do
      bucket.create_file local_file, remote_file_name

      assert_output "Added OWNER permission for #{email} to #{remote_file_name}\n" do
        add_file_owner bucket_name: bucket.name,
                       file_name:   remote_file_name,
                       email:       email
      end
      assert_includes bucket.file(remote_file_name).acl.owners, email
    end
  end

  describe "remove_file_acl" do
    it "removes a user from the acl for file in a bucket" do
      bucket.create_file local_file, remote_file_name
      bucket.file(remote_file_name).acl.add_owner email

      assert_output "Removed ACL permissions for #{email} from #{remote_file_name}\n" do
        remove_file_acl bucket_name: bucket.name,
                        file_name:   remote_file_name,
                        email:       email
      end
      refute_includes bucket.file(remote_file_name).acl.owners, email
    end
  end
end
