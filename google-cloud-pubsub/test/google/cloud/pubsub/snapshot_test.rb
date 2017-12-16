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

require "helper"

describe Google::Cloud::Pubsub::Snapshot, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:snapshot_name) { "snapshot-name-goes-here" }
  let(:snapshot_grpc) { Google::Pubsub::V1::Snapshot.decode_json(snapshot_json(topic_name, snapshot_name)) }
  let(:snapshot) { Google::Cloud::Pubsub::Snapshot.from_grpc snapshot_grpc, pubsub.service }

  it "knows its name" do
    snapshot.name.must_equal snapshot_path(snapshot_name)
  end

  it "knows its topic" do
    snapshot.topic.must_be_kind_of Google::Cloud::Pubsub::Topic
    snapshot.topic.must_be :lazy?
    snapshot.topic.name.must_equal topic_path(topic_name)
  end

  it "knows its expiration_time" do
    snapshot.expiration_time.must_be_kind_of ::Time
  end

  it "can delete itself" do
    del_res = nil
    mock = Minitest::Mock.new
    mock.expect :delete_snapshot, del_res, [snapshot_path(snapshot_name), options: default_options]
    pubsub.service.mocked_subscriber = mock

    snapshot.delete

    mock.verify
  end
end
