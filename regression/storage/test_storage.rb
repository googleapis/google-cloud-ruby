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
require "securerandom"
require "net/http"

# This test is a ruby version of gcloud-node's storage test.

describe "Storage", :storage do
  let(:bucket) { storage.create_bucket bucket_name }
  let(:bucket_name) { new_bucket_name }

  def new_bucket_name
    "gcloud-test-bucket-temp-#{SecureRandom.uuid}"
  end

  let(:files) do
    { logo: { path: "regression/data/CloudPlatform_128px_Retina.png" },
      big:  { path: "regression/data/three-mb-file.tif" } }
  end

  before do
    bucket # always create the bucket
  end

  after do
    bucket.files.map { |file| file.delete }
    bucket.delete
  end

  describe "getting buckets" do
    let(:new_buckets) { new_bucket_names.map { |b| storage.create_bucket b } }
    let(:new_bucket_names) { [new_bucket_name, new_bucket_name, new_bucket_name] }

    before do
      new_buckets # always create the buckets
    end

    after do
      new_buckets.each { |b| b.delete }
    end

    it "should get buckets" do
      all_buckets = storage.buckets
      all_buckets.map(&:name).must_include bucket.name
      all_buckets.map(&:name).must_include new_buckets[0].name
      all_buckets.map(&:name).must_include new_buckets[1].name
      all_buckets.map(&:name).must_include new_buckets[2].name
    end
  end

  describe "write, read, and remove files" do
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

    it "should write metadata" do
      skip

      meta = { content_type: "x-image/x-png",
               title: "Logo Image" }
      uploaded = bucket.create_file files[:logo][:path],
                                    "CloudLogo",
                                    meta

      uploaded.content_type.must_equal meta[:content_type]
      uploaded.meta["title"].must_equal meta[:title]
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
      bucket.files.map { |file| file.delete }

      uploaded = bucket.create_file files[:logo][:path], filenames[0]
      uploaded.copy filenames[1]
      uploaded.copy filenames[2]
    end

    it "should get files" do
      files = bucket.files
      assert_equal filenames.size, files.size
    end

    it "should paginate the list" do
      skip

      limit = filenames.size - 1
      files = bucket.files limit: limit
      files.size.must_equal limit

      files = bucket.files limit: limit, offset: limit
      files.size.must_equal 1
    end
  end

  describe "sign urls" do
    let(:local_file) { File.open files.logo.path }
    let(:file) do
      bucket.create_file "LogoToSign.jpg" do |f|
        f.write File.read(files.logo.path)
      end
    end

    it "should create a signed read url" do
      skip

      five_min_from_now = Time.now + 5 * 60
      url = file.signed_url action: "read",
                            expires: five_min_from_now

      read_contents = Net::HTTP.get URI(url)
      assert_equal local_file.read, read_contents
    end

    it "should create a signed delete url" do
      skip

      url = file.signed_url action: "delete",
                            expires: five_min_from_now

      http = Net::HTTP.new URI(url)
      resp = http.delete uri.path

      assert_equal 404, resp.code
    end
  end
end
