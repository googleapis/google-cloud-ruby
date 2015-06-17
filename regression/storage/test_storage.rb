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
    { logo: { path: "regression/data/CloudPlatform_128px_Retina.png" },
      big:  { path: "regression/data/three-mb-file.tif" } }
  end

  before do
    # always create the bucket
    bucket
  end

  after do
    bucket.files.map &:delete
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
      all_bucket_names = storage.buckets.map(&:name)
      all_bucket_names.must_include bucket_name
      new_bucket_names.each do |new_bucket_name|
        all_bucket_names.must_include new_bucket_name
      end
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

    it "should upload resumable and download a file" do
      original = File.new files[:big][:path]
      Gcloud::Storage.stub :resumable_threshold, original.size-1 do
        uploaded = bucket.create_file original, "BigLogo"
        Tempfile.open "gcloud-ruby" do |tmpfile|
          downloaded = uploaded.download tmpfile

          downloaded.size.must_equal original.size
          downloaded.size.must_equal uploaded.size
          downloaded.size.must_equal tmpfile.size # Same file
        end
        uploaded.delete
      end
    end

    it "should upload resumable with chunk_size" do
      original = File.new files[:big][:path]
      Gcloud::Storage.stub :resumable_threshold, original.size-1 do
        uploaded = bucket.create_file original, "BigLogo", chunk_size: 1024*1024*2 # 2MB
        Tempfile.open "gcloud-ruby" do |tmpfile|
          downloaded = uploaded.download tmpfile

          downloaded.size.must_equal original.size
          downloaded.size.must_equal uploaded.size
          downloaded.size.must_equal tmpfile.size # Same file
        end
        uploaded.delete
      end
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
end
