# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0  the "License";
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
require "google/cloud/errors"
require "grpc/errors"
require "google/gax/errors"
require "google/rpc/status_pb"

describe Google::Cloud::Error, :wrapped_rest_error do
  # This test confirms that a whole array of any-wrapped detail messages
  # containing various messages from the `google/rpc/error_details.proto`
  # will be correctly deserialized and surfaced to the end-user
  # in the `status_details` field when wrapping the rest error
  it "contains multiple detail messages" do
    error = wrapped_rest_error gapic_rest_error(status_code: 404, extended_details: true)

    di = error.status_details.find {|entry| entry.is_a?(Google::Rpc::DebugInfo)} 
    _(di).must_equal debug_info

    lm = error.status_details.find {|entry| entry.is_a?(Google::Rpc::LocalizedMessage)} 
    _(lm).must_equal localized_message

    help_detail = error.status_details.find {|entry| entry.is_a?(Google::Rpc::Help)} 
  end
end
