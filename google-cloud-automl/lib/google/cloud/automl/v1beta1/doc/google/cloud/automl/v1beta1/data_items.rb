# Copyright 2019 Google LLC
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
    module AutoML
      module V1beta1
        # A representation of an image.
        # Only images up to 30MB in size are supported.
        # @!attribute [rw] image_bytes
        #   @return [String]
        #     Image content represented as a stream of bytes.
        #     Note: As with all `bytes` fields, protobuffers use a pure binary
        #     representation, whereas JSON representations use base64.
        # @!attribute [rw] input_config
        #   @return [Google::Cloud::AutoML::V1beta1::InputConfig]
        #     An input config specifying the content of the image.
        # @!attribute [rw] thumbnail_uri
        #   @return [String]
        #     Output only. HTTP URI to the thumbnail image.
        class Image; end

        # A representation of a text snippet.
        # @!attribute [rw] content
        #   @return [String]
        #     Required. The content of the text snippet as a string. Up to 250000
        #     characters long.
        # @!attribute [rw] mime_type
        #   @return [String]
        #     The format of the source text. Currently the only two allowed values are
        #     "text/html" and "text/plain". If left blank the format is automatically
        #     determined from the type of the uploaded content.
        # @!attribute [rw] content_uri
        #   @return [String]
        #     Output only. HTTP URI where you can download the content.
        class TextSnippet; end

        # A structured text document e.g. a PDF.
        # @!attribute [rw] input_config
        #   @return [Google::Cloud::AutoML::V1beta1::DocumentInputConfig]
        #     An input config specifying the content of the document.
        class Document; end

        # A representation of a row in a relational table.
        # @!attribute [rw] column_spec_ids
        #   @return [Array<String>]
        #     Input Only.
        #     The resource IDs of the column specs describing the columns of the row.
        #     If set must contain, but possibly in a different order, all input feature
        #
        #     {Google::Cloud::AutoML::V1beta1::TablesModelMetadata#input_feature_column_specs column_spec_ids}
        #     of the Model this row is being passed to.
        #     Note: The below `values` field must match order of this field, if this
        #     field is set.
        # @!attribute [rw] values
        #   @return [Array<Google::Protobuf::Value>]
        #     Input Only.
        #     The values of the row cells, given in the same order as the
        #     column_spec_ids, or, if not set, then in the same order as input feature
        #
        #     {Google::Cloud::AutoML::V1beta1::TablesModelMetadata#input_feature_column_specs column_specs}
        #     of the Model this row is being passed to.
        class Row; end

        # Example data used for training or prediction.
        # @!attribute [rw] image
        #   @return [Google::Cloud::AutoML::V1beta1::Image]
        #     Example image.
        # @!attribute [rw] text_snippet
        #   @return [Google::Cloud::AutoML::V1beta1::TextSnippet]
        #     Example text.
        # @!attribute [rw] document
        #   @return [Google::Cloud::AutoML::V1beta1::Document]
        #     Example document.
        # @!attribute [rw] row
        #   @return [Google::Cloud::AutoML::V1beta1::Row]
        #     Example relational table row.
        class ExamplePayload; end
      end
    end
  end
end