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
      module V1p3beta1
        # Parameters for a product search request.
        # @!attribute [rw] catalog_name
        #   @return [String]
        #     The resource name of the catalog to search.
        #
        #     Format is: `productSearch/catalogs/CATALOG_NAME`.
        # @!attribute [rw] category
        #   @return [Google::Cloud::Vision::V1p3beta1::ProductSearchCategory]
        #     The category to search in.
        #     Optional. It is inferred by the system if it is not specified.
        #     [Deprecated] Use `product_category`.
        # @!attribute [rw] product_category
        #   @return [String]
        #     The product category to search in.
        #     Optional. It is inferred by the system if it is not specified.
        #     Supported values are `bag`, `shoe`, `sunglasses`, `dress`, `outerwear`,
        #     `skirt`, `top`, `shorts`, and `pants`.
        # @!attribute [rw] normalized_bounding_poly
        #   @return [Google::Cloud::Vision::V1p3beta1::NormalizedBoundingPoly]
        #     The bounding polygon around the area of interest in the image.
        #     Optional. If it is not specified, system discretion will be applied.
        #     [Deprecated] Use `bounding_poly`.
        # @!attribute [rw] bounding_poly
        #   @return [Google::Cloud::Vision::V1p3beta1::BoundingPoly]
        #     The bounding polygon around the area of interest in the image.
        #     Optional. If it is not specified, system discretion will be applied.
        # @!attribute [rw] view
        #   @return [Google::Cloud::Vision::V1p3beta1::ProductSearchResultsView]
        #     Specifies the verbosity of the  product search results.
        #     Optional. Defaults to `BASIC`.
        # @!attribute [rw] product_set
        #   @return [String]
        #     The resource name of a {Google::Cloud::Vision::V1p3beta1::ProductSet ProductSet} to be searched for similar images.
        #
        #     Format is:
        #     `projects/PROJECT_ID/locations/LOC_ID/productSets/PRODUCT_SET_ID`.
        # @!attribute [rw] product_categories
        #   @return [Array<String>]
        #     The list of product categories to search in. Currently, we only consider
        #     the first category, and either "homegoods" or "apparel" should be
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
        # @!attribute [rw] category
        #   @return [Google::Cloud::Vision::V1p3beta1::ProductSearchCategory]
        #     Product category.
        #     [Deprecated] Use `product_category`.
        # @!attribute [rw] product_category
        #   @return [String]
        #     Product category.
        #     Supported values are `bag` and `shoe`.
        #     [Deprecated] `product_category` is provided in each Product.
        # @!attribute [rw] index_time
        #   @return [Google::Protobuf::Timestamp]
        #     Timestamp of the index which provided these results. Changes made after
        #     this time are not reflected in the current results.
        # @!attribute [rw] products
        #   @return [Array<Google::Cloud::Vision::V1p3beta1::ProductSearchResults::ProductInfo>]
        #     List of detected products.
        # @!attribute [rw] results
        #   @return [Array<Google::Cloud::Vision::V1p3beta1::ProductSearchResults::Result>]
        #     List of results, one for each product match.
        class ProductSearchResults
          # Information about a product.
          # @!attribute [rw] product_id
          #   @return [String]
          #     Product ID.
          # @!attribute [rw] image_uri
          #   @return [String]
          #     The URI of the image which matched the query image.
          #
          #     This field is returned only if `view` is set to `FULL` in
          #     the request.
          # @!attribute [rw] score
          #   @return [Float]
          #     A confidence level on the match, ranging from 0 (no confidence) to
          #     1 (full confidence).
          #
          #     This field is returned only if `view` is set to `FULL` in
          #     the request.
          class ProductInfo; end

          # Information about a product.
          # @!attribute [rw] product
          #   @return [Google::Cloud::Vision::V1p3beta1::Product]
          #     The Product.
          # @!attribute [rw] score
          #   @return [Float]
          #     A confidence level on the match, ranging from 0 (no confidence) to
          #     1 (full confidence).
          #
          #     This field is returned only if `view` is set to `FULL` in
          #     the request.
          # @!attribute [rw] image
          #   @return [String]
          #     The resource name of the image from the product that is the closest match
          #     to the query.
          class Result; end
        end

        # Supported product search categories.
        module ProductSearchCategory
          # Default value used when a category is not specified.
          PRODUCT_SEARCH_CATEGORY_UNSPECIFIED = 0

          # Shoes category.
          SHOES = 1

          # Bags category.
          BAGS = 2
        end

        # Specifies the fields to include in product search results.
        module ProductSearchResultsView
          # Product search results contain only `product_category` and `product_id`.
          # Default value.
          BASIC = 0

          # Product search results contain `product_category`, `product_id`,
          # `image_uri`, and `score`.
          FULL = 1
        end
      end
    end
  end
end