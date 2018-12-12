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
# # limitations under the License.


require "uri"

module Google
  module Cloud
    module Vision
      module V1p3beta1
        class ImageAnnotatorClient

          # @param images [Array<String>, Array<File>]
          #   An array containing files, file paths, io objects, image urls, or Google Cloud Storage urls. Can be used with or instead of image.
          # @param image [File, String]
          #   A file, file path, io object, url pointing to an image, or Google Cloud Storage url. Can be used with or instead of images.
          # @param max_results [Integer]
          #   Optional. Defaults to 10.
          # @param options [Google::Gax::CallOptions]
          #   Optional. Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @param async [Boolean]
          #   Optional. Defaults to false. Specifies whether to preform the request synchronously and return a 
          #   BatchAnnotateImagesResponse instance or to return a Google::Gax::Operation.
          # @param mime_type [String]
          #   Required only if async is true.
          # @param batch_size [Integer]
          #   Optional. Defaults to 10. When async is true, this specifies the number of input files per output json.
          # @param destination [String]
          #   Required only if async is true. A Google Cloud Storage location for storing the output.
          # @param image_context [Hash<Any>]
          #   Optional. Image context and/or feature-specific parameters.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse, Google::Gax::Operation]
          # @example
          #   require "google/cloud/vision"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1p3beta1)
          #
          #   response = image_annotator_client.face_detection image: "path\to\image.png"
          #   response.responses.each do |res|
          #     puts res
          #   end

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
            &blk

            feature = { type: :FACE_DETECTION }
            feature[:max_results] = max_results
            images << image if image

            formatted_images = images.map do |img|
              formatted_image = normalize_image img
              formatted_image[:mime_type] = mime_type if mime_type
              formatted_image
            end

            requests = formatted_images.map do |img|
              request = {
                image: img,
                features: [feature]
              }
              request[:image_context] = image_context if image_context
              request
            end

            if async
              requests.map! do |request|
                {
                  input_config: {
                    gcs_source: {
                      uri: request[:image][:source][:gcs_image_uri]
                    },
                    mime_type: mime_type
                  },
                  features: request[:features],
                  output_config: {
                    gcs_destination: {
                      uri: destination
                    },
                    batch_size: batch_size
                  }
                }
              end
              async_batch_annotate_files requests, options: options
            else
              batch_annotate_images requests, options: options, &blk
            end
          end

          # @param images [Array<String>, Array<File>]
          #   An array containing files, file paths, io objects, image urls, or Google Cloud Storage urls. Can be used with or instead of image.
          # @param image [File, String]
          #   A file, file path, io object, url pointing to an image, or Google Cloud Storage url. Can be used with or instead of images.
          # @param max_results [Integer]
          #   Optional. Defaults to 10.
          # @param options [Google::Gax::CallOptions]
          #   Optional. Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @param async [Boolean]
          #   Optional. Defaults to false. Specifies whether to preform the request synchronously and return a 
          #   BatchAnnotateImagesResponse instance or to return a Google::Gax::Operation.
          # @param mime_type [String]
          #   Required only if async is true.
          # @param batch_size [Integer]
          #   Optional. Defaults to 10. When async is true, this specifies the number of input files per output json.
          # @param destination [String]
          #   Required only if async is true. A Google Cloud Storage location for storing the output.
          # @param image_context [Hash<Any>]
          #   Optional. Image context and/or feature-specific parameters.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse, Google::Gax::Operation]
          # @example
          #   require "google/cloud/vision"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1p3beta1)
          #
          #   response = image_annotator_client.landmark_detection image: "path\to\image.png"
          #   response.responses.each do |res|
          #     puts res
          #   end

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
            &blk

            feature = { type: :LANDMARK_DETECTION }
            feature[:max_results] = max_results
            images << image if image

            formatted_images = images.map do |img|
              formatted_image = normalize_image img
              formatted_image[:mime_type] = mime_type if mime_type
              formatted_image
            end

            requests = formatted_images.map do |img|
              request = {
                image: img,
                features: [feature]
              }
              request[:image_context] = image_context if image_context
              request
            end

            if async
              requests.map! do |request|
                {
                  input_config: {
                    gcs_source: {
                      uri: request[:image][:source][:gcs_image_uri]
                    },
                    mime_type: mime_type
                  },
                  features: request[:features],
                  output_config: {
                    gcs_destination: {
                      uri: destination
                    },
                    batch_size: batch_size
                  }
                }
              end
              async_batch_annotate_files requests, options: options
            else
              batch_annotate_images requests, options: options, &blk
            end
          end

          # @param images [Array<String>, Array<File>]
          #   An array containing files, file paths, io objects, image urls, or Google Cloud Storage urls. Can be used with or instead of image.
          # @param image [File, String]
          #   A file, file path, io object, url pointing to an image, or Google Cloud Storage url. Can be used with or instead of images.
          # @param max_results [Integer]
          #   Optional. Defaults to 10.
          # @param options [Google::Gax::CallOptions]
          #   Optional. Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @param async [Boolean]
          #   Optional. Defaults to false. Specifies whether to preform the request synchronously and return a 
          #   BatchAnnotateImagesResponse instance or to return a Google::Gax::Operation.
          # @param mime_type [String]
          #   Required only if async is true.
          # @param batch_size [Integer]
          #   Optional. Defaults to 10. When async is true, this specifies the number of input files per output json.
          # @param destination [String]
          #   Required only if async is true. A Google Cloud Storage location for storing the output.
          # @param image_context [Hash<Any>]
          #   Optional. Image context and/or feature-specific parameters.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse, Google::Gax::Operation]
          # @example
          #   require "google/cloud/vision"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1p3beta1)
          #
          #   response = image_annotator_client.logo_detection image: "path\to\image.png"
          #   response.responses.each do |res|
          #     puts res
          #   end

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
            &blk

            feature = { type: :LOGO_DETECTION }
            feature[:max_results] = max_results
            images << image if image

            formatted_images = images.map do |img|
              formatted_image = normalize_image img
              formatted_image[:mime_type] = mime_type if mime_type
              formatted_image
            end

            requests = formatted_images.map do |img|
              request = {
                image: img,
                features: [feature]
              }
              request[:image_context] = image_context if image_context
              request
            end

            if async
              requests.map! do |request|
                {
                  input_config: {
                    gcs_source: {
                      uri: request[:image][:source][:gcs_image_uri]
                    },
                    mime_type: mime_type
                  },
                  features: request[:features],
                  output_config: {
                    gcs_destination: {
                      uri: destination
                    },
                    batch_size: batch_size
                  }
                }
              end
              async_batch_annotate_files requests, options: options
            else
              batch_annotate_images requests, options: options, &blk
            end
          end

          # @param images [Array<String>, Array<File>]
          #   An array containing files, file paths, io objects, image urls, or Google Cloud Storage urls. Can be used with or instead of image.
          # @param image [File, String]
          #   A file, file path, io object, url pointing to an image, or Google Cloud Storage url. Can be used with or instead of images.
          # @param max_results [Integer]
          #   Optional. Defaults to 10.
          # @param options [Google::Gax::CallOptions]
          #   Optional. Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @param async [Boolean]
          #   Optional. Defaults to false. Specifies whether to preform the request synchronously and return a 
          #   BatchAnnotateImagesResponse instance or to return a Google::Gax::Operation.
          # @param mime_type [String]
          #   Required only if async is true.
          # @param batch_size [Integer]
          #   Optional. Defaults to 10. When async is true, this specifies the number of input files per output json.
          # @param destination [String]
          #   Required only if async is true. A Google Cloud Storage location for storing the output.
          # @param image_context [Hash<Any>]
          #   Optional. Image context and/or feature-specific parameters.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse, Google::Gax::Operation]
          # @example
          #   require "google/cloud/vision"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1p3beta1)
          #
          #   response = image_annotator_client.label_detection image: "path\to\image.png"
          #   response.responses.each do |res|
          #     puts res
          #   end

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
            &blk

            feature = { type: :LABEL_DETECTION }
            feature[:max_results] = max_results
            images << image if image

            formatted_images = images.map do |img|
              formatted_image = normalize_image img
              formatted_image[:mime_type] = mime_type if mime_type
              formatted_image
            end

            requests = formatted_images.map do |img|
              request = {
                image: img,
                features: [feature]
              }
              request[:image_context] = image_context if image_context
              request
            end

            if async
              requests.map! do |request|
                {
                  input_config: {
                    gcs_source: {
                      uri: request[:image][:source][:gcs_image_uri]
                    },
                    mime_type: mime_type
                  },
                  features: request[:features],
                  output_config: {
                    gcs_destination: {
                      uri: destination
                    },
                    batch_size: batch_size
                  }
                }
              end
              async_batch_annotate_files requests, options: options
            else
              batch_annotate_images requests, options: options, &blk
            end
          end

          # @param images [Array<String>, Array<File>]
          #   An array containing files, file paths, io objects, image urls, or Google Cloud Storage urls. Can be used with or instead of image.
          # @param image [File, String]
          #   A file, file path, io object, url pointing to an image, or Google Cloud Storage url. Can be used with or instead of images.
          # @param max_results [Integer]
          #   Optional. Defaults to 10.
          # @param options [Google::Gax::CallOptions]
          #   Optional. Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @param async [Boolean]
          #   Optional. Defaults to false. Specifies whether to preform the request synchronously and return a 
          #   BatchAnnotateImagesResponse instance or to return a Google::Gax::Operation.
          # @param mime_type [String]
          #   Required only if async is true.
          # @param batch_size [Integer]
          #   Optional. Defaults to 10. When async is true, this specifies the number of input files per output json.
          # @param destination [String]
          #   Required only if async is true. A Google Cloud Storage location for storing the output.
          # @param image_context [Hash<Any>]
          #   Optional. Image context and/or feature-specific parameters.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse, Google::Gax::Operation]
          # @example
          #   require "google/cloud/vision"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1p3beta1)
          #
          #   response = image_annotator_client.text_detection image: "path\to\image.png"
          #   response.responses.each do |res|
          #     puts res
          #   end

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
            &blk

            feature = { type: :TEXT_DETECTION }
            feature[:max_results] = max_results
            images << image if image

            formatted_images = images.map do |img|
              formatted_image = normalize_image img
              formatted_image[:mime_type] = mime_type if mime_type
              formatted_image
            end

            requests = formatted_images.map do |img|
              request = {
                image: img,
                features: [feature]
              }
              request[:image_context] = image_context if image_context
              request
            end

            if async
              requests.map! do |request|
                {
                  input_config: {
                    gcs_source: {
                      uri: request[:image][:source][:gcs_image_uri]
                    },
                    mime_type: mime_type
                  },
                  features: request[:features],
                  output_config: {
                    gcs_destination: {
                      uri: destination
                    },
                    batch_size: batch_size
                  }
                }
              end
              async_batch_annotate_files requests, options: options
            else
              batch_annotate_images requests, options: options, &blk
            end
          end

          # @param images [Array<String>, Array<File>]
          #   An array containing files, file paths, io objects, image urls, or Google Cloud Storage urls. Can be used with or instead of image.
          # @param image [File, String]
          #   A file, file path, io object, url pointing to an image, or Google Cloud Storage url. Can be used with or instead of images.
          # @param max_results [Integer]
          #   Optional. Defaults to 10.
          # @param options [Google::Gax::CallOptions]
          #   Optional. Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @param async [Boolean]
          #   Optional. Defaults to false. Specifies whether to preform the request synchronously and return a 
          #   BatchAnnotateImagesResponse instance or to return a Google::Gax::Operation.
          # @param mime_type [String]
          #   Required only if async is true.
          # @param batch_size [Integer]
          #   Optional. Defaults to 10. When async is true, this specifies the number of input files per output json.
          # @param destination [String]
          #   Required only if async is true. A Google Cloud Storage location for storing the output.
          # @param image_context [Hash<Any>]
          #   Optional. Image context and/or feature-specific parameters.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse, Google::Gax::Operation]
          # @example
          #   require "google/cloud/vision"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1p3beta1)
          #
          #   response = image_annotator_client.document_text_detection image: "path\to\image.png"
          #   response.responses.each do |res|
          #     puts res
          #   end

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
            &blk

            feature = { type: :DOCUMENT_TEXT_DETECTION }
            feature[:max_results] = max_results
            images << image if image

            formatted_images = images.map do |img|
              formatted_image = normalize_image img
              formatted_image[:mime_type] = mime_type if mime_type
              formatted_image
            end

            requests = formatted_images.map do |img|
              request = {
                image: img,
                features: [feature]
              }
              request[:image_context] = image_context if image_context
              request
            end

            if async
              requests.map! do |request|
                {
                  input_config: {
                    gcs_source: {
                      uri: request[:image][:source][:gcs_image_uri]
                    },
                    mime_type: mime_type
                  },
                  features: request[:features],
                  output_config: {
                    gcs_destination: {
                      uri: destination
                    },
                    batch_size: batch_size
                  }
                }
              end
              async_batch_annotate_files requests, options: options
            else
              batch_annotate_images requests, options: options, &blk
            end
          end

          # @param images [Array<String>, Array<File>]
          #   An array containing files, file paths, io objects, image urls, or Google Cloud Storage urls. Can be used with or instead of image.
          # @param image [File, String]
          #   A file, file path, io object, url pointing to an image, or Google Cloud Storage url. Can be used with or instead of images.
          # @param max_results [Integer]
          #   Optional. Defaults to 10.
          # @param options [Google::Gax::CallOptions]
          #   Optional. Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @param async [Boolean]
          #   Optional. Defaults to false. Specifies whether to preform the request synchronously and return a 
          #   BatchAnnotateImagesResponse instance or to return a Google::Gax::Operation.
          # @param mime_type [String]
          #   Required only if async is true.
          # @param batch_size [Integer]
          #   Optional. Defaults to 10. When async is true, this specifies the number of input files per output json.
          # @param destination [String]
          #   Required only if async is true. A Google Cloud Storage location for storing the output.
          # @param image_context [Hash<Any>]
          #   Optional. Image context and/or feature-specific parameters.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse, Google::Gax::Operation]
          # @example
          #   require "google/cloud/vision"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1p3beta1)
          #
          #   response = image_annotator_client.safe_search_detection image: "path\to\image.png"
          #   response.responses.each do |res|
          #     puts res
          #   end

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
            &blk

            feature = { type: :SAFE_SEARCH_DETECTION }
            feature[:max_results] = max_results
            images << image if image

            formatted_images = images.map do |img|
              formatted_image = normalize_image img
              formatted_image[:mime_type] = mime_type if mime_type
              formatted_image
            end

            requests = formatted_images.map do |img|
              request = {
                image: img,
                features: [feature]
              }
              request[:image_context] = image_context if image_context
              request
            end

            if async
              requests.map! do |request|
                {
                  input_config: {
                    gcs_source: {
                      uri: request[:image][:source][:gcs_image_uri]
                    },
                    mime_type: mime_type
                  },
                  features: request[:features],
                  output_config: {
                    gcs_destination: {
                      uri: destination
                    },
                    batch_size: batch_size
                  }
                }
              end
              async_batch_annotate_files requests, options: options
            else
              batch_annotate_images requests, options: options, &blk
            end
          end

          # @param images [Array<String>, Array<File>]
          #   An array containing files, file paths, io objects, image urls, or Google Cloud Storage urls. Can be used with or instead of image.
          # @param image [File, String]
          #   A file, file path, io object, url pointing to an image, or Google Cloud Storage url. Can be used with or instead of images.
          # @param max_results [Integer]
          #   Optional. Defaults to 10.
          # @param options [Google::Gax::CallOptions]
          #   Optional. Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @param async [Boolean]
          #   Optional. Defaults to false. Specifies whether to preform the request synchronously and return a 
          #   BatchAnnotateImagesResponse instance or to return a Google::Gax::Operation.
          # @param mime_type [String]
          #   Required only if async is true.
          # @param batch_size [Integer]
          #   Optional. Defaults to 10. When async is true, this specifies the number of input files per output json.
          # @param destination [String]
          #   Required only if async is true. A Google Cloud Storage location for storing the output.
          # @param image_context [Hash<Any>]
          #   Optional. Image context and/or feature-specific parameters.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse, Google::Gax::Operation]
          # @example
          #   require "google/cloud/vision"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1p3beta1)
          #
          #   response = image_annotator_client.image_properties_detection image: "path\to\image.png"
          #   response.responses.each do |res|
          #     puts res
          #   end

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
            &blk

            feature = { type: :IMAGE_PROPERTIES }
            feature[:max_results] = max_results
            images << image if image

            formatted_images = images.map do |img|
              formatted_image = normalize_image img
              formatted_image[:mime_type] = mime_type if mime_type
              formatted_image
            end

            requests = formatted_images.map do |img|
              request = {
                image: img,
                features: [feature]
              }
              request[:image_context] = image_context if image_context
              request
            end

            if async
              requests.map! do |request|
                {
                  input_config: {
                    gcs_source: {
                      uri: request[:image][:source][:gcs_image_uri]
                    },
                    mime_type: mime_type
                  },
                  features: request[:features],
                  output_config: {
                    gcs_destination: {
                      uri: destination
                    },
                    batch_size: batch_size
                  }
                }
              end
              async_batch_annotate_files requests, options: options
            else
              batch_annotate_images requests, options: options, &blk
            end
          end

          # @param images [Array<String>, Array<File>]
          #   An array containing files, file paths, io objects, image urls, or Google Cloud Storage urls. Can be used with or instead of image.
          # @param image [File, String]
          #   A file, file path, io object, url pointing to an image, or Google Cloud Storage url. Can be used with or instead of images.
          # @param max_results [Integer]
          #   Optional. Defaults to 10.
          # @param options [Google::Gax::CallOptions]
          #   Optional. Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @param async [Boolean]
          #   Optional. Defaults to false. Specifies whether to preform the request synchronously and return a 
          #   BatchAnnotateImagesResponse instance or to return a Google::Gax::Operation.
          # @param mime_type [String]
          #   Required only if async is true.
          # @param batch_size [Integer]
          #   Optional. Defaults to 10. When async is true, this specifies the number of input files per output json.
          # @param destination [String]
          #   Required only if async is true. A Google Cloud Storage location for storing the output.
          # @param image_context [Hash<Any>]
          #   Optional. Image context and/or feature-specific parameters.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse, Google::Gax::Operation]
          # @example
          #   require "google/cloud/vision"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1p3beta1)
          #
          #   response = image_annotator_client.web_detection image: "path\to\image.png"
          #   response.responses.each do |res|
          #     puts res
          #   end

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
            &blk

            feature = { type: :WEB_DETECTION }
            feature[:max_results] = max_results
            images << image if image

            formatted_images = images.map do |img|
              formatted_image = normalize_image img
              formatted_image[:mime_type] = mime_type if mime_type
              formatted_image
            end

            requests = formatted_images.map do |img|
              request = {
                image: img,
                features: [feature]
              }
              request[:image_context] = image_context if image_context
              request
            end

            if async
              requests.map! do |request|
                {
                  input_config: {
                    gcs_source: {
                      uri: request[:image][:source][:gcs_image_uri]
                    },
                    mime_type: mime_type
                  },
                  features: request[:features],
                  output_config: {
                    gcs_destination: {
                      uri: destination
                    },
                    batch_size: batch_size
                  }
                }
              end
              async_batch_annotate_files requests, options: options
            else
              batch_annotate_images requests, options: options, &blk
            end
          end

          # @param images [Array<String>, Array<File>]
          #   An array containing files, file paths, io objects, image urls, or Google Cloud Storage urls. Can be used with or instead of image.
          # @param image [File, String]
          #   A file, file path, io object, url pointing to an image, or Google Cloud Storage url. Can be used with or instead of images.
          # @param max_results [Integer]
          #   Optional. Defaults to 10.
          # @param options [Google::Gax::CallOptions]
          #   Optional. Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @param async [Boolean]
          #   Optional. Defaults to false. Specifies whether to preform the request synchronously and return a 
          #   BatchAnnotateImagesResponse instance or to return a Google::Gax::Operation.
          # @param mime_type [String]
          #   Required only if async is true.
          # @param batch_size [Integer]
          #   Optional. Defaults to 10. When async is true, this specifies the number of input files per output json.
          # @param destination [String]
          #   Required only if async is true. A Google Cloud Storage location for storing the output.
          # @param image_context [Hash<Any>]
          #   Optional. Image context and/or feature-specific parameters.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse, Google::Gax::Operation]
          # @example
          #   require "google/cloud/vision"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1p3beta1)
          #
          #   response = image_annotator_client.product_search_detection image: "path\to\image.png"
          #   response.responses.each do |res|
          #     puts res
          #   end

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
            &blk

            feature = { type: :PRODUCT_SEARCH }
            feature[:max_results] = max_results
            images << image if image

            formatted_images = images.map do |img|
              formatted_image = normalize_image img
              formatted_image[:mime_type] = mime_type if mime_type
              formatted_image
            end

            requests = formatted_images.map do |img|
              request = {
                image: img,
                features: [feature]
              }
              request[:image_context] = image_context if image_context
              request
            end

            if async
              requests.map! do |request|
                {
                  input_config: {
                    gcs_source: {
                      uri: request[:image][:source][:gcs_image_uri]
                    },
                    mime_type: mime_type
                  },
                  features: request[:features],
                  output_config: {
                    gcs_destination: {
                      uri: destination
                    },
                    batch_size: batch_size
                  }
                }
              end
              async_batch_annotate_files requests, options: options
            else
              batch_annotate_images requests, options: options, &blk
            end
          end

          # @param images [Array<String>, Array<File>]
          #   An array containing files, file paths, io objects, image urls, or Google Cloud Storage urls. Can be used with or instead of image.
          # @param image [File, String]
          #   A file, file path, io object, url pointing to an image, or Google Cloud Storage url. Can be used with or instead of images.
          # @param max_results [Integer]
          #   Optional. Defaults to 10.
          # @param options [Google::Gax::CallOptions]
          #   Optional. Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @param async [Boolean]
          #   Optional. Defaults to false. Specifies whether to preform the request synchronously and return a 
          #   BatchAnnotateImagesResponse instance or to return a Google::Gax::Operation.
          # @param mime_type [String]
          #   Required only if async is true.
          # @param batch_size [Integer]
          #   Optional. Defaults to 10. When async is true, this specifies the number of input files per output json.
          # @param destination [String]
          #   Required only if async is true. A Google Cloud Storage location for storing the output.
          # @param image_context [Hash<Any>]
          #   Optional. Image context and/or feature-specific parameters.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse, Google::Gax::Operation]
          # @example
          #   require "google/cloud/vision"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1p3beta1)
          #
          #   response = image_annotator_client.object_localization_detection image: "path\to\image.png"
          #   response.responses.each do |res|
          #     puts res
          #   end

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
            &blk

            feature = { type: :OBJECT_LOCALIZATION }
            feature[:max_results] = max_results
            images << image if image

            formatted_images = images.map do |img|
              formatted_image = normalize_image img
              formatted_image[:mime_type] = mime_type if mime_type
              formatted_image
            end

            requests = formatted_images.map do |img|
              request = {
                image: img,
                features: [feature]
              }
              request[:image_context] = image_context if image_context
              request
            end

            if async
              requests.map! do |request|
                {
                  input_config: {
                    gcs_source: {
                      uri: request[:image][:source][:gcs_image_uri]
                    },
                    mime_type: mime_type
                  },
                  features: request[:features],
                  output_config: {
                    gcs_destination: {
                      uri: destination
                    },
                    batch_size: batch_size
                  }
                }
              end
              async_batch_annotate_files requests, options: options
            else
              batch_annotate_images requests, options: options, &blk
            end
          end

          # @param images [Array<String>, Array<File>]
          #   An array containing files, file paths, io objects, image urls, or Google Cloud Storage urls. Can be used with or instead of image.
          # @param image [File, String]
          #   A file, file path, io object, url pointing to an image, or Google Cloud Storage url. Can be used with or instead of images.
          # @param max_results [Integer]
          #   Optional. Defaults to 10.
          # @param options [Google::Gax::CallOptions]
          #   Optional. Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @param async [Boolean]
          #   Optional. Defaults to false. Specifies whether to preform the request synchronously and return a 
          #   BatchAnnotateImagesResponse instance or to return a Google::Gax::Operation.
          # @param mime_type [String]
          #   Required only if async is true.
          # @param batch_size [Integer]
          #   Optional. Defaults to 10. When async is true, this specifies the number of input files per output json.
          # @param destination [String]
          #   Required only if async is true. A Google Cloud Storage location for storing the output.
          # @param image_context [Hash<Any>]
          #   Optional. Image context and/or feature-specific parameters.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1p3beta1::BatchAnnotateImagesResponse, Google::Gax::Operation]
          # @example
          #   require "google/cloud/vision"
          #
          #   image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new(version: :v1p3beta1)
          #
          #   response = image_annotator_client.crop_hints_detection image: "path\to\image.png"
          #   response.responses.each do |res|
          #     puts res
          #   end

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
            &blk

            feature = { type: :CROP_HINTS }
            feature[:max_results] = max_results
            images << image if image

            formatted_images = images.map do |img|
              formatted_image = normalize_image img
              formatted_image[:mime_type] = mime_type if mime_type
              formatted_image
            end

            requests = formatted_images.map do |img|
              request = {
                image: img,
                features: [feature]
              }
              request[:image_context] = image_context if image_context
              request
            end

            if async
              requests.map! do |request|
                {
                  input_config: {
                    gcs_source: {
                      uri: request[:image][:source][:gcs_image_uri]
                    },
                    mime_type: mime_type
                  },
                  features: request[:features],
                  output_config: {
                    gcs_destination: {
                      uri: destination
                    },
                    batch_size: batch_size
                  }
                }
              end
              async_batch_annotate_files requests, options: options
            else
              batch_annotate_images requests, options: options, &blk
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
            raise TypeError.new("Image must be a filepath, url, or IO object") unless formatted_image
            formatted_image
          end
        end

        class ProductSearchClient
          # Alias for Google::Cloud::Vision::V1p3beta1::ProductSearchClient.location_path.
          # @param project [String]
          # @param location [String]
          # @return [String]
          def location_path project, location
            self.class.location_path project, location
          end
          
          # Alias for Google::Cloud::Vision::V1p3beta1::ProductSearchClient.product_set_path.
          # @param project [String]
          # @param location [String]
          # @param product_set [String]
          # @return [String]
          def product_set_path project, location, product_set
            self.class.product_set_path project, location, product_set
          end
          
          # Alias for Google::Cloud::Vision::V1p3beta1::ProductSearchClient.product_path.
          # @param project [String]
          # @param location [String]
          # @param product [String]
          # @return [String]
          def product_path project, location, product
            self.class.product_path project, location, product
          end
          
          # Alias for Google::Cloud::Vision::V1p3beta1::ProductSearchClient.reference_image_path.
          # @param project [String]
          # @param location [String]
          # @param product [String]
          # @param reference_image [String]
          # @return [String]
          def reference_image_path project, location, product, reference_image
            self.class.reference_image_path project, location, product, reference_image
          end
        end
      end
    end
  end
end
