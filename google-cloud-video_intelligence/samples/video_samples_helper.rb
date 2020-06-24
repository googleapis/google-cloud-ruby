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

def print_labels labels
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
end

def print_annotations annotation_result
  puts "Scenes:"

  annotation_result.shot_annotations.each do |shot_annotation|
    start_time = (shot_annotation.start_time_offset.seconds +
                  shot_annotation.start_time_offset.nanos / 1e9)
    end_time =   (shot_annotation.end_time_offset.seconds +
                  shot_annotation.end_time_offset.nanos / 1e9)

    puts "#{start_time} to #{end_time}"
  end
end

def print_explicit_annotation_frames explicit_annotation
  explicit_annotation.frames.each do |frame|
    frame_time = frame.time_offset.seconds + frame.time_offset.nanos / 1e9

    puts "Time: #{frame_time}"
    puts "pornography: #{frame.pornography_likelihood}"
  end
end

def print_transcriptions transcriptions
  transcriptions.each do |transcription|
    transcription.alternatives.each do |alternative|
      puts "Alternative level information:"

      puts "Transcript: #{alternative.transcript}"
      puts "Confidence: #{alternative.confidence}"

      puts "Word level information:"
      alternative.words.each do |word_info|
        start_time = (word_info.start_time.seconds +
                       word_info.start_time.nanos / 1e9)
        end_time =   (word_info.end_time.seconds +
                       word_info.end_time.nanos / 1e9)

        puts "#{word_info.word}: #{start_time} to #{end_time}"
      end
    end
  end
end

def print_text_annotations text_annotations
  text_annotations.each do |text_annotation|
    puts "Text: #{text_annotation.text}"

    # Print information about the first segment of the text.
    text_segment = text_annotation.segments.first
    print_segment_times text_segment.segment

    puts "Confidence: #{text_segment.confidence}"

    # Print information about the first frame of the segment.
    frame = text_segment.frames.first
    time_offset = (frame.time_offset.seconds +
                    frame.time_offset.nanos / 1e9)
    puts "Time offset for the first frame: #{time_offset}"

    puts "Rotated bounding box vertices:"
    frame.rotated_bounding_box.vertices.each do |vertex|
      puts "\tVertex.x: #{vertex.x}, Vertex.y: #{vertex.y}"
    end
  end
end

def print_object_annotations object_annotations
  object_annotations.each do |object_annotation|
    puts "Entity description: #{object_annotation.entity.description}"
    puts "Entity id: #{object_annotation.entity.entity_id}" if object_annotation.entity.entity_id

    object_segment = object_annotation.segment
    print_segment_times object_segment

    puts "Confidence: #{object_annotation.confidence}"

    # Print information about the first frame of the segment.
    frame = object_annotation.frames.first

    time_offset = (frame.time_offset.seconds +
                    frame.time_offset.nanos / 1e9)
    puts "Time offset for the first frame: #{time_offset}s"

    box = frame.normalized_bounding_box
    print_bounding_box_position box
  end
end

def print_segment_times segment
  start_time_offset = segment.start_time_offset
  end_time_offset = segment.end_time_offset
  start_time = (start_time_offset.seconds +
                start_time_offset.nanos / 1e9)
  end_time =   (end_time_offset.seconds +
                end_time_offset.nanos / 1e9)
  puts "Segment start_time: #{start_time}, end_time: #{end_time}"
end

def print_bounding_box_position box
  puts "Bounding box position:"
  puts "\tleft  : #{box.left}"
  puts "\ttop   : #{box.top}"
  puts "\tright : #{box.right}"
  puts "\tbottom: #{box.bottom}\n"
end

def print_usage
  puts <<~USAGE
    Usage: bundle exec ruby video_samples.rb [command] [arguments]

    Commands:
      analyze_labels           <gcs_path>   Detects labels given a GCS path.
      analyze_labels_local     <local_path> Detects labels given file path.
      analyze_shots            <gcs_path>   Detects camera shot changes given a GCS path.
      analyze_explicit_content <gcs_path>   Detects explicit content given a GCS path.
      transcribe_speech        <gcs_path>   Transcribes speech given a GCS path.
      detect_text_gcs          <gcs_path>   Detects text given a GCS path.
      detect_text_local        <local_path> Detects text given file path.
      track_objects_gcs        <gcs_path>   Track objects given a GCS path.
      track_objects_local      <local_path> Track objects given file path.
  USAGE
end
