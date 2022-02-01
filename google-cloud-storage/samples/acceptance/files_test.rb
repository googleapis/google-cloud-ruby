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
require_relative "../storage_generate_signed_url_v2"
require_relative "../storage_change_file_storage_class"
require_relative "../storage_compose_file"
require_relative "../storage_copy_file"
require_relative "../storage_copy_file_archived_generation"
require_relative "../storage_delete_file"
require_relative "../storage_delete_file_archived_generation"
require_relative "../storage_download_encrypted_file"
require_relative "../storage_download_file"
require_relative "../storage_download_file_into_memory"
require_relative "../storage_download_file_requester_pays"
require_relative "../storage_download_public_file"
require_relative "../storage_generate_encryption_key"
require_relative "../storage_generate_signed_post_policy_v4"
require_relative "../storage_generate_signed_url_v4"
require_relative "../storage_generate_upload_signed_url_v4"
require_relative "../storage_get_metadata"
require_relative "../storage_list_files"
require_relative "../storage_list_files_with_prefix"
require_relative "../storage_list_file_archived_generations"
require_relative "../storage_make_public"
require_relative "../storage_move_file"
require_relative "../storage_object_csek_to_cmek"
require_relative "../storage_release_event_based_hold"
require_relative "../storage_release_temporary_hold"
require_relative "../storage_rotate_encryption_key"
require_relative "../storage_set_event_based_hold"
require_relative "../storage_set_metadata"
require_relative "../storage_set_temporary_hold"
require_relative "../storage_upload_encrypted_file"
require_relative "../storage_upload_file"
require_relative "../storage_upload_from_memory"
require_relative "../storage_upload_with_kms_key"

describe "Files Snippets" do
  let(:storage_client)   { Google::Cloud::Storage.new }
  let(:local_file)       { File.expand_path "data/file.txt", __dir__ }
  let(:encryption_key)   { OpenSSL::Cipher.new("aes-256-cfb").encrypt.random_key }
  let(:kms_key)          { get_kms_key storage_client.project }
  let(:remote_file_name) { "path/file_name_#{SecureRandom.hex}.txt" }
  let(:downloaded_file)  { "test_download_#{SecureRandom.hex}" }
  let(:file_1_name) { "path/file_1_name_#{SecureRandom.hex}.txt" }
  let(:file_2_name) { "path/file_2_name_#{SecureRandom.hex}.txt" }
  let(:bucket) { @bucket }
  let(:secondary_bucket) { @secondary_bucket }
  let(:file_content) { "some content" }

  before :all do
    @bucket = create_bucket_helper random_bucket_name
    @secondary_bucket = create_bucket_helper "ruby_storage_sample_#{SecureRandom.hex}_secondary"
  end

  after :all do
    delete_bucket_helper @bucket.name
    delete_bucket_helper @secondary_bucket.name
  end

  after do
    bucket.requester_pays = false
    bucket.files.each(&:delete)
  end

  it "list_files" do
    bucket.create_file local_file, file_1_name
    bucket.create_file local_file, file_2_name

    out, _err = capture_io do
      list_files bucket_name: bucket.name
    end

    assert_match file_1_name, out
    assert_match file_2_name, out
  end

  it "list_files_with_prefix" do
    ["foo/file.txt", "foo/data.txt", "bar/file.txt", "bar/data.txt"].each do |file|
      bucket.create_file local_file, file
    end

    out, _err = capture_io do
      list_files_with_prefix bucket_name: bucket.name, prefix: "foo/"
    end

    assert_match "foo/file.txt", out
    assert_match "foo/data.txt", out
    refute_match "bar/file.txt", out
    refute_match "bar/data.txt", out
  end

  it "list_file_archived_generations" do
    file_1 = bucket.create_file local_file, file_1_name
    file_2 = bucket.create_file local_file, file_2_name

    out, _err = capture_io do
      list_file_archived_generations bucket_name: bucket.name
    end

    assert_match "#{file_1_name},#{file_1.generation}", out
    assert_match "#{file_2_name},#{file_2.generation}", out
  end

  it "generate_encryption_key" do
    mock_cipher = Minitest::Mock.new

    def mock_cipher.encrypt
      self
    end

    def mock_cipher.random_key
      @random_key ||= OpenSSL::Cipher.new("aes-256-cfb").encrypt.random_key
    end

    encryption_key_base64 = Base64.encode64 mock_cipher.random_key

    OpenSSL::Cipher.stub :new, mock_cipher do
      assert_output "Sample encryption key: #{encryption_key_base64}" do
        generate_encryption_key
      end
    end
  end

  it "upload_file" do
    assert_output "Uploaded #{local_file} as #{remote_file_name} in bucket #{bucket.name}\n" do
      upload_file bucket_name: bucket.name, local_file_path: local_file, file_name: remote_file_name
    end

    assert_equal bucket.files.first.name, remote_file_name
  end

  it "upload_file_from_memory" do
    assert_output "Uploaded file #{remote_file_name} to bucket #{bucket.name} with content: #{file_content}\n" do
      upload_file_from_memory bucket_name: bucket.name,
                              file_name: remote_file_name,
                              file_content: file_content
    end
  end

  it "upload_encrypted_file" do
    assert_output "Uploaded #{remote_file_name} with encryption key\n" do
      upload_encrypted_file bucket_name:     bucket.name,
                            local_file_path: local_file,
                            file_name:       remote_file_name,
                            encryption_key:  encryption_key
    end

    assert_equal bucket.files.first.name, remote_file_name
    refute_nil bucket.files.first.encryption_key_sha256
  end

  it "upload_with_kms_key" do
    assert_output(/Uploaded #{remote_file_name} and encrypted service side using #{kms_key}/) do
      upload_with_kms_key bucket_name:     bucket.name,
                          local_file_path: local_file,
                          file_name:       remote_file_name,
                          kms_key:         kms_key
    end

    assert_equal bucket.files.first.name, remote_file_name
    assert_match kms_key, bucket.files.first.kms_key
  end

  it "download_file" do
    bucket.create_file local_file, remote_file_name

    Tempfile.open [downloaded_file] do |tmpfile|
      tmpfile.binmode

      assert_output "Downloaded #{remote_file_name} to #{tmpfile}\n" do
        download_file bucket_name:     bucket.name,
                      file_name:       remote_file_name,
                      local_file_path: tmpfile
      end

      assert File.file? tmpfile
    end
  end

  it "download_file_into_memory" do
    bucket.create_file StringIO.new(file_content), remote_file_name

    assert_output "Contents of storage object #{remote_file_name} in bucket #{bucket.name} are: #{file_content}\n" do
      download_file_into_memory bucket_name: bucket.name,
                                file_name: remote_file_name
    end
  end

  it "download_public_file" do
    bucket.create_file local_file, remote_file_name

    Tempfile.open [downloaded_file] do |tmpfile|
      tmpfile.binmode

      assert_output "Downloaded #{remote_file_name} to #{tmpfile}\n" do
        download_file bucket_name:     bucket.name,
                      file_name:       remote_file_name,
                      local_file_path: tmpfile
      end

      assert File.file? tmpfile
    end
  end

  it "download_file_requester_pays" do
    bucket.requester_pays = true
    bucket.create_file local_file, remote_file_name

    Tempfile.open [downloaded_file] do |tmpfile|
      tmpfile.binmode

      assert_output "Downloaded #{remote_file_name} using billing project #{storage_client.project}\n" do
        download_file_requester_pays bucket_name:     bucket.name,
                                     file_name:       remote_file_name,
                                     local_file_path: tmpfile
      end

      assert File.file? tmpfile
    end
  end

  it "download_encrypted_file" do
    bucket.create_file local_file, remote_file_name, encryption_key: encryption_key

    Tempfile.open [downloaded_file] do |tmpfile|
      tmpfile.binmode

      assert_output "Downloaded encrypted #{remote_file_name} to #{tmpfile}\n" do
        download_encrypted_file bucket_name:     bucket.name,
                                file_name:       remote_file_name,
                                local_file_path: tmpfile,
                                encryption_key:  encryption_key
      end

      assert File.file? tmpfile
      assert_equal File.read(local_file), File.read(tmpfile)
    end
  end

  it "delete_file" do
    bucket.create_file local_file, remote_file_name

    assert_output "Deleted #{remote_file_name}\n" do
      delete_file bucket_name: bucket.name, file_name: remote_file_name
    end

    assert_nil bucket.file remote_file_name
  end

  it "delete_file_archived_generation" do
    file = bucket.create_file local_file, remote_file_name

    assert_output "Generation #{file.generation} of file #{remote_file_name} was deleted from #{bucket.name}\n" do
      delete_file_archived_generation bucket_name: bucket.name, file_name: remote_file_name, generation: file.generation
    end

    assert_nil bucket.file remote_file_name
  end

  it "get_metadata" do
    bucket.create_file local_file, remote_file_name

    file = bucket.file remote_file_name
    expected_output = <<~OUTPUT
      Name: #{file.name}
      Bucket: #{bucket.name}
      Storage class: #{bucket.storage_class}
      ID: #{file.id}
      Size: #{file.size} bytes
      Created: #{file.created_at}
      Updated: #{file.updated_at}
      Generation: #{file.generation}
      Metageneration: #{file.metageneration}
      Etag: #{file.etag}
      Owners: #{file.acl.owners.join ','}
      Crc32c: #{file.crc32c}
      md5_hash: #{file.md5}
      Cache-control: #{file.cache_control}
      Content-type: #{file.content_type}
      Content-disposition: #{file.content_disposition}
      Content-encoding: #{file.content_encoding}
      Content-language: #{file.content_language}
      KmsKeyName: #{file.kms_key}
      Event-based hold enabled?: #{file.event_based_hold?}
      Temporary hold enaled?: #{file.temporary_hold?}
      Retention Expiration: #{file.retention_expires_at}
      Custom Time: #{file.custom_time}
      Metadata:
    OUTPUT

    assert_output expected_output do
      get_metadata bucket_name: bucket.name,
                   file_name:   remote_file_name
    end
  end

  it "set_metadata" do
    bucket.create_file local_file, remote_file_name

    metadata_key   = "your-metadata-key"
    metadata_value = "your-metadata-value"

    assert_output "Metadata for #{remote_file_name} has been updated.\n" do
      set_metadata bucket_name: bucket.name, file_name: remote_file_name
    end

    assert_equal bucket.file(remote_file_name).metadata[metadata_key], metadata_value
  end

  it "make_public" do
    bucket.create_file local_file, remote_file_name
    response = Net::HTTP.get URI(bucket.file(remote_file_name).public_url)
    refute_equal File.read(local_file), response

    assert_output "#{remote_file_name} is publicly accessible at #{bucket.file(remote_file_name).public_url}\n" do
      make_public bucket_name: bucket.name,
                  file_name:   remote_file_name
    end

    response = Net::HTTP.get URI(bucket.file(remote_file_name).public_url)
    assert_equal File.read(local_file), response
  end

  it "move_file" do
    bucket.create_file local_file, remote_file_name

    new_name = "path/new_name.txt"
    assert_nil bucket.file new_name

    assert_output "#{remote_file_name} has been renamed to #{new_name}\n" do
      move_file bucket_name: bucket.name,
                file_name:   remote_file_name,
                new_name:    new_name
    end

    assert_nil bucket.file remote_file_name
    refute_nil bucket.file new_name
  end

  it "compose_file" do
    file_1 = bucket.create_file local_file, file_1_name
    file_2 = bucket.create_file local_file, file_2_name

    expected_out = "Composed new file #{remote_file_name} in the bucket #{bucket.name} " \
                   "by combining #{file_1.name} and #{file_2.name}\n"
    assert_output expected_out do
      compose_file bucket_name:           bucket.name,
                   first_file_name:       file_1.name,
                   second_file_name:      file_2.name,
                   destination_file_name: remote_file_name
    end

    refute_nil bucket.file remote_file_name
  end

  it "copy_file" do
    bucket.create_file local_file, remote_file_name
    assert_nil secondary_bucket.file remote_file_name

    assert_output "#{remote_file_name} in #{bucket.name} copied to #{remote_file_name} in #{secondary_bucket.name}\n" do
      copy_file source_bucket_name:      bucket.name,
                source_file_name:        remote_file_name,
                destination_bucket_name: secondary_bucket.name,
                destination_file_name:   remote_file_name
    end

    refute_nil bucket.file remote_file_name
    refute_nil secondary_bucket.file remote_file_name
  end

  it "copy_file_archived_generation" do
    file = bucket.create_file local_file, remote_file_name
    assert_nil secondary_bucket.file remote_file_name

    expected_out = "Generation #{file.generation} of the file #{remote_file_name} in bucket #{bucket.name} copied " \
                   "to file #{remote_file_name} in bucket #{secondary_bucket.name}\n"
    assert_output expected_out do
      copy_file_archived_generation source_bucket_name:      bucket.name,
                                    source_file_name:        remote_file_name,
                                    generation:              file.generation,
                                    destination_bucket_name: secondary_bucket.name,
                                    destination_file_name:   remote_file_name
    end

    refute_nil bucket.file remote_file_name
    refute_nil secondary_bucket.file remote_file_name
  end

  it "rotate_encryption_key" do
    bucket.create_file local_file, remote_file_name, encryption_key: encryption_key

    new_encryption_key = OpenSSL::Cipher.new("aes-256-cfb").encrypt.random_key
    file_contents = File.read local_file

    assert_output "The encryption key for #{remote_file_name} in #{bucket.name} was rotated.\n" do
      rotate_encryption_key bucket_name:            bucket.name,
                            file_name:              remote_file_name,
                            current_encryption_key: encryption_key,
                            new_encryption_key:     new_encryption_key
    end

    Tempfile.open [downloaded_file] do |tmpfile|
      tmpfile.binmode

      bucket.file(remote_file_name).download tmpfile, encryption_key: new_encryption_key
      downloaded_contents = File.read tmpfile
      assert_equal file_contents, downloaded_contents
    end
  end

  it "object_csek_to_cmek" do
    file = bucket.create_file local_file, remote_file_name, encryption_key: encryption_key
    assert file.encryption_key_sha256
    expected_out = "File #{file.name} in bucket #{bucket.name} is now managed by the KMS key #{kms_key} instead of " \
                   "a customer-supplied encryption key\n"
    assert_output expected_out do
      object_csek_to_cmek bucket_name:    bucket.name,
                          file_name:      file.name,
                          encryption_key: encryption_key,
                          kms_key_name:   kms_key
    end

    file = bucket.file file.name

    assert file.exists?
    assert_match kms_key, file.kms_key
    assert_nil file.encryption_key_sha256
  end

  it "generate_signed_url_v2" do
    bucket.create_file local_file, remote_file_name

    out, _err = capture_io do
      generate_signed_url_v2 bucket_name: bucket.name,
                             file_name:   remote_file_name
    end

    assert_match "The signed url for #{remote_file_name} is", out
    signed_url = out.scan(/http.*$/).first
    refute_nil signed_url

    file_contents = Net::HTTP.get URI(signed_url)
    assert_equal file_contents, File.read(local_file)
  end

  it "generate_signed_url_v4" do
    bucket.create_file local_file, remote_file_name

    out, _err = capture_io do
      generate_signed_url_v4 bucket_name: bucket.name,
                             file_name:   remote_file_name
    end

    signed_url = out.scan(/http.*$/).first
    refute_nil signed_url

    file_contents = Net::HTTP.get URI(signed_url)
    assert_equal file_contents, File.read(local_file)
  end

  it "generate_upload_signed_url_v4" do
    refute bucket.file remote_file_name

    out, _err = capture_io do
      generate_upload_signed_url_v4 bucket_name: bucket.name,
                                    file_name:   remote_file_name
    end

    signed_url = out.scan(/http.*$/).first
    refute_nil signed_url

    uri = URI.parse signed_url
    http = Net::HTTP.new uri.host
    request = Net::HTTP::Put.new uri.request_uri
    request.body = File.read local_file
    request["Content-Type"] = "text/plain"
    request["Content-Length"] = File.size local_file

    response = http.request request
    assert_equal response.code, "200"

    assert bucket.file remote_file_name
  end
  describe "post object" do
    require "net/http"
    require "uri"
    let(:uri) { URI.parse Google::Cloud::Storage::GOOGLEAPIS_URL }
    let(:data) { File.expand_path "../../acceptance/data/logo.jpg", __dir__ }

    it "generate_signed_post_policy_v4" do
      refute bucket.file remote_file_name
      post_object = nil
      out, _err = capture_io do
        post_object = generate_signed_post_policy_v4 bucket_name: bucket.name,
                                                     file_name:   remote_file_name
      end

      assert_includes out, "<form action='https://storage.googleapis.com/#{bucket.name}/'"
      assert_includes out, "<input name='key' value='#{remote_file_name}'"
      assert_includes out, "<input name='x-goog-signature'"
      assert_includes out, "<input name='x-goog-date'"
      assert_includes out, "<input name='x-goog-credential'"
      assert_includes out, "<input name='x-goog-algorithm' value='GOOG4-RSA-SHA256'"
      assert_includes out, "<input name='policy'"
      assert_includes out, "<input name='x-goog-meta-test' value='data'"
      assert_includes out, "<input type='file' name='file'/>"
      assert_includes out, "<input type='submit' value='Upload File'/>"

      assert post_object
      expected_keys = [
        "key",
        "policy",
        "x-goog-algorithm",
        "x-goog-credential",
        "x-goog-date",
        "x-goog-meta-test",
        "x-goog-signature"
      ]
      assert_equal expected_keys, post_object.fields.keys.sort

      form_data = [["file", File.open(data)]]

      post_object.fields.each do |key, value|
        form_data.push [key, value]
      end

      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true
      request = Net::HTTP::Post.new post_object.url
      request.set_form form_data, "multipart/form-data"

      response = http.request request

      _(response.code).must_equal "204"
      file = bucket.file post_object.fields["key"]
      _(file).wont_be :nil?
      Tempfile.open ["google-cloud-logo", ".jpg"] do |tmpfile|
        tmpfile.binmode
        downloaded = file.download tmpfile
        _(File.read(downloaded.path, mode: "rb")).must_equal File.read(data, mode: "rb")
      end
    end
  end

  it "set_event_based_hold" do
    bucket.create_file local_file, remote_file_name

    assert_output "Event-based hold was set for #{remote_file_name}.\n" do
      set_event_based_hold bucket_name: bucket.name,
                           file_name:   remote_file_name
    end

    assert bucket.file(remote_file_name).event_based_hold?
    bucket.file(remote_file_name).release_event_based_hold!
  end

  it "release_event_based_hold" do
    bucket.create_file local_file, remote_file_name
    bucket.file(remote_file_name).set_event_based_hold!
    assert bucket.file(remote_file_name).event_based_hold?

    assert_output "Event-based hold was released for #{remote_file_name}.\n" do
      release_event_based_hold bucket_name: bucket.name,
                               file_name:   remote_file_name
    end

    refute bucket.file(remote_file_name).event_based_hold?
  end

  it "set_temporary_hold" do
    bucket.create_file local_file, remote_file_name
    refute bucket.file(remote_file_name).temporary_hold?

    assert_output "Temporary hold was set for #{remote_file_name}.\n" do
      set_temporary_hold bucket_name: bucket.name,
                         file_name:   remote_file_name
    end

    assert bucket.file(remote_file_name).temporary_hold?
    bucket.file(remote_file_name).release_temporary_hold!
  end

  it "release_temporary_hold" do
    bucket.create_file local_file, remote_file_name
    bucket.file(remote_file_name).set_temporary_hold!
    assert bucket.file(remote_file_name).temporary_hold?

    assert_output "Temporary hold was released for #{remote_file_name}.\n" do
      release_temporary_hold bucket_name: bucket.name, file_name: remote_file_name
    end

    refute bucket.file(remote_file_name).temporary_hold?
  end

  it "change_file_storage_class" do
    bucket.create_file local_file, remote_file_name
    assert_equal "STANDARD", bucket.file(remote_file_name).storage_class

    assert_output "File #{remote_file_name} in bucket #{bucket.name} had its storage class set to NEARLINE\n" do
      change_file_storage_class bucket_name: bucket.name, file_name: remote_file_name
    end

    assert_equal "NEARLINE", bucket.file(remote_file_name).storage_class
  end
end
