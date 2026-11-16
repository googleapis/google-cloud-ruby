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


if ENV["CI"] || ENV["KOKORO_JOB_NAME"]
  # Load JUnit XML formatter from googleapis/ruby-common-tools to write tmp/reports/sponge_log.xml for Kokoro/TestGrid.
  begin
    require "gapic/minitest_junit_preloader"
  rescue LoadError
    # Do nothing if preloader is not available (e.g. local runs)
  end
end

require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"
require "google/cloud/pubsub"
require "securerandom"
require "toys/utils/git_cache"
require Toys::Utils::GitCache.new.get "https://github.com/googleapis/ruby-common-tools.git",
                                      path: "lib/sample_loader.rb", update: 300

# Every topic ID shares this run's prefix, which embeds the run's start time, so Minitest.after_run
# (below) can delete topics left behind by failed tests and by earlier runs that were killed or whose
# cleanup hit an error.
$topic_id_prefix = "ruby-pubsub-samples-test-topic-#{Time.now.utc.strftime '%Y-%m-%dt%H-%M-%Sz'}-" \
                   "#{SecureRandom.hex 2}"

def random_topic_id
  "#{$topic_id_prefix}-#{SecureRandom.hex 4}"
end

def sample_topic_created_before? topic_name, time
  pattern = %r{/topics/ruby-pubsub-samples-test-topic-(\d{4})-(\d{2})-(\d{2})t(\d{2})-(\d{2})-(\d{2})z-}
  match = pattern.match topic_name
  !match.nil? && Time.utc(*match.captures.map(&:to_i)) < time
end

Minitest.after_run do
  pubsub = Google::Cloud::PubSub.new
  stale_before = Time.now.utc - (24 * 60 * 60)
  pubsub.topic_admin.list_topics(project: pubsub.project_path).each do |topic|
    next unless topic.name.include?($topic_id_prefix) || sample_topic_created_before?(topic.name, stale_before)
    pubsub.topic_admin.delete_topic topic: topic.name
  end
rescue StandardError => e
  puts "Error while cleaning up sample topics: #{e}"
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
