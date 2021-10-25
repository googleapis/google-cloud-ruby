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

describe Google::Cloud::Storage::Notification, :mock_storage do
  let(:bucket_name) { "my-bucket" }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name: bucket_name).to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }

  let(:topic_name) { "my-topic" }
  let(:notification_gapi) { random_notification_gapi }
  let(:notification) { Google::Cloud::Storage::Notification.from_gapi bucket_name, notification_gapi, storage.service }
  let(:notification_user_project) { Google::Cloud::Storage::Notification.from_gapi  bucket_name, notification_gapi, storage.service, user_project: true }


  it "knows its attributes" do
    _(notification.id).must_equal "1"
    _(notification.custom_attrs).must_equal({ "foo" => "bar" })
    _(notification.event_types).must_equal ["OBJECT_FINALIZE"]
    _(notification.prefix).must_equal "my-prefix"
    _(notification.payload).must_equal "NONE"
    _(notification.topic).must_equal "//pubsub.googleapis.com/projects/#{project}/topics/#{topic_name}"
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_notification, nil, [bucket.name, notification.id, { user_project: nil }]

    notification.service.mocked_service = mock

    notification.delete

    mock.verify
  end

  it "can delete itself with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :delete_notification, nil, [bucket.name, notification_user_project.id, { user_project: "test" }]

    notification_user_project.service.mocked_service = mock

    notification_user_project.delete

    mock.verify
  end
end
