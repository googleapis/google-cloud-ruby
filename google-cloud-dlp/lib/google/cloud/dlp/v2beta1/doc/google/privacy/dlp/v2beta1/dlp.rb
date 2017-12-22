# Copyright 2017 Google LLC
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
  module Privacy
    module Dlp
      ##
      # # DLP API Contents
      #
      # | Class | Description |
      # | ----- | ----------- |
      # | [DlpServiceClient][] | The Google Data Loss Prevention API provides methods for detection of privacy-sensitive fragments in text, images, and Google Cloud Platform storage repositories. |
      # | [Data Types][] | Data types for Google::Cloud::Dlp::V2beta1 |
      #
      # [DlpServiceClient]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-dlp/latest/google/privacy/dlp/v2beta1/dlpserviceclient
      # [Data Types]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-dlp/latest/google/privacy/dlp/v2beta1/datatypes
      #
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
        # @!attribute [rw] custom_info_types
        #   @return [Array<Google::Privacy::Dlp::V2beta1::CustomInfoType>]
        #     Custom info types provided by the user.
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

          # Configuration for determining how redaction of images should occur.
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

        # Request to de-identify a list of items.
        # @!attribute [rw] deidentify_config
        #   @return [Google::Privacy::Dlp::V2beta1::DeidentifyConfig]
        #     Configuration for the de-identification of the list of content items.
        # @!attribute [rw] inspect_config
        #   @return [Google::Privacy::Dlp::V2beta1::InspectConfig]
        #     Configuration for the inspector.
        # @!attribute [rw] items
        #   @return [Array<Google::Privacy::Dlp::V2beta1::ContentItem>]
        #     The list of items to inspect. Up to 100 are allowed per request.
        #     All items will be treated as text/*.
        class DeidentifyContentRequest; end

        # Results of de-identifying a list of items.
        # @!attribute [rw] items
        #   @return [Array<Google::Privacy::Dlp::V2beta1::ContentItem>]
        # @!attribute [rw] summaries
        #   @return [Array<Google::Privacy::Dlp::V2beta1::DeidentificationSummary>]
        #     A review of the transformations that took place for each item.
        class DeidentifyContentResponse; end

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
        #     Optional location to store findings.
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
        #     The bucket must already exist and
        #     the Google APIs service account for DLP must have write permission to
        #     write to the given bucket.
        #     Results are split over multiple csv files with each file name matching
        #     the pattern "[operation_id]_[count].csv", for example
        #     +3094877188788974909_1.csv+. The +operation_id+ matches the
        #     identifier for the Operation, and the +count+ is a counter used for
        #     tracking the number of files written.
        #
        #     The CSV file(s) contain the following columns regardless of storage type
        #     scanned:
        #     * id
        #     * info_type
        #     * likelihood
        #     * byte size of finding
        #     * quote
        #     * timestamp
        #
        #     For Cloud Storage the next columns are:
        #
        #     * file_path
        #     * start_offset
        #
        #     For Cloud Datastore the next columns are:
        #
        #     * project_id
        #     * namespace_id
        #     * path
        #     * column_name
        #     * offset
        #
        #     For BigQuery the next columns are:
        #
        #     * row_number
        #     * project_id
        #     * dataset_id
        #     * table_id
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
        #     the longrunning operation created by a call to InspectDataSource.
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
        #
        #     Examples:
        #
        #     * info_type=EMAIL_ADDRESS
        #     * info_type=PHONE_NUMBER,EMAIL_ADDRESS
        #     * likelihood=VERY_LIKELY
        #     * likelihood=VERY_LIKELY,LIKELY
        #     * info_type=EMAIL_ADDRESS,likelihood=VERY_LIKELY,LIKELY
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

        # Description of the information type (infoType).
        # @!attribute [rw] name
        #   @return [String]
        #     Internal name of the infoType.
        # @!attribute [rw] display_name
        #   @return [String]
        #     Human readable form of the infoType name.
        # @!attribute [rw] categories
        #   @return [Array<Google::Privacy::Dlp::V2beta1::CategoryDescription>]
        #     List of categories this infoType belongs to.
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

        # Request for creating a risk analysis operation.
        # @!attribute [rw] privacy_metric
        #   @return [Google::Privacy::Dlp::V2beta1::PrivacyMetric]
        #     Privacy metric to compute.
        # @!attribute [rw] source_table
        #   @return [Google::Privacy::Dlp::V2beta1::BigQueryTable]
        #     Input dataset to compute metrics over.
        class AnalyzeDataSourceRiskRequest; end

        # Privacy metric to compute for reidentification risk analysis.
        # @!attribute [rw] numerical_stats_config
        #   @return [Google::Privacy::Dlp::V2beta1::PrivacyMetric::NumericalStatsConfig]
        # @!attribute [rw] categorical_stats_config
        #   @return [Google::Privacy::Dlp::V2beta1::PrivacyMetric::CategoricalStatsConfig]
        # @!attribute [rw] k_anonymity_config
        #   @return [Google::Privacy::Dlp::V2beta1::PrivacyMetric::KAnonymityConfig]
        # @!attribute [rw] l_diversity_config
        #   @return [Google::Privacy::Dlp::V2beta1::PrivacyMetric::LDiversityConfig]
        class PrivacyMetric
          # Compute numerical stats over an individual column, including
          # min, max, and quantiles.
          # @!attribute [rw] field
          #   @return [Google::Privacy::Dlp::V2beta1::FieldId]
          #     Field to compute numerical stats on. Supported types are
          #     integer, float, date, datetime, timestamp, time.
          class NumericalStatsConfig; end

          # Compute numerical stats over an individual column, including
          # number of distinct values and value count distribution.
          # @!attribute [rw] field
          #   @return [Google::Privacy::Dlp::V2beta1::FieldId]
          #     Field to compute categorical stats on. All column types are
          #     supported except for arrays and structs. However, it may be more
          #     informative to use NumericalStats when the field type is supported,
          #     depending on the data.
          class CategoricalStatsConfig; end

          # k-anonymity metric, used for analysis of reidentification risk.
          # @!attribute [rw] quasi_ids
          #   @return [Array<Google::Privacy::Dlp::V2beta1::FieldId>]
          #     Set of fields to compute k-anonymity over. When multiple fields are
          #     specified, they are considered a single composite key. Structs and
          #     repeated data types are not supported; however, nested fields are
          #     supported so long as they are not structs themselves or nested within
          #     a repeated field.
          # @!attribute [rw] entity_id
          #   @return [Google::Privacy::Dlp::V2beta1::EntityId]
          #     Optional message indicating that each distinct +EntityId+ should not
          #     contribute to the k-anonymity count more than once per equivalence class.
          class KAnonymityConfig; end

          # l-diversity metric, used for analysis of reidentification risk.
          # @!attribute [rw] quasi_ids
          #   @return [Array<Google::Privacy::Dlp::V2beta1::FieldId>]
          #     Set of quasi-identifiers indicating how equivalence classes are
          #     defined for the l-diversity computation. When multiple fields are
          #     specified, they are considered a single composite key.
          # @!attribute [rw] sensitive_attribute
          #   @return [Google::Privacy::Dlp::V2beta1::FieldId]
          #     Sensitive field for computing the l-value.
          class LDiversityConfig; end
        end

        # Metadata returned within the
        # [+riskAnalysis.operations.get+](https://cloud.google.com/dlp/docs/reference/rest/v2beta1/riskAnalysis.operations/get)
        # for risk analysis.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time which this request was started.
        # @!attribute [rw] requested_privacy_metric
        #   @return [Google::Privacy::Dlp::V2beta1::PrivacyMetric]
        #     Privacy metric to compute.
        # @!attribute [rw] requested_source_table
        #   @return [Google::Privacy::Dlp::V2beta1::BigQueryTable]
        #     Input dataset to compute metrics over.
        class RiskAnalysisOperationMetadata; end

        # Result of a risk analysis
        # [+Operation+](https://cloud.google.com/dlp/docs/reference/rest/v2beta1/inspect.operations)
        # request.
        # @!attribute [rw] numerical_stats_result
        #   @return [Google::Privacy::Dlp::V2beta1::RiskAnalysisOperationResult::NumericalStatsResult]
        # @!attribute [rw] categorical_stats_result
        #   @return [Google::Privacy::Dlp::V2beta1::RiskAnalysisOperationResult::CategoricalStatsResult]
        # @!attribute [rw] k_anonymity_result
        #   @return [Google::Privacy::Dlp::V2beta1::RiskAnalysisOperationResult::KAnonymityResult]
        # @!attribute [rw] l_diversity_result
        #   @return [Google::Privacy::Dlp::V2beta1::RiskAnalysisOperationResult::LDiversityResult]
        class RiskAnalysisOperationResult
          # Result of the numerical stats computation.
          # @!attribute [rw] min_value
          #   @return [Google::Privacy::Dlp::V2beta1::Value]
          #     Minimum value appearing in the column.
          # @!attribute [rw] max_value
          #   @return [Google::Privacy::Dlp::V2beta1::Value]
          #     Maximum value appearing in the column.
          # @!attribute [rw] quantile_values
          #   @return [Array<Google::Privacy::Dlp::V2beta1::Value>]
          #     List of 99 values that partition the set of field values into 100 equal
          #     sized buckets.
          class NumericalStatsResult; end

          # Result of the categorical stats computation.
          # @!attribute [rw] value_frequency_histogram_buckets
          #   @return [Array<Google::Privacy::Dlp::V2beta1::RiskAnalysisOperationResult::CategoricalStatsResult::CategoricalStatsHistogramBucket>]
          #     Histogram of value frequencies in the column.
          class CategoricalStatsResult
            # Histogram bucket of value frequencies in the column.
            # @!attribute [rw] value_frequency_lower_bound
            #   @return [Integer]
            #     Lower bound on the value frequency of the values in this bucket.
            # @!attribute [rw] value_frequency_upper_bound
            #   @return [Integer]
            #     Upper bound on the value frequency of the values in this bucket.
            # @!attribute [rw] bucket_size
            #   @return [Integer]
            #     Total number of records in this bucket.
            # @!attribute [rw] bucket_values
            #   @return [Array<Google::Privacy::Dlp::V2beta1::ValueFrequency>]
            #     Sample of value frequencies in this bucket. The total number of
            #     values returned per bucket is capped at 20.
            class CategoricalStatsHistogramBucket; end
          end

          # Result of the k-anonymity computation.
          # @!attribute [rw] equivalence_class_histogram_buckets
          #   @return [Array<Google::Privacy::Dlp::V2beta1::RiskAnalysisOperationResult::KAnonymityResult::KAnonymityHistogramBucket>]
          #     Histogram of k-anonymity equivalence classes.
          class KAnonymityResult
            # The set of columns' values that share the same k-anonymity value.
            # @!attribute [rw] quasi_ids_values
            #   @return [Array<Google::Privacy::Dlp::V2beta1::Value>]
            #     Set of values defining the equivalence class. One value per
            #     quasi-identifier column in the original KAnonymity metric message.
            #     The order is always the same as the original request.
            # @!attribute [rw] equivalence_class_size
            #   @return [Integer]
            #     Size of the equivalence class, for example number of rows with the
            #     above set of values.
            class KAnonymityEquivalenceClass; end

            # Histogram bucket of equivalence class sizes in the table.
            # @!attribute [rw] equivalence_class_size_lower_bound
            #   @return [Integer]
            #     Lower bound on the size of the equivalence classes in this bucket.
            # @!attribute [rw] equivalence_class_size_upper_bound
            #   @return [Integer]
            #     Upper bound on the size of the equivalence classes in this bucket.
            # @!attribute [rw] bucket_size
            #   @return [Integer]
            #     Total number of records in this bucket.
            # @!attribute [rw] bucket_values
            #   @return [Array<Google::Privacy::Dlp::V2beta1::RiskAnalysisOperationResult::KAnonymityResult::KAnonymityEquivalenceClass>]
            #     Sample of equivalence classes in this bucket. The total number of
            #     classes returned per bucket is capped at 20.
            class KAnonymityHistogramBucket; end
          end

          # Result of the l-diversity computation.
          # @!attribute [rw] sensitive_value_frequency_histogram_buckets
          #   @return [Array<Google::Privacy::Dlp::V2beta1::RiskAnalysisOperationResult::LDiversityResult::LDiversityHistogramBucket>]
          #     Histogram of l-diversity equivalence class sensitive value frequencies.
          class LDiversityResult
            # The set of columns' values that share the same l-diversity value.
            # @!attribute [rw] quasi_ids_values
            #   @return [Array<Google::Privacy::Dlp::V2beta1::Value>]
            #     Quasi-identifier values defining the k-anonymity equivalence
            #     class. The order is always the same as the original request.
            # @!attribute [rw] equivalence_class_size
            #   @return [Integer]
            #     Size of the k-anonymity equivalence class.
            # @!attribute [rw] num_distinct_sensitive_values
            #   @return [Integer]
            #     Number of distinct sensitive values in this equivalence class.
            # @!attribute [rw] top_sensitive_values
            #   @return [Array<Google::Privacy::Dlp::V2beta1::ValueFrequency>]
            #     Estimated frequencies of top sensitive values.
            class LDiversityEquivalenceClass; end

            # Histogram bucket of sensitive value frequencies in the table.
            # @!attribute [rw] sensitive_value_frequency_lower_bound
            #   @return [Integer]
            #     Lower bound on the sensitive value frequencies of the equivalence
            #     classes in this bucket.
            # @!attribute [rw] sensitive_value_frequency_upper_bound
            #   @return [Integer]
            #     Upper bound on the sensitive value frequencies of the equivalence
            #     classes in this bucket.
            # @!attribute [rw] bucket_size
            #   @return [Integer]
            #     Total number of records in this bucket.
            # @!attribute [rw] bucket_values
            #   @return [Array<Google::Privacy::Dlp::V2beta1::RiskAnalysisOperationResult::LDiversityResult::LDiversityEquivalenceClass>]
            #     Sample of equivalence classes in this bucket. The total number of
            #     classes returned per bucket is capped at 20.
            class LDiversityHistogramBucket; end
          end
        end

        # A value of a field, including its frequency.
        # @!attribute [rw] value
        #   @return [Google::Privacy::Dlp::V2beta1::Value]
        #     A value contained in the field in question.
        # @!attribute [rw] count
        #   @return [Integer]
        #     How many times the value is contained in the field.
        class ValueFrequency; end

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

        # The configuration that controls how the data will change.
        # @!attribute [rw] info_type_transformations
        #   @return [Google::Privacy::Dlp::V2beta1::InfoTypeTransformations]
        #     Treat the dataset as free-form text and apply the same free text
        #     transformation everywhere.
        # @!attribute [rw] record_transformations
        #   @return [Google::Privacy::Dlp::V2beta1::RecordTransformations]
        #     Treat the dataset as structured. Transformations can be applied to
        #     specific locations within structured datasets, such as transforming
        #     a column within a table.
        class DeidentifyConfig; end

        # A rule for transforming a value.
        # @!attribute [rw] replace_config
        #   @return [Google::Privacy::Dlp::V2beta1::ReplaceValueConfig]
        # @!attribute [rw] redact_config
        #   @return [Google::Privacy::Dlp::V2beta1::RedactConfig]
        # @!attribute [rw] character_mask_config
        #   @return [Google::Privacy::Dlp::V2beta1::CharacterMaskConfig]
        # @!attribute [rw] crypto_replace_ffx_fpe_config
        #   @return [Google::Privacy::Dlp::V2beta1::CryptoReplaceFfxFpeConfig]
        # @!attribute [rw] fixed_size_bucketing_config
        #   @return [Google::Privacy::Dlp::V2beta1::FixedSizeBucketingConfig]
        # @!attribute [rw] bucketing_config
        #   @return [Google::Privacy::Dlp::V2beta1::BucketingConfig]
        # @!attribute [rw] replace_with_info_type_config
        #   @return [Google::Privacy::Dlp::V2beta1::ReplaceWithInfoTypeConfig]
        # @!attribute [rw] time_part_config
        #   @return [Google::Privacy::Dlp::V2beta1::TimePartConfig]
        # @!attribute [rw] crypto_hash_config
        #   @return [Google::Privacy::Dlp::V2beta1::CryptoHashConfig]
        class PrimitiveTransformation; end

        # For use with +Date+, +Timestamp+, and +TimeOfDay+, extract or preserve a
        # portion of the value.
        # @!attribute [rw] part_to_extract
        #   @return [Google::Privacy::Dlp::V2beta1::TimePartConfig::TimePart]
        class TimePartConfig
          module TimePart
            TIME_PART_UNSPECIFIED = 0

            # [000-9999]
            YEAR = 1

            # [1-12]
            MONTH = 2

            # [1-31]
            DAY_OF_MONTH = 3

            # [1-7]
            DAY_OF_WEEK = 4

            # [1-52]
            WEEK_OF_YEAR = 5

            # [0-24]
            HOUR_OF_DAY = 6
          end
        end

        # Pseudonymization method that generates surrogates via cryptographic hashing.
        # Uses SHA-256.
        # Outputs a 32 byte digest as an uppercase hex string
        # (for example, 41D1567F7F99F1DC2A5FAB886DEE5BEE).
        # Currently, only string and integer values can be hashed.
        # @!attribute [rw] crypto_key
        #   @return [Google::Privacy::Dlp::V2beta1::CryptoKey]
        #     The key used by the hash function.
        class CryptoHashConfig; end

        # Replace each input value with a given +Value+.
        # @!attribute [rw] new_value
        #   @return [Google::Privacy::Dlp::V2beta1::Value]
        #     Value to replace it with.
        class ReplaceValueConfig; end

        # Replace each matching finding with the name of the info_type.
        class ReplaceWithInfoTypeConfig; end

        # Redact a given value. For example, if used with an +InfoTypeTransformation+
        # transforming PHONE_NUMBER, and input 'My phone number is 206-555-0123', the
        # output would be 'My phone number is '.
        class RedactConfig; end

        # Characters to skip when doing deidentification of a value. These will be left
        # alone and skipped.
        # @!attribute [rw] characters_to_skip
        #   @return [String]
        # @!attribute [rw] common_characters_to_ignore
        #   @return [Google::Privacy::Dlp::V2beta1::CharsToIgnore::CharacterGroup]
        class CharsToIgnore
          module CharacterGroup
            CHARACTER_GROUP_UNSPECIFIED = 0

            # 0-9
            NUMERIC = 1

            # A-Z
            ALPHA_UPPER_CASE = 2

            # a-z
            ALPHA_LOWER_CASE = 3

            # US Punctuation, one of !"#$%&'()*+,-./:;<=>?@[\]^_+{|}~
            PUNCTUATION = 4

            # Whitespace character, one of [ \t\n\x0B\f\r]
            WHITESPACE = 5
          end
        end

        # Partially mask a string by replacing a given number of characters with a
        # fixed character. Masking can start from the beginning or end of the string.
        # This can be used on data of any type (numbers, longs, and so on) and when
        # de-identifying structured data we'll attempt to preserve the original data's
        # type. (This allows you to take a long like 123 and modify it to a string like
        # **3.
        # @!attribute [rw] masking_character
        #   @return [String]
        #     Character to mask the sensitive values&mdash;for example, "*" for an
        #     alphabetic string such as name, or "0" for a numeric string such as ZIP
        #     code or credit card number. String must have length 1. If not supplied, we
        #     will default to "*" for strings, 0 for digits.
        # @!attribute [rw] number_to_mask
        #   @return [Integer]
        #     Number of characters to mask. If not set, all matching chars will be
        #     masked. Skipped characters do not count towards this tally.
        # @!attribute [rw] reverse_order
        #   @return [true, false]
        #     Mask characters in reverse order. For example, if +masking_character+ is
        #     '0', number_to_mask is 14, and +reverse_order+ is false, then
        #     1234-5678-9012-3456 -> 00000000000000-3456
        #     If +masking_character+ is '*', +number_to_mask+ is 3, and +reverse_order+
        #     is true, then 12345 -> 12***
        # @!attribute [rw] characters_to_ignore
        #   @return [Array<Google::Privacy::Dlp::V2beta1::CharsToIgnore>]
        #     When masking a string, items in this list will be skipped when replacing.
        #     For example, if your string is 555-555-5555 and you ask us to skip +-+ and
        #     mask 5 chars with * we would produce ***-*55-5555.
        class CharacterMaskConfig; end

        # Buckets values based on fixed size ranges. The
        # Bucketing transformation can provide all of this functionality,
        # but requires more configuration. This message is provided as a convenience to
        # the user for simple bucketing strategies.
        # The resulting value will be a hyphenated string of
        # lower_bound-upper_bound.
        # This can be used on data of type: double, long.
        # If the bound Value type differs from the type of data
        # being transformed, we will first attempt converting the type of the data to
        # be transformed to match the type of the bound before comparing.
        # @!attribute [rw] lower_bound
        #   @return [Google::Privacy::Dlp::V2beta1::Value]
        #     Lower bound value of buckets. All values less than +lower_bound+ are
        #     grouped together into a single bucket; for example if +lower_bound+ = 10,
        #     then all values less than 10 are replaced with the value “-10”. [Required].
        # @!attribute [rw] upper_bound
        #   @return [Google::Privacy::Dlp::V2beta1::Value]
        #     Upper bound value of buckets. All values greater than upper_bound are
        #     grouped together into a single bucket; for example if +upper_bound+ = 89,
        #     then all values greater than 89 are replaced with the value “89+”.
        #     [Required].
        # @!attribute [rw] bucket_size
        #   @return [Float]
        #     Size of each bucket (except for minimum and maximum buckets). So if
        #     +lower_bound+ = 10, +upper_bound+ = 89, and +bucket_size+ = 10, then the
        #     following buckets would be used: -10, 10-20, 20-30, 30-40, 40-50, 50-60,
        #     60-70, 70-80, 80-89, 89+. Precision up to 2 decimals works. [Required].
        class FixedSizeBucketingConfig; end

        # Generalization function that buckets values based on ranges. The ranges and
        # replacement values are dynamically provided by the user for custom behavior,
        # such as 1-30 -> LOW 31-65 -> MEDIUM 66-100 -> HIGH
        # This can be used on
        # data of type: number, long, string, timestamp.
        # If the bound +Value+ type differs from the type of data being transformed, we
        # will first attempt converting the type of the data to be transformed to match
        # the type of the bound before comparing.
        # @!attribute [rw] buckets
        #   @return [Array<Google::Privacy::Dlp::V2beta1::BucketingConfig::Bucket>]
        class BucketingConfig
          # Buckets represented as ranges, along with replacement values. Ranges must
          # be non-overlapping.
          # @!attribute [rw] min
          #   @return [Google::Privacy::Dlp::V2beta1::Value]
          #     Lower bound of the range, inclusive. Type should be the same as max if
          #     used.
          # @!attribute [rw] max
          #   @return [Google::Privacy::Dlp::V2beta1::Value]
          #     Upper bound of the range, exclusive; type must match min.
          # @!attribute [rw] replacement_value
          #   @return [Google::Privacy::Dlp::V2beta1::Value]
          #     Replacement value for this bucket. If not provided
          #     the default behavior will be to hyphenate the min-max range.
          class Bucket; end
        end

        # Replaces an identifier with a surrogate using FPE with the FFX
        # mode of operation.
        # The identifier must be representable by the US-ASCII character set.
        # For a given crypto key and context, the same identifier will be
        # replaced with the same surrogate.
        # Identifiers must be at least two characters long.
        # In the case that the identifier is the empty string, it will be skipped.
        # @!attribute [rw] crypto_key
        #   @return [Google::Privacy::Dlp::V2beta1::CryptoKey]
        #     The key used by the encryption algorithm. [required]
        # @!attribute [rw] context
        #   @return [Google::Privacy::Dlp::V2beta1::FieldId]
        #     A context may be used for higher security since the same
        #     identifier in two different contexts likely will be given a distinct
        #     surrogate. The principle is that the likeliness is inversely related
        #     to the ratio of the number of distinct identifiers per context over the
        #     number of possible surrogates: As long as this ratio is small, the
        #     likehood is large.
        #
        #     If the context is not set, a default tweak will be used.
        #     If the context is set but:
        #
        #     1. there is no record present when transforming a given value or
        #     1. the field is not present when transforming a given value,
        #
        #     a default tweak will be used.
        #
        #     Note that case (1) is expected when an +InfoTypeTransformation+ is
        #     applied to both structured and non-structured +ContentItem+s.
        #     Currently, the referenced field may be of value type integer or string.
        #
        #     The tweak is constructed as a sequence of bytes in big endian byte order
        #     such that:
        #
        #     * a 64 bit integer is encoded followed by a single byte of value 1
        #     * a string is encoded in UTF-8 format followed by a single byte of value 2
        #
        #     This is also known as the 'tweak', as in tweakable encryption.
        # @!attribute [rw] common_alphabet
        #   @return [Google::Privacy::Dlp::V2beta1::CryptoReplaceFfxFpeConfig::FfxCommonNativeAlphabet]
        # @!attribute [rw] custom_alphabet
        #   @return [String]
        #     This is supported by mapping these to the alphanumeric characters
        #     that the FFX mode natively supports. This happens before/after
        #     encryption/decryption.
        #     Each character listed must appear only once.
        #     Number of characters must be in the range [2, 62].
        #     This must be encoded as ASCII.
        #     The order of characters does not matter.
        # @!attribute [rw] radix
        #   @return [Integer]
        #     The native way to select the alphabet. Must be in the range [2, 62].
        class CryptoReplaceFfxFpeConfig
          # These are commonly used subsets of the alphabet that the FFX mode
          # natively supports. In the algorithm, the alphabet is selected using
          # the "radix". Therefore each corresponds to particular radix.
          module FfxCommonNativeAlphabet
            FFX_COMMON_NATIVE_ALPHABET_UNSPECIFIED = 0

            # [0-9] (radix of 10)
            NUMERIC = 1

            # [0-9A-F] (radix of 16)
            HEXADECIMAL = 2

            # [0-9A-Z] (radix of 36)
            UPPER_CASE_ALPHA_NUMERIC = 3

            # [0-9A-Za-z] (radix of 62)
            ALPHA_NUMERIC = 4
          end
        end

        # This is a data encryption key (DEK) (as opposed to
        # a key encryption key (KEK) stored by KMS).
        # When using KMS to wrap/unwrap DEKs, be sure to set an appropriate
        # IAM policy on the KMS CryptoKey (KEK) to ensure an attacker cannot
        # unwrap the data crypto key.
        # @!attribute [rw] transient
        #   @return [Google::Privacy::Dlp::V2beta1::TransientCryptoKey]
        # @!attribute [rw] unwrapped
        #   @return [Google::Privacy::Dlp::V2beta1::UnwrappedCryptoKey]
        # @!attribute [rw] kms_wrapped
        #   @return [Google::Privacy::Dlp::V2beta1::KmsWrappedCryptoKey]
        class CryptoKey; end

        # Use this to have a random data crypto key generated.
        # It will be discarded after the operation/request finishes.
        # @!attribute [rw] name
        #   @return [String]
        #     Name of the key. [required]
        #     This is an arbitrary string used to differentiate different keys.
        #     A unique key is generated per name: two separate +TransientCryptoKey+
        #     protos share the same generated key if their names are the same.
        #     When the data crypto key is generated, this name is not used in any way
        #     (repeating the api call will result in a different key being generated).
        class TransientCryptoKey; end

        # Using raw keys is prone to security risks due to accidentally
        # leaking the key. Choose another type of key if possible.
        # @!attribute [rw] key
        #   @return [String]
        #     The AES 128/192/256 bit key. [required]
        class UnwrappedCryptoKey; end

        # Include to use an existing data crypto key wrapped by KMS.
        # Authorization requires the following IAM permissions when sending a request
        # to perform a crypto transformation using a kms-wrapped crypto key:
        # dlp.kms.encrypt
        # @!attribute [rw] wrapped_key
        #   @return [String]
        #     The wrapped data crypto key. [required]
        # @!attribute [rw] crypto_key_name
        #   @return [String]
        #     The resource name of the KMS CryptoKey to use for unwrapping. [required]
        class KmsWrappedCryptoKey; end

        # A type of transformation that will scan unstructured text and
        # apply various +PrimitiveTransformation+s to each finding, where the
        # transformation is applied to only values that were identified as a specific
        # info_type.
        # @!attribute [rw] transformations
        #   @return [Array<Google::Privacy::Dlp::V2beta1::InfoTypeTransformations::InfoTypeTransformation>]
        #     Transformation for each info type. Cannot specify more than one
        #     for a given info type. [required]
        class InfoTypeTransformations
          # A transformation to apply to text that is identified as a specific
          # info_type.
          # @!attribute [rw] info_types
          #   @return [Array<Google::Privacy::Dlp::V2beta1::InfoType>]
          #     Info types to apply the transformation to. Empty list will match all
          #     available info types for this transformation.
          # @!attribute [rw] primitive_transformation
          #   @return [Google::Privacy::Dlp::V2beta1::PrimitiveTransformation]
          #     Primitive transformation to apply to the info type. [required]
          class InfoTypeTransformation; end
        end

        # The transformation to apply to the field.
        # @!attribute [rw] fields
        #   @return [Array<Google::Privacy::Dlp::V2beta1::FieldId>]
        #     Input field(s) to apply the transformation to. [required]
        # @!attribute [rw] condition
        #   @return [Google::Privacy::Dlp::V2beta1::RecordCondition]
        #     Only apply the transformation if the condition evaluates to true for the
        #     given +RecordCondition+. The conditions are allowed to reference fields
        #     that are not used in the actual transformation. [optional]
        #
        #     Example Use Cases:
        #
        #     * Apply a different bucket transformation to an age column if the zip code
        #       column for the same record is within a specific range.
        #     * Redact a field if the date of birth field is greater than 85.
        # @!attribute [rw] primitive_transformation
        #   @return [Google::Privacy::Dlp::V2beta1::PrimitiveTransformation]
        #     Apply the transformation to the entire field.
        # @!attribute [rw] info_type_transformations
        #   @return [Google::Privacy::Dlp::V2beta1::InfoTypeTransformations]
        #     Treat the contents of the field as free text, and selectively
        #     transform content that matches an +InfoType+.
        class FieldTransformation; end

        # A type of transformation that is applied over structured data such as a
        # table.
        # @!attribute [rw] field_transformations
        #   @return [Array<Google::Privacy::Dlp::V2beta1::FieldTransformation>]
        #     Transform the record by applying various field transformations.
        # @!attribute [rw] record_suppressions
        #   @return [Array<Google::Privacy::Dlp::V2beta1::RecordSuppression>]
        #     Configuration defining which records get suppressed entirely. Records that
        #     match any suppression rule are omitted from the output [optional].
        class RecordTransformations; end

        # Configuration to suppress records whose suppression conditions evaluate to
        # true.
        # @!attribute [rw] condition
        #   @return [Google::Privacy::Dlp::V2beta1::RecordCondition]
        class RecordSuppression; end

        # A condition for determining whether a transformation should be applied to
        # a field.
        # @!attribute [rw] expressions
        #   @return [Google::Privacy::Dlp::V2beta1::RecordCondition::Expressions]
        class RecordCondition
          # The field type of +value+ and +field+ do not need to match to be
          # considered equal, but not all comparisons are possible.
          #
          # A +value+ of type:
          #
          # * +string+ can be compared against all other types
          # * +boolean+ can only be compared against other booleans
          # * +integer+ can be compared against doubles or a string if the string value
          #   can be parsed as an integer.
          # * +double+ can be compared against integers or a string if the string can
          #   be parsed as a double.
          # * +Timestamp+ can be compared against strings in RFC 3339 date string
          #   format.
          # * +TimeOfDay+ can be compared against timestamps and strings in the format
          #   of 'HH:mm:ss'.
          #
          # If we fail to compare do to type mismatch, a warning will be given and
          # the condition will evaluate to false.
          # @!attribute [rw] field
          #   @return [Google::Privacy::Dlp::V2beta1::FieldId]
          #     Field within the record this condition is evaluated against. [required]
          # @!attribute [rw] operator
          #   @return [Google::Privacy::Dlp::V2beta1::RelationalOperator]
          #     Operator used to compare the field or info type to the value. [required]
          # @!attribute [rw] value
          #   @return [Google::Privacy::Dlp::V2beta1::Value]
          #     Value to compare against. [Required, except for +EXISTS+ tests.]
          class Condition; end

          # @!attribute [rw] conditions
          #   @return [Array<Google::Privacy::Dlp::V2beta1::RecordCondition::Condition>]
          class Conditions; end

          # A collection of expressions
          # @!attribute [rw] logical_operator
          #   @return [Google::Privacy::Dlp::V2beta1::RecordCondition::Expressions::LogicalOperator]
          #     The operator to apply to the result of conditions. Default and currently
          #     only supported value is +AND+.
          # @!attribute [rw] conditions
          #   @return [Google::Privacy::Dlp::V2beta1::RecordCondition::Conditions]
          class Expressions
            module LogicalOperator
              LOGICAL_OPERATOR_UNSPECIFIED = 0

              AND = 1
            end
          end
        end

        # High level summary of deidentification.
        # @!attribute [rw] transformed_bytes
        #   @return [Integer]
        #     Total size in bytes that were transformed in some way.
        # @!attribute [rw] transformation_summaries
        #   @return [Array<Google::Privacy::Dlp::V2beta1::TransformationSummary>]
        #     Transformations applied to the dataset.
        class DeidentificationSummary; end

        # Summary of a single tranformation.
        # @!attribute [rw] info_type
        #   @return [Google::Privacy::Dlp::V2beta1::InfoType]
        #     Set if the transformation was limited to a specific info_type.
        # @!attribute [rw] field
        #   @return [Google::Privacy::Dlp::V2beta1::FieldId]
        #     Set if the transformation was limited to a specific FieldId.
        # @!attribute [rw] transformation
        #   @return [Google::Privacy::Dlp::V2beta1::PrimitiveTransformation]
        #     The specific transformation these stats apply to.
        # @!attribute [rw] field_transformations
        #   @return [Array<Google::Privacy::Dlp::V2beta1::FieldTransformation>]
        #     The field transformation that was applied. This list will contain
        #     multiple only in the case of errors.
        # @!attribute [rw] record_suppress
        #   @return [Google::Privacy::Dlp::V2beta1::RecordSuppression]
        #     The specific suppression option these stats apply to.
        # @!attribute [rw] results
        #   @return [Array<Google::Privacy::Dlp::V2beta1::TransformationSummary::SummaryResult>]
        class TransformationSummary
          # A collection that informs the user the number of times a particular
          # +TransformationResultCode+ and error details occurred.
          # @!attribute [rw] count
          #   @return [Integer]
          # @!attribute [rw] code
          #   @return [Google::Privacy::Dlp::V2beta1::TransformationSummary::TransformationResultCode]
          # @!attribute [rw] details
          #   @return [String]
          #     A place for warnings or errors to show up if a transformation didn't
          #     work as expected.
          class SummaryResult; end

          # Possible outcomes of transformations.
          module TransformationResultCode
            TRANSFORMATION_RESULT_CODE_UNSPECIFIED = 0

            SUCCESS = 1

            ERROR = 2
          end
        end

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

        # Operators available for comparing the value of fields.
        module RelationalOperator
          RELATIONAL_OPERATOR_UNSPECIFIED = 0

          # Equal.
          EQUAL_TO = 1

          # Not equal to.
          NOT_EQUAL_TO = 2

          # Greater than.
          GREATER_THAN = 3

          # Less than.
          LESS_THAN = 4

          # Greater than or equals.
          GREATER_THAN_OR_EQUALS = 5

          # Less than or equals.
          LESS_THAN_OR_EQUALS = 6

          # Exists
          EXISTS = 7
        end
      end
    end
  end
end