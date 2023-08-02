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
require_relative "channel_definition"
require_relative "input_definition"
require_relative "event_definition"
require_relative "asset_definition"

DELETION_THRESHOLD_TIME_HOURS_IN_MILLISECONDS = 10_800_000

class LiveStreamSnippetSpec < Minitest::Spec
  let(:client) { Google::Cloud::Video::LiveStream.livestream_service }

  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }
  let(:location_id) { "us-central1" }
  let(:location_path) { client.location_path project: project_id, location: location_id }

  let(:input_id) { "my-input-test-#{(Time.now.to_f * 1000).to_i}" }
  let(:input_name) { "projects/#{project_id}/locations/#{location_id}/inputs/#{input_id}" }
  let(:input_path) { client.input_path project: project_id, location: location, input: input_id }

  let(:update_input_id) { "my-update-input-test-#{(Time.now.to_f * 1000).to_i}" }
  let(:update_input_name) { "projects/#{project_id}/locations/#{location_id}/inputs/#{update_input_id}" }
  let(:update_input_path) { client.input_path project: project_id, location: location, input: update_input_id }

  let(:channel_id) { "my-channel-#{(Time.now.to_f * 1000).to_i}" }
  let(:channel_name) { "projects/#{project_id}/locations/#{location_id}/channels/#{channel_id}" }
  let(:output_uri) { "gs://my-bucket/my-output-folder/" }

  let(:event_id) { "my-event" }
  let(:event_name) { "#{channel_name}/events/#{event_id}" }

  let(:asset_id) { "my-asset-test-#{(Time.now.to_f * 1000).to_i}" }
  let(:asset_name) { "projects/#{project_id}/locations/#{location_id}/assets/#{asset_id}" }
  let(:asset_uri) { "gs://cloud-samples-data/media/ForBiggerEscapes.mp4" }

  let(:pool_id) { "default" } # only 1 pool supported per location
  let(:pool_name) { "projects/#{project_id}/locations/#{location_id}/pools/#{pool_id}" }
  let(:update_pool_peer_network) { "projects/#{project_id}/global/networks/default" }

  attr_writer :channel_created_started
  attr_writer :channel_created_stopped
  attr_writer :input_created
  attr_writer :update_input_created
  attr_writer :event_created
  attr_writer :asset_created

  before do
    @channel_created_started = false
    @channel_created_stopped = false
    @input_created = false
    @update_input_created = false
    @event_created = false
    @asset_created = false
    # Remove old channels and inputs in the test project if they exist
    response = client.list_channels parent: location_path
    response.each do |channel|
      tmp = channel.name.to_s.split "-"
      create_time = tmp.last.to_i
      now = (Time.now.to_f * 1000).to_i # Milliseconds, preserves float value for precision
      next if create_time >= (now - DELETION_THRESHOLD_TIME_HOURS_IN_MILLISECONDS)
      begin
        event_name = "#{channel.name}/events/#{event_id}"
        client.delete_event name: event_name
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
      begin
        operation = client.stop_channel name: channel.name.to_s
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
      begin
        operation = client.delete_channel name: channel.name.to_s
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError => e
        puts "Rescued: #{e.inspect}"
      end
    end

    response = client.list_inputs parent: location_path
    response.each do |input|
      tmp = input.name.to_s.split "-"
      create_time = tmp.last.to_i
      now = (Time.now.to_f * 1000).to_i
      next if create_time >= (now - DELETION_THRESHOLD_TIME_HOURS_IN_MILLISECONDS)
      begin
        operation = client.delete_input name: input.name.to_s
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
    end

    response = client.list_assets parent: location_path
    response.each do |asset|
      tmp = asset.name.to_s.split "-"
      create_time = tmp.last.to_i
      now = (Time.now.to_f * 1000).to_i
      next if create_time >= (now - DELETION_THRESHOLD_TIME_HOURS_IN_MILLISECONDS)
      begin
        operation = client.delete_asset name: asset.name.to_s
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
    end
  end

  let :input do
    operation = client.create_input(
      parent: location_path,
      input:  input_def,
      input_id: input_id
    )
    operation.wait_until_done!
    operation.response
  end

  let :update_input do
    operation = client.create_input(
      parent: location_path,
      input:  input_def,
      input_id: update_input_id
    )
    operation.wait_until_done!
    operation.response
  end

  let :channel do
    input_path = client.input_path project: project_id, location: location_id, input: input_id
    operation = client.create_channel parent: location_path, channel: channel_def(input_path, output_uri), channel_id: channel_id
    operation.wait_until_done!
    operation.response
  end

  let :started_channel do
    input_path = client.input_path project: project_id, location: location_id, input: input_id
    operation = client.create_channel parent: location_path, channel: channel_def(input_path, output_uri), channel_id: channel_id
    operation.wait_until_done!
    start = client.start_channel name: channel_name
    start.wait_until_done!
    operation.response
  end

  let :started_channel_with_event do
    input_path = client.input_path project: project_id, location: location_id, input: input_id
    operation = client.create_channel parent: location_path, channel: channel_def(input_path, output_uri), channel_id: channel_id
    operation.wait_until_done!
    start = client.start_channel name: channel_name
    start.wait_until_done!
    client.create_event parent: channel_name, event: event_def, event_id: event_id
    operation.response
  end

  let :asset do
    operation = client.create_asset(
      parent: location_path,
      asset:  asset_def(asset_uri),
      asset_id: asset_id
    )
    operation.wait_until_done!
    operation.response
  end

  after do
    if @event_created
      begin
        client.delete_event name: event_name
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
    end
    if @channel_created_started
      begin
        operation = client.stop_channel name: channel_name
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
    end
    if @channel_created_started || @channel_created_stopped
      begin
        operation = client.delete_channel name: channel_name
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError => e
        puts "Rescued: #{e.inspect}"
      end
    end
    if @update_input_created
      begin
        operation = client.delete_input name: update_input_name
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError => e
        puts "Rescued: #{e.inspect}"
      end
    end
    if @input_created
      begin
        operation = client.delete_input name: input_name
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError => e
        puts "Rescued: #{e.inspect}"
      end
    end
    if @asset_created
      begin
        operation = client.delete_asset name: asset_name
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError => e
        puts "Rescued: #{e.inspect}"
      end
    end
  end

  register_spec_type(self) { |*descs| descs.include? :live_stream_snippet }
end
