# Copyright 2019 Google LLC
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
require "time"

describe Google::Cloud do
  focus
  it "does a thing" do
    require "google/cloud/pubsub/v1"

    time_obj = Time.parse "2019-03-13T15:40:43.729054800Z"
    time_obj.to_i.must_equal 1552491643
    time_obj.nsec.must_equal 729054800

    time_obj = Time.parse "2019-03-13T15:40:43.729054800Z"
    ts_obj = Google::Protobuf::Timestamp.new seconds: time_obj.to_i, nanos: time_obj.nsec
    msg = Google::Cloud::PubSub::V1::PubsubMessage.new publish_time: ts_obj

    msg.to_json.must_equal "{\"attributes\":{},\"publishTime\":\"2019-03-13T15:40:43.729054800Z\"}"

    decoded_msg = Google::Cloud::PubSub::V1::PubsubMessage.decode_json msg.to_json
    decoded_msg.publish_time.must_equal ts_obj
    decoded_msg.publish_time.seconds.must_equal time_obj.to_i
    decoded_msg.publish_time.nanos.must_equal time_obj.nsec
  end
end
