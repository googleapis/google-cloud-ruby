# Copyright 2017, Google Inc. All rights reserved.
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
  module Privacy
    module Dlp
      module V2beta1
        # Configuration description of the scanning process.
        # When used with redactContent only info_types and min_likelihood are currently
        # used.
        # @!attribute [rw] info_types
        #   @return [Array<Google::Privacy::Dlp::V2beta1::InfoType>]
        #     Restricts what info_types to look for. The values must correspond to
        #     InfoType values returned by ListInfoTypes or found in documentation.
        #     Empty info_types runs all enabled detectors.
        # @!attribute [rw] min_likelihood
        #   @return [Google::Privacy::Dlp::V2beta1::Likelihood]
        #     Only returns findings equal or above this threshold.
        # @!attribute [rw] max_findings
        #   @return [Integer]
        #     Limits the number of findings per content item or long running operation.
        # @!attribute [rw] include_quote
        #   @return [true, false]
        #     When true, a contextual quote from the data that triggered a finding is
        #     included in the response; see Finding.quote.
        # @!attribute [rw] exclude_types
        #   @return [true, false]
        #     When true, excludes type information of the findings.
        # @!attribute [rw] info_type_limits
        #   @return [Array<Google::Privacy::Dlp::V2beta1::InspectConfig::InfoTypeLimit>]
        #     Configuration of findings limit given for specified info types.
        class InspectConfig
          # Max findings configuration per info type, per content item or long running
          # operation.
          # @!attribute [rw] info_type
          #   @return [Google::Privacy::Dlp::V2beta1::InfoType]
          #     Type of information the findings limit applies to. Only one limit per
          #     info_type should be provided. If InfoTypeLimit does not have an
          #     info_type, the DLP API applies the limit against all info_types that are
          #     found but not specified in another InfoTypeLimit.
          # @!attribute [rw] max_findings
          #   @return [Integer]
          #     Max findings limit for the given infoType.
          class InfoTypeLimit; end
        end

        # Additional configuration for inspect long running operations.
        # @!attribute [rw] max_item_findings
        #   @return [Integer]
        #     Max number of findings per file, Datastore entity, or database row.
        class OperationConfig; end

        # Container structure for the content to inspect.
        # @!attribute [rw] type
        #   @return [String]
        #     Type of the content, as defined in Content-Type HTTP header.
        #     Supported types are: all "text" types, octet streams, PNG images,
        #     JPEG images.
        # @!attribute [rw] data
        #   @return [String]
        #     Content data to inspect or redact.
        # @!attribute [rw] value
        #   @return [String]
        #     String data to inspect or redact.
        # @!attribute [rw] table
        #   @return [Google::Privacy::Dlp::V2beta1::Table]
        #     Structured content for inspection.
        class ContentItem; end

        # Structured content to inspect. Up to 50,000 +Value+s per request allowed.
        # @!attribute [rw] headers
        #   @return [Array<Google::Privacy::Dlp::V2beta1::FieldId>]
        # @!attribute [rw] rows
        #   @return [Array<Google::Privacy::Dlp::V2beta1::Table::Row>]
        class Table
          # @!attribute [rw] values
          #   @return [Array<Google::Privacy::Dlp::V2beta1::Value>]
          class Row; end
        end

        # All the findings for a single scanned item.
        # @!attribute [rw] findings
        #   @return [Array<Google::Privacy::Dlp::V2beta1::Finding>]
        #     List of findings for an item.
        # @!attribute [rw] findings_truncated
        #   @return [true, false]
        #     If true, then this item might have more findings than were returned,
        #     and the findings returned are an arbitrary subset of all findings.
        #     The findings list might be truncated because the input items were too
        #     large, or because the server reached the maximum amount of resources
        #     allowed for a single API call. For best results, divide the input into
        #     smaller batches.
        class InspectResult; end

        # Container structure describing a single finding within a string or image.
        # @!attribute [rw] quote
        #   @return [String]
        #     The specific string that may be potentially sensitive info.
        # @!attribute [rw] info_type
        #   @return [Google::Privacy::Dlp::V2beta1::InfoType]
        #     The specific type of info the string might be.
        # @!attribute [rw] likelihood
        #   @return [Google::Privacy::Dlp::V2beta1::Likelihood]
        #     Estimate of how likely it is that the info_type is correct.
        # @!attribute [rw] location
        #   @return [Google::Privacy::Dlp::V2beta1::Location]
        #     Location of the info found.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     Timestamp when finding was detected.
        class Finding; end

        # Specifies the location of a finding within its source item.
        # @!attribute [rw] byte_range
        #   @return [Google::Privacy::Dlp::V2beta1::Range]
        #     Zero-based byte offsets within a content item.
        # @!attribute [rw] codepoint_range
        #   @return [Google::Privacy::Dlp::V2beta1::Range]
        #     Character offsets within a content item, included when content type
        #     is a text. Default charset assumed to be UTF-8.
        # @!attribute [rw] image_boxes
        #   @return [Array<Google::Privacy::Dlp::V2beta1::ImageLocation>]
        #     Location within an image's pixels.
        # @!attribute [rw] record_key
        #   @return [Google::Privacy::Dlp::V2beta1::RecordKey]
        #     Key of the finding.
        # @!attribute [rw] field_id
        #   @return [Google::Privacy::Dlp::V2beta1::FieldId]
        #     Field id of the field containing the finding.
        # @!attribute [rw] table_location
        #   @return [Google::Privacy::Dlp::V2beta1::TableLocation]
        #     Location within a +ContentItem.Table+.
        class Location; end

        # Location of a finding within a +ContentItem.Table+.
        # @!attribute [rw] row_index
        #   @return [Integer]
        #     The zero-based index of the row where the finding is located.
        class TableLocation; end

        # Generic half-open interval [start, end)
        # @!attribute [rw] start
        #   @return [Integer]
        #     Index of the first character of the range (inclusive).
        # @!attribute [rw] end
        #   @return [Integer]
        #     Index of the last character of the range (exclusive).
        class Range; end

        # Bounding box encompassing detected text within an image.
        # @!attribute [rw] top
        #   @return [Integer]
        #     Top coordinate of the bounding box. (0,0) is upper left.
        # @!attribute [rw] left
        #   @return [Integer]
        #     Left coordinate of the bounding box. (0,0) is upper left.
        # @!attribute [rw] width
        #   @return [Integer]
        #     Width of the bounding box in pixels.
        # @!attribute [rw] height
        #   @return [Integer]
        #     Height of the bounding box in pixels.
        class ImageLocation; end

        # Request to search for potentially sensitive info in a list of items
        # and replace it with a default or provided content.
        # @!attribute [rw] inspect_config
        #   @return [Google::Privacy::Dlp::V2beta1::InspectConfig]
        #     Configuration for the inspector.
        # @!attribute [rw] items
        #   @return [Array<Google::Privacy::Dlp::V2beta1::ContentItem>]
        #     The list of items to inspect. Up to 100 are allowed per request.
        # @!attribute [rw] replace_configs
        #   @return [Array<Google::Privacy::Dlp::V2beta1::RedactContentRequest::ReplaceConfig>]
        #     The strings to replace findings text findings with. Must specify at least
        #     one of these or one ImageRedactionConfig if redacting images.
        # @!attribute [rw] image_redaction_configs
        #   @return [Array<Google::Privacy::Dlp::V2beta1::RedactContentRequest::ImageRedactionConfig>]
        #     The configuration for specifying what content to redact from images.
        class RedactContentRequest
          # @!attribute [rw] info_type
          #   @return [Google::Privacy::Dlp::V2beta1::InfoType]
          #     Type of information to replace. Only one ReplaceConfig per info_type
          #     should be provided. If ReplaceConfig does not have an info_type, the DLP
          #     API matches it against all info_types that are found but not specified in
          #     another ReplaceConfig.
          # @!attribute [rw] replace_with
          #   @return [String]
          #     Content replacing sensitive information of given type. Max 256 chars.
          class ReplaceConfig; end

          # Configuration for determing how redaction of images should occur.
          # @!attribute [rw] info_type
          #   @return [Google::Privacy::Dlp::V2beta1::InfoType]
          #     Only one per info_type should be provided per request. If not
          #     specified, and redact_all_text is false, the DLP API will redact all
          #     text that it matches against all info_types that are found, but not
          #     specified in another ImageRedactionConfig.
          # @!attribute [rw] redact_all_text
          #   @return [true, false]
          #     If true, all text found in the image, regardless whether it matches an
          #     info_type, is redacted.
          # @!attribute [rw] redaction_color
          #   @return [Google::Privacy::Dlp::V2beta1::Color]
          #     The color to use when redacting content from an image. If not specified,
          #     the default is black.
          class ImageRedactionConfig; end
        end

        # Represents a color in the RGB color space.
        # @!attribute [rw] red
        #   @return [Float]
        #     The amount of red in the color as a value in the interval [0, 1].
        # @!attribute [rw] green
        #   @return [Float]
        #     The amount of green in the color as a value in the interval [0, 1].
        # @!attribute [rw] blue
        #   @return [Float]
        #     The amount of blue in the color as a value in the interval [0, 1].
        class Color; end

        # Results of redacting a list of items.
        # @!attribute [rw] items
        #   @return [Array<Google::Privacy::Dlp::V2beta1::ContentItem>]
        #     The redacted content.
        class RedactContentResponse; end

        # Request to search for potentially sensitive info in a list of items.
        # @!attribute [rw] inspect_config
        #   @return [Google::Privacy::Dlp::V2beta1::InspectConfig]
        #     Configuration for the inspector.
        # @!attribute [rw] items
        #   @return [Array<Google::Privacy::Dlp::V2beta1::ContentItem>]
        #     The list of items to inspect. Items in a single request are
        #     considered "related" unless inspect_config.independent_inputs is true.
        #     Up to 100 are allowed per request.
        class InspectContentRequest; end

        # Results of inspecting a list of items.
        # @!attribute [rw] results
        #   @return [Array<Google::Privacy::Dlp::V2beta1::InspectResult>]
        #     Each content_item from the request has a result in this list, in the
        #     same order as the request.
        class InspectContentResponse; end

        # Request for scheduling a scan of a data subset from a Google Platform data
        # repository.
        # @!attribute [rw] inspect_config
        #   @return [Google::Privacy::Dlp::V2beta1::InspectConfig]
        #     Configuration for the inspector.
        # @!attribute [rw] storage_config
        #   @return [Google::Privacy::Dlp::V2beta1::StorageConfig]
        #     Specification of the data set to process.
        # @!attribute [rw] output_config
        #   @return [Google::Privacy::Dlp::V2beta1::OutputStorageConfig]
        #     Optional location to store findings. The bucket must already exist and
        #     the Google APIs service account for DLP must have write permission to
        #     write to the given bucket.
        #     <p>Results are split over multiple csv files with each file name matching
        #     the pattern "[operation_id]_[count].csv", for example
        #     +3094877188788974909_1.csv+. The +operation_id+ matches the
        #     identifier for the Operation, and the +count+ is a counter used for
        #     tracking the number of files written. <p>The CSV file(s) contain the
        #     following columns regardless of storage type scanned: <li>id <li>info_type
        #     <li>likelihood <li>byte size of finding <li>quote <li>timestamp<br/>
        #     <p>For Cloud Storage the next columns are: <li>file_path
        #     <li>start_offset<br/>
        #     <p>For Cloud Datastore the next columns are: <li>project_id
        #     <li>namespace_id <li>path <li>column_name <li>offset<br/>
        #     <p>For BigQuery the next columns are: <li>row_number <li>project_id
        #     <li>dataset_id <li>table_id
        # @!attribute [rw] operation_config
        #   @return [Google::Privacy::Dlp::V2beta1::OperationConfig]
        #     Additional configuration settings for long running operations.
        class CreateInspectOperationRequest; end

        # Cloud repository for storing output.
        # @!attribute [rw] table
        #   @return [Google::Privacy::Dlp::V2beta1::BigQueryTable]
        #     Store findings in a new table in the dataset.
        # @!attribute [rw] storage_path
        #   @return [Google::Privacy::Dlp::V2beta1::CloudStoragePath]
        #     The path to a Google Cloud Storage location to store output.
        class OutputStorageConfig; end

        # Statistics regarding a specific InfoType.
        # @!attribute [rw] info_type
        #   @return [Google::Privacy::Dlp::V2beta1::InfoType]
        #     The type of finding this stat is for.
        # @!attribute [rw] count
        #   @return [Integer]
        #     Number of findings for this info type.
        class InfoTypeStatistics; end

        # Metadata returned within GetOperation for an inspect request.
        # @!attribute [rw] processed_bytes
        #   @return [Integer]
        #     Total size in bytes that were processed.
        # @!attribute [rw] total_estimated_bytes
        #   @return [Integer]
        #     Estimate of the number of bytes to process.
        # @!attribute [rw] info_type_stats
        #   @return [Array<Google::Privacy::Dlp::V2beta1::InfoTypeStatistics>]
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time which this request was started.
        # @!attribute [rw] request_inspect_config
        #   @return [Google::Privacy::Dlp::V2beta1::InspectConfig]
        #     The inspect config used to create the Operation.
        # @!attribute [rw] request_storage_config
        #   @return [Google::Privacy::Dlp::V2beta1::StorageConfig]
        #     The storage config used to create the Operation.
        # @!attribute [rw] request_output_config
        #   @return [Google::Privacy::Dlp::V2beta1::OutputStorageConfig]
        #     Optional location to store findings.
        class InspectOperationMetadata; end

        # The operational data.
        # @!attribute [rw] name
        #   @return [String]
        #     The server-assigned name, which is only unique within the same service that
        #     originally returns it. If you use the default HTTP mapping, the
        #     +name+ should have the format of +inspect/results/{id}+.
        class InspectOperationResult; end

        # Request for the list of results in a given inspect operation.
        # @!attribute [rw] name
        #   @return [String]
        #     Identifier of the results set returned as metadata of
        #     the longrunning operation created by a call to CreateInspectOperation.
        #     Should be in the format of +inspect/results/{id}+.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Maximum number of results to return.
        #     If 0, the implementation selects a reasonable value.
        # @!attribute [rw] page_token
        #   @return [String]
        #     The value returned by the last +ListInspectFindingsResponse+; indicates
        #     that this is a continuation of a prior +ListInspectFindings+ call, and that
        #     the system should return the next page of data.
        # @!attribute [rw] filter
        #   @return [String]
        #     Restricts findings to items that match. Supports info_type and likelihood.
        #     <p>Examples:<br/>
        #     <li>info_type=EMAIL_ADDRESS
        #     <li>info_type=PHONE_NUMBER,EMAIL_ADDRESS
        #     <li>likelihood=VERY_LIKELY
        #     <li>likelihood=VERY_LIKELY,LIKELY
        #     <li>info_type=EMAIL_ADDRESS,likelihood=VERY_LIKELY,LIKELY
        class ListInspectFindingsRequest; end

        # Response to the ListInspectFindings request.
        # @!attribute [rw] result
        #   @return [Google::Privacy::Dlp::V2beta1::InspectResult]
        #     The results.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     If not empty, indicates that there may be more results that match the
        #     request; this value should be passed in a new +ListInspectFindingsRequest+.
        class ListInspectFindingsResponse; end

        # Info type description.
        # @!attribute [rw] name
        #   @return [String]
        #     Internal name of the info type.
        # @!attribute [rw] display_name
        #   @return [String]
        #     Human readable form of the info type name.
        # @!attribute [rw] categories
        #   @return [Array<Google::Privacy::Dlp::V2beta1::CategoryDescription>]
        #     List of categories this info type belongs to.
        class InfoTypeDescription; end

        # Request for the list of info types belonging to a given category,
        # or all supported info types if no category is specified.
        # @!attribute [rw] category
        #   @return [String]
        #     Category name as returned by ListRootCategories.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional BCP-47 language code for localized info type friendly
        #     names. If omitted, or if localized strings are not available,
        #     en-US strings will be returned.
        class ListInfoTypesRequest; end

        # Response to the ListInfoTypes request.
        # @!attribute [rw] info_types
        #   @return [Array<Google::Privacy::Dlp::V2beta1::InfoTypeDescription>]
        #     Set of sensitive info types belonging to a category.
        class ListInfoTypesResponse; end

        # Info Type Category description.
        # @!attribute [rw] name
        #   @return [String]
        #     Internal name of the category.
        # @!attribute [rw] display_name
        #   @return [String]
        #     Human readable form of the category name.
        class CategoryDescription; end

        # Request for root categories of Info Types supported by the API.
        # Example values might include "FINANCE", "HEALTH", "FAST", "DEFAULT".
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional language code for localized friendly category names.
        #     If omitted or if localized strings are not available,
        #     en-US strings will be returned.
        class ListRootCategoriesRequest; end

        # Response for ListRootCategories request.
        # @!attribute [rw] categories
        #   @return [Array<Google::Privacy::Dlp::V2beta1::CategoryDescription>]
        #     List of all into type categories supported by the API.
        class ListRootCategoriesResponse; end

        # Set of primitive values supported by the system.
        # @!attribute [rw] integer_value
        #   @return [Integer]
        # @!attribute [rw] float_value
        #   @return [Float]
        # @!attribute [rw] string_value
        #   @return [String]
        # @!attribute [rw] boolean_value
        #   @return [true, false]
        # @!attribute [rw] timestamp_value
        #   @return [Google::Protobuf::Timestamp]
        # @!attribute [rw] time_value
        #   @return [Google::Type::TimeOfDay]
        # @!attribute [rw] date_value
        #   @return [Google::Type::Date]
        class Value; end

        # Categorization of results based on how likely they are to represent a match,
        # based on the number of elements they contain which imply a match.
        module Likelihood
          # Default value; information with all likelihoods is included.
          LIKELIHOOD_UNSPECIFIED = 0

          # Few matching elements.
          VERY_UNLIKELY = 1

          UNLIKELY = 2

          # Some matching elements.
          POSSIBLE = 3

          LIKELY = 4

          # Many matching elements.
          VERY_LIKELY = 5
        end
      end
    end
  end
end