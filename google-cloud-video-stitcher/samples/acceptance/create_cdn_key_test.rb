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

describe "#create_cdn_key", :stitcher_snippet do
  it "creates a Media CDN key" do
    sample = SampleLoader.load "create_cdn_key.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location: location_id,
                 cdn_key_id: media_cdn_key_id, hostname: hostname,
                 key_name: key_name, private_key: media_cdn_private_key,
                 is_media_cdn: true
    end
    @media_cdn_key_created = true

    cdn_key_id_regex = Regexp.escape media_cdn_key_id
    assert_match %r{CDN key: projects/\S+/locations/#{location_id}/cdnKeys/#{cdn_key_id_regex}}, out
  end

  it "creates a Cloud CDN key" do
    sample = SampleLoader.load "create_cdn_key.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location: location_id,
                 cdn_key_id: cloud_cdn_key_id, hostname: hostname,
                 key_name: key_name, private_key: cloud_cdn_private_key,
                 is_media_cdn: false
    end
    @cloud_cdn_key_created = true

    cdn_key_id_regex = Regexp.escape cloud_cdn_key_id
    assert_match %r{CDN key: projects/\S+/locations/#{location_id}/cdnKeys/#{cdn_key_id_regex}}, out
  end
end
