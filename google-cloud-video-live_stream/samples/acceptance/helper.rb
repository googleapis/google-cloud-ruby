# Copyright 2022 Google LLC
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

require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"

require "google/cloud/video/live_stream"

require_relative "../../../.toys/.lib/sample_loader"

class LiveStreamSnippetSpec < Minitest::Spec
  let(:client) { Google::Cloud::Video::LiveStream.livestream_service }

  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }

  let(:location_id) { "us-central1" }
  let(:input_id) { "my-input-test-#{(Time.now.to_f * 1000).to_i}" }
  let(:input_name) { "projects/#{project_id}/locations/#{location_id}/inputs/#{input_id}" }
  let(:input_location_path) { client.location_path project: project_id, location: location_id }

  let :input do
    operation = client.create_input(
      parent: input_location_path,
      input:  {
        type: Google::Cloud::Video::LiveStream::V1::Input::Type::RTMP_PUSH
      },
      input_id: input_id
    )
    operation.wait_until_done!
    operation.response
  end

  after do
    client.delete_input name: input_name
  rescue Google::Cloud::NotFoundError
    # Do nothing
  end

  register_spec_type(self) { |*descs| descs.include? :live_stream_snippet }
end
