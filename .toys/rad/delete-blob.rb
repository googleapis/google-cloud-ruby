# frozen_string_literal: true

# Copyright 2021 Google LLC
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

desc "Delete cloud-rad blobs"

include :exec, e: true
include :terminal

required_arg :prefix
flag :yes

def run
  blobs = filter_blobs list_blobs
  puts "Found #{blobs.size} blobs to delete..."
  blobs.each { |blob| delete_blob blob if confirm_blob blob }
end

def list_blobs
  capture(["gsutil", "ls", "gs://docs-staging-v2"]).split("\n")
end

def filter_blobs blobs
  blobs.find_all do |url|
    url.start_with?("gs://docs-staging-v2/ruby-#{prefix}") ||
      url.start_with?("gs://docs-staging-v2/docfx-ruby-#{prefix}")
  end
end

def confirm_blob blob
  return true if yes
  puts "Delete #{blob}?", :bold
  result = ask("[Y]es / [N]o / [A]ll / [Q]uit ").downcase
  case result
  when "q"
    puts "aborted", :bold, :red
    exit 1
  when "a"
    set :yes, true
    true
  when "y"
    true
  when "n"
    false
  else
    puts "Bad response: #{result}"
    confirm_blob blob
  end
end

def delete_blob blob
  payload = <<~PAYLOAD
    full_job_name: "cloud-devrel/client-libraries/doc-pipeline/delete-blob"
    wait_until_started: false
    env_vars {
      key: "BLOB_TO_DELETE"
      value: "#{blob}"
    }
  PAYLOAD
  exec ["stubby", "call", "blade:kokoro-api", "KokoroApi.Build"], in: [:string, payload]
end
