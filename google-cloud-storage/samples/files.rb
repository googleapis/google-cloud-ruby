# Copyright 2016 Google LLC
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

def list_bucket_contents bucket_name:
  # [START list_bucket_contents]
  # bucket_name = "Your Google Cloud Storage bucket name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  bucket.files.each do |file|
    puts file.name
  end
  # [END list_bucket_contents]
end

def list_bucket_contents_with_prefix bucket_name:, prefix:
  # [START list_bucket_contents_with_prefix]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # prefix      = "Filter results to files whose names begin with this prefix"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  files   = bucket.files prefix: prefix

  files.each do |file|
    puts file.name
  end
  # [END list_bucket_contents_with_prefix]
end

def generate_encryption_key_base64
  # [START generate_encryption_key_base64]
  require "base64"
  require "openssl"

  encryption_key  = OpenSSL::Cipher.new("aes-256-cfb").encrypt.random_key
  encoded_enc_key = Base64.encode64 encryption_key

  puts "Sample encryption key: #{encoded_enc_key}"
  # [END generate_encryption_key_base64]
end

def upload_file bucket_name:, local_file_path:, storage_file_path: nil
  # [START upload_file]
  # bucket_name       = "Your Google Cloud Storage bucket name"
  # local_file_path   = "Path to local file to upload"
  # storage_file_path = "Path to store the file in Google Cloud Storage"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  file = bucket.create_file local_file_path, storage_file_path

  puts "Uploaded #{file.name}"
  # [END upload_file]
end

def upload_encrypted_file bucket_name:, local_file_path:, storage_file_path: nil, encryption_key:
  # [START upload_encrypted_file]
  # bucket_name       = "Your Google Cloud Storage bucket name"
  # local_file_path   = "Path to local file to upload"
  # storage_file_path = "Path to store the file in Google Cloud Storage"
  # encryption_key    = "AES-256 encryption key"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  bucket = storage.bucket bucket_name

  file = bucket.create_file local_file_path, storage_file_path,
                            encryption_key: encryption_key

  puts "Uploaded #{file.name} with encryption key"
  # [END upload_encrypted_file]
end

def upload_with_kms_key bucket_name:, local_file_path:, storage_file_path: nil, kms_key:
  # [START storage_upload_with_kms_key]
  # bucket_name       = "Your Google Cloud Storage bucket name"
  # local_file_path   = "Path to local file to upload"
  # storage_file_path = "Path to store the file in Google Cloud Storage"
  # kms_key           = "KMS key resource id"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  bucket = storage.bucket bucket_name

  file = bucket.create_file local_file_path, storage_file_path,
                            kms_key: kms_key

  puts "Uploaded #{file.name} and encrypted service side using #{file.kms_key}"
  # [END storage_upload_with_kms_key]
end

def download_file bucket_name:, file_name:, local_path:
  # [START download_file]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to download locally"
  # local_path  = "Destination path for downloaded file"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.download local_path

  puts "Downloaded #{file.name}"
  # [END download_file]
end

def download_public_file bucket_name:, file_name:, local_path:
  # [START download_public_file]
  # bucket_name = "A public Google Cloud Storage bucket name"
  # file_name   = "Name of a file in the Cloud Storage bucket"
  # local_path  = "Destination path for downloaded file"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.anonymous
  bucket  = storage.bucket bucket_name, skip_lookup: true
  file    = bucket.file file_name

  file.download local_path

  puts "Downloaded #{file.name}"
  # [END download_public_file]
end

def download_file_requester_pays bucket_name:, file_name:, local_path:
  # [START download_file_requester_pays]
  # bucket_name = "A Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to download locally"
  # local_path  = "Destination path for downloaded file"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name, skip_lookup: true, user_project: true
  file    = bucket.file file_name

  file.download local_path

  puts "Downloaded #{file.name} using billing project #{storage.project}"
  # [END download_file_requester_pays]
end

def download_encrypted_file bucket_name:, storage_file_path:,
                            local_file_path:, encryption_key:
  # [START download_encrypted_file]
  # bucket_name    = "Your Google Cloud Storage bucket name"
  # file_name      = "Name of file in Google Cloud Storage to download locally"
  # local_path     = "Destination path for downloaded file"
  # encryption_key = "AES-256 encryption key"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  bucket = storage.bucket bucket_name

  file = bucket.file storage_file_path, encryption_key: encryption_key
  file.download local_file_path, encryption_key: encryption_key

  puts "Downloaded encrypted #{file.name}"
  # [END download_encrypted_file]
end

def delete_file bucket_name:, file_name:
  # [START delete_file]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to delete"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.delete

  puts "Deleted #{file.name}"
  # [END delete_file]
end

def list_file_details bucket_name:, file_name:
  # [START list_file_details]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  puts "Name: #{file.name}"
  puts "Bucket: #{bucket.name}"
  puts "Storage class: #{bucket.storage_class}"
  puts "ID: #{file.id}"
  puts "Size: #{file.size} bytes"
  puts "Created: #{file.created_at}"
  puts "Updated: #{file.updated_at}"
  puts "Generation: #{file.generation}"
  puts "Metageneration: #{file.metageneration}"
  puts "Etag: #{file.etag}"
  puts "Owners: #{file.acl.owners.join ','}"
  puts "Crc32c: #{file.crc32c}"
  puts "md5_hash: #{file.md5}"
  puts "Cache-control: #{file.cache_control}"
  puts "Content-type: #{file.content_type}"
  puts "Content-disposition: #{file.content_disposition}"
  puts "Content-encoding: #{file.content_encoding}"
  puts "Content-language: #{file.content_language}"
  puts "KmsKeyName: #{file.kms_key}"
  puts "Event-based hold enabled?: #{file.event_based_hold?}"
  puts "Temporary hold enaled?: #{file.temporary_hold?}"
  puts "Retention Expiration: #{file.retention_expires_at}"
  puts "Custom Time: #{file.custom_time}"
  puts "Metadata:"
  file.metadata.each do |key, value|
    puts " - #{key} = #{value}"
  end
  # [END list_file_details]
end

def set_metadata bucket_name:, file_name:, content_type:, metadata_key:, metadata_value:
  # [START set_metadata]
  # bucket_name    = "Your Google Cloud Storage bucket name"
  # file_name      = "Name of file in Google Cloud Storage"
  # content_type   = "file Content-Type"
  # metadata_key   = "Custom metadata key"
  # metadata_value = "Custom metadata value"
  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.update do |file|
    # Fixed key file metadata
    file.content_type = content_type

    # Custom file metadata
    file.metadata[metadata_key] = metadata_value
  end

  puts "Metadata for #{file_name} has been updated."
  # [END set_metadata]
end

def make_file_public bucket_name:, file_name:
  # [START make_file_public]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to make public"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.acl.public!

  puts "#{file.name} is publicly accessible at #{file.public_url}"
  # [END make_file_public]
end

def rename_file bucket_name:, file_name:, new_name:
  # [START rename_file]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to rename"
  # new_name    = "File will be renamed to this new name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  renamed_file = file.copy new_name

  file.delete

  puts "#{file_name} has been renamed to #{renamed_file.name}"
  # [END rename_file]
end

def copy_file source_bucket_name:, source_file_name:, dest_bucket_name:, dest_file_name:
  # [START copy_file]
  # source_bucket_name = "Source bucket to copy file from"
  # source_file_name   = "Source file name"
  # dest_bucket_name   = "Destination bucket to copy file to"
  # dest_file_name     = "Destination file name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket source_bucket_name
  file    = bucket.file source_file_name

  destination_bucket = storage.bucket dest_bucket_name
  destination_file   = file.copy destination_bucket.name, dest_file_name

  puts "#{file.name} in #{bucket.name} copied to " \
       "#{destination_file.name} in #{destination_bucket.name}"
  # [END copy_file]
end

def rotate_encryption_key bucket_name:, file_name:, current_encryption_key:, new_encryption_key:
  # [START rotate_encryption_key]
  # bucket_name            = "Your Google Cloud Storage bucket name"
  # file_name              = "Name of a file in the Cloud Storage bucket"
  # current_encryption_key = "Encryption key currently being used"
  # new_encryption_key     = "New encryption key to use"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name, encryption_key: current_encryption_key

  file.rotate encryption_key:     current_encryption_key,
              new_encryption_key: new_encryption_key

  puts "The encryption key for #{file.name} in #{bucket.name} was rotated."
  # [END rotate_encryption_key]
end

def generate_signed_url bucket_name:, file_name:
  # [START generate_signed_url]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of a file in the Cloud Storage bucket"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  url = file.signed_url

  puts "The signed url for #{file_name} is #{url}"
  # [END generate_signed_url]
end

def generate_signed_get_url_v4 bucket_name:, file_name:
  # [START storage_generate_signed_url_v4]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of a file in the Google Cloud Storage bucket"
  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  storage_expiry_time = 5 * 60 # 5 minutes

  url = storage.signed_url bucket_name, file_name, method: "GET",
                           expires: storage_expiry_time, version: :v4

  puts "Generated GET signed url:"
  puts url
  puts "You can use this URL with any user agent, for example:"
  puts "curl #{url}"
  # [END storage_generate_signed_url_v4]
end

def generate_signed_put_url_v4 bucket_name:, file_name:
  # [START storage_generate_upload_signed_url_v4]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of a file in the Cloud Storage bucket"
  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  storage_expiry_time = 5 * 60 # 5 minutes

  url = storage.signed_url bucket_name, file_name, method: "PUT",
                           expires: storage_expiry_time, version: :v4,
                           headers: { "Content-Type" => "text/plain" }
  puts "Generated PUT signed URL:"
  puts url
  puts "You can use this URL with any user agent, for example:"
  puts "curl -X PUT -H 'Content-Type: text/plain' --upload-file my-file '#{url}'"
  # [END storage_generate_upload_signed_url_v4]
end

def generate_signed_post_policy_v4 bucket_name:, file_name:
  # [START storage_generate_signed_post_policy_v4]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of a file to create in the Cloud Storage bucket"
  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  bucket = storage.bucket bucket_name
  post_object = bucket.generate_signed_post_policy_v4 file_name,
                                                      expires: 600,
                                                      fields:  { "x-goog-meta-test": "data" }

  html_form = "<form action='#{post_object.url}' method='POST' enctype='multipart/form-data'>\n"
  post_object.fields.each do |name, value|
    html_form += "  <input name='#{name}' value='#{value}' type='hidden'/>\n"
  end
  html_form += "  <input type='file' name='file'/><br />\n"
  html_form += "  <input type='submit' value='Upload File' name='submit'/><br />\n"
  html_form += "</form>\n"

  puts html_form
  # [END storage_generate_signed_post_policy_v4]
end

def set_event_based_hold bucket_name:, file_name:
  # [START storage_set_event_based_hold]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of a file in the Cloud Storage bucket"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.set_event_based_hold!

  puts "Event-based hold was set for #{file_name}."
  # [END storage_set_event_based_hold]
end

def release_event_based_hold bucket_name:, file_name:
  # [START storage_release_event_based_hold]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of a file in the Cloud Storage bucket"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.release_event_based_hold!

  puts "Event-based hold was released for #{file_name}."
  # [END storage_release_event_based_hold]
end

def set_temporary_hold bucket_name:, file_name:
  # [START storage_set_temporary_hold]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of a file in the Cloud Storage bucket"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.set_temporary_hold!

  puts "Temporary hold was set for #{file_name}."
  # [END storage_set_temporary_hold]
end

def release_temporary_hold bucket_name:, file_name:
  # [START storage_release_temporary_hold]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of a file in the Cloud Storage bucket"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.release_temporary_hold!

  puts "Temporary hold was released for #{file_name}."
  # [END storage_release_temporary_hold]
end

def run_sample arguments
  command = arguments.shift

  case command
  when "list"
    list_bucket_contents bucket_name: arguments.shift
  when "upload"
    upload_file bucket_name:       arguments.shift,
                local_file_path:   arguments.shift,
                storage_file_path: arguments.shift
  when "encrypted_upload"
    upload_encrypted_file bucket_name:       arguments.shift,
                          local_file_path:   arguments.shift,
                          storage_file_path: arguments.shift,
                          encryption_key:    Base64.decode64(arguments.shift)
  when "kms_upload"
    upload_with_kms_key bucket_name:       arguments.shift,
                        local_file_path:   arguments.shift,
                        storage_file_path: arguments.shift,
                        kms_key:           arguments.shift
  when "download"
    download_file bucket_name: arguments.shift,
                  file_name:   arguments.shift,
                  local_path:  arguments.shift
  when "download_public_file"
    download_public_file bucket_name: arguments.shift,
                         file_name:   arguments.shift,
                         local_path:  arguments.shift
  when "encrypted_download"
    download_file bucket_name:   arguments.shift,
                  file_name:     arguments.shift,
                  local_path:    arguments.shift,
                  encrypted_key: Base64.decode64(arguments.shift)
  when "download_with_requester_pays"
    download_file_requester_pays bucket_name: arguments.shift,
                                 file_name:   arguments.shift,
                                 local_path:  arguments.shift
  when "rotate_encryption_key"
    rotate_encryption_key bucket_name:            arguments.shift,
                          file_name:              arguments.shift,
                          current_encryption_key: arguments.shift,
                          new_encryption_key:     arguments.shift
  when "generate_encryption_key"
    generate_encryption_key_base64
  when "delete"
    delete_file bucket_name: arguments.shift,
                file_name:   arguments.shift
  when "metadata"
    list_file_details bucket_name: arguments.shift,
                      file_name:   arguments.shift
  when "make_public"
    make_file_public bucket_name: arguments.shift,
                     file_name:   arguments.shift
  when "rename"
    rename_file bucket_name: arguments.shift,
                file_name:   arguments.shift,
                new_name:    arguments.shift
  when "copy"
    copy_file source_bucket_name: arguments.shift,
              source_file_name:   arguments.shift,
              dest_bucket_name:   arguments.shift,
              dest_file_name:     arguments.shift
  when "generate_signed_url"
    generate_signed_url bucket_name: arguments.shift,
                        file_name:   arguments.shift
  when "generate_signed_get_url_v4"
    generate_signed_get_url_v4 bucket_name: arguments.shift,
                               file_name:   arguments.shift
  when "generate_signed_put_url_v4"
    generate_signed_put_url_v4 bucket_name: arguments.shift,
                               file_name:   arguments.shift
  when "generate_signed_post_policy_v4"
    generate_signed_post_policy_v4 bucket_name: arguments.shift,
                                   file_name:   arguments.shift
  when "set_event_based_hold"
    set_event_based_hold bucket_name: arguments.shift,
                         file_name:   arguments.shift
  when "release_event_based_hold"
    release_event_based_hold bucket_name: arguments.shift,
                             file_name:   arguments.shift
  when "set_temporary_hold"
    set_temporary_hold bucket_name: arguments.shift,
                       file_name:   arguments.shift
  when "release_temporary_hold"
    release_temporary_hold bucket_name: arguments.shift,
                           file_name:   arguments.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby files.rb [command] [arguments]

      Commands:
        list                 <bucket>                                     List all files in the bucket
        upload               <bucket> <file> <dest_path>                  Upload local file to a bucket
        encrypted_upload     <bucket> <file> <dest_path> <encryption_key> Upload local file as an encrypted file to a bucket
        kms_upload           <bucket> <file> <dest_path> <kms_key>        Upload local file and encrypt service side using a KMS key
        download             <bucket> <file> <path>                       Download a file from a bucket
        download_public_file <bucket> <file> <path>                       Download a publically accessible file from a bucket
        encrypted_download <bucket> <file> <path> <encryption_key>        Download an encrypted file from a bucket
        download_with_requester_pays <project> <bucket> <file> <path>     Download a file from a requester pays enabled bucket
        rotate_encryption_key <bucket> <file> <base64_current_encryption_key> <base64_new_encryption_key> Update encryption key of an encrypted file.
        generate_encryption_key                                           Generate a sample encryption key
        delete       <bucket> <file>                                      Delete a file from a bucket
        metadata     <bucket> <file>                                      Display metadata for a file in a bucket
        make_public  <bucket> <file>                                      Make a file in a bucket public
        rename       <bucket> <file> <new>                                Rename a file in a bucket
        copy <srcBucket> <srcFile> <destBucket> <destFile>                Copy file to other bucket
        generate_signed_url <bucket> <file>                               Generate a V2 signed url for a file
        generate_signed_get_url_v4 <bucket> <file>                        Generate a V4 signed get url for a file
        generate_signed_put_url_v4 <bucket> <file>                        Generate a V4 signed put url for a file
        generate_signed_post_policy_v4 <bucket> <file>                    Generate a V4 signed post policy for a file and print HTML form
        set_event_based_hold       <bucket> <file>                        Set an event-based hold on a file
        release_event_based_hold   <bucket> <file>                        Relase an event-based hold on a file
        set_temporary_hold         <bucket> <file>                        Set a temporary hold on a file
        release_temporary_hold     <bucket> <file>                        Release a temporary hold on a file

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end

if $PROGRAM_NAME == __FILE__
  run_sample ARGV
end
