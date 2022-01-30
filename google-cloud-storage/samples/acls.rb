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
