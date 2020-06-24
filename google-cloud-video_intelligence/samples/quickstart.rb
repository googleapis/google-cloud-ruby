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

# [START video_quickstart]
require "google/cloud/video_intelligence"

video_client = Google::Cloud::VideoIntelligence.video_intelligence_service
features     = [:LABEL_DETECTION]
path         = "gs://cloud-samples-data/video/cat.mp4"

# Register a callback during the method call
operation = video_client.annotate_video features: features, input_uri: path

puts "Processing video for label annotations:"
operation.wait_until_done!

raise operation.results.message? if operation.error?
puts "Finished Processing."

labels = operation.results.annotation_results.first.segment_label_annotations

labels.each do |label|
  puts "Label description: #{label.entity.description}"

  label.category_entities.each do |category_entity|
    puts "Label category description: #{category_entity.description}"
  end

  label.segments.each do |segment|
    start_time = (segment.segment.start_time_offset.seconds +
                   segment.segment.start_time_offset.nanos / 1e9)
    end_time =   (segment.segment.end_time_offset.seconds +
                   segment.segment.end_time_offset.nanos / 1e9)

    puts "Segment: #{start_time} to #{end_time}"
    puts "Confidence: #{segment.confidence}"
  end
end
# [END video_quickstart]
