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

require "helper"

describe Google::Cloud::Storage::Bucket, :notification, :mock_storage do
  let(:bucket_name) { "found-bucket" }
  let(:bucket_hash) { random_bucket_hash bucket_name }
  let(:bucket_json) { bucket_hash.to_json }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }
  let(:bucket_user_project) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service, user_project: true }

  let(:topic_name) { "my-topic" }
  let(:topic_name_full_path) { "//pubsub.googleapis.com/projects/#{storage.project}/topics/#{topic_name}" }
  let(:custom_attrs) { { "foo" => "bar" } }
  let(:notification_id) { "1" }
  let(:event_types) { ["OBJECT_FINALIZE"] }
  let(:filename_prefix) { "my-prefix" }
  let(:payload) { "NONE" }

  it "creates a notification" do
    mock = Minitest::Mock.new
    mock.expect :insert_notification, random_notification_gapi(id: notification_id, topic: topic_name_full_path),
                [bucket.name, random_notification_gapi(id: nil, topic: topic_name_full_path), { user_project: nil }]

    bucket.service.mocked_service = mock

    notification = bucket.create_notification topic_name, custom_attrs: custom_attrs,
                                                          event_types: event_types,
                                                          prefix: filename_prefix,
                                                          payload: payload

    mock.verify

    notification.wont_be_nil
    notification.id.must_equal notification_id
    notification.custom_attrs.must_equal custom_attrs
    notification.event_types.must_equal event_types
    notification.prefix.must_equal filename_prefix
    notification.payload.must_equal payload
    notification.topic.must_equal topic_name_full_path
    notification.user_project.must_be :nil?
  end

  it "creates a notification with a boolean payload" do
    mock = Minitest::Mock.new
    mock.expect :insert_notification, random_notification_gapi(id: notification_id, payload: "JSON_API_V1"),
                [bucket.name, random_notification_gapi(id: nil, payload: "JSON_API_V1"), { user_project: nil }]

    bucket.service.mocked_service = mock

    notification = bucket.create_notification topic_name, custom_attrs: custom_attrs,
                                                          event_types: event_types,
                                                          prefix: filename_prefix,
                                                          payload: true

    mock.verify

    notification.payload.must_equal "JSON_API_V1"
  end

  it "creates a notification with a array of symbols event type" do
    mock = Minitest::Mock.new
    mock.expect :insert_notification, random_notification_gapi(id: notification_id),
                [bucket.name, random_notification_gapi(id: nil), { user_project: nil }]

    bucket.service.mocked_service = mock

    notification = bucket.create_notification topic_name, custom_attrs: custom_attrs,
                                                          event_types: [:finalize],
                                                          prefix: filename_prefix,
                                                          payload: payload

    mock.verify

    notification.event_types.must_equal event_types
  end

  it "creates a notification with a single symbol event type" do
    mock = Minitest::Mock.new
    mock.expect :insert_notification, random_notification_gapi(id: notification_id),
                [bucket.name, random_notification_gapi(id: nil), { user_project: nil }]

    bucket.service.mocked_service = mock

    notification = bucket.create_notification topic_name, custom_attrs: custom_attrs,
                                                          event_types: :finalize,
                                                          prefix: filename_prefix,
                                                          payload: payload

    mock.verify

    notification.event_types.must_equal event_types
  end

  it "creates a notification with new_notification alias" do
    mock = Minitest::Mock.new
    mock.expect :insert_notification, minimal_notification_gapi,
                [bucket.name, minimal_notification_gapi, { user_project: nil }]

    bucket.service.mocked_service = mock

    bucket.new_notification topic_name

    mock.verify
  end

  it "creates a notification with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :insert_notification, minimal_notification_gapi,
                [bucket_user_project.name, minimal_notification_gapi, { user_project: "test" }]

    bucket_user_project.service.mocked_service = mock

    notification = bucket_user_project.create_notification topic_name

    mock.verify

    notification.user_project.must_equal true
  end

  it "lists notifications" do
    num_notifications = 3

    mock = Minitest::Mock.new
    mock.expect :list_notifications, list_notifications_gapi(num_notifications),
                [bucket.name, user_project: nil]

    bucket.service.mocked_service = mock

    notifications = bucket.notifications

    mock.verify

    notifications.size.must_equal num_notifications
    notifications.each do |notification|
      notification.must_be_kind_of Google::Cloud::Storage::Notification
      notification.user_project.must_be :nil?
    end
  end

  it "lists notifications with find_notifications alias" do
    mock = Minitest::Mock.new
    mock.expect :list_notifications, list_notifications_gapi, [bucket.name, { user_project: nil }]

    bucket.service.mocked_service = mock

    bucket.find_notifications

    mock.verify
  end

  it "lists notifications with user_project set to true" do
    num_notifications = 3

    mock = Minitest::Mock.new
    mock.expect :list_notifications, list_notifications_gapi(num_notifications),
                [bucket_user_project.name, { user_project: "test" }]

    bucket_user_project.service.mocked_service = mock

    notifications = bucket_user_project.notifications

    mock.verify

    notifications.size.must_equal num_notifications
    notifications.each do |notification|
      notification.must_be_kind_of Google::Cloud::Storage::Notification
      notification.user_project.must_equal true
    end
  end

  it "finds a notification" do
    notification_id = "1"

    mock = Minitest::Mock.new
    mock.expect :get_notification, random_notification_gapi(id: notification_id),
      [bucket.name, notification_id, { user_project: nil }]

    bucket.service.mocked_service = mock

    notification = bucket.notification notification_id

    mock.verify

    notification.id.must_equal notification_id
    notification.custom_attrs.must_equal custom_attrs
    notification.event_types.must_equal event_types
    notification.prefix.must_equal filename_prefix
    notification.payload.must_equal payload
    notification.topic.must_equal topic_name_full_path
    notification.user_project.must_be :nil?
  end

  it "finds a notification with find_notification alias" do
    notification_id = "1"

    mock = Minitest::Mock.new
    mock.expect :get_notification, random_notification_gapi(id: notification_id),
      [bucket.name, notification_id, { user_project: nil }]

    bucket.service.mocked_service = mock

    bucket.find_notification notification_id

    mock.verify
  end

  it "finds a notification with user_project set to true" do
    notification_id = "1"

    mock = Minitest::Mock.new
    mock.expect :get_notification, random_notification_gapi(id: notification_id),
      [bucket_user_project.name, notification_id, { user_project: "test" }]

    bucket_user_project.service.mocked_service = mock

    notification = bucket_user_project.notification notification_id

    mock.verify

    notification.user_project.must_equal true
  end

  def minimal_notification_gapi
    Google::Apis::StorageV1::Notification.new(
      payload_format: "JSON_API_V1",
      topic: "//pubsub.googleapis.com/projects/test/topics/my-topic"
    )
  end

  def list_notifications_gapi count = 2
    notifications = count.times.map { minimal_notification_gapi }
    Google::Apis::StorageV1::Notifications.new kind: "storage#notifications", items: notifications
  end
end
