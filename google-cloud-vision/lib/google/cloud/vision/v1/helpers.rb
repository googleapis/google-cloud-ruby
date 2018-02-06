# Copyright 2018 Google LLC
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

require "google/cloud/vision/v1/image_annotator_pb.rb"

module Google
  module Cloud
    module Vision
      module V1
        class ImageAnnotatorClient
          # Alias to save some repetition
          VisionV1 = Google::Cloud::Vision::V1

          def request_to_object request, **kwargs
            # Sanity check: if request is already an AnnotateImageRequest, do
            # nothing
            if request.is_a?(VisionV1::AnnotateImageRequest)
              return request if kwargs.empty?
              raise "Invalid to pass both AnnotateImageRequest and kwargs."
            end

            if request.is_a?(String)
              # Guess whether the string is a URL or a filename.
              kwargs = if request.include?("://")
                         kwargs.merge(image: { source: { image_uri: request } })
                       else
                         kwargs.merge(image: { content: IO.binread(request) })
                       end

            elsif request.is_a?(IO) || request.is_a?(StringIO)
              kwargs = kwargs.merge(image: { content: request.binmode.read })

            else
              # Request is a Hash
              kwargs = kwargs.merge(request)
            end
            VisionV1::AnnotateImageRequest.new(kwargs)
          end

          #   Annotate a single image.
          #   @param [String, IO, Hash,
          #       Google::Cloud::Vision::V1::AnnotateImageRequest] request
          #     The image to be annotated, specified as a
          #     {Google::Cloud::Vision::V1::AnnotateImageRequest} or Hash of
          #     the same form. In simple cases, you may instead specify a String
          #     (the URL or filename of the image) or an +IO+ (the image
          #     itself).
          #   @param [Array<Google::Cloud::Vision::V1::Feature>,
          #       Array<Hash>] features
          #     The features to annotate, specified as an array of
          #     {Google::Cloud::Vision::V1::Feature} or Hash of the same form.
          #   @param [Hash, Object] **kwargs
          #     Any other fields of +AnnotateImageRequest+ to intialize, if the
          #     +request+ parameter is a filename, URL, or +IO+.
          #   @param [Google::Gax::CallOptions] options
          #     Overrides the default settings for this call, e.g, timeout,
          #     retries, etc.
          #   @return [Google::CLoud::Vision::V1::AnnotateImageResponse]
          #     The annotations for the image.
          #   @raise [Google::Gax::GaxError] if the RPC is aborted.
          #   @example
          #     require "google/cloud/vision/v1"
          #
          #     image_annotator_client = Google::Cloud::Vision.new
          #     response = image_annotator_client.annotate_image(
          #       "path/to/image",
          #       features: [{ type: :FACE_DETECTION }, { type: :CROP_HINTS }]
          #     )
          def annotate_image request, options: nil, **kwargs
            request = request_to_object(request, **kwargs)

            # If features not set, use all of them
            if request.features.empty?
              VisionV1::Feature::Type.descriptor.each do |enum_value|
                request.features.push(VisionV1::Feature.new(type: enum_value))
              end
            end

            requests = [request]

            # We only sent one request, so we can pull out the only response.
            batch_annotate_images(requests, options: options).responses[0]
          end

          # @!macro [attach] create_feature_method
          #   @method $1(request, options: nil)
          #   Annotate a single image with the feature +$1+.
          #   @param [String, IO, Hash,
          #       Google::Cloud::Vision::V1::AnnotateImageRequest] request
          #     The image to be annotated, specified as a
          #     {Google::Cloud::Vision::V1::AnnotateImageRequest} or Hash of
          #     the same form. In simple cases, you may instead specify a String
          #     (the URL or filename of the image) or an +IO+ (the image
          #     itself).
          #   @param [Google::Gax::CallOptions] options
          #     Overrides the default settings for this call, e.g, timeout,
          #     retries, etc.
          #   @return [Google::CLoud::Vision::V1::AnnotateImageResponse]
          #     The annotations for the image.
          #   @raise [Google::Gax::GaxError] if the RPC is aborted.
          #   @raise [ArgumentError] if features other than +$1+ are requested.
          #   @example
          #     require "google/cloud/vision/v1"
          #
          #     image_annotator_client = Google::Cloud::Vision.new
          #     response = image_annotator_client.$1("path/to/image")
          def self.create_feature_method feature
            define_method(feature) do |request, options: nil, **kwargs|
              # Convert String or IO input to request object
              request = request_to_object(request, **kwargs)
              feature_enum = feature.upcase
              if request.features.any? { |f| f.type = feature_enum }
                raise ArgumentError, "Feature cannot be set explicitly"
              end

              request.features.push(
                VisionV1::Feature.new(type: feature_enum)
              )
              annotate_image(request, options: options)
            end
          end

          # Feature methods. This "loop" is unrolled so that YARD
          # attaches documentation correctly.
          create_feature_method(:image_properties)
          create_feature_method(:safe_search_detection)
          create_feature_method(:logo_detection)
          create_feature_method(:web_detection)
          create_feature_method(:face_detection)
          create_feature_method(:text_detection)
          create_feature_method(:document_text_detection)
          create_feature_method(:landmark_detection)
          create_feature_method(:label_detection)
          create_feature_method(:crop_hints)

          private_class_method :create_feature_method
        end
      end
    end
  end
end
