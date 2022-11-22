# Copyright 2020 Google LLC
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

# rubocop:disable Style/Documentation

require "uri"

module Google
  module Cloud
    module Vision
      module V1p4beta1
        module ImageAnnotator
          class Client
            ##
            # Detect features of type CROP_HINTS.
            #
            # @param images [Array<String>, Array<File>]
            #   An array containing files, file paths, io objects, image urls, or
            #   Google Cloud Storage urls. Can be used with or instead of image.
            # @param image [File, String]
            #   A file, file path, io object, url pointing to an image, or Google
            #   Cloud Storage url. Can be used with or instead of images.
            # @param max_results [Integer]
            #   Optional. Defaults to 10.
            # @param options [Gapic::CallOptions]
            #   Optional. Overrides the default settings for this call, e.g,
            #   timeout, retries, etc.
            # @param async [Boolean]
            #   Optional. Defaults to `false`. If `false`, performs the request
            #   synchronously, returning a `BatchAnnotateImagesResponse`. If `true`,
            #   performs the request asynchronously, returning a `Gapic::Operation`.
            # @param mime_type [String]
            #   Required only if async is `true`.
            # @param batch_size [Integer]
            #   Optional. Defaults to 10. When async is `true`, this specifies the
            #   number of input files per output json.
            # @param destination [String]
            #   A Google Cloud Storage location for storing the output. Required
            #   only if async is `true`.
            # @param image_context [Hash]
            #   Optional. Image context and/or feature-specific parameters.
            #
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse, Gapic::Operation]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            #
            # @return [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse] if async is `false`.
            # @return [Gapic::Operation] if async is `true`.
            #
            # @raise [Google::Cloud::Error] if the RPC is aborted.
            #
            # @example
            #   require "google/cloud/vision/v1p4beta1"
            #
            #   image_annotator_client = Google::Cloud::Vision::V1p4beta1::ImageAnnotator::Client.new
            #
            #   response = image_annotator_client.crop_hints_detection image: "path/to/image.png"
            #   response.responses.each do |res|
            #     puts res
            #   end
            #
            def crop_hints_detection \
                images: [],
                image: nil,
                max_results: 10,
                options: nil,
                async: false,
                mime_type: nil,
                batch_size: 10,
                destination: nil,
                image_context: nil,
                &block

              feature = { type: :CROP_HINTS, max_results: max_results }
              images << image if image
              formatted_images = images.map do |img|
                formatted_image = normalize_image img
                formatted_image[:mime_type] = mime_type if mime_type
                formatted_image
              end
              requests = formatted_images.map do |img|
                request = { image: img, features: [feature] }
                request[:image_context] = image_context if image_context
                request
              end
              batch_request = { requests: requests }

              if async
                requests.map! do |request|
                  {
                    input_config:  {
                      gcs_source: {
                        uri: request[:image][:source][:gcs_image_uri]
                      },
                      mime_type:  mime_type
                    },
                    features:      request[:features],
                    output_config: {
                      gcs_destination: {
                        uri: destination
                      },
                      batch_size:      batch_size
                    }
                  }
                end
                async_batch_annotate_files batch_request, options, &block
              else
                batch_annotate_images batch_request, options, &block
              end
            end

            ##
            # Detect features of type DOCUMENT_TEXT_DETECTION.
            #
            # @param images [Array<String>, Array<File>]
            #   An array containing files, file paths, io objects, image urls, or
            #   Google Cloud Storage urls. Can be used with or instead of image.
            # @param image [File, String]
            #   A file, file path, io object, url pointing to an image, or Google
            #   Cloud Storage url. Can be used with or instead of images.
            # @param max_results [Integer]
            #   Optional. Defaults to 10.
            # @param options [Gapic::CallOptions]
            #   Optional. Overrides the default settings for this call, e.g,
            #   timeout, retries, etc.
            # @param async [Boolean]
            #   Optional. Defaults to `false`. If `false`, performs the request
            #   synchronously, returning a `BatchAnnotateImagesResponse`. If `true`,
            #   performs the request asynchronously, returning a `Gapic::Operation`.
            # @param mime_type [String]
            #   Required only if async is `true`.
            # @param batch_size [Integer]
            #   Optional. Defaults to 10. When async is `true`, this specifies the
            #   number of input files per output json.
            # @param destination [String]
            #   A Google Cloud Storage location for storing the output. Required
            #   only if async is `true`.
            # @param image_context [Hash]
            #   Optional. Image context and/or feature-specific parameters.
            #
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse, Gapic::Operation]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            #
            # @return [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse] if async is `false`.
            # @return [Gapic::Operation] if async is `true`.
            #
            # @raise [Google::Cloud::Error] if the RPC is aborted.
            #
            # @example
            #   require "google/cloud/vision/v1p4beta1"
            #
            #   image_annotator_client = Google::Cloud::Vision::V1p4beta1::ImageAnnotator::Client.new
            #
            #   response = image_annotator_client.document_text_detection image: "path/to/image.png"
            #   response.responses.each do |res|
            #     puts res
            #   end
            #
            def document_text_detection \
                images: [],
                image: nil,
                max_results: 10,
                options: nil,
                async: false,
                mime_type: nil,
                batch_size: 10,
                destination: nil,
                image_context: nil,
                &block

              feature = { type: :DOCUMENT_TEXT_DETECTION, max_results: max_results }
              images << image if image
              formatted_images = images.map do |img|
                formatted_image = normalize_image img
                formatted_image[:mime_type] = mime_type if mime_type
                formatted_image
              end
              requests = formatted_images.map do |img|
                request = { image: img, features: [feature] }
                request[:image_context] = image_context if image_context
                request
              end
              batch_request = { requests: requests }

              if async
                requests.map! do |request|
                  {
                    input_config:  {
                      gcs_source: {
                        uri: request[:image][:source][:gcs_image_uri]
                      },
                      mime_type:  mime_type
                    },
                    features:      request[:features],
                    output_config: {
                      gcs_destination: {
                        uri: destination
                      },
                      batch_size:      batch_size
                    }
                  }
                end
                async_batch_annotate_files batch_request, options, &block
              else
                batch_annotate_images batch_request, options, &block
              end
            end

            ##
            # Detect features of type FACE_DETECTION.
            #
            # @param images [Array<String>, Array<File>]
            #   An array containing files, file paths, io objects, image urls, or
            #   Google Cloud Storage urls. Can be used with or instead of image.
            # @param image [File, String]
            #   A file, file path, io object, url pointing to an image, or Google
            #   Cloud Storage url. Can be used with or instead of images.
            # @param max_results [Integer]
            #   Optional. Defaults to 10.
            # @param options [Gapic::CallOptions]
            #   Optional. Overrides the default settings for this call, e.g,
            #   timeout, retries, etc.
            # @param async [Boolean]
            #   Optional. Defaults to `false`. If `false`, performs the request
            #   synchronously, returning a `BatchAnnotateImagesResponse`. If `true`,
            #   performs the request asynchronously, returning a `Gapic::Operation`.
            # @param mime_type [String]
            #   Required only if async is `true`.
            # @param batch_size [Integer]
            #   Optional. Defaults to 10. When async is `true`, this specifies the
            #   number of input files per output json.
            # @param destination [String]
            #   A Google Cloud Storage location for storing the output. Required
            #   only if async is `true`.
            # @param image_context [Hash]
            #   Optional. Image context and/or feature-specific parameters.
            #
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse, Gapic::Operation]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            #
            # @return [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse] if async is `false`.
            # @return [Gapic::Operation] if async is `true`.
            #
            # @raise [Google::Cloud::Error] if the RPC is aborted.
            #
            # @example
            #   require "google/cloud/vision/v1p4beta1"
            #
            #   image_annotator_client = Google::Cloud::Vision::V1p4beta1::ImageAnnotator::Client.new
            #
            #   response = image_annotator_client.face_detection image: "path/to/image.png"
            #   response.responses.each do |res|
            #     puts res
            #   end
            #
            def face_detection \
                images: [],
                image: nil,
                max_results: 10,
                options: nil,
                async: false,
                mime_type: nil,
                batch_size: 10,
                destination: nil,
                image_context: nil,
                &block

              feature = { type: :FACE_DETECTION, max_results: max_results }
              images << image if image
              formatted_images = images.map do |img|
                formatted_image = normalize_image img
                formatted_image[:mime_type] = mime_type if mime_type
                formatted_image
              end
              requests = formatted_images.map do |img|
                request = { image: img, features: [feature] }
                request[:image_context] = image_context if image_context
                request
              end
              batch_request = { requests: requests }

              if async
                requests.map! do |request|
                  {
                    input_config:  {
                      gcs_source: {
                        uri: request[:image][:source][:gcs_image_uri]
                      },
                      mime_type:  mime_type
                    },
                    features:      request[:features],
                    output_config: {
                      gcs_destination: {
                        uri: destination
                      },
                      batch_size:      batch_size
                    }
                  }
                end
                async_batch_annotate_files batch_request, options, &block
              else
                batch_annotate_images batch_request, options, &block
              end
            end

            ##
            # Detect features of type IMAGE_PROPERTIES.
            #
            # @param images [Array<String>, Array<File>]
            #   An array containing files, file paths, io objects, image urls, or
            #   Google Cloud Storage urls. Can be used with or instead of image.
            # @param image [File, String]
            #   A file, file path, io object, url pointing to an image, or Google
            #   Cloud Storage url. Can be used with or instead of images.
            # @param max_results [Integer]
            #   Optional. Defaults to 10.
            # @param options [Gapic::CallOptions]
            #   Optional. Overrides the default settings for this call, e.g,
            #   timeout, retries, etc.
            # @param async [Boolean]
            #   Optional. Defaults to `false`. If `false`, performs the request
            #   synchronously, returning a `BatchAnnotateImagesResponse`. If `true`,
            #   performs the request asynchronously, returning a `Gapic::Operation`.
            # @param mime_type [String]
            #   Required only if async is `true`.
            # @param batch_size [Integer]
            #   Optional. Defaults to 10. When async is `true`, this specifies the
            #   number of input files per output json.
            # @param destination [String]
            #   A Google Cloud Storage location for storing the output. Required
            #   only if async is `true`.
            # @param image_context [Hash]
            #   Optional. Image context and/or feature-specific parameters.
            #
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse, Gapic::Operation]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            #
            # @return [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse] if async is `false`.
            # @return [Gapic::Operation] if async is `true`.
            #
            # @raise [Google::Cloud::Error] if the RPC is aborted.
            #
            # @example
            #   require "google/cloud/vision/v1p4beta1"
            #
            #   image_annotator_client = Google::Cloud::Vision::V1p4beta1::ImageAnnotator::Client.new
            #
            #   response = image_annotator_client.image_properties_detection image: "path/to/image.png"
            #   response.responses.each do |res|
            #     puts res
            #   end
            #
            def image_properties_detection \
                images: [],
                image: nil,
                max_results: 10,
                options: nil,
                async: false,
                mime_type: nil,
                batch_size: 10,
                destination: nil,
                image_context: nil,
                &block

              feature = { type: :IMAGE_PROPERTIES, max_results: max_results }
              images << image if image
              formatted_images = images.map do |img|
                formatted_image = normalize_image img
                formatted_image[:mime_type] = mime_type if mime_type
                formatted_image
              end
              requests = formatted_images.map do |img|
                request = { image: img, features: [feature] }
                request[:image_context] = image_context if image_context
                request
              end
              batch_request = { requests: requests }

              if async
                requests.map! do |request|
                  {
                    input_config:  {
                      gcs_source: {
                        uri: request[:image][:source][:gcs_image_uri]
                      },
                      mime_type:  mime_type
                    },
                    features:      request[:features],
                    output_config: {
                      gcs_destination: {
                        uri: destination
                      },
                      batch_size:      batch_size
                    }
                  }
                end
                async_batch_annotate_files batch_request, options, &block
              else
                batch_annotate_images batch_request, options, &block
              end
            end

            ##
            # Detect features of type LABEL_DETECTION.
            #
            # @param images [Array<String>, Array<File>]
            #   An array containing files, file paths, io objects, image urls, or
            #   Google Cloud Storage urls. Can be used with or instead of image.
            # @param image [File, String]
            #   A file, file path, io object, url pointing to an image, or Google
            #   Cloud Storage url. Can be used with or instead of images.
            # @param max_results [Integer]
            #   Optional. Defaults to 10.
            # @param options [Gapic::CallOptions]
            #   Optional. Overrides the default settings for this call, e.g,
            #   timeout, retries, etc.
            # @param async [Boolean]
            #   Optional. Defaults to `false`. If `false`, performs the request
            #   synchronously, returning a `BatchAnnotateImagesResponse`. If `true`,
            #   performs the request asynchronously, returning a `Gapic::Operation`.
            # @param mime_type [String]
            #   Required only if async is `true`.
            # @param batch_size [Integer]
            #   Optional. Defaults to 10. When async is `true`, this specifies the
            #   number of input files per output json.
            # @param destination [String]
            #   A Google Cloud Storage location for storing the output. Required
            #   only if async is `true`.
            # @param image_context [Hash]
            #   Optional. Image context and/or feature-specific parameters.
            #
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse, Gapic::Operation]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            #
            # @return [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse] if async is `false`.
            # @return [Gapic::Operation] if async is `true`.
            #
            # @raise [Google::Cloud::Error] if the RPC is aborted.
            #
            # @example
            #   require "google/cloud/vision/v1p4beta1"
            #
            #   image_annotator_client = Google::Cloud::Vision::V1p4beta1::ImageAnnotator::Client.new
            #
            #   response = image_annotator_client.label_detection image: "path/to/image.png"
            #   response.responses.each do |res|
            #     puts res
            #   end
            #
            def label_detection \
                images: [],
                image: nil,
                max_results: 10,
                options: nil,
                async: false,
                mime_type: nil,
                batch_size: 10,
                destination: nil,
                image_context: nil,
                &block

              feature = { type: :LABEL_DETECTION, max_results: max_results }
              images << image if image
              formatted_images = images.map do |img|
                formatted_image = normalize_image img
                formatted_image[:mime_type] = mime_type if mime_type
                formatted_image
              end
              requests = formatted_images.map do |img|
                request = { image: img, features: [feature] }
                request[:image_context] = image_context if image_context
                request
              end
              batch_request = { requests: requests }

              if async
                requests.map! do |request|
                  {
                    input_config:  {
                      gcs_source: {
                        uri: request[:image][:source][:gcs_image_uri]
                      },
                      mime_type:  mime_type
                    },
                    features:      request[:features],
                    output_config: {
                      gcs_destination: {
                        uri: destination
                      },
                      batch_size:      batch_size
                    }
                  }
                end
                async_batch_annotate_files batch_request, options, &block
              else
                batch_annotate_images batch_request, options, &block
              end
            end

            ##
            # Detect features of type LANDMARK_DETECTION.
            #
            # @param images [Array<String>, Array<File>]
            #   An array containing files, file paths, io objects, image urls, or
            #   Google Cloud Storage urls. Can be used with or instead of image.
            # @param image [File, String]
            #   A file, file path, io object, url pointing to an image, or Google
            #   Cloud Storage url. Can be used with or instead of images.
            # @param max_results [Integer]
            #   Optional. Defaults to 10.
            # @param options [Gapic::CallOptions]
            #   Optional. Overrides the default settings for this call, e.g,
            #   timeout, retries, etc.
            # @param async [Boolean]
            #   Optional. Defaults to `false`. If `false`, performs the request
            #   synchronously, returning a `BatchAnnotateImagesResponse`. If `true`,
            #   performs the request asynchronously, returning a `Gapic::Operation`.
            # @param mime_type [String]
            #   Required only if async is `true`.
            # @param batch_size [Integer]
            #   Optional. Defaults to 10. When async is `true`, this specifies the
            #   number of input files per output json.
            # @param destination [String]
            #   A Google Cloud Storage location for storing the output. Required
            #   only if async is `true`.
            # @param image_context [Hash]
            #   Optional. Image context and/or feature-specific parameters.
            #
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse, Gapic::Operation]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            #
            # @return [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse] if async is `false`.
            # @return [Gapic::Operation] if async is `true`.
            #
            # @raise [Google::Cloud::Error] if the RPC is aborted.
            #
            # @example
            #   require "google/cloud/vision/v1p4beta1"
            #
            #   image_annotator_client = Google::Cloud::Vision::V1p4beta1::ImageAnnotator::Client.new
            #
            #   response = image_annotator_client.landmark_detection image: "path/to/image.png"
            #   response.responses.each do |res|
            #     puts res
            #   end
            #
            def landmark_detection \
                images: [],
                image: nil,
                max_results: 10,
                options: nil,
                async: false,
                mime_type: nil,
                batch_size: 10,
                destination: nil,
                image_context: nil,
                &block

              feature = { type: :LANDMARK_DETECTION, max_results: max_results }
              images << image if image
              formatted_images = images.map do |img|
                formatted_image = normalize_image img
                formatted_image[:mime_type] = mime_type if mime_type
                formatted_image
              end
              requests = formatted_images.map do |img|
                request = { image: img, features: [feature] }
                request[:image_context] = image_context if image_context
                request
              end
              batch_request = { requests: requests }

              if async
                requests.map! do |request|
                  {
                    input_config:  {
                      gcs_source: {
                        uri: request[:image][:source][:gcs_image_uri]
                      },
                      mime_type:  mime_type
                    },
                    features:      request[:features],
                    output_config: {
                      gcs_destination: {
                        uri: destination
                      },
                      batch_size:      batch_size
                    }
                  }
                end
                async_batch_annotate_files batch_request, options, &block
              else
                batch_annotate_images batch_request, options, &block
              end
            end

            ##
            # Detect features of type LOGO_DETECTION.
            #
            # @param images [Array<String>, Array<File>]
            #   An array containing files, file paths, io objects, image urls, or
            #   Google Cloud Storage urls. Can be used with or instead of image.
            # @param image [File, String]
            #   A file, file path, io object, url pointing to an image, or Google
            #   Cloud Storage url. Can be used with or instead of images.
            # @param max_results [Integer]
            #   Optional. Defaults to 10.
            # @param options [Gapic::CallOptions]
            #   Optional. Overrides the default settings for this call, e.g,
            #   timeout, retries, etc.
            # @param async [Boolean]
            #   Optional. Defaults to `false`. If `false`, performs the request
            #   synchronously, returning a `BatchAnnotateImagesResponse`. If `true`,
            #   performs the request asynchronously, returning a `Gapic::Operation`.
            # @param mime_type [String]
            #   Required only if async is `true`.
            # @param batch_size [Integer]
            #   Optional. Defaults to 10. When async is `true`, this specifies the
            #   number of input files per output json.
            # @param destination [String]
            #   A Google Cloud Storage location for storing the output. Required
            #   only if async is `true`.
            # @param image_context [Hash]
            #   Optional. Image context and/or feature-specific parameters.
            #
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse, Gapic::Operation]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            #
            # @return [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse] if async is `false`.
            # @return [Gapic::Operation] if async is `true`.
            #
            # @raise [Google::Cloud::Error] if the RPC is aborted.
            #
            # @example
            #   require "google/cloud/vision/v1p4beta1"
            #
            #   image_annotator_client = Google::Cloud::Vision::V1p4beta1::ImageAnnotator::Client.new
            #
            #   response = image_annotator_client.logo_detection image: "path/to/image.png"
            #   response.responses.each do |res|
            #     puts res
            #   end
            #
            def logo_detection \
                images: [],
                image: nil,
                max_results: 10,
                options: nil,
                async: false,
                mime_type: nil,
                batch_size: 10,
                destination: nil,
                image_context: nil,
                &block

              feature = { type: :LOGO_DETECTION, max_results: max_results }
              images << image if image
              formatted_images = images.map do |img|
                formatted_image = normalize_image img
                formatted_image[:mime_type] = mime_type if mime_type
                formatted_image
              end
              requests = formatted_images.map do |img|
                request = { image: img, features: [feature] }
                request[:image_context] = image_context if image_context
                request
              end
              batch_request = { requests: requests }

              if async
                requests.map! do |request|
                  {
                    input_config:  {
                      gcs_source: {
                        uri: request[:image][:source][:gcs_image_uri]
                      },
                      mime_type:  mime_type
                    },
                    features:      request[:features],
                    output_config: {
                      gcs_destination: {
                        uri: destination
                      },
                      batch_size:      batch_size
                    }
                  }
                end
                async_batch_annotate_files batch_request, options, &block
              else
                batch_annotate_images batch_request, options, &block
              end
            end

            ##
            # Detect features of type OBJECT_LOCALIZATION.
            #
            # @param images [Array<String>, Array<File>]
            #   An array containing files, file paths, io objects, image urls, or
            #   Google Cloud Storage urls. Can be used with or instead of image.
            # @param image [File, String]
            #   A file, file path, io object, url pointing to an image, or Google
            #   Cloud Storage url. Can be used with or instead of images.
            # @param max_results [Integer]
            #   Optional. Defaults to 10.
            # @param options [Gapic::CallOptions]
            #   Optional. Overrides the default settings for this call, e.g,
            #   timeout, retries, etc.
            # @param async [Boolean]
            #   Optional. Defaults to `false`. If `false`, performs the request
            #   synchronously, returning a `BatchAnnotateImagesResponse`. If `true`,
            #   performs the request asynchronously, returning a `Gapic::Operation`.
            # @param mime_type [String]
            #   Required only if async is `true`.
            # @param batch_size [Integer]
            #   Optional. Defaults to 10. When async is `true`, this specifies the
            #   number of input files per output json.
            # @param destination [String]
            #   A Google Cloud Storage location for storing the output. Required
            #   only if async is `true`.
            # @param image_context [Hash]
            #   Optional. Image context and/or feature-specific parameters.
            #
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse, Gapic::Operation]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            #
            # @return [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse] if async is `false`.
            # @return [Gapic::Operation] if async is `true`.
            #
            # @raise [Google::Cloud::Error] if the RPC is aborted.
            #
            # @example
            #   require "google/cloud/vision/v1p4beta1"
            #
            #   image_annotator_client = Google::Cloud::Vision::V1p4beta1::ImageAnnotator::Client.new
            #
            #   response = image_annotator_client.object_localization_detection image: "path/to/image.png"
            #   response.responses.each do |res|
            #     puts res
            #   end
            #
            def object_localization_detection \
                images: [],
                image: nil,
                max_results: 10,
                options: nil,
                async: false,
                mime_type: nil,
                batch_size: 10,
                destination: nil,
                image_context: nil,
                &block

              feature = { type: :OBJECT_LOCALIZATION, max_results: max_results }
              images << image if image
              formatted_images = images.map do |img|
                formatted_image = normalize_image img
                formatted_image[:mime_type] = mime_type if mime_type
                formatted_image
              end
              requests = formatted_images.map do |img|
                request = { image: img, features: [feature] }
                request[:image_context] = image_context if image_context
                request
              end
              batch_request = { requests: requests }

              if async
                requests.map! do |request|
                  {
                    input_config:  {
                      gcs_source: {
                        uri: request[:image][:source][:gcs_image_uri]
                      },
                      mime_type:  mime_type
                    },
                    features:      request[:features],
                    output_config: {
                      gcs_destination: {
                        uri: destination
                      },
                      batch_size:      batch_size
                    }
                  }
                end
                async_batch_annotate_files batch_request, options, &block
              else
                batch_annotate_images batch_request, options, &block
              end
            end

            ##
            # Detect features of type PRODUCT_SEARCH.
            #
            # @param images [Array<String>, Array<File>]
            #   An array containing files, file paths, io objects, image urls, or
            #   Google Cloud Storage urls. Can be used with or instead of image.
            # @param image [File, String]
            #   A file, file path, io object, url pointing to an image, or Google
            #   Cloud Storage url. Can be used with or instead of images.
            # @param max_results [Integer]
            #   Optional. Defaults to 10.
            # @param options [Gapic::CallOptions]
            #   Optional. Overrides the default settings for this call, e.g,
            #   timeout, retries, etc.
            # @param async [Boolean]
            #   Optional. Defaults to `false`. If `false`, performs the request
            #   synchronously, returning a `BatchAnnotateImagesResponse`. If `true`,
            #   performs the request asynchronously, returning a `Gapic::Operation`.
            # @param mime_type [String]
            #   Required only if async is `true`.
            # @param batch_size [Integer]
            #   Optional. Defaults to 10. When async is `true`, this specifies the
            #   number of input files per output json.
            # @param destination [String]
            #   A Google Cloud Storage location for storing the output. Required
            #   only if async is `true`.
            # @param image_context [Hash]
            #   Optional. Image context and/or feature-specific parameters.
            #
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse, Gapic::Operation]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            #
            # @return [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse] if async is `false`.
            # @return [Gapic::Operation] if async is `true`.
            #
            # @raise [Google::Cloud::Error] if the RPC is aborted.
            #
            # @example
            #   require "google/cloud/vision/v1p4beta1"
            #
            #   image_annotator_client = Google::Cloud::Vision::V1p4beta1::ImageAnnotator::Client.new
            #
            #   response = image_annotator_client.product_search_detection image: "path/to/image.png"
            #   response.responses.each do |res|
            #     puts res
            #   end
            #
            def product_search_detection \
                images: [],
                image: nil,
                max_results: 10,
                options: nil,
                async: false,
                mime_type: nil,
                batch_size: 10,
                destination: nil,
                image_context: nil,
                &block

              feature = { type: :PRODUCT_SEARCH, max_results: max_results }
              images << image if image
              formatted_images = images.map do |img|
                formatted_image = normalize_image img
                formatted_image[:mime_type] = mime_type if mime_type
                formatted_image
              end
              requests = formatted_images.map do |img|
                request = { image: img, features: [feature] }
                request[:image_context] = image_context if image_context
                request
              end
              batch_request = { requests: requests }

              if async
                requests.map! do |request|
                  {
                    input_config:  {
                      gcs_source: {
                        uri: request[:image][:source][:gcs_image_uri]
                      },
                      mime_type:  mime_type
                    },
                    features:      request[:features],
                    output_config: {
                      gcs_destination: {
                        uri: destination
                      },
                      batch_size:      batch_size
                    }
                  }
                end
                async_batch_annotate_files batch_request, options, &block
              else
                batch_annotate_images batch_request, options, &block
              end
            end

            ##
            # Detect features of type SAFE_SEARCH_DETECTION.
            #
            # @param images [Array<String>, Array<File>]
            #   An array containing files, file paths, io objects, image urls, or
            #   Google Cloud Storage urls. Can be used with or instead of image.
            # @param image [File, String]
            #   A file, file path, io object, url pointing to an image, or Google
            #   Cloud Storage url. Can be used with or instead of images.
            # @param max_results [Integer]
            #   Optional. Defaults to 10.
            # @param options [Gapic::CallOptions]
            #   Optional. Overrides the default settings for this call, e.g,
            #   timeout, retries, etc.
            # @param async [Boolean]
            #   Optional. Defaults to `false`. If `false`, performs the request
            #   synchronously, returning a `BatchAnnotateImagesResponse`. If `true`,
            #   performs the request asynchronously, returning a `Gapic::Operation`.
            # @param mime_type [String]
            #   Required only if async is `true`.
            # @param batch_size [Integer]
            #   Optional. Defaults to 10. When async is `true`, this specifies the
            #   number of input files per output json.
            # @param destination [String]
            #   A Google Cloud Storage location for storing the output. Required
            #   only if async is `true`.
            # @param image_context [Hash]
            #   Optional. Image context and/or feature-specific parameters.
            #
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse, Gapic::Operation]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            #
            # @return [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse] if async is `false`.
            # @return [Gapic::Operation] if async is `true`.
            #
            # @raise [Google::Cloud::Error] if the RPC is aborted.
            #
            # @example
            #   require "google/cloud/vision/v1p4beta1"
            #
            #   image_annotator_client = Google::Cloud::Vision::V1p4beta1::ImageAnnotator::Client.new
            #
            #   response = image_annotator_client.safe_search_detection image: "path/to/image.png"
            #   response.responses.each do |res|
            #     puts res
            #   end
            #
            def safe_search_detection \
                images: [],
                image: nil,
                max_results: 10,
                options: nil,
                async: false,
                mime_type: nil,
                batch_size: 10,
                destination: nil,
                image_context: nil,
                &block

              feature = { type: :SAFE_SEARCH_DETECTION, max_results: max_results }
              images << image if image
              formatted_images = images.map do |img|
                formatted_image = normalize_image img
                formatted_image[:mime_type] = mime_type if mime_type
                formatted_image
              end
              requests = formatted_images.map do |img|
                request = { image: img, features: [feature] }
                request[:image_context] = image_context if image_context
                request
              end
              batch_request = { requests: requests }

              if async
                requests.map! do |request|
                  {
                    input_config:  {
                      gcs_source: {
                        uri: request[:image][:source][:gcs_image_uri]
                      },
                      mime_type:  mime_type
                    },
                    features:      request[:features],
                    output_config: {
                      gcs_destination: {
                        uri: destination
                      },
                      batch_size:      batch_size
                    }
                  }
                end
                async_batch_annotate_files batch_request, options, &block
              else
                batch_annotate_images batch_request, options, &block
              end
            end

            ##
            # Detect features of type TEXT_DETECTION.
            #
            # @param images [Array<String>, Array<File>]
            #   An array containing files, file paths, io objects, image urls, or
            #   Google Cloud Storage urls. Can be used with or instead of image.
            # @param image [File, String]
            #   A file, file path, io object, url pointing to an image, or Google
            #   Cloud Storage url. Can be used with or instead of images.
            # @param max_results [Integer]
            #   Optional. Defaults to 10.
            # @param options [Gapic::CallOptions]
            #   Optional. Overrides the default settings for this call, e.g,
            #   timeout, retries, etc.
            # @param async [Boolean]
            #   Optional. Defaults to `false`. If `false`, performs the request
            #   synchronously, returning a `BatchAnnotateImagesResponse`. If `true`,
            #   performs the request asynchronously, returning a `Gapic::Operation`.
            # @param mime_type [String]
            #   Required only if async is `true`.
            # @param batch_size [Integer]
            #   Optional. Defaults to 10. When async is `true`, this specifies the
            #   number of input files per output json.
            # @param destination [String]
            #   A Google Cloud Storage location for storing the output. Required
            #   only if async is `true`.
            # @param image_context [Hash]
            #   Optional. Image context and/or feature-specific parameters.
            #
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse, Gapic::Operation]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            #
            # @return [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse] if async is `false`.
            # @return [Gapic::Operation] if async is `true`.
            #
            # @raise [Google::Cloud::Error] if the RPC is aborted.
            #
            # @example
            #   require "google/cloud/vision/v1p4beta1"
            #
            #   image_annotator_client = Google::Cloud::Vision::V1p4beta1::ImageAnnotator::Client.new
            #
            #   response = image_annotator_client.text_detection image: "path/to/image.png"
            #   response.responses.each do |res|
            #     puts res
            #   end
            #
            def text_detection \
                images: [],
                image: nil,
                max_results: 10,
                options: nil,
                async: false,
                mime_type: nil,
                batch_size: 10,
                destination: nil,
                image_context: nil,
                &block

              feature = { type: :TEXT_DETECTION, max_results: max_results }
              images << image if image
              formatted_images = images.map do |img|
                formatted_image = normalize_image img
                formatted_image[:mime_type] = mime_type if mime_type
                formatted_image
              end
              requests = formatted_images.map do |img|
                request = { image: img, features: [feature] }
                request[:image_context] = image_context if image_context
                request
              end
              batch_request = { requests: requests }

              if async
                requests.map! do |request|
                  {
                    input_config:  {
                      gcs_source: {
                        uri: request[:image][:source][:gcs_image_uri]
                      },
                      mime_type:  mime_type
                    },
                    features:      request[:features],
                    output_config: {
                      gcs_destination: {
                        uri: destination
                      },
                      batch_size:      batch_size
                    }
                  }
                end
                async_batch_annotate_files batch_request, options, &block
              else
                batch_annotate_images batch_request, options, &block
              end
            end

            ##
            # Detect features of type WEB_DETECTION.
            #
            # @param images [Array<String>, Array<File>]
            #   An array containing files, file paths, io objects, image urls, or
            #   Google Cloud Storage urls. Can be used with or instead of image.
            # @param image [File, String]
            #   A file, file path, io object, url pointing to an image, or Google
            #   Cloud Storage url. Can be used with or instead of images.
            # @param max_results [Integer]
            #   Optional. Defaults to 10.
            # @param options [Gapic::CallOptions]
            #   Optional. Overrides the default settings for this call, e.g,
            #   timeout, retries, etc.
            # @param async [Boolean]
            #   Optional. Defaults to `false`. If `false`, performs the request
            #   synchronously, returning a `BatchAnnotateImagesResponse`. If `true`,
            #   performs the request asynchronously, returning a `Gapic::Operation`.
            # @param mime_type [String]
            #   Required only if async is `true`.
            # @param batch_size [Integer]
            #   Optional. Defaults to 10. When async is `true`, this specifies the
            #   number of input files per output json.
            # @param destination [String]
            #   A Google Cloud Storage location for storing the output. Required
            #   only if async is `true`.
            # @param image_context [Hash]
            #   Optional. Image context and/or feature-specific parameters.
            #
            # @yield [result, operation] Access the result along with the RPC operation
            # @yieldparam result [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse, Gapic::Operation]
            # @yieldparam operation [GRPC::ActiveCall::Operation]
            #
            # @return [Google::Cloud::Vision::V1p4beta1::BatchAnnotateImagesResponse] if async is `false`.
            # @return [Gapic::Operation] if async is `true`.
            #
            # @raise [Google::Cloud::Error] if the RPC is aborted.
            #
            # @example
            #   require "google/cloud/vision/v1p4beta1"
            #
            #   image_annotator_client = Google::Cloud::Vision::V1p4beta1::ImageAnnotator::Client.new
            #
            #   response = image_annotator_client.web_detection image: "path/to/image.png"
            #   response.responses.each do |res|
            #     puts res
            #   end
            #
            def web_detection \
                images: [],
                image: nil,
                max_results: 10,
                options: nil,
                async: false,
                mime_type: nil,
                batch_size: 10,
                destination: nil,
                image_context: nil,
                &block

              feature = { type: :WEB_DETECTION, max_results: max_results }
              images << image if image
              formatted_images = images.map do |img|
                formatted_image = normalize_image img
                formatted_image[:mime_type] = mime_type if mime_type
                formatted_image
              end
              requests = formatted_images.map do |img|
                request = { image: img, features: [feature] }
                request[:image_context] = image_context if image_context
                request
              end
              batch_request = { requests: requests }

              if async
                requests.map! do |request|
                  {
                    input_config:  {
                      gcs_source: {
                        uri: request[:image][:source][:gcs_image_uri]
                      },
                      mime_type:  mime_type
                    },
                    features:      request[:features],
                    output_config: {
                      gcs_destination: {
                        uri: destination
                      },
                      batch_size:      batch_size
                    }
                  }
                end
                async_batch_annotate_files batch_request, options, &block
              else
                batch_annotate_images batch_request, options, &block
              end
            end

            private

            def normalize_image image
              formatted_image =
                if image.respond_to? :binmode
                  { content: image.binmode.read }
                elsif image.is_a? String
                  if File.file? image
                    { content: File.binread(image) }
                  elsif image =~ URI::DEFAULT_PARSER.make_regexp
                    if URI(image).scheme == "gs"
                      { source: { gcs_image_uri: image } }
                    else
                      { source: { image_uri: image } }
                    end
                  end
                end
              raise TypeError, "Image must be a filepath, url, or IO object" unless formatted_image
              formatted_image
            end
          end
        end
      end
    end
  end
end

# rubocop:enable Style/Documentation
