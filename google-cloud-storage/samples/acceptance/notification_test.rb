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

require "google/cloud/pubsub"
require_relative "helper"
require_relative "../storage_print_pubsub_bucket_notification"
require_relative "../storage_list_bucket_notifications"
require_relative "../storage_create_bucket_notifications"
require_relative "../storage_delete_bucket_notification"

describe "Buckets Notification Snippets" do
  let(:storage_client) { Google::Cloud::Storage.new }
  let(:bucket) { @bucket }
  let(:topic) { @topic }

  before :all do
    @bucket = create_bucket_helper random_bucket_name
    pubsub = Google::Cloud::Pubsub.new
    @topic = pubsub.create_topic random_topic_name
    topic.policy do |p|
      p.add "roles/pubsub.publisher",
            "serviceAccount:#{storage_client.service_account_email}"
    end
  end

  after :all do
    delete_bucket_helper @bucket.name
    topic.delete
  end

  describe "Notification Lifecycle" do
    it "Create Notification" do
      actual_output, _err = capture_io do
        create_bucket_notifications bucket_name: bucket.name,
                                    topic_name: topic.name
      end

      notification = bucket.notifications.first
      expected_output = "Successfully created notification with ID #{notification.id} for bucket #{bucket.name}\n"

      assert_equal expected_output, actual_output

      bucket.notifications.first.delete
    end

    it "Delete Notification" do
      notification = bucket.create_notification topic.name

      assert_output "Successfully deleted notification with ID #{notification.id} for bucket #{bucket.name}\n" do
        delete_bucket_notification bucket_name: bucket.name,
                                   notification_id: notification.id
      end

      assert_empty bucket.notifications
    end
  end

  describe "Get notification details" do
    let(:notification) { @notification }

    before :all do
      @notification = bucket.create_notification topic.name
    end

    after :all do
      notification.delete
    end

    it "Print Notification" do
      expected_output = <<~OUTPUT
        Notification ID: #{notification.id}
        Topic Name: #{notification.topic}
        Event Types: #{notification.event_types}
        Kind of Notification: #{notification.kind}
        Custom Attributes: #{notification.custom_attrs}
        Payload Format: #{notification.payload}
        Blob Name Prefix: #{notification.prefix}
        Self Link: #{notification.api_url}
      OUTPUT

      assert_output expected_output do
        print_pubsub_bucket_notification bucket_name: bucket.name,
                                         notification_id: notification.id
      end
    end

    it "List Notifications for a bucket" do
      expected_output = "Notification ID: #{notification.id}\n"
      assert_output expected_output do
        list_bucket_notifications bucket_name: bucket.name
      end
    end
  end
end
