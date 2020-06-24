# Copyright 2017 Google, Inc
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

require_relative "video_samples_helper"

def analyze_labels_gcs path:
  # [START video_analyze_labels_gcs]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  # Register a callback during the method call
  op_promise = video.annotate_video [:LABEL_DETECTION], input_uri: path do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    labels = operation.results.annotation_results.first.segment_label_annotations
    print_labels labels
  end

  puts "Processing video for label annotations:"
  op_promise.wait_until_done!
  # [END video_analyze_labels_gcs]
end

def analyze_labels_local path:
  # [START video_analyze_labels]
  # path = "Path to a local video file: path/to/file.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  video_contents = File.binread path

  # Register a callback during the method call
  op_promise = video.annotate_video [:LABEL_DETECTION], input_content: video_contents do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    labels = operation.results.annotation_results.first.segment_label_annotations
    print_labels labels
  end

  puts "Processing video for label annotations:"
  op_promise.wait_until_done!
  # [END video_analyze_labels]
end

def analyze_shots path:
  # [START video_analyze_shots]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  # Register a callback during the method call
  op_promise = video.annotate_video [:SHOT_CHANGE_DETECTION], input_uri: path do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished processing."

    # first result is retrieved because a single video was processed
    annotation_result = operation.results.annotation_results.first
    print_annotations annotation_result
  end

  puts "Processing video for shot change annotations:"
  op_promise.wait_until_done!
  # [END video_analyze_shots]
end

def analyze_explicit_content path:
  # [START video_analyze_explicit_content]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  # Register a callback during the method call
  op_promise = video.annotate_video [:EXPLICIT_CONTENT_DETECTION], input_uri: path do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    explicit_annotation = operation.results.annotation_results.first.explicit_annotation
    print_explicit_annotation_frames explicit_annotation
  end

  puts "Processing video for label annotations:"
  op_promise.wait_until_done!
  # [END video_analyze_explicit_content]
end

def transcribe_speech_gcs path:
  # [START video_speech_transcription_gcs]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  context = {
    speech_transcription_config: {
      language_code:                "en-US",
      enable_automatic_punctuation: true
    }
  }

  # Register a callback during the method call
  op_promise = video.annotate_video [:SPEECH_TRANSCRIPTION], input_uri: path, video_context: context do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    transcriptions = operation.results.annotation_results.first.speech_transcriptions
    print_transcriptions transcriptions
  end

  puts "Processing video for speech transcriptions:"
  op_promise.wait_until_done!
  # [END video_speech_transcription_gcs]
end

def detect_text_gcs path:
  # [START video_detect_text_gcs]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  # Register a callback during the method call
  op_promise = video.annotate_video [:TEXT_DETECTION], input_uri: path do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    text_annotations = operation.results.annotation_results.first.text_annotations
    print_text_annotations text_annotations
  end

  puts "Processing video for text detection:"
  op_promise.wait_until_done!
  # [END video_detect_text_gcs]
end

def detect_text_local path:
  # [START video_detect_text]
  # "Path to a local video file: path/to/file.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  video_contents = File.binread path

  # Register a callback during the method call
  op_promise = video.annotate_video [:TEXT_DETECTION], input_content: video_contents do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    text_annotations = operation.results.annotation_results.first.text_annotations
    print_text_annotations text_annotations
  end

  puts "Processing video for text detection:"
  op_promise.wait_until_done!
  # [END video_detect_text]
end

def track_objects_gcs path:
  # [START video_object_tracking_gcs]
  # path = "Path to a video file on Google Cloud Storage: gs://bucket/video.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  # Register a callback during the method call
  op_promise = video.annotate_video [:OBJECT_TRACKING], input_uri: path do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    object_annotations = operation.results.annotation_results.first.object_annotations
    print_object_annotations object_annotations
  end

  puts "Processing video for object tracking:"
  op_promise.wait_until_done!
  # [END video_object_tracking_gcs]
end

def track_objects_local path:
  # [START video_object_tracking]
  # "Path to a local video file: path/to/file.mp4"

  require "google/cloud/video_intelligence"

  video = Google::Cloud::VideoIntelligence.new

  video_contents = File.binread path

  # Register a callback during the method call
  op_promise = video.annotate_video [:OBJECT_TRACKING], input_content: video_contents do |operation|
    raise operation.results.message? if operation.error?
    puts "Finished Processing."

    object_annotations = operation.results.annotation_results.first.object_annotations
    print_object_annotations object_annotations
  end

  puts "Processing video for object tracking:"
  op_promise.wait_until_done!
  # [END video_object_tracking]
end

def run_sample arguments
  command = arguments.shift

  case command
  when "analyze_labels"
    analyze_labels_gcs path: arguments.shift
  when "analyze_labels_local"
    analyze_labels_local path: arguments.shift
  when "analyze_shots"
    analyze_shots path: arguments.shift
  when "analyze_explicit_content"
    analyze_explicit_content path: arguments.shift
  when "transcribe_speech"
    transcribe_speech_gcs path: arguments.shift
  when "detect_text_gcs"
    detect_text_gcs path: arguments.shift
  when "detect_text_local"
    detect_text_local path: arguments.shift
  when "track_objects_gcs"
    track_objects_gcs path: arguments.shift
  when "track_objects_local"
    track_objects_local path: arguments.shift
  else
    print_usage
  end
end

run_sample ARGV if $PROGRAM_NAME == __FILE__
