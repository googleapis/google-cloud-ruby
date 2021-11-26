# Copyright 2017 Google LLC
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

def print_bucket_acl bucket_name:
  # [START storage_print_bucket_acl]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  puts "ACL for #{bucket_name}:"

  bucket.acl.owners.each do |owner|
    puts "OWNER #{owner}"
  end

  bucket.acl.writers.each do |writer|
    puts "WRITER #{writer}"
  end

  bucket.acl.readers.each do |reader|
    puts "READER #{reader}"
  end
  # [END storage_print_bucket_acl]
end

def print_bucket_acl_for_user bucket_name:, email:
  # [START storage_print_bucket_acl_for_user]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # email       = "Google Cloud Storage ACL Entity email"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  puts "Permissions for #{email}:"
  puts "OWNER"  if bucket.acl.owners.include?  email
  puts "WRITER" if bucket.acl.writers.include? email
  puts "READER" if bucket.acl.readers.include? email
  # [END storage_print_bucket_acl_for_user]
end

def add_bucket_owner bucket_name:, email:
  # [START storage_add_bucket_owner]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # email       = "Google Cloud Storage ACL Entity email"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  bucket.acl.add_owner email

  puts "Added OWNER permission for #{email} to #{bucket_name}"
  # [END storage_add_bucket_owner]
end

def remove_bucket_acl bucket_name:, email:
  # [START storage_remove_bucket_owner]
  # project_id  = "Your Google Cloud project ID"
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # email       = "Google Cloud Storage ACL Entity email"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  bucket.acl.delete email

  puts "Removed ACL permissions for #{email} from #{bucket_name}"
  # [END storage_remove_bucket_owner]
end

def add_bucket_default_owner bucket_name:, email:
  # [START storage_add_bucket_default_owner]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # email       = "Google Cloud Storage ACL Entity email"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  bucket.default_acl.add_owner email

  puts "Added default OWNER permission for #{email} to #{bucket_name}"
  # [END storage_add_bucket_default_owner]
end

def remove_bucket_default_acl bucket_name:, email:
  # [START storage_remove_bucket_default_owner]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # email       = "Google Cloud Storage ACL Entity email"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  bucket.default_acl.delete email

  puts "Removed default ACL permissions for #{email} from #{bucket_name}"
  # [END storage_remove_bucket_default_owner]
end

def print_file_acl bucket_name:, file_name:
  # [START storage_print_file_acl]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # file_name   = "Name of a file in the Storage bucket"
  # email       = "Google Cloud Storage ACL Entity email"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  puts "ACL for #{file_name} in #{bucket_name}:"

  file.acl.owners.each do |owner|
    puts "OWNER #{owner}"
  end

  file.acl.readers.each do |reader|
    puts "READER #{reader}"
  end
  # [END storage_print_file_acl]
end

def print_file_acl_for_user bucket_name:, file_name:, email:
  # [START storage_print_file_acl_for_user]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # file_name   = "Name of a file in the Storage bucket"
  # email       = "Google Cloud Storage ACL Entity email"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  puts "Permissions for #{email}:"
  puts "OWNER"  if file.acl.owners.include?  email
  puts "READER" if file.acl.readers.include? email
  # [END storage_print_file_acl_for_user]
end

def add_file_owner bucket_name:, file_name:, email:
  # [START storage_add_file_owner]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # file_name   = "Name of a file in the Storage bucket"
  # email       = "Google Cloud Storage ACL Entity email"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.acl.add_owner email

  puts "Added OWNER permission for #{email} to #{file_name}"
  # [END storage_add_file_owner]
end

def remove_file_acl bucket_name:, file_name:, email:
  # [START storage_remove_file_owner]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # file_name   = "Name of a file in the Storage bucket"
  # email       = "Google Cloud Storage ACL Entity email"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.acl.delete email

  puts "Removed ACL permissions for #{email} from #{file_name}"
  # [END storage_remove_file_owner]
end

def run_sample arguments
  command = arguments.shift

  case command
  when "print_bucket_acl"
    print_bucket_acl bucket_name: arguments.shift
  when "print_bucket_acl_for_user"
    print_bucket_acl_for_user bucket_name: arguments.shift,
                              email:       arguments.shift
  when "add_bucket_owner"
    add_bucket_owner bucket_name: arguments.shift,
                     email:       arguments.shift
  when "remove_bucket_acl"
    remove_bucket_acl bucket_name: arguments.shift,
                      email:       arguments.shift
  when "add_bucket_default_owner"
    add_bucket_default_owner bucket_name: arguments.shift,
                             email:       arguments.shift
  when "remove_bucket_default_acl"
    remove_bucket_default_acl bucket_name: arguments.shift,
                              email:       arguments.shift
  when "print_file_acl"
    print_file_acl bucket_name: arguments.shift,
                   file_name:   arguments.shift
  when "print_file_acl_for_user"
    print_file_acl_for_user bucket_name: arguments.shift,
                            file_name:   arguments.shift,
                            email:       arguments.shift
  when "add_file_owner"
    add_file_owner bucket_name: arguments.shift,
                   file_name:   arguments.shift,
                   email:       arguments.shift
  when "remove_file_acl"
    remove_file_acl bucket_name: arguments.shift,
                    file_name:   arguments.shift,
                    email:       arguments.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby acls.rb [command] [arguments]

      Commands:
        print_bucket_acl <bucket>                  Print bucket Access Control List
        print_bucket_acl_for_user <bucket> <email> Print bucket ACL for an email
        add_bucket_owner <bucket> <email>          Add a new OWNER to a bucket
        remove_bucket_acl <bucket> <email>         Remove an entity from a bucket ACL
        add_bucket_default_owner <bucket> <email>  Add a default OWNER for a bucket
        remove_bucket_default_acl <bucket> <email> Remove an entity from default bucket ACL
        print_file_acl <bucket> <file>             Print file ACL
        print_file_acl_for_user <bucket> <file> <email> Print file ACL for an email
        add_file_owner <bucket> <file> <email>          Add an OWNER to a file
        remove_file_acl <bucket> <file> <email>         Remove an entity from a file ACL

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end

if $PROGRAM_NAME == __FILE__
  run_sample ARGV
end
