# Copyright 2017 Google LLC
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

describe Google::Cloud::Storage::Bucket, :notification, :storage do
  let(:project_email) { "serviceAccount:#{storage.service_account_email}" }
  let(:bucket_name) { $bucket_names.first }
  let :bucket do
    storage.bucket(bucket_name) ||
    safe_gcs_execute { storage.create_bucket(bucket_name) }
  end
  let(:topic_name) { "#{prefix}_bucket_notification_topic" }
  let(:topic_name_full_path) { "//pubsub.googleapis.com/projects/#{storage.project}/topics/#{topic_name}" }
  let(:custom_attrs) { { "foo" => "bar" } }
  let(:event_types) { ["OBJECT_FINALIZE"] }
  let(:filename_prefix) { "my-prefix" }
  let(:payload) { "NONE" }

  it "creates a Pub/Sub subscription notification" do
    begin
      topic = Google::Cloud.pubsub.create_topic topic_name
      topic.policy do |p|
        p.add "roles/pubsub.publisher", project_email
      end

      notification = bucket.create_notification topic.name, custom_attrs: custom_attrs,
                                                            event_types: event_types,
                                                            prefix: filename_prefix,
                                                            payload: payload

      notification.wont_be_nil
      notification.id.wont_be_nil
      notification.custom_attrs.must_equal custom_attrs
      notification.event_types.must_equal event_types
      notification.prefix.must_equal filename_prefix
      notification.payload.must_equal payload
      notification.topic.must_equal topic_name_full_path

      bucket.notifications.wont_be :empty?

      fresh_notification = bucket.notification notification.id
      fresh_notification.wont_be_nil
      fresh_notification.id.wont_be_nil
      fresh_notification.custom_attrs.must_equal custom_attrs
      fresh_notification.event_types.must_equal event_types
      fresh_notification.prefix.must_equal filename_prefix
      fresh_notification.payload.must_equal payload
      fresh_notification.topic.must_equal topic_name_full_path


      fresh_notification.delete
    ensure
      bucket.notifications.map(&:delete)
      post_topic = Google::Cloud.pubsub.topic "#{prefix}_bucket_notification_topic"
      post_topic.delete if post_topic # Assume no subscriptions to clean up.
    end
  end
end
