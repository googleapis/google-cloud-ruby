# Copyright 2020 Google, LLC
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

require "google/cloud/errors"
require "google/cloud/storage"
require "minitest/autorun"
require "securerandom"

def delete_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new

  retry_resource_exhaustion do
    bucket = storage_client.bucket bucket_name
    return unless bucket

    bucket.files.each(&:delete)
    bucket.delete
  end
end

def create_file_and_upload bucket, file_name, text_content
  local_file = Tempfile.new "language-sample-test-file"
  File.write local_file.path, text_content
  bucket.create_file local_file.path, file_name
ensure
  local_file.close
  local_file.unlink
end

def retry_resource_exhaustion
  5.times do
    begin
      return yield
    rescue Google::Cloud::ResourceExhaustedError => e
      puts "\n#{e} Gonna try again"
      sleep rand(1..3)
    rescue StandardError => e
      puts "\n#{e}"
      raise e
    end
  end
  raise Google::Cloud::ResourceExhaustedError, "Maybe take a break from creating and deleting buckets for a bit"
end

def positive_text
  "Happy love it. I am glad, pleased, and delighted."
end

def negative_text
  "I hate it. I am mad, annoyed, and irritated."
end

def entities_text
  "Alice wrote a book. Bob likes the book."
end

def syntax_text
  "I am Fox Tall. The porcupine stole my pickup truck."
end

def entities_sentiment_text
  "Plums are great. Prunes are bad."
end

def classification_text
  "Google, headquartered in Mountain View, unveiled the new Android phone " \
  "at the Consumer Electronic Show Sundar Pichai said in his keynote that" \
  "users love their new Android phones."
end

def bucket_name
  "ruby_language_sample_fixtures"
end

def create_fixtures_bucket
  storage_client = Google::Cloud::Storage.new
  bucket = retry_resource_exhaustion do
    storage_client.create_bucket bucket_name
  end
  create_file_and_upload bucket, "positive.txt", positive_text
  create_file_and_upload bucket, "negative.txt", negative_text
  create_file_and_upload bucket, "entities.txt", entities_text
  create_file_and_upload bucket, "syntax.txt", syntax_text
  create_file_and_upload bucket, "classify.txt", classification_text
  create_file_and_upload bucket, "entity_sentiment.txt", entities_sentiment_text
end
