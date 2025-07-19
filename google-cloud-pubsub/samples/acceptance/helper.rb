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

require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"
require "google/cloud/pubsub"
require "securerandom"
require "toys/utils/git_cache"
require Toys::Utils::GitCache.new.get "https://github.com/googleapis/ruby-common-tools.git",
                                      path: "lib/sample_loader.rb", update: 300

def random_topic_id
  "ruby-pubsub-samples-test-topic-#{SecureRandom.hex 4}"
end

def random_schema_id
  "ruby-pubsub-samples-test-schema-#{SecureRandom.hex 4}"
end

def random_subscription_id
  "ruby-pubsub-samples-test-subscription-#{SecureRandom.hex 4}"
end

def random_dataset_id
  "rubypubsubsamplestestdataset#{SecureRandom.hex 4}"
end

def random_table_id
  "ruby-pubsub-samples-test-table-#{SecureRandom.hex 4}"
end

def random_bucket_id
  "ruby-pubsub-samples-test-bucket-#{SecureRandom.hex 4}"
end

def create_table
  bigquery = Google::Cloud::Bigquery.new
  @dataset = bigquery.create_dataset random_dataset_id
  table_id = random_table_id

  @table = @dataset.create_table table_id do |updater|
    updater.string "data",  mode: :required
    updater.string "message_id",  mode: :required
    updater.string "attributes",  mode: :required
    updater.string "subscription_name",  mode: :required
    updater.timestamp "publish_time",  mode: :required
  end

  @table.id
end

def cleanup_bq table, dataset
  table.delete
  dataset.delete
end

# Pub/Sub calls may not respond immediately.
# Wrap expectations that may require multiple attempts with this method.
def expect_with_retry sample_name, attempts: 5
  @attempt_number ||= 0
  yield
  @attempt_number = nil
rescue Minitest::Assertion => e
  @attempt_number += 1
  puts "failed attempt #{@attempt_number} for #{sample_name}"
  sleep @attempt_number*@attempt_number
  retry if @attempt_number < attempts
  @attempt_number = nil
  raise e
end
