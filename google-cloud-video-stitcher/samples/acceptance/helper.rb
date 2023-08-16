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
require "net/http"

require "google/cloud/video/stitcher"

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

  let(:media_cdn_key_id) { "my-media-test-#{(Time.now.to_f * 1000).to_i}" }
  let(:media_cdn_key_name) { "projects/#{project_id}/locations/#{location_id}/cdnKeys/#{media_cdn_key_id}" }
  let(:cloud_cdn_key_id) { "my-cloud-test-#{(Time.now.to_f * 1000).to_i}" }
  let(:cloud_cdn_key_name) { "projects/#{project_id}/locations/#{location_id}/cdnKeys/#{cloud_cdn_key_id}" }
  let(:akamai_cdn_key_id) { "my-akamai-test-#{(Time.now.to_f * 1000).to_i}" }
  let(:akamai_cdn_key_name) { "projects/#{project_id}/locations/#{location_id}/cdnKeys/#{akamai_cdn_key_id}" }

  let(:hostname) { "cdn.example.com" }
  let(:updated_hostname) { "updated.example.com" }
  let(:key_name) { "my-key" }
  let(:media_cdn_private_key) { "MTIzNDU2Nzg5MDEyMzQ1Njc4Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNAAA" }
  let(:updated_media_cdn_private_key) { "ZZZzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIZZZ" }
  let(:cloud_cdn_private_key) { "VGhpcyBpcyBhIHRlc3Qgc3RyaW5nLg==" }
  let(:updated_cloud_cdn_private_key) { "VGhpcyBpcyBhbiB1cGRhdGVkIHRlc3Qgc3RyaW5nLg==" }
  let(:akamai_token_key) { "VGhpcyBpcyBhIHRlc3Qgc3RyaW5nLg==" }
  let(:updated_akamai_token_key) { "VGhpcyBpcyBhbiB1cGRhdGVkIHRlc3Qgc3RyaW5nLg==" }

  let(:vod_uri) { "https://storage.googleapis.com/cloud-samples-data/media/hls-vod/manifest.m3u8" }
  let(:vod_ad_tag_uri) { "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpreonly&ciu_szs=300x250%2C728x90&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&correlator=" }

  let(:live_config_id) { "my-live-config-test-#{(Time.now.to_f * 1000).to_i}" }
  let(:live_config_name) { "projects/#{project_id}/locations/#{location_id}/liveConfigs/#{live_config_id}" }

  let(:live_uri) { "https://storage.googleapis.com/cloud-samples-data/media/hls-live/manifest.m3u8" }
  let(:live_ad_tag_uri) { "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=" }

  attr_writer :slate_created
  attr_writer :akamai_cdn_key_created
  attr_writer :cloud_cdn_key_created
  attr_writer :media_cdn_key_created
  attr_writer :live_config_created

  before do
    @slate_created = false
    @akamai_cdn_key_created = false
    @cloud_cdn_key_created = false
    @media_cdn_key_created = false
    @live_config_created = false
    @session_id = ""
    @ad_tag_detail_id = ""
    @stitch_detail_id = ""
    # Remove old slates in the test project if they exist
    response = client.list_slates parent: location_path
    response.each do |slate|
      tmp = slate.name.to_s.split "-"
      create_time = tmp.last.to_i
      now = (Time.now.to_f * 1000).to_i # Milliseconds, preserves float value for precision
      next if create_time >= (now - DELETION_THRESHOLD_TIME_HOURS_IN_MILLISECONDS)
      begin
        operation = client.delete_slate name: slate.name.to_s
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError => e
        puts "Rescued: #{e.inspect}"
      end
    end

    # Remove old CDN keys in the test project if they exist
    response = client.list_cdn_keys parent: location_path
    response.each do |cdn_key|
      tmp = cdn_key.name.to_s.split "-"
      create_time = tmp.last.to_i
      now = (Time.now.to_f * 1000).to_i # Milliseconds, preserves float value for precision
      next if create_time >= (now - DELETION_THRESHOLD_TIME_HOURS_IN_MILLISECONDS)
      begin
        operation = client.delete_cdn_key name: cdn_key.name.to_s
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError => e
        puts "Rescued: #{e.inspect}"
      end
    end

    # Remove old live configs in the test project if they exist
    response = client.list_live_configs parent: location_path
    response.each do |live_config|
      tmp = live_config.name.to_s.split "-"
      create_time = tmp.last.to_i
      now = (Time.now.to_f * 1000).to_i # Milliseconds, preserves float value for precision
      next if create_time >= (now - DELETION_THRESHOLD_TIME_HOURS_IN_MILLISECONDS)
      begin
        operation = client.delete_live_config name: live_config.name.to_s
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError => e
        puts "Rescued: #{e.inspect}"
      end
    end
  end

  let :slate do
    operation = client.create_slate(
      parent: location_path,
      slate_id: slate_id,
      slate: slate_def(slate_uri)
    )
    operation.wait_until_done!
    operation.response
  end

  let :vod_session do
    client.create_vod_session(
      parent: location_path,
      vod_session: vod_session_def(vod_uri, vod_ad_tag_uri)
    )
  end

  let :live_config do
    operation = client.create_live_config(
      parent: location_path,
      live_config_id: live_config_id,
      live_config: live_config_def(live_uri, live_ad_tag_uri, slate_name)
    )
    operation.wait_until_done!
    operation.response
  end

  let :live_session do
    client.create_live_session(
      parent: location_path,
      live_session: live_session_def(live_config_name)
    )
  end

  let :akamai_cdn_key do
    operation = client.create_cdn_key(
      parent: location_path,
      cdn_key_id: akamai_cdn_key_id,
      cdn_key: akamai_cdn_def(akamai_cdn_key_name, hostname, akamai_token_key)
    )
    operation.wait_until_done!
    operation.response
  end

  let :cloud_cdn_key do
    operation = client.create_cdn_key(
      parent: location_path,
      cdn_key_id: cloud_cdn_key_id,
      cdn_key: cloud_cdn_def(cloud_cdn_key_name, hostname, key_name, cloud_cdn_private_key)
    )
    operation.wait_until_done!
    operation.response
  end

  let :media_cdn_key do
    operation = client.create_cdn_key(
      parent: location_path,
      cdn_key_id: media_cdn_key_id,
      cdn_key: media_cdn_def(media_cdn_key_name, hostname, key_name, media_cdn_private_key)
    )
    operation.wait_until_done!
    operation.response
  end

  after do
    if @slate_created
      begin
        operation = client.delete_slate name: slate_name
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
    end
    if @akamai_cdn_key_created
      begin
        operation = client.delete_cdn_key name: akamai_cdn_key_name
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
    end
    if @cloud_cdn_key_created
      begin
        operation = client.delete_cdn_key name: cloud_cdn_key_name
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
    end
    if @media_cdn_key_created
      begin
        operation = client.delete_cdn_key name: media_cdn_key_name
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
    end
    if @live_config_created
      begin
        operation = client.delete_live_config name: live_config_name
        operation.wait_until_done!
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
    end
  end

  ##
  # Definitions for Video Stitcher resources
  def akamai_cdn_def cdn_key_path, hostname, akamai_token_key
    {
      name: cdn_key_path,
      hostname: hostname,
      akamai_cdn_key: {
        token_key: akamai_token_key
      }
    }
  end

  def cloud_cdn_def cdn_key_path, hostname, key_name, private_key
    {
      name: cdn_key_path,
      hostname: hostname,
      google_cdn_key: {
        key_name: key_name,
        private_key: private_key
      }
    }
  end

  def live_config_def source_uri, ad_tag_uri, slate_name
    {
      source_uri: source_uri,
      ad_tag_uri: ad_tag_uri,
      ad_tracking: Google::Cloud::Video::Stitcher::V1::AdTracking::SERVER,
      stitching_policy: Google::Cloud::Video::Stitcher::V1::LiveConfig::StitchingPolicy::CUT_CURRENT,
      default_slate: slate_name
    }
  end

  def live_session_def live_config_name
    {
      live_config: live_config_name
    }
  end

  def media_cdn_def cdn_key_path, hostname, key_name, private_key
    {
      name: cdn_key_path,
      hostname: hostname,
      media_cdn_key: {
        key_name: key_name,
        private_key: private_key
      }
    }
  end

  def slate_def slate_uri
    {
      uri: slate_uri
    }
  end

  def vod_session_def source_uri, ad_tag_uri
    {
      source_uri: source_uri,
      ad_tag_uri: ad_tag_uri,
      ad_tracking: Google::Cloud::Video::Stitcher::V1::AdTracking::SERVER
    }
  end

  ##
  # Curl the play_uri first. The last line of the response will contain a
  # renditions location. Curl the live session name with the rendition
  # location appended.
  def get_renditions uri
    res = Net::HTTP.get_response URI(uri)
    unless res.is_a? Net::HTTPSuccess
      return
    end
    tmp = res.body.strip
    renditions = tmp.split("\n").last
    renditions_uri = uri.sub(/manifest\.m3u8.*/, renditions)
    Net::HTTP.get_response URI(renditions_uri)
  end

  register_spec_type(self) { |*descs| descs.include? :stitcher_snippet }
end
