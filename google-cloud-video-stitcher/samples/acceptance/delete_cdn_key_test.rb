# Copyright 2022 Google LLC
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

require_relative "helper"

describe "#delete_cdn_key", :stitcher_snippet do
  it "deletes the Akamai CDN key" do
    sample = SampleLoader.load "delete_cdn_key.rb"

    refute_nil akamai_cdn_key
    @akamai_cdn_key_created = true

    client.get_cdn_key name: akamai_cdn_key_name

    assert_output(/Deleted CDN key/) do
      sample.run project_id: project_id, location: location_id, cdn_key_id: akamai_cdn_key_id
    end

    assert_raises Google::Cloud::NotFoundError do
      client.get_cdn_key name: akamai_cdn_key_name
    end
  end

  it "deletes the Media CDN key" do
    sample = SampleLoader.load "delete_cdn_key.rb"

    refute_nil media_cdn_key
    @media_cdn_key_created = true

    client.get_cdn_key name: media_cdn_key_name

    assert_output(/Deleted CDN key/) do
      sample.run project_id: project_id, location: location_id, cdn_key_id: media_cdn_key_id
    end

    assert_raises Google::Cloud::NotFoundError do
      client.get_cdn_key name: media_cdn_key_name
    end
  end

  it "deletes the Cloud CDN key" do
    sample = SampleLoader.load "delete_cdn_key.rb"

    refute_nil cloud_cdn_key
    @cloud_cdn_key_created = true

    client.get_cdn_key name: cloud_cdn_key_name

    assert_output(/Deleted CDN key/) do
      sample.run project_id: project_id, location: location_id, cdn_key_id: cloud_cdn_key_id
    end

    assert_raises Google::Cloud::NotFoundError do
      client.get_cdn_key name: cloud_cdn_key_name
    end
  end
end
