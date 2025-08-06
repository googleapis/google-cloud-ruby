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
    pubsub = Google::Cloud::PubSub.new
    topic_admin = pubsub.topic_admin
    topic = nil
    begin
      topic = topic_admin.create_topic name: pubsub.topic_path(topic_name)

      policy = {
        bindings: [
          {
            role: "roles/pubsub.publisher",
            members: [project_email]
          }
        ]
      }
      pubsub.iam.set_iam_policy resource: topic.name, policy: policy

      notification = bucket.create_notification topic.name, custom_attrs: custom_attrs,
                                                            event_types: event_types,
                                                            prefix: filename_prefix,
                                                            payload: payload

      _(notification).wont_be_nil
      _(notification.id).wont_be_nil
      _(notification.custom_attrs).must_equal custom_attrs
      _(notification.event_types).must_equal event_types
      _(notification.prefix).must_equal filename_prefix
      _(notification.payload).must_equal payload
      _(notification.topic).must_equal topic_name_full_path

      _(bucket.notifications).wont_be :empty?

      fresh_notification = bucket.notification notification.id
      _(fresh_notification).wont_be_nil
      _(fresh_notification.id).wont_be_nil
      _(fresh_notification.custom_attrs).must_equal custom_attrs
      _(fresh_notification.event_types).must_equal event_types
      _(fresh_notification.prefix).must_equal filename_prefix
      _(fresh_notification.payload).must_equal payload
      _(fresh_notification.topic).must_equal topic_name_full_path


      fresh_notification.delete
    ensure
      bucket.notifications.map(&:delete)
      topic_admin.delete_topic topic: topic.name if topic
    end
  end
end
