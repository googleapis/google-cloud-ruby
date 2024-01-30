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
require "net/http"
require "uri"
require "zlib"

describe Google::Cloud::Storage::File, :storage do
  let :bucket do
    storage.bucket(bucket_name) ||
    safe_gcs_execute { storage.create_bucket(bucket_name) }
  end
  let(:bucket_name) { $bucket_names.first }
  let(:files) do
    { logo: { path: "acceptance/data/CloudPlatform_128px_Retina.png" },
      big:  { path: "acceptance/data/three-mb-file.tif" } }
  end
  let(:files_big_md5) { Google::Cloud::Storage::File::Verifier.md5_for File.new(files[:big][:path]) }
  let(:files_big_crc32c) { Google::Cloud::Storage::File::Verifier.crc32c_for File.new(files[:big][:path]) }
  let(:io_md5) { Google::Cloud::Storage::File::Verifier.md5_for StringIO.new("Hello world!") }
  let(:io_crc32c) { Google::Cloud::Storage::File::Verifier.crc32c_for StringIO.new("Hello world!") }
  let(:custom_time) { DateTime.new 2020, 2, 3, 4, 5, 6 }

  before do
    # always create the bucket
    bucket
  end

  after do
    bucket.files(versions: true).all { |f| f.delete generation: true rescue nil }
  end

  it "should upload and download a file" do
    original = File.new files[:logo][:path]
    uploaded = bucket.create_file original, "CloudLogo.png",
      cache_control: "public, max-age=3600",
      content_disposition: "attachment; filename=filename.ext",
      content_language: "en",
      content_type: "text/plain",
      custom_time: custom_time,
      metadata: { player: "Alice", score: 101 }

    Tempfile.open ["google-cloud", ".png"] do |tmpfile|
      tmpfile.binmode
      downloaded = uploaded.download tmpfile

      _(downloaded.size).must_equal original.size
      _(downloaded.size).must_equal uploaded.size
      _(downloaded.size).must_equal tmpfile.size # Same file

      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(original.path, mode: "rb")
    end

    _(uploaded.created_at).must_be_kind_of DateTime
    _(uploaded.api_url).must_be_kind_of String
    _(uploaded.media_url).must_be_kind_of String
    _(uploaded.public_url).must_be_kind_of String
    _(uploaded.url).must_be_kind_of String

    _(uploaded.md5).must_be_kind_of String
    _(uploaded.crc32c).must_be_kind_of String
    _(uploaded.etag).must_be_kind_of String

    _(uploaded.cache_control).must_equal "public, max-age=3600"
    _(uploaded.content_disposition).must_equal "attachment; filename=filename.ext"
    _(uploaded.content_encoding).must_be :nil?
    _(uploaded.content_language).must_equal "en"
    _(uploaded.content_type).must_equal "text/plain"
    _(uploaded.custom_time).must_be_kind_of DateTime
    _(uploaded.custom_time).must_equal custom_time

    _(uploaded.metadata).must_be_kind_of Hash
    _(uploaded.metadata.size).must_equal 2
    _(uploaded.metadata.frozen?).must_equal true
    _(uploaded.metadata["player"]).must_equal "Alice"
    _(uploaded.metadata["score"]).must_equal "101"

    uploaded.delete
  end

  it "should upload, replace and download a previous generation of a file" do
    bucket.versioning = true unless bucket.versioning?
    filename = "generation_file.txt"
    uploaded_1 = bucket.create_file StringIO.new("generation 1"), filename
    generation_1 = uploaded_1.generation
    uploaded_1.reload!
    _(uploaded_1.generation).must_equal generation_1

    uploaded_2 = bucket.create_file StringIO.new("generation 2"), filename, if_generation_match: generation_1
    generation_2 = uploaded_2.generation
    _(generation_2).wont_equal generation_1

    expect do
      bucket.create_file StringIO.new("generation 2"), filename, if_generation_match: generation_1
    end.must_raise Google::Cloud::FailedPreconditionError

    uploaded_1.reload! generation: true
    _(uploaded_1.generation).must_equal generation_1
    uploaded_2.reload!
    _(uploaded_2.generation).must_equal generation_2
    uploaded_1.reload!
    _(uploaded_1.generation).must_equal generation_2

    Tempfile.open ["generation_file", ".txt"] do |tmpfile|
      downloaded = bucket.file(filename, if_generation_match: generation_2).download tmpfile
      _(File.read(downloaded.path)).must_equal "generation 2"
    end

    Tempfile.open ["generation_file", ".txt"] do |tmpfile|
      downloaded =  bucket.file(filename, generation: generation_1).download tmpfile
      _(File.read(downloaded.path)).must_equal "generation 1"
    end

    uploaded_2.delete generation: generation_1
    uploaded_2.delete if_generation_match: generation_2
    bucket.versioning = false
  end

  it "should upload and delete a file with strange filename" do
    original = File.new files[:logo][:path]
    uploaded = bucket.create_file original, "#{[101, 769].pack("U*")}.png",
      cache_control: "public, max-age=3600",
      content_disposition: "attachment; filename=filename.ext",
      content_language: "en",
      content_type: "text/plain",
      metadata: { player: "Alice", score: 101 }
    uploaded.delete
  end

  it "should upload and download a larger file" do
    original = File.new files[:big][:path]
    uploaded = bucket.create_file original, "BigLogo.png"
    Tempfile.open ["google-cloud", ".png"] do |tmpfile|
      tmpfile.binmode
      downloaded = uploaded.download tmpfile, verify: :all

      _(downloaded.size).must_equal original.size
      _(downloaded.size).must_equal uploaded.size
      _(downloaded.size).must_equal tmpfile.size # Same file

      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(original.path, mode: "rb")
    end
    uploaded.delete
  end

  it "should upload and download a larger file with checksum: :md5" do
    original = File.new files[:big][:path]
    uploaded = bucket.create_file original, "BigLogo.png", checksum: :md5

    _(uploaded.md5).must_equal files_big_md5
    Tempfile.open ["google-cloud", ".png"] do |tmpfile|
      tmpfile.binmode
      downloaded = uploaded.download tmpfile, verify: :md5

      _(downloaded.size).must_equal original.size
      _(downloaded.size).must_equal uploaded.size
      _(downloaded.size).must_equal tmpfile.size # Same file

      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(original.path, mode: "rb")
    end
    uploaded.delete
  end

  it "should upload and download a larger file with checksum: :crc32c" do
    original = File.new files[:big][:path]
    uploaded = bucket.create_file original, "BigLogo.png", checksum: :crc32c

    _(uploaded.crc32c).must_equal files_big_crc32c
    Tempfile.open ["google-cloud", ".png"] do |tmpfile|
      tmpfile.binmode
      downloaded = uploaded.download tmpfile, verify: :crc32c

      _(downloaded.size).must_equal original.size
      _(downloaded.size).must_equal uploaded.size
      _(downloaded.size).must_equal tmpfile.size # Same file

      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(original.path, mode: "rb")
    end
    uploaded.delete
  end

  it "should upload and download a larger file with md5" do
    original = File.new files[:big][:path]
    uploaded = bucket.create_file original, "BigLogo.png", md5: files_big_md5

    _(uploaded.md5).must_equal files_big_md5
    Tempfile.open ["google-cloud", ".png"] do |tmpfile|
      tmpfile.binmode
      downloaded = uploaded.download tmpfile, verify: :md5

      _(downloaded.size).must_equal original.size
      _(downloaded.size).must_equal uploaded.size
      _(downloaded.size).must_equal tmpfile.size # Same file

      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(original.path, mode: "rb")
    end
    uploaded.delete
  end

  it "should upload and download a larger file with crc32c" do
    original = File.new files[:big][:path]
    uploaded = bucket.create_file original, "BigLogo.png", crc32c: files_big_crc32c

    _(uploaded.crc32c).must_equal files_big_crc32c
    Tempfile.open ["google-cloud", ".png"] do |tmpfile|
      tmpfile.binmode
      downloaded = uploaded.download tmpfile, verify: :crc32c

      _(downloaded.size).must_equal original.size
      _(downloaded.size).must_equal uploaded.size
      _(downloaded.size).must_equal tmpfile.size # Same file

      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(original.path, mode: "rb")
    end
    uploaded.delete
  end

  it "creates and gets and updates and deletes a file" do
    _(bucket.file("CRUDLogo")).must_be :nil?

    original = File.new files[:logo][:path]
    uploaded = bucket.create_file original, "CRUDLogo.png"

    _(bucket.file("CRUDLogo.png")).wont_be :nil?

    generation = uploaded.generation
    _(generation).must_be_kind_of Integer

    _(uploaded.created_at).must_be_kind_of DateTime
    _(uploaded.api_url).must_be_kind_of String
    _(uploaded.media_url).must_be_kind_of String
    _(uploaded.public_url).must_be_kind_of String
    _(uploaded.url).must_be_kind_of String

    _(uploaded.md5).must_be_kind_of String
    _(uploaded.crc32c).must_be_kind_of String
    _(uploaded.etag).must_be_kind_of String

    _(uploaded.cache_control).must_be :nil?
    _(uploaded.content_disposition).must_be :nil?
    _(uploaded.content_encoding).must_be :nil?
    _(uploaded.content_language).must_be :nil?
    _(uploaded.content_type).must_equal "image/png"
    _(uploaded.custom_time).must_be :nil?

    _(uploaded.metadata).must_be_kind_of Hash
    _(uploaded.metadata).must_be :empty?
    _(uploaded.metageneration).must_equal 1

    uploaded.update if_generation_match: generation,
                    if_generation_not_match: (generation - 1),
                    if_metageneration_match: 1,
                    if_metageneration_not_match: 0 do |f|
      f.cache_control = "private, max-age=0, no-cache"
      f.content_disposition = "attachment; filename=filename.ext"
      f.content_language = "en"
      f.content_type = "text/plain"
      f.custom_time = custom_time
      f.metadata = { player: "Alice" }
      f.metadata[:score] = 101
    end

    _(uploaded.created_at).must_be_kind_of DateTime
    _(uploaded.api_url).must_be_kind_of String
    _(uploaded.media_url).must_be_kind_of String
    _(uploaded.public_url).must_be_kind_of String
    _(uploaded.url).must_be_kind_of String

    _(uploaded.md5).must_be_kind_of String
    _(uploaded.crc32c).must_be_kind_of String
    _(uploaded.etag).must_be_kind_of String

    _(uploaded.cache_control).must_equal "private, max-age=0, no-cache"
    _(uploaded.content_disposition).must_equal "attachment; filename=filename.ext"
    _(uploaded.content_encoding).must_be :nil?
    _(uploaded.content_language).must_equal "en"
    _(uploaded.content_type).must_equal "text/plain"
    _(uploaded.custom_time).must_equal custom_time

    _(uploaded.metadata).must_be_kind_of Hash
    _(uploaded.metadata.size).must_equal 2
    _(uploaded.metadata.frozen?).must_equal true
    _(uploaded.metadata["player"]).must_equal "Alice"
    _(uploaded.metadata["score"]).must_equal "101"
    _(uploaded.metageneration).must_equal 2

    expect do
      uploaded.update if_generation_match: (generation - 1) do |f|
        f.content_language = "de"
      end
    end.must_raise Google::Cloud::FailedPreconditionError

    uploaded.reload!

    _(uploaded.generation).must_equal generation

    _(uploaded.created_at).must_be_kind_of DateTime
    _(uploaded.api_url).must_be_kind_of String
    _(uploaded.media_url).must_be_kind_of String
    _(uploaded.public_url).must_be_kind_of String
    _(uploaded.url).must_be_kind_of String

    _(uploaded.md5).must_be_kind_of String
    _(uploaded.crc32c).must_be_kind_of String
    _(uploaded.etag).must_be_kind_of String

    _(uploaded.cache_control).must_equal "private, max-age=0, no-cache"
    _(uploaded.content_disposition).must_equal "attachment; filename=filename.ext"
    _(uploaded.content_encoding).must_be :nil?
    _(uploaded.content_language).must_equal "en"
    _(uploaded.content_type).must_equal "text/plain"
    _(uploaded.custom_time).must_equal custom_time

    _(uploaded.metadata).must_be_kind_of Hash
    _(uploaded.metadata.size).must_equal 2
    _(uploaded.metadata.frozen?).must_equal true
    _(uploaded.metadata["player"]).must_equal "Alice"
    _(uploaded.metadata["score"]).must_equal "101"

    _(bucket.file("CRUDLogo.png")).wont_be :nil?

    uploaded.delete

    _(bucket.file("CRUDLogo.png")).must_be :nil?
  end

  it "should upload and download a file without specifying path" do
    original = File.new files[:logo][:path]
    uploaded = bucket.create_file original
    _(uploaded.name).must_equal original.path

    Tempfile.open ["google-cloud", ".png"] do |tmpfile|
      tmpfile.binmode
      downloaded = uploaded.download tmpfile
      _(downloaded).must_be_kind_of Tempfile

      _(downloaded.size).must_equal original.size
      _(downloaded.size).must_equal uploaded.size
      _(downloaded.size).must_equal tmpfile.size # Same file

      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(original.path, mode: "rb")
    end

    uploaded.delete
  end

  it "should upload and download a file using IO" do
    inmemory = StringIO.new(File.read(files[:logo][:path], mode: "rb"))

    uploaded = bucket.create_file inmemory, "uploaded/with/inmemory.png"
    _(uploaded.name).must_equal "uploaded/with/inmemory.png"

    downloaded = uploaded.download
    _(downloaded).must_be_kind_of StringIO

    inmemory.rewind
    _(downloaded.size).must_equal inmemory.size
    _(downloaded.size).must_equal uploaded.size

    _(downloaded.read).must_equal inmemory.read
    _(downloaded.read.encoding).must_equal inmemory.read.encoding

    uploaded.delete
  end

  it "should upload and download text using IO" do
    inmemory = StringIO.new "Hello world!"
    uploaded = bucket.create_file inmemory, "uploaded/with/inmemory.txt"
    _(uploaded.name).must_equal "uploaded/with/inmemory.txt"
    _(uploaded.md5).must_equal io_md5

    downloadio = StringIO.new()
    downloaded = uploaded.download downloadio
    _(downloaded).must_be_kind_of StringIO
    _(downloaded).must_equal downloadio # The object returned is the object provided

    inmemory.rewind
    _(downloaded.size).must_equal inmemory.size
    _(downloaded.size).must_equal uploaded.size

    _(downloaded.read).must_equal inmemory.read
    _(downloaded.read.encoding).must_equal inmemory.read.encoding

    uploaded.delete
  end

  it "should upload text using IO and checksum: :md5" do
    inmemory = StringIO.new "Hello world!"
    uploaded = bucket.create_file inmemory, "uploaded/with/inmemory.txt", checksum: :md5
    _(uploaded.md5).must_equal io_md5

    uploaded.delete
  end

  it "should upload text using IO and checksum: :crc32c" do
    inmemory = StringIO.new "Hello world!"
    uploaded = bucket.create_file inmemory, "uploaded/with/inmemory.txt", checksum: :crc32c
    _(uploaded.crc32c).must_equal io_crc32c

    uploaded.delete
  end

  it "should upload, download, and verify gzip content_type" do
    gzipped = gzipped_string_io

    uploaded = bucket.create_file gzipped, "uploaded/with/gzip-type.txt", content_type: "application/gzip"
    _(uploaded.name).must_equal "uploaded/with/gzip-type.txt"
    _(uploaded.content_type).must_equal "application/gzip"
    _(uploaded.content_encoding).must_be_nil
    downloadio = StringIO.new()
    downloaded = uploaded.download downloadio
    _(downloaded).must_be_kind_of StringIO
    _(downloaded).must_equal downloadio # The object returned is the object provided
    gzipped.rewind

    _(downloaded.size).must_equal gzipped.size
    _(downloaded.size).must_equal uploaded.size

    data = downloaded.read
    _(data).must_equal gzipped.read
    gzr = Zlib::GzipReader.new StringIO.new(data)
    _(gzr.read).must_equal "hello world"

    uploaded.delete
  end

  it "should upload, download, verify, and decompress when Content-Encoding gzip response header" do
    data = "hello world"
    gzipped = gzipped_string_io data

    uploaded = bucket.create_file gzipped, "uploaded/with/gzip-encoding.txt", content_type: "text/plain", content_encoding: "gzip"
    _(uploaded.name).must_equal "uploaded/with/gzip-encoding.txt"
    _(uploaded.content_type).must_equal "text/plain"
    _(uploaded.content_encoding).must_equal "gzip"

    downloadio = StringIO.new()
    downloaded = uploaded.download downloadio
    _(downloaded).must_be_kind_of StringIO
    _(downloaded).wont_equal downloadio # The object returned is NOT the object provided

    downloaded_data = downloaded.read
    _(downloaded_data).must_equal data
    _(downloaded_data.encoding).must_equal data.encoding

    uploaded.delete
  end

  it "should upload and download an empty file" do
    begin
      data = ""
      file = StringIO.new

      uploaded = bucket.create_file file, "uploaded/empty-file.txt"
      _(uploaded.name).must_equal "uploaded/empty-file.txt"

      downloadio = StringIO.new
      downloaded = uploaded.download downloadio
      _(downloaded).must_be_kind_of StringIO

      downloaded_data = downloaded.string
      _(downloaded_data).must_equal data
    ensure
      uploaded.delete
    end
  end

  it "should download and verify when Content-Encoding gzip response header with skip_decompress" do
    bucket = bucket_public
    file = bucket.file bucket_public_file_gzip
    _(file.content_encoding).must_equal "gzip"
    Tempfile.open ["hello_world", ".txt"] do |tmpfile|
      tmpfile.binmode
      downloaded = file.download tmpfile, skip_decompress: true

      data = File.read(downloaded.path, mode: "rb")
      gzr = Zlib::GzipReader.new StringIO.new(data)
      _(gzr.read).must_equal "hello world"
    end
  end

  it "should download, verify, and decompress when Content-Encoding gzip response header with skip_lookup" do
    bucket = storage.bucket bucket_public.name, skip_lookup: true
    file = bucket.file bucket_public_file_gzip, skip_lookup: true
    _(file.content_encoding).must_be_nil # metadata not loaded
    _(file.content_type).must_be_nil # metadata not loaded
    Tempfile.open ["hello_world", ".txt"] do |tmpfile|
      tmpfile.binmode
      downloaded = file.download tmpfile

      _(File.read(downloaded.path, mode: "rb")).must_equal "hello world"
    end
  end

  it "should download, verify, and decompress when Content-Encoding gzip response header with crc32c verification" do
    bucket = bucket_public
    file = bucket.file bucket_public_file_gzip

    Tempfile.open ["hello_world", ".txt"] do |tmpfile|
      tmpfile.binmode
      downloaded = file.download tmpfile, verify: :crc32c

      _(File.read(downloaded.path, mode: "rb")).must_equal "hello world" # decompressed file data
    end
  end

  it "should upload and partially download text" do
    inmemory = StringIO.new "Hello world!"
    uploaded = bucket.create_file inmemory, "uploaded/with/inmemory.txt"

    downloaded = uploaded.download range: 3..6
    _(downloaded).must_be_kind_of StringIO

    downloaded.rewind
    downloaded_partial = downloaded.read

    partial_download_custom_error_msg = lambda do
      download_io = StringIO.new
      uploaded.download download_io, verify: :none
      download_io.rewind
      puts "*"*42
      puts "The full downloaded file contents are: #{download_io.read.inspect}"
      puts "*"*42

      "Another partial download failure - #{"lo w".inspect} != #{downloaded_partial.inspect}"
    end
    assert_equal "lo w", downloaded_partial, partial_download_custom_error_msg

    uploaded.delete
  end

  it "should download a file while skipping lookups" do
    original = File.new files[:logo][:path]
    uploaded = bucket.create_file original, "CloudLogo.png"

    bucket = storage.bucket bucket_name, skip_lookup: true
    file = bucket.file "CloudLogo.png", skip_lookup: true

    _(bucket).must_be :lazy?
    _(file).must_be :lazy?

    Tempfile.open ["google-cloud", ".png"] do |tmpfile|
      tmpfile.binmode
      downloaded = file.download tmpfile

      _(downloaded.size).must_equal original.size
      _(downloaded.size).must_equal uploaded.size
      _(downloaded.size).must_equal tmpfile.size # Same file

      _(File.read(downloaded.path, mode: "rb")).must_equal File.read(original.path, mode: "rb")
    end

    uploaded.delete
  end

  it "should write metadata" do
    uploaded = bucket.create_file files[:logo][:path],
                                  "CloudLogo",
                                  content_type: "x-image/x-png",
                                  metadata: { title: "Logo Image" }

    _(uploaded.content_type).must_equal "x-image/x-png"
    _(uploaded.metadata["title"]).must_equal "Logo Image"
  end

  it "should list generations" do
    uploaded = bucket.create_file files[:logo][:path],
                                  "CloudLogo"

    _(uploaded.generation).wont_be :nil?
    _(uploaded.generations).wont_be :nil?
  end

  it "should create and update storage_class" do
    uploaded = bucket.create_file files[:logo][:path], "CloudLogo-storage_class.png", storage_class: :nearline

    _(uploaded.storage_class).must_equal "NEARLINE"
    uploaded.storage_class = :archive
    _(uploaded.storage_class).must_equal "ARCHIVE"

    retrieved1 = bucket.file "CloudLogo-storage_class.png"

    _(retrieved1.storage_class).must_equal "ARCHIVE"
  end

  it "should copy an existing file" do
    uploaded = bucket.create_file files[:logo][:path], "CloudLogo", acl: "public_read", content_language: "en"
    _(uploaded.acl.readers).must_include "allUsers" # has "public_read"
    _(uploaded.content_language).must_equal "en"

    copied = try_with_backoff "copying existing file" do
      uploaded.copy "CloudLogoCopy"
    end

    _(uploaded.name).must_equal "CloudLogo"
    _(uploaded.content_language).must_equal "en"
    _(copied.name).must_equal "CloudLogoCopy"
    _(copied.acl.readers).wont_include "allUsers" # does NOT have "public_read"
    _(copied.content_language).must_equal "en"
    _(copied.size).must_equal uploaded.size

    Tempfile.open ["CloudLogo", ".png"] do |tmpfile1|
      tmpfile1.binmode
      Tempfile.open ["CloudLogoCopy", ".png"] do |tmpfile2|
        tmpfile2.binmode
        downloaded1 = uploaded.download tmpfile1
        downloaded2 = copied.download tmpfile2
        _(downloaded1.size).must_equal downloaded2.size

        _(File.read(downloaded1.path, mode: "rb")).must_equal File.read(downloaded2.path, mode: "rb")
      end
    end

    uploaded.delete
    copied.delete
  end

  it "should copy an existing file, with updates" do
    uploaded = bucket.create_file files[:logo][:path], "CloudLogo", acl: "public_read", content_language: "en", content_type: "image/png"
    _(uploaded.acl.readers).must_include "allUsers" # has "public_read"
    _(uploaded.content_language).must_equal "en"
    _(uploaded.content_type).must_equal "image/png"

    copied = try_with_backoff "copying existing file" do
      uploaded.copy "CloudLogoCopy" do |copy|
        copy.content_language = "de"
      end
    end
    _(uploaded.content_language).must_equal "en"
    _(copied.acl.readers).wont_include "allUsers" # does NOT have "public_read"
    _(copied.content_language).must_equal "de"
    _(copied.content_type).must_be :nil?

    _(uploaded.name).must_equal "CloudLogo"
    _(copied.name).must_equal "CloudLogoCopy"
    _(copied.size).must_equal uploaded.size

    Tempfile.open ["CloudLogo", ".png"] do |tmpfile1|
      tmpfile1.binmode
      Tempfile.open ["CloudLogoCopy", ".png"] do |tmpfile2|
        tmpfile2.binmode
        downloaded1 = uploaded.download tmpfile1
        downloaded2 = copied.download tmpfile2
        _(downloaded1.size).must_equal downloaded2.size

        _(File.read(downloaded1.path, mode: "rb")).must_equal File.read(downloaded2.path, mode: "rb")
      end
    end

    uploaded.delete
    copied.delete
  end

  it "should copy an existing file, with force_copy_metadata set to true" do
    uploaded = bucket.create_file files[:logo][:path], "CloudLogo", acl: "public_read", content_language: "en", content_type: "image/png"
    _(uploaded.acl.readers).must_include "allUsers" # has "public_read"
    _(uploaded.content_language).must_equal "en"
    _(uploaded.content_type).must_equal "image/png"
    _(uploaded.metadata).must_be :empty?

    copied = try_with_backoff "copying existing file" do
      uploaded.copy "CloudLogoCopy", force_copy_metadata: true do |copy|
        copy.content_language = "de"
      end
    end
    _(uploaded.content_language).must_equal "en"
    copied2 = bucket.file copied.name
    _(copied2.acl.readers).wont_include "allUsers" # does NOT have "public_read"
    _(copied.acl.readers).wont_include "allUsers" # does NOT have "public_read"
    _(copied.content_language).must_equal "de"
    _(copied.content_type).must_equal "image/png"
    _(copied.metadata).must_be :empty?

    _(uploaded.name).must_equal "CloudLogo"
    _(copied.name).must_equal "CloudLogoCopy"
    _(copied.size).must_equal uploaded.size

    Tempfile.open ["CloudLogo", ".png"] do |tmpfile1|
      tmpfile1.binmode
      Tempfile.open ["CloudLogoCopy", ".png"] do |tmpfile2|
        tmpfile2.binmode
        downloaded1 = uploaded.download tmpfile1
        downloaded2 = copied.download tmpfile2
        _(downloaded1.size).must_equal downloaded2.size

        _(File.read(downloaded1.path, mode: "rb")).must_equal File.read(downloaded2.path, mode: "rb")
      end
    end

    uploaded.delete
    copied.delete
  end

  it "should rewrite an existing file, with updates" do
    uploaded = bucket.create_file files[:logo][:path], "CloudLogo.png"
    _(uploaded.cache_control).must_be :nil?
    _(uploaded.content_type).must_equal "image/png"

    copied = try_with_backoff "rewriting existing file" do
      uploaded.rewrite "CloudLogoCopy.png" do |f|
        f.cache_control = "public, max-age: 7200"
      end
    end
    _(uploaded.cache_control).must_be :nil?
    _(uploaded.content_type).must_equal "image/png"
    _(copied.cache_control).must_equal "public, max-age: 7200"
    _(copied.content_type).must_be :nil?

    _(uploaded.name).must_equal "CloudLogo.png"
    _(copied.name).must_equal "CloudLogoCopy.png"
    _(copied.size).must_equal uploaded.size

    Tempfile.open ["CloudLogo", ".png"] do |tmpfile1|
      tmpfile1.binmode
      Tempfile.open ["CloudLogoCopy", ".png"] do |tmpfile2|
        tmpfile2.binmode
        downloaded1 = uploaded.download tmpfile1
        downloaded2 = copied.download tmpfile2
        _(downloaded1.size).must_equal downloaded2.size

        _(File.read(downloaded1.path, mode: "rb")).must_equal File.read(downloaded2.path, mode: "rb")
      end
    end

    uploaded.delete
    copied.delete
  end

  it "should rewrite an existing file, with force_copy_metadata set to true" do
    uploaded = bucket.create_file files[:logo][:path], "CloudLogo.png"
    _(uploaded.cache_control).must_be :nil?
    _(uploaded.content_type).must_equal "image/png"

    copied = try_with_backoff "rewriting existing file" do
      uploaded.rewrite "CloudLogoCopy.png", force_copy_metadata: true do |f|
        f.cache_control = "public, max-age: 7200"
      end
    end
    _(uploaded.cache_control).must_be :nil?
    _(uploaded.content_type).must_equal "image/png"
    _(copied.cache_control).must_equal "public, max-age: 7200"
    _(copied.content_type).must_equal "image/png"

    _(uploaded.name).must_equal "CloudLogo.png"
    _(copied.name).must_equal "CloudLogoCopy.png"
    _(copied.size).must_equal uploaded.size

    Tempfile.open ["CloudLogo", ".png"] do |tmpfile1|
      tmpfile1.binmode
      Tempfile.open ["CloudLogoCopy", ".png"] do |tmpfile2|
        tmpfile2.binmode
        downloaded1 = uploaded.download tmpfile1
        downloaded2 = copied.download tmpfile2
        _(downloaded1.size).must_equal downloaded2.size

        _(File.read(downloaded1.path, mode: "rb")).must_equal File.read(downloaded2.path, mode: "rb")
      end
    end

    uploaded.delete
    copied.delete
  end

  it "does not error when getting a file that does not exist" do
    file = bucket.file "this/file/does/not/exist.png"
    _(file).must_be :nil?
  end

  it "should compose existing files into a new file" do
    uploaded_a = bucket.create_file StringIO.new("a"), "a.txt"
    uploaded_b = bucket.create_file StringIO.new("b"), "b.txt"

    composed = try_with_backoff "copying existing file" do
      bucket.compose [uploaded_a, uploaded_b], "ab.txt"
    end

    _(composed.name).must_equal "ab.txt"
    _(composed.size).must_equal uploaded_a.size + uploaded_b.size

    Tempfile.open ["ab", ".txt"] do |tmpfile|
      downloaded = composed.download tmpfile

      _(File.read(downloaded.path)).must_equal "ab"
    end

    uploaded_a.delete
    uploaded_b.delete
    composed.delete
  end

  it "should raise when attempting to compose existing files with failing precondition" do
    uploaded_a = bucket.create_file StringIO.new("a"), "a.txt"
    uploaded_b = bucket.create_file StringIO.new("b"), "b.txt"
    if_source_generation_match = [nil, (uploaded_b.generation - 1)] # Bad generation value.

    expect do
      bucket.compose [uploaded_a.name, uploaded_b.name], "ab.txt", if_source_generation_match: if_source_generation_match
    end.must_raise Google::Cloud::FailedPreconditionError
    uploaded_a.delete
    uploaded_b.delete
  end

  describe "anonymous project" do
    let(:anonymous_storage) { Google::Cloud::Storage.anonymous }

    it "should list public files without authentication" do
      public_bucket = anonymous_storage.bucket bucket_public.name, skip_lookup: true
      files = public_bucket.files

      _(files).wont_be :empty?
    end

    it "should download a public file without authentication" do
      public_bucket = anonymous_storage.bucket bucket_public.name, skip_lookup: true
      file = public_bucket.file bucket_public_file_gzip, skip_lookup: true

      Tempfile.open ["hello_world", ".txt"] do |tmpfile|
        tmpfile.binmode
        downloaded = file.download tmpfile, verify: :none # gzipped file verification bug #1835, does not affect this test

        _(File.read(downloaded.path, mode: "rb")).must_equal "hello world" # decompressed file data
      end
    end

    it "raises when downloading a private file without authentication" do
      skip "Removed due to occasional failures in the CI build."
      original = File.new files[:logo][:path]
      file_name = "CloudLogo.png"
      bucket.create_file original, file_name

      private_bucket = anonymous_storage.bucket bucket_name, skip_lookup: true
      file = private_bucket.file file_name, skip_lookup: true

      Tempfile.open ["hello_world", ".txt"] do |tmpfile|
        tmpfile.binmode
        expect { file.download tmpfile }.must_raise Google::Cloud::UnauthenticatedError
      end
    end

    it "raises when creating a file in a private bucket without authentication" do
      skip "Removed due to occasional failures in the CI build."
      original = File.new files[:logo][:path]
      file_name = "CloudLogo-error.png"

      private_bucket = anonymous_storage.bucket bucket_name, skip_lookup: true
      expect { private_bucket.create_file original, file_name }.must_raise Google::Cloud::UnauthenticatedError
    end
  end

  describe "object retention" do
    # Note: While it would be best if we could clean up these buckets after
    # each test, some of them have retention and cannot be deleted without
    # incurring additional delays. So instead we delete things (including
    # objects lingering from previous runs) at the end of the entire test run
    # (see the bottom of storage_helper.rb).
    let(:object_lock_bucket) { storage.create_bucket("object-lock-bucket-#{Time.now.to_i}", enable_object_retention: true) }
    let(:data) { StringIO.new "Hello World!" }

    it "should update file with future retain until time" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      future_retain_until_time = (Time.now + 5).to_datetime
      retention = { mode: "Unlocked", retain_until_time: future_retain_until_time }
      uploaded_file.retention = retention

      _(uploaded_file.retention_mode).must_equal "Unlocked"
      _(uploaded_file.retention_retain_until_time).must_be_within_delta future_retain_until_time
    end

    it "should reduce retain until time of Unlocked with override" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 5).to_datetime
      future_retain_until_time = (Time.now + 10).to_datetime

      retention = { mode: "Unlocked", retain_until_time: future_retain_until_time }
      uploaded_file.retention = retention
      retention = { mode: "Unlocked", retain_until_time: retain_until_time, override_unlocked_retention: true }
      uploaded_file.retention = retention

      _(uploaded_file.retention_retain_until_time).must_be_within_delta retain_until_time
    end

    it "should remove retention of unlocked object with override" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 5).to_datetime
      retention = { mode: "Unlocked", retain_until_time: retain_until_time }

      uploaded_file.retention = retention

      uploaded_file.retention = { mode: nil, retain_until_time: nil, override_unlocked_retention: true }

      _(uploaded_file.retention).must_be :nil?
    end

    it "should extend retain until time of unlocked object" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 5).to_datetime
      retention = { mode: "Unlocked", retain_until_time: retain_until_time }
      uploaded_file.retention = retention

      future_retain_until_time = (Time.now + 25).to_datetime
      retention = { mode: "Unlocked", retain_until_time: future_retain_until_time }
      uploaded_file.retention = retention

      _(uploaded_file.retention_retain_until_time).must_be_within_delta future_retain_until_time
    end

    it "should extend retain until time of locked object" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 5).to_datetime
      retention = { mode: "Locked", retain_until_time: retain_until_time }
      uploaded_file.retention = retention

      future_retain_until_time = (Time.now + 25).to_datetime
      retention = { mode: "Locked", retain_until_time: future_retain_until_time }
      uploaded_file.retention = retention

      _(uploaded_file.retention_retain_until_time).must_be_within_delta future_retain_until_time
    end

    it "should update retention mode from unlocked to locked" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 500).to_datetime
      retention = { mode: "Unlocked", retain_until_time: retain_until_time }
      uploaded_file.retention = retention
      _(uploaded_file.retention_mode).must_equal "Unlocked"

      retention = { mode: "Locked", retain_until_time: retain_until_time, override_unlocked_retention: true }
      uploaded_file.retention = retention

      _(uploaded_file.retention_mode).must_equal "Locked"
    end

    it "should throw error when deleting object under retention" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 500).to_datetime
      retention = { mode: "Unlocked", retain_until_time: retain_until_time }
      uploaded_file.retention = retention
      _(uploaded_file.retention_mode).must_equal "Unlocked"

      expect { uploaded_file.delete }.must_raise Google::Cloud::PermissionDeniedError
    end

    it "should throw error when updating file with retain until time in the past" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 1).to_datetime
      retention = { mode: "Unlocked", retain_until_time: retain_until_time }
      uploaded_file.retention = retention
      _(uploaded_file.retention_mode).must_equal "Unlocked"
      _(uploaded_file.retention_retain_until_time).must_be_within_delta retain_until_time
      sleep(1)
      expect { uploaded_file.retention = retention }.must_raise Google::Cloud::InvalidArgumentError
    end

    it "should throw error when updating retention with only one argument" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 1).to_datetime
      retention = { mode: "Unlocked" }

      expect { uploaded_file.retention = retention }.must_raise Google::Cloud::InvalidArgumentError
    end

    it "should throw error when reducing retain until time without override" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 100).to_datetime
      retention = { mode: "Unlocked", retain_until_time: retain_until_time }
      uploaded_file.retention = retention

      reduced_retain_until_time = (Time.now + 2).to_datetime
      retention = { mode: "Unlocked", retain_until_time: reduced_retain_until_time }

      expect { uploaded_file.retention = retention }.must_raise Google::Cloud::PermissionDeniedError
    end

    it "should throw error when removing retention without override" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 5).to_datetime
      retention = { mode: "Unlocked", retain_until_time: retain_until_time }
      uploaded_file.retention = retention

      retention = { mode: nil, retain_until_time: nil }

      expect { uploaded_file.retention = retention }.must_raise Google::Cloud::PermissionDeniedError
    end

    it "should throw error when reducing retain until time of a locked object" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 100).to_datetime
      retention = { mode: "Locked", retain_until_time: retain_until_time }
      uploaded_file.retention = retention

      reduced_retain_until_time = (Time.now + 50).to_datetime
      retention = { mode: "Locked", retain_until_time: reduced_retain_until_time }

      expect { uploaded_file.retention = retention }.must_raise Google::Cloud::PermissionDeniedError
    end

    it "should throw error when removing retention of locked object" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 5).to_datetime
      retention = { mode: "Locked", retain_until_time: retain_until_time }
      uploaded_file.retention = retention

      retention = { mode: nil, retain_until_time: nil, override_unlocked_retention: true }

      expect { uploaded_file.retention = retention }.must_raise Google::Cloud::PermissionDeniedError
    end

    it "should throw error when updating mode from Locked to Unlocked" do
      uploaded_file = object_lock_bucket.create_file data, "object-lock-data.txt"

      retain_until_time = (Time.now + 500).to_datetime
      retention = { mode: "Locked", retain_until_time: retain_until_time }
      uploaded_file.retention = retention

      retention = { mode: "Unlocked", retain_until_time: retain_until_time, override_unlocked_retention: true }
      expect { uploaded_file.retention = retention }.must_raise Google::Cloud::PermissionDeniedError
    end
  end
end
