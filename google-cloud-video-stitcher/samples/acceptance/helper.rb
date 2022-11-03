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

require "google/cloud/video/stitcher"

require_relative "slate_definition"
require_relative "../../../.toys/.lib/sample_loader"


DELETION_THRESHOLD_TIME_HOURS_IN_MILLISECONDS = 10_800_000

class StitcherSnippetSpec < Minitest::Spec
  let(:credentials) { ENV["GOOGLE_CLOUD_CREDENTIALS"] || raise("missing GOOGLE_CLOUD_CREDENTIALS") }
  let(:client) { Google::Cloud::Video::Stitcher.video_stitcher_service }
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }
  let(:location_id) { "us-central1" }
  let(:location_path) { client.location_path project: project_id, location: location_id }
  let(:slate_id) { "my-slate-test-#{(Time.now.to_f * 1000).to_i}" }
  let(:slate_name) { "projects/#{project_id}/locations/#{location_id}/slates/#{slate_id}" }
  let(:slate_uri) { "https://storage.googleapis.com/cloud-samples-data/media/ForBiggerEscapes.mp4" }
  let(:updated_slate_uri) { "https://storage.googleapis.com/cloud-samples-data/media/ForBiggerJoyrides.mp4" }

  attr_writer :slate_created

  before do
    @slate_created = false
    # Remove old slates in the test project if they exist
    response = client.list_slates parent: location_path
    response.each do |slate|
      tmp = slate.name.to_s.split "-"
      create_time = tmp.last.to_i
      now = (Time.now.to_f * 1000).to_i # Milliseconds, preserves float value for precision
      next if create_time >= (now - DELETION_THRESHOLD_TIME_HOURS_IN_MILLISECONDS)
      begin
        client.delete_slate name: slate.name.to_s
      rescue Google::Cloud::NotFoundError => e
        puts "Rescued: #{e.inspect}"
      end
    end
  end

  let :slate do
    client.create_slate(
      parent: location_path,
      slate_id: slate_id,
      slate: slate_def(slate_uri)
    )
  end

  after do
    if @slate_created
      begin
        client.delete_slate name: slate_name
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
    end
  end

  register_spec_type(self) { |*descs| descs.include? :stitcher_snippet }
end
