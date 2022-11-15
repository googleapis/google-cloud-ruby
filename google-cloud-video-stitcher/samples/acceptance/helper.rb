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

require_relative "akamai_cdn_key_definition"
require_relative "cloud_cdn_key_definition"
require_relative "live_session_definition"
require_relative "slate_definition"
require_relative "vod_session_definition"
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

  let(:gcdn_cdn_key_id) { "my-gcdn-test-#{(Time.now.to_f * 1000).to_i}" }
  let(:gcdn_cdn_key_name) { "projects/#{project_id}/locations/#{location_id}/cdnKeys/#{gcdn_cdn_key_id}" }
  let(:akamai_cdn_key_id) { "my-akamai-test-#{(Time.now.to_f * 1000).to_i}" }
  let(:akamai_cdn_key_name) { "projects/#{project_id}/locations/#{location_id}/cdnKeys/#{akamai_cdn_key_id}" }

  let(:hostname) { "cdn.example.com" }
  let(:updated_hostname) { "updated.example.com" }
  let(:gcdn_key_name) { "gcdn-key" }
  let(:updated_gcdn_key_name) { "updated-gcdn-key" }
  let(:gcdn_private_key) { "VGhpcyBpcyBhIHRlc3Qgc3RyaW5nLg==" }
  let(:updated_gcdn_private_key) { "VGhpcyBpcyBhbiB1cGRhdGVkIHRlc3Qgc3RyaW5nLg==" }
  let(:akamai_token_key) { "VGhpcyBpcyBhIHRlc3Qgc3RyaW5nLg==" }
  let(:updated_akamai_token_key) { "VGhpcyBpcyBhbiB1cGRhdGVkIHRlc3Qgc3RyaW5nLg==" }

  let(:vod_uri) { "https://storage.googleapis.com/cloud-samples-data/media/hls-vod/manifest.m3u8" }
  let(:vod_ad_tag_uri) { "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpreonly&ciu_szs=300x250%2C728x90&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&correlator=" }

  let(:live_uri) { "https://storage.googleapis.com/cloud-samples-data/media/hls-live/manifest.m3u8" }
  let(:live_ad_tag_uri) { "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=" }

  attr_writer :slate_created
  attr_writer :akamai_cdn_key_created
  attr_writer :cloud_cdn_key_created

  before do
    @slate_created = false
    @akamai_cdn_key_created = false
    @cloud_cdn_key_created = false
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
        client.delete_slate name: slate.name.to_s
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
        client.delete_cdn_key name: cdn_key.name.to_s
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

  let :vod_session do
    client.create_vod_session(
      parent: location_path,
      vod_session: vod_session_def(vod_uri, vod_ad_tag_uri)
    )
  end

  let :live_session do
    client.create_live_session(
      parent: location_path,
      live_session: live_session_def(live_uri, live_ad_tag_uri, slate_id)
    )
  end

  let :akamai_cdn_key do
    client.create_cdn_key(
      parent: location_path,
      cdn_key_id: akamai_cdn_key_id,
      cdn_key: akamai_cdn_def(akamai_cdn_key_name, hostname, akamai_token_key)
    )
  end

  let :cloud_cdn_key do
    client.create_cdn_key(
      parent: location_path,
      cdn_key_id: gcdn_cdn_key_id,
      cdn_key: cloud_cdn_def(gcdn_cdn_key_name, hostname, gcdn_key_name, gcdn_private_key)
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
    if @akamai_cdn_key_created
      begin
        client.delete_cdn_key name: akamai_cdn_key_name
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
    end
    if @cloud_cdn_key_created
      begin
        client.delete_cdn_key name: gcdn_cdn_key_name
      rescue Google::Cloud::NotFoundError, Google::Cloud::FailedPreconditionError => e
        puts "Rescued: #{e.inspect}"
      end
    end
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
