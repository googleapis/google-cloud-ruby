# Copyright 2016 Google, Inc
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

# [START vision_face_detection_tutorial_imports]
require "google/cloud/vision"
# [END vision_face_detection_tutorial_imports]
# [START vision_face_detection_tutorial_process_response]
require "rmagick"
# [END vision_face_detection_tutorial_process_response]

# rubocop:disable Metrics/AbcSize

def draw_box_around_faces path_to_image_file:, path_to_output_file:
  # [START vision_face_detection_tutorial_client]
  image_annotator = Google::Cloud::Vision.image_annotator
  # [END vision_face_detection_tutorial_client]

  # [START vision_face_detection_tutorial_send_request]
  response = image_annotator.face_detection image: path_to_image_file
  # [END vision_face_detection_tutorial_send_request]

  # [START vision_face_detection_tutorial_process_response]
  response.responses.each do |res|
    res.face_annotations.each do |annotation|
      puts "Face bounds:"
      annotation.bounding_poly.vertices.each do |vertex|
        puts "(#{vertex.x}, #{vertex.y})"
      end

      x1 = annotation.bounding_poly.vertices[0].x.to_i
      y1 = annotation.bounding_poly.vertices[0].y.to_i
      x2 = annotation.bounding_poly.vertices[2].x.to_i
      y2 = annotation.bounding_poly.vertices[2].y.to_i

      photo = Magick::Image.read(path_to_image_file).first
      draw = Magick::Draw.new
      draw.stroke = "green"
      draw.stroke_width 5
      draw.fill_opacity 0
      draw.rectangle x1, y1, x2, y2
      draw.draw photo

      photo.write path_to_output_file
    end
  end

  puts "Output file: #{path_to_output_file}"
  # [END vision_face_detection_tutorial_process_response]
end

# rubocop:enable Metrics/AbcSize

# [START vision_face_detection_tutorial_run_application]
if $PROGRAM_NAME == __FILE__
  if ARGV.size == 2
    draw_box_around_faces path_to_image_file:  ARGV.shift,
                          path_to_output_file: ARGV.shift
  else
    puts <<~USAGE
      Usage: ruby draw_box_around_faces.rb [input-file] [output-file]
       Example:
        ruby draw_box_around_faces.rb images/face.png output-image.png
    USAGE
  end
end
# [END vision_face_detection_tutorial_run_application]
