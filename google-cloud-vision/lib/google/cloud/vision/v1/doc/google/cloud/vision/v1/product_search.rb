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


module Google
  module Cloud
    module Vision
      module V1
        # Parameters for a product search request.
        # @!attribute [rw] bounding_poly
        #   @return [Google::Cloud::Vision::V1::BoundingPoly]
        #     The bounding polygon around the area of interest in the image.
        #     Optional. If it is not specified, system discretion will be applied.
        # @!attribute [rw] product_set
        #   @return [String]
        #     The resource name of a {Google::Cloud::Vision::V1::ProductSet ProductSet} to be searched for similar images.
        #
        #     Format is:
        #     `projects/PROJECT_ID/locations/LOC_ID/productSets/PRODUCT_SET_ID`.
        # @!attribute [rw] product_categories
        #   @return [Array<String>]
        #     The list of product categories to search in. Currently, we only consider
        #     the first category, and either "homegoods", "apparel", or "toys" should be
        #     specified.
        # @!attribute [rw] filter
        #   @return [String]
        #     The filtering expression. This can be used to restrict search results based
        #     on Product labels. We currently support an AND of OR of key-value
        #     expressions, where each expression within an OR must have the same key.
        #
        #     For example, "(color = red OR color = blue) AND brand = Google" is
        #     acceptable, but not "(color = red OR brand = Google)" or "color: red".
        class ProductSearchParams; end

        # Results for a product search request.
        # @!attribute [rw] index_time
        #   @return [Google::Protobuf::Timestamp]
        #     Timestamp of the index which provided these results. Changes made after
        #     this time are not reflected in the current results.
        # @!attribute [rw] results
        #   @return [Array<Google::Cloud::Vision::V1::ProductSearchResults::Result>]
        #     List of results, one for each product match.
        # @!attribute [rw] product_grouped_results
        #   @return [Array<Google::Cloud::Vision::V1::ProductSearchResults::GroupedResult>]
        #     List of results grouped by products detected in the query image. Each entry
        #     corresponds to one bounding polygon in the query image, and contains the
        #     matching products specific to that region. There may be duplicate product
        #     matches in the union of all the per-product results.
        class ProductSearchResults
          # Information about a product.
          # @!attribute [rw] product
          #   @return [Google::Cloud::Vision::V1::Product]
          #     The Product.
          # @!attribute [rw] score
          #   @return [Float]
          #     A confidence level on the match, ranging from 0 (no confidence) to
          #     1 (full confidence).
          # @!attribute [rw] image
          #   @return [String]
          #     The resource name of the image from the product that is the closest match
          #     to the query.
          class Result; end

          # Information about the products similar to a single product in a query
          # image.
          # @!attribute [rw] bounding_poly
          #   @return [Google::Cloud::Vision::V1::BoundingPoly]
          #     The bounding polygon around the product detected in the query image.
          # @!attribute [rw] results
          #   @return [Array<Google::Cloud::Vision::V1::ProductSearchResults::Result>]
          #     List of results, one for each product match.
          class GroupedResult; end
        end
      end
    end
  end
end