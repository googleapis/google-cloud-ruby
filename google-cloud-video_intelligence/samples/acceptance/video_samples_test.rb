# Copyright 2020 Google, Inc
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

require_relative "../video_samples"
require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"
require "net/http"
require "tempfile"
require "uri"

describe "Google Cloud Video API sample" do
  before :all do
    @labels_file        = "cloud-samples-data/video/cat.mp4"
    @shots_file         = "cloud-samples-data/video/gbikes_dinosaur.mp4"
    @safe_search_file   = "cloud-samples-data/video/pizza.mp4"
    @transcription_file = "cloud-samples-data/video/googlework_short.mp4"
  end

  it "can analyze labels from a gcs file" do
    assert_output(/Label description: animal/) do
      analyze_labels_gcs path: "gs://#{@labels_file}"
    end
  end

  it "can analyze labels from a local file" do
    begin
      local_tempfile = Tempfile.new "temp_video"
      File.open local_tempfile.path, "w" do |file|
        file_contents = Net::HTTP.get URI("http://storage.googleapis.com/#{@transcription_file}")
        file.write file_contents
        file.flush
      end
      assert_output(/Finished Processing./) do
        analyze_labels_local path: local_tempfile.path
      end
    ensure
      local_tempfile.close
      local_tempfile.unlink
    end
  end

  it "can analyze explicit content from a gcs file" do
    assert_output(/pornography: VERY_UNLIKELY/) do
      analyze_explicit_content path: "gs://#{@safe_search_file}"
    end
  end

  it "can analyze shots from a gcs file" do
    assert_output(/0.0 to 5/) do
      analyze_shots path: "gs://#{@shots_file}"
    end
  end

  it "can transcribe speech from a gcs file" do
    assert_output(/cultural/) do
      transcribe_speech_gcs path: "gs://#{@transcription_file}"
    end
  end

  it "can detect texts from a gcs file" do
    assert_output(/GOOGLE/) do
      detect_text_gcs path: "gs://#{@transcription_file}"
    end
  end

  it "can detect texts from a local file" do
    begin
      local_tempfile = Tempfile.new "temp_video"
      File.open local_tempfile.path, "w" do |file|
        file_contents = Net::HTTP.get URI("http://storage.googleapis.com/#{@transcription_file}")
        file.write file_contents
        file.flush
      end
      assert_output(/GOOGLE/) do
        detect_text_local path: local_tempfile.path
      end
    ensure
      local_tempfile.close
      local_tempfile.unlink
    end
  end

  it "can track objects from a gcs file" do
    assert_output(/cat/) do
      track_objects_gcs path: "gs://#{@labels_file}"
    end
  end

  it "can track objects from a local file" do
    begin
      local_tempfile = Tempfile.new "temp_video"
      File.open local_tempfile.path, "w" do |file|
        file_contents = Net::HTTP.get URI("http://storage.googleapis.com/#{@transcription_file}")
        file.write file_contents
        file.flush
      end
      assert_output(/Finished Processing./) do
        track_objects_local path: local_tempfile.path
      end
    ensure
      local_tempfile.close
      local_tempfile.unlink
    end
  end
end
