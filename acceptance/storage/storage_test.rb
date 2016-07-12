# Copyright 2014 Google Inc. All rights reserved.
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

require "storage_helper"
require "net/http"

# This test is a ruby version of gcloud-node's storage test.

describe "Storage", :storage do
  let :bucket do
    storage.bucket(bucket_name) ||
    storage.create_bucket(bucket_name)
  end
  let(:bucket_name) { $bucket_names.first }

  let(:files) do
    { logo: { path: "acceptance/data/CloudPlatform_128px_Retina.png" },
      big:  { path: "acceptance/data/three-mb-file.tif" } }
  end

  before do
    # always create the bucket
    bucket
  end

  after do
    bucket.files.each &:delete
  end

  it "creates and gets and updates and deletes a bucket" do
    one_off_bucket_name = "#{bucket_name}_one_off"

    storage.bucket(one_off_bucket_name).must_be :nil?

    one_off_bucket = storage.create_bucket(one_off_bucket_name)

    storage.bucket(one_off_bucket_name).wont_be :nil?

    one_off_bucket.website_main.must_be :nil?
    one_off_bucket.website_404.must_be :nil?
    one_off_bucket.update do |b|
      b.website_main = "index.html"
      b.website_404 = "not_found.html"
    end
    one_off_bucket.website_main.wont_be :nil?
    one_off_bucket.website_404.wont_be :nil?

    one_off_bucket.files.all &:delete
    one_off_bucket.delete

    storage.bucket(one_off_bucket_name).must_be :nil?
  end

  describe "bucket acl" do
    it "adds a reader" do
      bucket.acl.private!
      user_val = "user-blowmage@gmail.com"
      bucket.acl.readers.wont_include user_val
      bucket.acl.add_reader user_val
      bucket.acl.readers.must_include user_val
      bucket.acl.refresh!
      bucket.acl.readers.must_include user_val
      bucket.refresh!
      bucket.acl.readers.must_include user_val
    end

    it "adds a writer" do
      bucket.acl.private!
      user_val = "user-blowmage@gmail.com"
      bucket.acl.writers.wont_include user_val
      bucket.acl.add_writer user_val
      bucket.acl.writers.must_include user_val
      bucket.acl.refresh!
      bucket.acl.writers.must_include user_val
      bucket.refresh!
      bucket.acl.writers.must_include user_val
    end

    it "adds an owner" do
      bucket.acl.private!
      user_val = "user-blowmage@gmail.com"
      bucket.acl.owners.wont_include user_val
      bucket.acl.add_owner user_val
      bucket.acl.owners.must_include user_val
      bucket.acl.refresh!
      bucket.acl.owners.must_include user_val
      bucket.refresh!
      bucket.acl.owners.must_include user_val
    end

    it "updates predefined rules" do
      bucket.acl.private!
      bucket.acl.readers.wont_include "allAuthenticatedUsers"
      bucket.acl.auth!
      bucket.acl.readers.must_include "allAuthenticatedUsers"
      bucket.acl.refresh!
      bucket.acl.readers.must_include "allAuthenticatedUsers"
      bucket.refresh!
      bucket.acl.readers.must_include "allAuthenticatedUsers"
    end

    it "deletes rules" do
      bucket.acl.auth!
      bucket.acl.readers.must_include "allAuthenticatedUsers"
      bucket.acl.delete "allAuthenticatedUsers"
      bucket.acl.readers.wont_include "allAuthenticatedUsers"
      bucket.acl.refresh!
      bucket.acl.readers.wont_include "allAuthenticatedUsers"
      bucket.refresh!
      bucket.acl.readers.wont_include "allAuthenticatedUsers"
    end
  end


  describe "bucket default acl" do
    it "adds a reader" do
      bucket.default_acl.private!
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
      bucket.default_acl.private!
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
      bucket.default_acl.private!
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
  end

  describe "getting buckets" do
    let(:new_buckets) do
      new_bucket_names.map do |b|
        storage.bucket(b) ||
        storage.create_bucket(b)
      end
    end
    let(:new_bucket_names) { $bucket_names.last 3 }

    before do
      bucket
      new_buckets # always create the buckets
    end

    after do
      new_buckets.each { |b| b.files.map &:delete }
    end

    it "should get buckets" do
      all_bucket_names = storage.buckets.all.map(&:name)
      all_bucket_names.must_include bucket_name
      new_bucket_names.each do |new_bucket_name|
        all_bucket_names.must_include new_bucket_name
      end
    end
  end

  describe "write, read, and remove files" do
    it "creates and gets and updates and deletes a file" do
      bucket.file("CRUDLogo").must_be :nil?

      original = File.new files[:logo][:path]
      uploaded = bucket.create_file original, "CRUDLogo"

      bucket.file("CRUDLogo").wont_be :nil?

      uploaded.cache_control.must_be :nil?
      uploaded.content_language.must_be :nil?
      uploaded.metadata.must_be :empty?
      uploaded.update do |f|
        f.cache_control = "private, max-age=0, no-cache"
        f.content_language = "en"
        f.metadata["test_type"] = "acceptance"
      end
      uploaded.cache_control.wont_be :nil?
      uploaded.content_language.wont_be :nil?
      uploaded.metadata.wont_be :empty?

      bucket.file("CRUDLogo").wont_be :nil?

      uploaded.delete

      bucket.file("CRUDLogo").must_be :nil?
    end

    it "should upload and download a file without specifying path" do
      original = File.new files[:logo][:path]
      uploaded = bucket.create_file original
      uploaded.name.must_equal original.path

      Tempfile.open "gcloud-ruby" do |tmpfile|
        downloaded = uploaded.download tmpfile

        downloaded.size.must_equal original.size
        downloaded.size.must_equal uploaded.size
        downloaded.size.must_equal tmpfile.size # Same file
      end

      uploaded.delete
    end

    it "should upload and download a file" do
      original = File.new files[:logo][:path]
      uploaded = bucket.create_file original, "CloudLogo"

      Tempfile.open "gcloud-ruby" do |tmpfile|
        downloaded = uploaded.download tmpfile

        downloaded.size.must_equal original.size
        downloaded.size.must_equal uploaded.size
        downloaded.size.must_equal tmpfile.size # Same file
      end

      uploaded.delete
    end

    it "should upload and download a larger file" do
      original = File.new files[:big][:path]
      uploaded = bucket.create_file original, "BigLogo"
      Tempfile.open "gcloud-ruby" do |tmpfile|
        downloaded = uploaded.download tmpfile, verify: :all

        downloaded.size.must_equal original.size
        downloaded.size.must_equal uploaded.size
        downloaded.size.must_equal tmpfile.size # Same file
      end
      uploaded.delete
    end

    it "should write metadata" do
      meta = { content_type: "x-image/x-png",
               metadata: { title: "Logo Image" } }
      uploaded = bucket.create_file files[:logo][:path],
                                    "CloudLogo",
                                    meta

      uploaded.content_type.must_equal meta[:content_type]
      uploaded.metadata["title"].must_equal meta[:metadata][:title]
    end

    it "should copy an existing file" do
      uploaded = bucket.create_file files[:logo][:path], "CloudLogo"
      copied = uploaded.copy "CloudLogoCopy"

      uploaded.name.must_equal "CloudLogo"
      copied.name.must_equal "CloudLogoCopy"
      copied.size.must_equal uploaded.size

      uploaded.delete
      copied.delete
    end
  end

  describe "list files" do
    let(:filenames) { ["CloudLogo1", "CloudLogo2", "CloudLogo3"] }

    before do
      # delete all files just in case
      bucket.files.all.each { |file| file.delete }

      uploaded = bucket.create_file files[:logo][:path], filenames[0]
      uploaded.copy filenames[1]
      uploaded.copy filenames[2]
    end

    it "should get files" do
      files = bucket.files
      assert_equal filenames.size, files.size
    end

    it "should paginate the list" do
      files = bucket.files(max: 2).all.to_a
      assert_equal filenames.size, files.size
    end
  end

  describe "sign urls" do
    let(:local_file) { File.new files[:logo][:path] }
    let(:file) do
      bucket.create_file local_file, "LogoToSign.jpg"
    end

    it "should create a signed read url" do
      five_min_from_now = 5 * 60
      url = file.signed_url method: "GET",
                            expires: five_min_from_now

      uri = URI url
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true
      resp = http.get uri.request_uri
      Tempfile.open "gcloud-ruby" do |tmpfile|
        tmpfile.write resp.body
        tmpfile.size.must_equal local_file.size
      end
    end

    it "should create a signed delete url" do
      five_min_from_now = 5 * 60
      url = file.signed_url method: "DELETE",
                            expires: five_min_from_now

      uri = URI url
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true
      resp = http.delete uri.request_uri

      resp.code.must_equal "204"
    end
  end

  describe "file acl" do
    let(:local_file) { File.new files[:logo][:path] }

    it "adds a reader" do
      bucket.default_acl.auth!
      file = bucket.create_file local_file, "ReaderTest.jpg"
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
      bucket.default_acl.auth!
      file = bucket.create_file local_file, "OwnerTest.jpg"
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
      bucket.default_acl.auth!
      file = bucket.create_file local_file, "AclTest.jpg"
      file.acl.readers.must_include "allAuthenticatedUsers"
      file.acl.private!
      file.acl.readers.must_be :empty?
      file.acl.refresh!
      file.acl.readers.must_be :empty?
      file.refresh!
      file.acl.readers.must_be :empty?
    end

    it "deletes rules" do
      bucket.default_acl.auth!
      file = bucket.create_file local_file, "AclTest.jpg"
      file.acl.readers.must_include "allAuthenticatedUsers"
      file.acl.delete "allAuthenticatedUsers"
      file.acl.readers.must_be :empty?
      file.acl.refresh!
      file.acl.readers.must_be :empty?
      file.refresh!
      file.acl.readers.must_be :empty?
    end
  end
end
