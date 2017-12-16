# Copyright 2017 Google LLC
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

module Google
  module Cloud
    module Vision
      module V1
        # Relevant information for the image from the Internet.
        # @!attribute [rw] web_entities
        #   @return [Array<Google::Cloud::Vision::V1::WebDetection::WebEntity>]
        #     Deduced entities from similar images on the Internet.
        # @!attribute [rw] full_matching_images
        #   @return [Array<Google::Cloud::Vision::V1::WebDetection::WebImage>]
        #     Fully matching images from the Internet.
        #     They're definite neardups and most often a copy of the query image with
        #     merely a size change.
        # @!attribute [rw] partial_matching_images
        #   @return [Array<Google::Cloud::Vision::V1::WebDetection::WebImage>]
        #     Partial matching images from the Internet.
        #     Those images are similar enough to share some key-point features. For
        #     example an original image will likely have partial matching for its crops.
        # @!attribute [rw] pages_with_matching_images
        #   @return [Array<Google::Cloud::Vision::V1::WebDetection::WebPage>]
        #     Web pages containing the matching images from the Internet.
        class WebDetection
          # Entity deduced from similar images on the Internet.
          # @!attribute [rw] entity_id
          #   @return [String]
          #     Opaque entity ID.
          # @!attribute [rw] score
          #   @return [Float]
          #     Overall relevancy score for the entity.
          #     Not normalized and not comparable across different image queries.
          # @!attribute [rw] description
          #   @return [String]
          #     Canonical description of the entity, in English.
          class WebEntity; end

          # Metadata for online images.
          # @!attribute [rw] url
          #   @return [String]
          #     The result image URL.
          # @!attribute [rw] score
          #   @return [Float]
          #     Overall relevancy score for the image.
          #     Not normalized and not comparable across different image queries.
          class WebImage; end

          # Metadata for web pages.
          # @!attribute [rw] url
          #   @return [String]
          #     The result web page URL.
          # @!attribute [rw] score
          #   @return [Float]
          #     Overall relevancy score for the web page.
          #     Not normalized and not comparable across different image queries.
          class WebPage; end
        end
      end
    end
  end
end