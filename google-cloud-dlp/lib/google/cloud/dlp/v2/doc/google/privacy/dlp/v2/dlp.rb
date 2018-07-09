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
  module Privacy
    module Dlp
      ##
      # # Cloud Data Loss Prevention (DLP) API Contents
      #
      # | Class | Description |
      # | ----- | ----------- |
      # | [DlpServiceClient][] | The Cloud Data Loss Prevention (DLP) API is a service that allows clients to detect the presence of Personally Identifiable Information (PII) and other privacy-sensitive data in user-supplied, unstructured data streams, like text blocks or images. |
      # | [Data Types][] | Data types for Google::Cloud::Dlp::V2 |
      #
      # [DlpServiceClient]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-dlp/latest/google/privacy/dlp/v2/dlpserviceclient
      # [Data Types]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-dlp/latest/google/privacy/dlp/v2/datatypes
      #
      module V2
        # Configuration description of the scanning process.
        # When used with redactContent only info_types and min_likelihood are currently
        # used.
        # @!attribute [rw] info_types
        #   @return [Array<Google::Privacy::Dlp::V2::InfoType>]
        #     Restricts what info_types to look for. The values must correspond to
        #     InfoType values returned by ListInfoTypes or listed at
        #     https://cloud.google.com/dlp/docs/infotypes-reference.
        #
        #     When no InfoTypes or CustomInfoTypes are specified in a request, the
        #     system may automatically choose what detectors to run. By default this may
        #     be all types, but may change over time as detectors are updated.
        # @!attribute [rw] min_likelihood
        #   @return [Google::Privacy::Dlp::V2::Likelihood]
        #     Only returns findings equal or above this threshold. The default is
        #     POSSIBLE.
        #     See https://cloud.google.com/dlp/docs/likelihood to learn more.
        # @!attribute [rw] limits
        #   @return [Google::Privacy::Dlp::V2::InspectConfig::FindingLimits]
        # @!attribute [rw] include_quote
        #   @return [true, false]
        #     When true, a contextual quote from the data that triggered a finding is
        #     included in the response; see Finding.quote.
        # @!attribute [rw] exclude_info_types
        #   @return [true, false]
        #     When true, excludes type information of the findings.
        # @!attribute [rw] custom_info_types
        #   @return [Array<Google::Privacy::Dlp::V2::CustomInfoType>]
        #     CustomInfoTypes provided by the user. See
        #     https://cloud.google.com/dlp/docs/creating-custom-infotypes to learn more.
        # @!attribute [rw] content_options
        #   @return [Array<Google::Privacy::Dlp::V2::ContentOption>]
        #     List of options defining data content to scan.
        #     If empty, text, images, and other content will be included.
        class InspectConfig
          # @!attribute [rw] max_findings_per_item
          #   @return [Integer]
          #     Max number of findings that will be returned for each item scanned.
          #     When set within +InspectDataSourceRequest+,
          #     the maximum returned is 1000 regardless if this is set higher.
          #     When set within +InspectContentRequest+, this field is ignored.
          # @!attribute [rw] max_findings_per_request
          #   @return [Integer]
          #     Max number of findings that will be returned per request/job.
          #     When set within +InspectContentRequest+, the maximum returned is 1000
          #     regardless if this is set higher.
          # @!attribute [rw] max_findings_per_info_type
          #   @return [Array<Google::Privacy::Dlp::V2::InspectConfig::FindingLimits::InfoTypeLimit>]
          #     Configuration of findings limit given for specified infoTypes.
          class FindingLimits
            # Max findings configuration per infoType, per content item or long
            # running DlpJob.
            # @!attribute [rw] info_type
            #   @return [Google::Privacy::Dlp::V2::InfoType]
            #     Type of information the findings limit applies to. Only one limit per
            #     info_type should be provided. If InfoTypeLimit does not have an
            #     info_type, the DLP API applies the limit against all info_types that
            #     are found but not specified in another InfoTypeLimit.
            # @!attribute [rw] max_findings
            #   @return [Integer]
            #     Max findings limit for the given infoType.
            class InfoTypeLimit; end
          end
        end

        # Container for bytes to inspect or redact.
        # @!attribute [rw] type
        #   @return [Google::Privacy::Dlp::V2::ByteContentItem::BytesType]
        #     The type of data stored in the bytes string. Default will be TEXT_UTF8.
        # @!attribute [rw] data
        #   @return [String]
        #     Content data to inspect or redact.
        class ByteContentItem
          module BytesType
            BYTES_TYPE_UNSPECIFIED = 0

            IMAGE = 6

            IMAGE_JPEG = 1

            IMAGE_BMP = 2

            IMAGE_PNG = 3

            IMAGE_SVG = 4

            TEXT_UTF8 = 5
          end
        end

        # Container structure for the content to inspect.
        # @!attribute [rw] value
        #   @return [String]
        #     String data to inspect or redact.
        # @!attribute [rw] table
        #   @return [Google::Privacy::Dlp::V2::Table]
        #     Structured content for inspection. See
        #     https://cloud.google.com/dlp/docs/inspecting-text#inspecting_a_table to
        #     learn more.
        # @!attribute [rw] byte_item
        #   @return [Google::Privacy::Dlp::V2::ByteContentItem]
        #     Content data to inspect or redact. Replaces +type+ and +data+.
        class ContentItem; end

        # Structured content to inspect. Up to 50,000 +Value+s per request allowed.
        # See https://cloud.google.com/dlp/docs/inspecting-text#inspecting_a_table to
        # learn more.
        # @!attribute [rw] headers
        #   @return [Array<Google::Privacy::Dlp::V2::FieldId>]
        # @!attribute [rw] rows
        #   @return [Array<Google::Privacy::Dlp::V2::Table::Row>]
        class Table
          # @!attribute [rw] values
          #   @return [Array<Google::Privacy::Dlp::V2::Value>]
          class Row; end
        end

        # All the findings for a single scanned item.
        # @!attribute [rw] findings
        #   @return [Array<Google::Privacy::Dlp::V2::Finding>]
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

        # Represents a piece of potentially sensitive content.
        # @!attribute [rw] quote
        #   @return [String]
        #     The content that was found. Even if the content is not textual, it
        #     may be converted to a textual representation here.
        #     Provided if +include_quote+ is true and the finding is
        #     less than or equal to 4096 bytes long. If the finding exceeds 4096 bytes
        #     in length, the quote may be omitted.
        # @!attribute [rw] info_type
        #   @return [Google::Privacy::Dlp::V2::InfoType]
        #     The type of content that might have been found.
        #     Provided if +excluded_types+ is false.
        # @!attribute [rw] likelihood
        #   @return [Google::Privacy::Dlp::V2::Likelihood]
        #     Confidence of how likely it is that the +info_type+ is correct.
        # @!attribute [rw] location
        #   @return [Google::Privacy::Dlp::V2::Location]
        #     Where the content was found.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     Timestamp when finding was detected.
        # @!attribute [rw] quote_info
        #   @return [Google::Privacy::Dlp::V2::QuoteInfo]
        #     Contains data parsed from quotes. Only populated if include_quote was set
        #     to true and a supported infoType was requested. Currently supported
        #     infoTypes: DATE, DATE_OF_BIRTH and TIME.
        class Finding; end

        # Specifies the location of the finding.
        # @!attribute [rw] byte_range
        #   @return [Google::Privacy::Dlp::V2::Range]
        #     Zero-based byte offsets delimiting the finding.
        #     These are relative to the finding's containing element.
        #     Note that when the content is not textual, this references
        #     the UTF-8 encoded textual representation of the content.
        #     Omitted if content is an image.
        # @!attribute [rw] codepoint_range
        #   @return [Google::Privacy::Dlp::V2::Range]
        #     Unicode character offsets delimiting the finding.
        #     These are relative to the finding's containing element.
        #     Provided when the content is text.
        # @!attribute [rw] content_locations
        #   @return [Array<Google::Privacy::Dlp::V2::ContentLocation>]
        #     List of nested objects pointing to the precise location of the finding
        #     within the file or record.
        class Location; end

        # Findings container location data.
        # @!attribute [rw] container_name
        #   @return [String]
        #     Name of the container where the finding is located.
        #     The top level name is the source file name or table name. Nested names
        #     could be absent if the embedded object has no string identifier
        #     (for an example an image contained within a document).
        # @!attribute [rw] record_location
        #   @return [Google::Privacy::Dlp::V2::RecordLocation]
        #     Location within a row or record of a database table.
        # @!attribute [rw] image_location
        #   @return [Google::Privacy::Dlp::V2::ImageLocation]
        #     Location within an image's pixels.
        # @!attribute [rw] document_location
        #   @return [Google::Privacy::Dlp::V2::DocumentLocation]
        #     Location data for document files.
        # @!attribute [rw] container_timestamp
        #   @return [Google::Protobuf::Timestamp]
        #     Findings container modification timestamp, if applicable.
        #     For Google Cloud Storage contains last file modification timestamp.
        #     For BigQuery table contains last_modified_time property.
        #     For Datastore - not populated.
        # @!attribute [rw] container_version
        #   @return [String]
        #     Findings container version, if available
        #     ("generation" for Google Cloud Storage).
        class ContentLocation; end

        # Location of a finding within a document.
        # @!attribute [rw] file_offset
        #   @return [Integer]
        #     Offset of the line, from the beginning of the file, where the finding
        #     is located.
        class DocumentLocation; end

        # Location of a finding within a row or record.
        # @!attribute [rw] record_key
        #   @return [Google::Privacy::Dlp::V2::RecordKey]
        #     Key of the finding.
        # @!attribute [rw] field_id
        #   @return [Google::Privacy::Dlp::V2::FieldId]
        #     Field id of the field containing the finding.
        # @!attribute [rw] table_location
        #   @return [Google::Privacy::Dlp::V2::TableLocation]
        #     Location within a +ContentItem.Table+.
        class RecordLocation; end

        # Location of a finding within a table.
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

        # Location of the finding within an image.
        # @!attribute [rw] bounding_boxes
        #   @return [Array<Google::Privacy::Dlp::V2::BoundingBox>]
        #     Bounding boxes locating the pixels within the image containing the finding.
        class ImageLocation; end

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
        class BoundingBox; end

        # Request to search for potentially sensitive info in an image and redact it
        # by covering it with a colored rectangle.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name, for example projects/my-project-id.
        # @!attribute [rw] inspect_config
        #   @return [Google::Privacy::Dlp::V2::InspectConfig]
        #     Configuration for the inspector.
        # @!attribute [rw] image_redaction_configs
        #   @return [Array<Google::Privacy::Dlp::V2::RedactImageRequest::ImageRedactionConfig>]
        #     The configuration for specifying what content to redact from images.
        # @!attribute [rw] include_findings
        #   @return [true, false]
        #     Whether the response should include findings along with the redacted
        #     image.
        # @!attribute [rw] byte_item
        #   @return [Google::Privacy::Dlp::V2::ByteContentItem]
        #     The content must be PNG, JPEG, SVG or BMP.
        class RedactImageRequest
          # Configuration for determining how redaction of images should occur.
          # @!attribute [rw] info_type
          #   @return [Google::Privacy::Dlp::V2::InfoType]
          #     Only one per info_type should be provided per request. If not
          #     specified, and redact_all_text is false, the DLP API will redact all
          #     text that it matches against all info_types that are found, but not
          #     specified in another ImageRedactionConfig.
          # @!attribute [rw] redact_all_text
          #   @return [true, false]
          #     If true, all text found in the image, regardless whether it matches an
          #     info_type, is redacted. Only one should be provided.
          # @!attribute [rw] redaction_color
          #   @return [Google::Privacy::Dlp::V2::Color]
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

        # Results of redacting an image.
        # @!attribute [rw] redacted_image
        #   @return [String]
        #     The redacted image. The type will be the same as the original image.
        # @!attribute [rw] extracted_text
        #   @return [String]
        #     If an image was being inspected and the InspectConfig's include_quote was
        #     set to true, then this field will include all text, if any, that was found
        #     in the image.
        # @!attribute [rw] inspect_result
        #   @return [Google::Privacy::Dlp::V2::InspectResult]
        #     The findings. Populated when include_findings in the request is true.
        class RedactImageResponse; end

        # Request to de-identify a list of items.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name, for example projects/my-project-id.
        # @!attribute [rw] deidentify_config
        #   @return [Google::Privacy::Dlp::V2::DeidentifyConfig]
        #     Configuration for the de-identification of the content item.
        #     Items specified here will override the template referenced by the
        #     deidentify_template_name argument.
        # @!attribute [rw] inspect_config
        #   @return [Google::Privacy::Dlp::V2::InspectConfig]
        #     Configuration for the inspector.
        #     Items specified here will override the template referenced by the
        #     inspect_template_name argument.
        # @!attribute [rw] item
        #   @return [Google::Privacy::Dlp::V2::ContentItem]
        #     The item to de-identify. Will be treated as text.
        # @!attribute [rw] inspect_template_name
        #   @return [String]
        #     Optional template to use. Any configuration directly specified in
        #     inspect_config will override those set in the template. Singular fields
        #     that are set in this request will replace their corresponding fields in the
        #     template. Repeated fields are appended. Singular sub-messages and groups
        #     are recursively merged.
        # @!attribute [rw] deidentify_template_name
        #   @return [String]
        #     Optional template to use. Any configuration directly specified in
        #     deidentify_config will override those set in the template. Singular fields
        #     that are set in this request will replace their corresponding fields in the
        #     template. Repeated fields are appended. Singular sub-messages and groups
        #     are recursively merged.
        class DeidentifyContentRequest; end

        # Results of de-identifying a ContentItem.
        # @!attribute [rw] item
        #   @return [Google::Privacy::Dlp::V2::ContentItem]
        #     The de-identified item.
        # @!attribute [rw] overview
        #   @return [Google::Privacy::Dlp::V2::TransformationOverview]
        #     An overview of the changes that were made on the +item+.
        class DeidentifyContentResponse; end

        # Request to re-identify an item.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name.
        # @!attribute [rw] reidentify_config
        #   @return [Google::Privacy::Dlp::V2::DeidentifyConfig]
        #     Configuration for the re-identification of the content item.
        #     This field shares the same proto message type that is used for
        #     de-identification, however its usage here is for the reversal of the
        #     previous de-identification. Re-identification is performed by examining
        #     the transformations used to de-identify the items and executing the
        #     reverse. This requires that only reversible transformations
        #     be provided here. The reversible transformations are:
        #
        #     * +CryptoReplaceFfxFpeConfig+
        # @!attribute [rw] inspect_config
        #   @return [Google::Privacy::Dlp::V2::InspectConfig]
        #     Configuration for the inspector.
        # @!attribute [rw] item
        #   @return [Google::Privacy::Dlp::V2::ContentItem]
        #     The item to re-identify. Will be treated as text.
        # @!attribute [rw] inspect_template_name
        #   @return [String]
        #     Optional template to use. Any configuration directly specified in
        #     +inspect_config+ will override those set in the template. Singular fields
        #     that are set in this request will replace their corresponding fields in the
        #     template. Repeated fields are appended. Singular sub-messages and groups
        #     are recursively merged.
        # @!attribute [rw] reidentify_template_name
        #   @return [String]
        #     Optional template to use. References an instance of +DeidentifyTemplate+.
        #     Any configuration directly specified in +reidentify_config+ or
        #     +inspect_config+ will override those set in the template. Singular fields
        #     that are set in this request will replace their corresponding fields in the
        #     template. Repeated fields are appended. Singular sub-messages and groups
        #     are recursively merged.
        class ReidentifyContentRequest; end

        # Results of re-identifying a item.
        # @!attribute [rw] item
        #   @return [Google::Privacy::Dlp::V2::ContentItem]
        #     The re-identified item.
        # @!attribute [rw] overview
        #   @return [Google::Privacy::Dlp::V2::TransformationOverview]
        #     An overview of the changes that were made to the +item+.
        class ReidentifyContentResponse; end

        # Request to search for potentially sensitive info in a ContentItem.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name, for example projects/my-project-id.
        # @!attribute [rw] inspect_config
        #   @return [Google::Privacy::Dlp::V2::InspectConfig]
        #     Configuration for the inspector. What specified here will override
        #     the template referenced by the inspect_template_name argument.
        # @!attribute [rw] item
        #   @return [Google::Privacy::Dlp::V2::ContentItem]
        #     The item to inspect.
        # @!attribute [rw] inspect_template_name
        #   @return [String]
        #     Optional template to use. Any configuration directly specified in
        #     inspect_config will override those set in the template. Singular fields
        #     that are set in this request will replace their corresponding fields in the
        #     template. Repeated fields are appended. Singular sub-messages and groups
        #     are recursively merged.
        class InspectContentRequest; end

        # Results of inspecting an item.
        # @!attribute [rw] result
        #   @return [Google::Privacy::Dlp::V2::InspectResult]
        #     The findings.
        class InspectContentResponse; end

        # Cloud repository for storing output.
        # @!attribute [rw] table
        #   @return [Google::Privacy::Dlp::V2::BigQueryTable]
        #     Store findings in an existing table or a new table in an existing
        #     dataset. If table_id is not set a new one will be generated
        #     for you with the following format:
        #     dlp_googleapis_yyyy_mm_dd_[dlp_job_id]. Pacific timezone will be used for
        #     generating the date details.
        #
        #     For Inspect, each column in an existing output table must have the same
        #     name, type, and mode of a field in the +Finding+ object.
        #
        #     For Risk, an existing output table should be the output of a previous
        #     Risk analysis job run on the same source table, with the same privacy
        #     metric and quasi-identifiers. Risk jobs that analyze the same table but
        #     compute a different privacy metric, or use different sets of
        #     quasi-identifiers, cannot store their results in the same table.
        # @!attribute [rw] output_schema
        #   @return [Google::Privacy::Dlp::V2::OutputStorageConfig::OutputSchema]
        #     Schema used for writing the findings for Inspect jobs. This field is only
        #     used for Inspect and must be unspecified for Risk jobs. Columns are derived
        #     from the +Finding+ object. If appending to an existing table, any columns
        #     from the predefined schema that are missing will be added. No columns in
        #     the existing table will be deleted.
        #
        #     If unspecified, then all available columns will be used for a new table,
        #     and no changes will be made to an existing table.
        class OutputStorageConfig
          # Predefined schemas for storing findings.
          module OutputSchema
            OUTPUT_SCHEMA_UNSPECIFIED = 0

            # Basic schema including only +info_type+, +quote+, +certainty+, and
            # +timestamp+.
            BASIC_COLUMNS = 1

            # Schema tailored to findings from scanning Google Cloud Storage.
            GCS_COLUMNS = 2

            # Schema tailored to findings from scanning Google Datastore.
            DATASTORE_COLUMNS = 3

            # Schema tailored to findings from scanning Google BigQuery.
            BIG_QUERY_COLUMNS = 4

            # Schema containing all columns.
            ALL_COLUMNS = 5
          end
        end

        # Statistics regarding a specific InfoType.
        # @!attribute [rw] info_type
        #   @return [Google::Privacy::Dlp::V2::InfoType]
        #     The type of finding this stat is for.
        # @!attribute [rw] count
        #   @return [Integer]
        #     Number of findings for this infoType.
        class InfoTypeStats; end

        # The results of an inspect DataSource job.
        # @!attribute [rw] requested_options
        #   @return [Google::Privacy::Dlp::V2::InspectDataSourceDetails::RequestedOptions]
        #     The configuration used for this job.
        # @!attribute [rw] result
        #   @return [Google::Privacy::Dlp::V2::InspectDataSourceDetails::Result]
        #     A summary of the outcome of this inspect job.
        class InspectDataSourceDetails
          # @!attribute [rw] snapshot_inspect_template
          #   @return [Google::Privacy::Dlp::V2::InspectTemplate]
          #     If run with an InspectTemplate, a snapshot of its state at the time of
          #     this run.
          # @!attribute [rw] job_config
          #   @return [Google::Privacy::Dlp::V2::InspectJobConfig]
          class RequestedOptions; end

          # @!attribute [rw] processed_bytes
          #   @return [Integer]
          #     Total size in bytes that were processed.
          # @!attribute [rw] total_estimated_bytes
          #   @return [Integer]
          #     Estimate of the number of bytes to process.
          # @!attribute [rw] info_type_stats
          #   @return [Array<Google::Privacy::Dlp::V2::InfoTypeStats>]
          #     Statistics of how many instances of each info type were found during
          #     inspect job.
          class Result; end
        end

        # InfoType description.
        # @!attribute [rw] name
        #   @return [String]
        #     Internal name of the infoType.
        # @!attribute [rw] display_name
        #   @return [String]
        #     Human readable form of the infoType name.
        # @!attribute [rw] supported_by
        #   @return [Array<Google::Privacy::Dlp::V2::InfoTypeSupportedBy>]
        #     Which parts of the API supports this InfoType.
        class InfoTypeDescription; end

        # Request for the list of infoTypes.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional BCP-47 language code for localized infoType friendly
        #     names. If omitted, or if localized strings are not available,
        #     en-US strings will be returned.
        # @!attribute [rw] filter
        #   @return [String]
        #     Optional filter to only return infoTypes supported by certain parts of the
        #     API. Defaults to supported_by=INSPECT.
        class ListInfoTypesRequest; end

        # Response to the ListInfoTypes request.
        # @!attribute [rw] info_types
        #   @return [Array<Google::Privacy::Dlp::V2::InfoTypeDescription>]
        #     Set of sensitive infoTypes.
        class ListInfoTypesResponse; end

        # Configuration for a risk analysis job. See
        # https://cloud.google.com/dlp/docs/concepts-risk-analysis to learn more.
        # @!attribute [rw] privacy_metric
        #   @return [Google::Privacy::Dlp::V2::PrivacyMetric]
        #     Privacy metric to compute.
        # @!attribute [rw] source_table
        #   @return [Google::Privacy::Dlp::V2::BigQueryTable]
        #     Input dataset to compute metrics over.
        # @!attribute [rw] actions
        #   @return [Array<Google::Privacy::Dlp::V2::Action>]
        #     Actions to execute at the completion of the job. Are executed in the order
        #     provided.
        class RiskAnalysisJobConfig; end

        # A column with a semantic tag attached.
        # @!attribute [rw] field
        #   @return [Google::Privacy::Dlp::V2::FieldId]
        #     Identifies the column. [required]
        # @!attribute [rw] info_type
        #   @return [Google::Privacy::Dlp::V2::InfoType]
        #     A column can be tagged with a InfoType to use the relevant public
        #     dataset as a statistical model of population, if available. We
        #     currently support US ZIP codes, region codes, ages and genders.
        #     To programmatically obtain the list of supported InfoTypes, use
        #     ListInfoTypes with the supported_by=RISK_ANALYSIS filter.
        # @!attribute [rw] custom_tag
        #   @return [String]
        #     A column can be tagged with a custom tag. In this case, the user must
        #     indicate an auxiliary table that contains statistical information on
        #     the possible values of this column (below).
        # @!attribute [rw] inferred
        #   @return [Google::Protobuf::Empty]
        #     If no semantic tag is indicated, we infer the statistical model from
        #     the distribution of values in the input data
        class QuasiId; end

        # An auxiliary table containing statistical information on the relative
        # frequency of different quasi-identifiers values. It has one or several
        # quasi-identifiers columns, and one column that indicates the relative
        # frequency of each quasi-identifier tuple.
        # If a tuple is present in the data but not in the auxiliary table, the
        # corresponding relative frequency is assumed to be zero (and thus, the
        # tuple is highly reidentifiable).
        # @!attribute [rw] table
        #   @return [Google::Privacy::Dlp::V2::BigQueryTable]
        #     Auxiliary table location. [required]
        # @!attribute [rw] quasi_ids
        #   @return [Array<Google::Privacy::Dlp::V2::StatisticalTable::QuasiIdentifierField>]
        #     Quasi-identifier columns. [required]
        # @!attribute [rw] relative_frequency
        #   @return [Google::Privacy::Dlp::V2::FieldId]
        #     The relative frequency column must contain a floating-point number
        #     between 0 and 1 (inclusive). Null values are assumed to be zero.
        #     [required]
        class StatisticalTable
          # A quasi-identifier column has a custom_tag, used to know which column
          # in the data corresponds to which column in the statistical model.
          # @!attribute [rw] field
          #   @return [Google::Privacy::Dlp::V2::FieldId]
          # @!attribute [rw] custom_tag
          #   @return [String]
          class QuasiIdentifierField; end
        end

        # Privacy metric to compute for reidentification risk analysis.
        # @!attribute [rw] numerical_stats_config
        #   @return [Google::Privacy::Dlp::V2::PrivacyMetric::NumericalStatsConfig]
        # @!attribute [rw] categorical_stats_config
        #   @return [Google::Privacy::Dlp::V2::PrivacyMetric::CategoricalStatsConfig]
        # @!attribute [rw] k_anonymity_config
        #   @return [Google::Privacy::Dlp::V2::PrivacyMetric::KAnonymityConfig]
        # @!attribute [rw] l_diversity_config
        #   @return [Google::Privacy::Dlp::V2::PrivacyMetric::LDiversityConfig]
        # @!attribute [rw] k_map_estimation_config
        #   @return [Google::Privacy::Dlp::V2::PrivacyMetric::KMapEstimationConfig]
        # @!attribute [rw] delta_presence_estimation_config
        #   @return [Google::Privacy::Dlp::V2::PrivacyMetric::DeltaPresenceEstimationConfig]
        class PrivacyMetric
          # Compute numerical stats over an individual column, including
          # min, max, and quantiles.
          # @!attribute [rw] field
          #   @return [Google::Privacy::Dlp::V2::FieldId]
          #     Field to compute numerical stats on. Supported types are
          #     integer, float, date, datetime, timestamp, time.
          class NumericalStatsConfig; end

          # Compute numerical stats over an individual column, including
          # number of distinct values and value count distribution.
          # @!attribute [rw] field
          #   @return [Google::Privacy::Dlp::V2::FieldId]
          #     Field to compute categorical stats on. All column types are
          #     supported except for arrays and structs. However, it may be more
          #     informative to use NumericalStats when the field type is supported,
          #     depending on the data.
          class CategoricalStatsConfig; end

          # k-anonymity metric, used for analysis of reidentification risk.
          # @!attribute [rw] quasi_ids
          #   @return [Array<Google::Privacy::Dlp::V2::FieldId>]
          #     Set of fields to compute k-anonymity over. When multiple fields are
          #     specified, they are considered a single composite key. Structs and
          #     repeated data types are not supported; however, nested fields are
          #     supported so long as they are not structs themselves or nested within
          #     a repeated field.
          # @!attribute [rw] entity_id
          #   @return [Google::Privacy::Dlp::V2::EntityId]
          #     Optional message indicating that multiple rows might be associated to a
          #     single individual. If the same entity_id is associated to multiple
          #     quasi-identifier tuples over distict rows, we consider the entire
          #     collection of tuples as the composite quasi-identifier. This collection
          #     is a multiset: the order in which the different tuples appear in the
          #     dataset is ignored, but their frequency is taken into account.
          #
          #     Important note: a maximum of 1000 rows can be associated to a single
          #     entity ID. If more rows are associated with the same entity ID, some
          #     might be ignored.
          class KAnonymityConfig; end

          # l-diversity metric, used for analysis of reidentification risk.
          # @!attribute [rw] quasi_ids
          #   @return [Array<Google::Privacy::Dlp::V2::FieldId>]
          #     Set of quasi-identifiers indicating how equivalence classes are
          #     defined for the l-diversity computation. When multiple fields are
          #     specified, they are considered a single composite key.
          # @!attribute [rw] sensitive_attribute
          #   @return [Google::Privacy::Dlp::V2::FieldId]
          #     Sensitive field for computing the l-value.
          class LDiversityConfig; end

          # Reidentifiability metric. This corresponds to a risk model similar to what
          # is called "journalist risk" in the literature, except the attack dataset is
          # statistically modeled instead of being perfectly known. This can be done
          # using publicly available data (like the US Census), or using a custom
          # statistical model (indicated as one or several BigQuery tables), or by
          # extrapolating from the distribution of values in the input dataset.
          # A column with a semantic tag attached.
          # @!attribute [rw] quasi_ids
          #   @return [Array<Google::Privacy::Dlp::V2::PrivacyMetric::KMapEstimationConfig::TaggedField>]
          #     Fields considered to be quasi-identifiers. No two columns can have the
          #     same tag. [required]
          # @!attribute [rw] region_code
          #   @return [String]
          #     ISO 3166-1 alpha-2 region code to use in the statistical modeling.
          #     Required if no column is tagged with a region-specific InfoType (like
          #     US_ZIP_5) or a region code.
          # @!attribute [rw] auxiliary_tables
          #   @return [Array<Google::Privacy::Dlp::V2::PrivacyMetric::KMapEstimationConfig::AuxiliaryTable>]
          #     Several auxiliary tables can be used in the analysis. Each custom_tag
          #     used to tag a quasi-identifiers column must appear in exactly one column
          #     of one auxiliary table.
          class KMapEstimationConfig
            # @!attribute [rw] field
            #   @return [Google::Privacy::Dlp::V2::FieldId]
            #     Identifies the column. [required]
            # @!attribute [rw] info_type
            #   @return [Google::Privacy::Dlp::V2::InfoType]
            #     A column can be tagged with a InfoType to use the relevant public
            #     dataset as a statistical model of population, if available. We
            #     currently support US ZIP codes, region codes, ages and genders.
            #     To programmatically obtain the list of supported InfoTypes, use
            #     ListInfoTypes with the supported_by=RISK_ANALYSIS filter.
            # @!attribute [rw] custom_tag
            #   @return [String]
            #     A column can be tagged with a custom tag. In this case, the user must
            #     indicate an auxiliary table that contains statistical information on
            #     the possible values of this column (below).
            # @!attribute [rw] inferred
            #   @return [Google::Protobuf::Empty]
            #     If no semantic tag is indicated, we infer the statistical model from
            #     the distribution of values in the input data
            class TaggedField; end

            # An auxiliary table contains statistical information on the relative
            # frequency of different quasi-identifiers values. It has one or several
            # quasi-identifiers columns, and one column that indicates the relative
            # frequency of each quasi-identifier tuple.
            # If a tuple is present in the data but not in the auxiliary table, the
            # corresponding relative frequency is assumed to be zero (and thus, the
            # tuple is highly reidentifiable).
            # @!attribute [rw] table
            #   @return [Google::Privacy::Dlp::V2::BigQueryTable]
            #     Auxiliary table location. [required]
            # @!attribute [rw] quasi_ids
            #   @return [Array<Google::Privacy::Dlp::V2::PrivacyMetric::KMapEstimationConfig::AuxiliaryTable::QuasiIdField>]
            #     Quasi-identifier columns. [required]
            # @!attribute [rw] relative_frequency
            #   @return [Google::Privacy::Dlp::V2::FieldId]
            #     The relative frequency column must contain a floating-point number
            #     between 0 and 1 (inclusive). Null values are assumed to be zero.
            #     [required]
            class AuxiliaryTable
              # A quasi-identifier column has a custom_tag, used to know which column
              # in the data corresponds to which column in the statistical model.
              # @!attribute [rw] field
              #   @return [Google::Privacy::Dlp::V2::FieldId]
              # @!attribute [rw] custom_tag
              #   @return [String]
              class QuasiIdField; end
            end
          end

          # δ-presence metric, used to estimate how likely it is for an attacker to
          # figure out that one given individual appears in a de-identified dataset.
          # Similarly to the k-map metric, we cannot compute δ-presence exactly without
          # knowing the attack dataset, so we use a statistical model instead.
          # @!attribute [rw] quasi_ids
          #   @return [Array<Google::Privacy::Dlp::V2::QuasiId>]
          #     Fields considered to be quasi-identifiers. No two fields can have the
          #     same tag. [required]
          # @!attribute [rw] region_code
          #   @return [String]
          #     ISO 3166-1 alpha-2 region code to use in the statistical modeling.
          #     Required if no column is tagged with a region-specific InfoType (like
          #     US_ZIP_5) or a region code.
          # @!attribute [rw] auxiliary_tables
          #   @return [Array<Google::Privacy::Dlp::V2::StatisticalTable>]
          #     Several auxiliary tables can be used in the analysis. Each custom_tag
          #     used to tag a quasi-identifiers field must appear in exactly one
          #     field of one auxiliary table.
          class DeltaPresenceEstimationConfig; end
        end

        # Result of a risk analysis operation request.
        # @!attribute [rw] requested_privacy_metric
        #   @return [Google::Privacy::Dlp::V2::PrivacyMetric]
        #     Privacy metric to compute.
        # @!attribute [rw] requested_source_table
        #   @return [Google::Privacy::Dlp::V2::BigQueryTable]
        #     Input dataset to compute metrics over.
        # @!attribute [rw] numerical_stats_result
        #   @return [Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::NumericalStatsResult]
        # @!attribute [rw] categorical_stats_result
        #   @return [Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::CategoricalStatsResult]
        # @!attribute [rw] k_anonymity_result
        #   @return [Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::KAnonymityResult]
        # @!attribute [rw] l_diversity_result
        #   @return [Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::LDiversityResult]
        # @!attribute [rw] k_map_estimation_result
        #   @return [Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::KMapEstimationResult]
        # @!attribute [rw] delta_presence_estimation_result
        #   @return [Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::DeltaPresenceEstimationResult]
        class AnalyzeDataSourceRiskDetails
          # Result of the numerical stats computation.
          # @!attribute [rw] min_value
          #   @return [Google::Privacy::Dlp::V2::Value]
          #     Minimum value appearing in the column.
          # @!attribute [rw] max_value
          #   @return [Google::Privacy::Dlp::V2::Value]
          #     Maximum value appearing in the column.
          # @!attribute [rw] quantile_values
          #   @return [Array<Google::Privacy::Dlp::V2::Value>]
          #     List of 99 values that partition the set of field values into 100 equal
          #     sized buckets.
          class NumericalStatsResult; end

          # Result of the categorical stats computation.
          # @!attribute [rw] value_frequency_histogram_buckets
          #   @return [Array<Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::CategoricalStatsResult::CategoricalStatsHistogramBucket>]
          #     Histogram of value frequencies in the column.
          class CategoricalStatsResult
            # @!attribute [rw] value_frequency_lower_bound
            #   @return [Integer]
            #     Lower bound on the value frequency of the values in this bucket.
            # @!attribute [rw] value_frequency_upper_bound
            #   @return [Integer]
            #     Upper bound on the value frequency of the values in this bucket.
            # @!attribute [rw] bucket_size
            #   @return [Integer]
            #     Total number of values in this bucket.
            # @!attribute [rw] bucket_values
            #   @return [Array<Google::Privacy::Dlp::V2::ValueFrequency>]
            #     Sample of value frequencies in this bucket. The total number of
            #     values returned per bucket is capped at 20.
            # @!attribute [rw] bucket_value_count
            #   @return [Integer]
            #     Total number of distinct values in this bucket.
            class CategoricalStatsHistogramBucket; end
          end

          # Result of the k-anonymity computation.
          # @!attribute [rw] equivalence_class_histogram_buckets
          #   @return [Array<Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::KAnonymityResult::KAnonymityHistogramBucket>]
          #     Histogram of k-anonymity equivalence classes.
          class KAnonymityResult
            # The set of columns' values that share the same ldiversity value
            # @!attribute [rw] quasi_ids_values
            #   @return [Array<Google::Privacy::Dlp::V2::Value>]
            #     Set of values defining the equivalence class. One value per
            #     quasi-identifier column in the original KAnonymity metric message.
            #     The order is always the same as the original request.
            # @!attribute [rw] equivalence_class_size
            #   @return [Integer]
            #     Size of the equivalence class, for example number of rows with the
            #     above set of values.
            class KAnonymityEquivalenceClass; end

            # @!attribute [rw] equivalence_class_size_lower_bound
            #   @return [Integer]
            #     Lower bound on the size of the equivalence classes in this bucket.
            # @!attribute [rw] equivalence_class_size_upper_bound
            #   @return [Integer]
            #     Upper bound on the size of the equivalence classes in this bucket.
            # @!attribute [rw] bucket_size
            #   @return [Integer]
            #     Total number of equivalence classes in this bucket.
            # @!attribute [rw] bucket_values
            #   @return [Array<Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::KAnonymityResult::KAnonymityEquivalenceClass>]
            #     Sample of equivalence classes in this bucket. The total number of
            #     classes returned per bucket is capped at 20.
            # @!attribute [rw] bucket_value_count
            #   @return [Integer]
            #     Total number of distinct equivalence classes in this bucket.
            class KAnonymityHistogramBucket; end
          end

          # Result of the l-diversity computation.
          # @!attribute [rw] sensitive_value_frequency_histogram_buckets
          #   @return [Array<Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::LDiversityResult::LDiversityHistogramBucket>]
          #     Histogram of l-diversity equivalence class sensitive value frequencies.
          class LDiversityResult
            # The set of columns' values that share the same ldiversity value.
            # @!attribute [rw] quasi_ids_values
            #   @return [Array<Google::Privacy::Dlp::V2::Value>]
            #     Quasi-identifier values defining the k-anonymity equivalence
            #     class. The order is always the same as the original request.
            # @!attribute [rw] equivalence_class_size
            #   @return [Integer]
            #     Size of the k-anonymity equivalence class.
            # @!attribute [rw] num_distinct_sensitive_values
            #   @return [Integer]
            #     Number of distinct sensitive values in this equivalence class.
            # @!attribute [rw] top_sensitive_values
            #   @return [Array<Google::Privacy::Dlp::V2::ValueFrequency>]
            #     Estimated frequencies of top sensitive values.
            class LDiversityEquivalenceClass; end

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
            #     Total number of equivalence classes in this bucket.
            # @!attribute [rw] bucket_values
            #   @return [Array<Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::LDiversityResult::LDiversityEquivalenceClass>]
            #     Sample of equivalence classes in this bucket. The total number of
            #     classes returned per bucket is capped at 20.
            # @!attribute [rw] bucket_value_count
            #   @return [Integer]
            #     Total number of distinct equivalence classes in this bucket.
            class LDiversityHistogramBucket; end
          end

          # Result of the reidentifiability analysis. Note that these results are an
          # estimation, not exact values.
          # @!attribute [rw] k_map_estimation_histogram
          #   @return [Array<Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::KMapEstimationResult::KMapEstimationHistogramBucket>]
          #     The intervals [min_anonymity, max_anonymity] do not overlap. If a value
          #     doesn't correspond to any such interval, the associated frequency is
          #     zero. For example, the following records:
          #       {min_anonymity: 1, max_anonymity: 1, frequency: 17}
          #       {min_anonymity: 2, max_anonymity: 3, frequency: 42}
          #       {min_anonymity: 5, max_anonymity: 10, frequency: 99}
          #     mean that there are no record with an estimated anonymity of 4, 5, or
          #     larger than 10.
          class KMapEstimationResult
            # A tuple of values for the quasi-identifier columns.
            # @!attribute [rw] quasi_ids_values
            #   @return [Array<Google::Privacy::Dlp::V2::Value>]
            #     The quasi-identifier values.
            # @!attribute [rw] estimated_anonymity
            #   @return [Integer]
            #     The estimated anonymity for these quasi-identifier values.
            class KMapEstimationQuasiIdValues; end

            # A KMapEstimationHistogramBucket message with the following values:
            #   min_anonymity: 3
            #   max_anonymity: 5
            #   frequency: 42
            # means that there are 42 records whose quasi-identifier values correspond
            # to 3, 4 or 5 people in the overlying population. An important particular
            # case is when min_anonymity = max_anonymity = 1: the frequency field then
            # corresponds to the number of uniquely identifiable records.
            # @!attribute [rw] min_anonymity
            #   @return [Integer]
            #     Always positive.
            # @!attribute [rw] max_anonymity
            #   @return [Integer]
            #     Always greater than or equal to min_anonymity.
            # @!attribute [rw] bucket_size
            #   @return [Integer]
            #     Number of records within these anonymity bounds.
            # @!attribute [rw] bucket_values
            #   @return [Array<Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::KMapEstimationResult::KMapEstimationQuasiIdValues>]
            #     Sample of quasi-identifier tuple values in this bucket. The total
            #     number of classes returned per bucket is capped at 20.
            # @!attribute [rw] bucket_value_count
            #   @return [Integer]
            #     Total number of distinct quasi-identifier tuple values in this bucket.
            class KMapEstimationHistogramBucket; end
          end

          # Result of the δ-presence computation. Note that these results are an
          # estimation, not exact values.
          # @!attribute [rw] delta_presence_estimation_histogram
          #   @return [Array<Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::DeltaPresenceEstimationResult::DeltaPresenceEstimationHistogramBucket>]
          #     The intervals [min_probability, max_probability) do not overlap. If a
          #     value doesn't correspond to any such interval, the associated frequency
          #     is zero. For example, the following records:
          #       {min_probability: 0, max_probability: 0.1, frequency: 17}
          #       {min_probability: 0.2, max_probability: 0.3, frequency: 42}
          #       {min_probability: 0.3, max_probability: 0.4, frequency: 99}
          #     mean that there are no record with an estimated probability in [0.1, 0.2)
          #     nor larger or equal to 0.4.
          class DeltaPresenceEstimationResult
            # A tuple of values for the quasi-identifier columns.
            # @!attribute [rw] quasi_ids_values
            #   @return [Array<Google::Privacy::Dlp::V2::Value>]
            #     The quasi-identifier values.
            # @!attribute [rw] estimated_probability
            #   @return [Float]
            #     The estimated probability that a given individual sharing these
            #     quasi-identifier values is in the dataset. This value, typically called
            #     δ, is the ratio between the number of records in the dataset with these
            #     quasi-identifier values, and the total number of individuals (inside
            #     *and* outside the dataset) with these quasi-identifier values.
            #     For example, if there are 15 individuals in the dataset who share the
            #     same quasi-identifier values, and an estimated 100 people in the entire
            #     population with these values, then δ is 0.15.
            class DeltaPresenceEstimationQuasiIdValues; end

            # A DeltaPresenceEstimationHistogramBucket message with the following
            # values:
            #   min_probability: 0.1
            #   max_probability: 0.2
            #   frequency: 42
            # means that there are 42 records for which δ is in [0.1, 0.2). An
            # important particular case is when min_probability = max_probability = 1:
            # then, every individual who shares this quasi-identifier combination is in
            # the dataset.
            # @!attribute [rw] min_probability
            #   @return [Float]
            #     Between 0 and 1.
            # @!attribute [rw] max_probability
            #   @return [Float]
            #     Always greater than or equal to min_probability.
            # @!attribute [rw] bucket_size
            #   @return [Integer]
            #     Number of records within these probability bounds.
            # @!attribute [rw] bucket_values
            #   @return [Array<Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails::DeltaPresenceEstimationResult::DeltaPresenceEstimationQuasiIdValues>]
            #     Sample of quasi-identifier tuple values in this bucket. The total
            #     number of classes returned per bucket is capped at 20.
            # @!attribute [rw] bucket_value_count
            #   @return [Integer]
            #     Total number of distinct quasi-identifier tuple values in this bucket.
            class DeltaPresenceEstimationHistogramBucket; end
          end
        end

        # A value of a field, including its frequency.
        # @!attribute [rw] value
        #   @return [Google::Privacy::Dlp::V2::Value]
        #     A value contained in the field in question.
        # @!attribute [rw] count
        #   @return [Integer]
        #     How many times the value is contained in the field.
        class ValueFrequency; end

        # Set of primitive values supported by the system.
        # Note that for the purposes of inspection or transformation, the number
        # of bytes considered to comprise a 'Value' is based on its representation
        # as a UTF-8 encoded string. For example, if 'integer_value' is set to
        # 123456789, the number of bytes would be counted as 9, even though an
        # int64 only holds up to 8 bytes of data.
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
        # @!attribute [rw] day_of_week_value
        #   @return [Google::Type::DayOfWeek]
        class Value; end

        # Message for infoType-dependent details parsed from quote.
        # @!attribute [rw] date_time
        #   @return [Google::Privacy::Dlp::V2::DateTime]
        class QuoteInfo; end

        # Message for a date time object.
        # @!attribute [rw] date
        #   @return [Google::Type::Date]
        #     One or more of the following must be set. All fields are optional, but
        #     when set must be valid date or time values.
        # @!attribute [rw] day_of_week
        #   @return [Google::Type::DayOfWeek]
        # @!attribute [rw] time
        #   @return [Google::Type::TimeOfDay]
        # @!attribute [rw] time_zone
        #   @return [Google::Privacy::Dlp::V2::DateTime::TimeZone]
        class DateTime
          # @!attribute [rw] offset_minutes
          #   @return [Integer]
          #     Set only if the offset can be determined. Positive for time ahead of UTC.
          #     E.g. For "UTC-9", this value is -540.
          class TimeZone; end
        end

        # The configuration that controls how the data will change.
        # @!attribute [rw] info_type_transformations
        #   @return [Google::Privacy::Dlp::V2::InfoTypeTransformations]
        #     Treat the dataset as free-form text and apply the same free text
        #     transformation everywhere.
        # @!attribute [rw] record_transformations
        #   @return [Google::Privacy::Dlp::V2::RecordTransformations]
        #     Treat the dataset as structured. Transformations can be applied to
        #     specific locations within structured datasets, such as transforming
        #     a column within a table.
        class DeidentifyConfig; end

        # A rule for transforming a value.
        # @!attribute [rw] replace_config
        #   @return [Google::Privacy::Dlp::V2::ReplaceValueConfig]
        # @!attribute [rw] redact_config
        #   @return [Google::Privacy::Dlp::V2::RedactConfig]
        # @!attribute [rw] character_mask_config
        #   @return [Google::Privacy::Dlp::V2::CharacterMaskConfig]
        # @!attribute [rw] crypto_replace_ffx_fpe_config
        #   @return [Google::Privacy::Dlp::V2::CryptoReplaceFfxFpeConfig]
        # @!attribute [rw] fixed_size_bucketing_config
        #   @return [Google::Privacy::Dlp::V2::FixedSizeBucketingConfig]
        # @!attribute [rw] bucketing_config
        #   @return [Google::Privacy::Dlp::V2::BucketingConfig]
        # @!attribute [rw] replace_with_info_type_config
        #   @return [Google::Privacy::Dlp::V2::ReplaceWithInfoTypeConfig]
        # @!attribute [rw] time_part_config
        #   @return [Google::Privacy::Dlp::V2::TimePartConfig]
        # @!attribute [rw] crypto_hash_config
        #   @return [Google::Privacy::Dlp::V2::CryptoHashConfig]
        # @!attribute [rw] date_shift_config
        #   @return [Google::Privacy::Dlp::V2::DateShiftConfig]
        class PrimitiveTransformation; end

        # For use with +Date+, +Timestamp+, and +TimeOfDay+, extract or preserve a
        # portion of the value.
        # @!attribute [rw] part_to_extract
        #   @return [Google::Privacy::Dlp::V2::TimePartConfig::TimePart]
        class TimePartConfig
          module TimePart
            TIME_PART_UNSPECIFIED = 0

            # [0-9999]
            YEAR = 1

            # [1-12]
            MONTH = 2

            # [1-31]
            DAY_OF_MONTH = 3

            # [1-7]
            DAY_OF_WEEK = 4

            # [1-52]
            WEEK_OF_YEAR = 5

            # [0-23]
            HOUR_OF_DAY = 6
          end
        end

        # Pseudonymization method that generates surrogates via cryptographic hashing.
        # Uses SHA-256.
        # The key size must be either 32 or 64 bytes.
        # Outputs a 32 byte digest as an uppercase hex string
        # (for example, 41D1567F7F99F1DC2A5FAB886DEE5BEE).
        # Currently, only string and integer values can be hashed.
        # @!attribute [rw] crypto_key
        #   @return [Google::Privacy::Dlp::V2::CryptoKey]
        #     The key used by the hash function.
        class CryptoHashConfig; end

        # Replace each input value with a given +Value+.
        # @!attribute [rw] new_value
        #   @return [Google::Privacy::Dlp::V2::Value]
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
        #   @return [Google::Privacy::Dlp::V2::CharsToIgnore::CommonCharsToIgnore]
        class CharsToIgnore
          module CommonCharsToIgnore
            COMMON_CHARS_TO_IGNORE_UNSPECIFIED = 0

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
        #   @return [Array<Google::Privacy::Dlp::V2::CharsToIgnore>]
        #     When masking a string, items in this list will be skipped when replacing.
        #     For example, if your string is 555-555-5555 and you ask us to skip +-+ and
        #     mask 5 chars with * we would produce ***-*55-5555.
        class CharacterMaskConfig; end

        # Buckets values based on fixed size ranges. The
        # Bucketing transformation can provide all of this functionality,
        # but requires more configuration. This message is provided as a convenience to
        # the user for simple bucketing strategies.
        #
        # The transformed value will be a hyphenated string of
        # <lower_bound>-<upper_bound>, i.e if lower_bound = 10 and upper_bound = 20
        # all values that are within this bucket will be replaced with "10-20".
        #
        # This can be used on data of type: double, long.
        #
        # If the bound Value type differs from the type of data
        # being transformed, we will first attempt converting the type of the data to
        # be transformed to match the type of the bound before comparing.
        #
        # See https://cloud.google.com/dlp/docs/concepts-bucketing to learn more.
        # @!attribute [rw] lower_bound
        #   @return [Google::Privacy::Dlp::V2::Value]
        #     Lower bound value of buckets. All values less than +lower_bound+ are
        #     grouped together into a single bucket; for example if +lower_bound+ = 10,
        #     then all values less than 10 are replaced with the value “-10”. [Required].
        # @!attribute [rw] upper_bound
        #   @return [Google::Privacy::Dlp::V2::Value]
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
        # See https://cloud.google.com/dlp/docs/concepts-bucketing to learn more.
        # @!attribute [rw] buckets
        #   @return [Array<Google::Privacy::Dlp::V2::BucketingConfig::Bucket>]
        #     Set of buckets. Ranges must be non-overlapping.
        class BucketingConfig
          # Bucket is represented as a range, along with replacement values.
          # @!attribute [rw] min
          #   @return [Google::Privacy::Dlp::V2::Value]
          #     Lower bound of the range, inclusive. Type should be the same as max if
          #     used.
          # @!attribute [rw] max
          #   @return [Google::Privacy::Dlp::V2::Value]
          #     Upper bound of the range, exclusive; type must match min.
          # @!attribute [rw] replacement_value
          #   @return [Google::Privacy::Dlp::V2::Value]
          #     Replacement value for this bucket. If not provided
          #     the default behavior will be to hyphenate the min-max range.
          class Bucket; end
        end

        # Replaces an identifier with a surrogate using FPE with the FFX
        # mode of operation; however when used in the +ReidentifyContent+ API method,
        # it serves the opposite function by reversing the surrogate back into
        # the original identifier.
        # The identifier must be encoded as ASCII.
        # For a given crypto key and context, the same identifier will be
        # replaced with the same surrogate.
        # Identifiers must be at least two characters long.
        # In the case that the identifier is the empty string, it will be skipped.
        # See https://cloud.google.com/dlp/docs/pseudonymization to learn more.
        # @!attribute [rw] crypto_key
        #   @return [Google::Privacy::Dlp::V2::CryptoKey]
        #     The key used by the encryption algorithm. [required]
        # @!attribute [rw] context
        #   @return [Google::Privacy::Dlp::V2::FieldId]
        #     The 'tweak', a context may be used for higher security since the same
        #     identifier in two different contexts won't be given the same surrogate. If
        #     the context is not set, a default tweak will be used.
        #
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
        # @!attribute [rw] common_alphabet
        #   @return [Google::Privacy::Dlp::V2::CryptoReplaceFfxFpeConfig::FfxCommonNativeAlphabet]
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
        # @!attribute [rw] surrogate_info_type
        #   @return [Google::Privacy::Dlp::V2::InfoType]
        #     The custom infoType to annotate the surrogate with.
        #     This annotation will be applied to the surrogate by prefixing it with
        #     the name of the custom infoType followed by the number of
        #     characters comprising the surrogate. The following scheme defines the
        #     format: info_type_name(surrogate_character_count):surrogate
        #
        #     For example, if the name of custom infoType is 'MY_TOKEN_INFO_TYPE' and
        #     the surrogate is 'abc', the full replacement value
        #     will be: 'MY_TOKEN_INFO_TYPE(3):abc'
        #
        #     This annotation identifies the surrogate when inspecting content using the
        #     custom infoType
        #     [+SurrogateType+](https://cloud.google.com/dlp/docs/reference/rest/v2/InspectConfig#surrogatetype).
        #     This facilitates reversal of the surrogate when it occurs in free text.
        #
        #     In order for inspection to work properly, the name of this infoType must
        #     not occur naturally anywhere in your data; otherwise, inspection may
        #     find a surrogate that does not correspond to an actual identifier.
        #     Therefore, choose your custom infoType name carefully after considering
        #     what your data looks like. One way to select a name that has a high chance
        #     of yielding reliable detection is to include one or more unicode characters
        #     that are highly improbable to exist in your data.
        #     For example, assuming your data is entered from a regular ASCII keyboard,
        #     the symbol with the hex code point 29DD might be used like so:
        #     ⧝MY_TOKEN_TYPE
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
        #   @return [Google::Privacy::Dlp::V2::TransientCryptoKey]
        # @!attribute [rw] unwrapped
        #   @return [Google::Privacy::Dlp::V2::UnwrappedCryptoKey]
        # @!attribute [rw] kms_wrapped
        #   @return [Google::Privacy::Dlp::V2::KmsWrappedCryptoKey]
        class CryptoKey; end

        # Use this to have a random data crypto key generated.
        # It will be discarded after the request finishes.
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

        # Shifts dates by random number of days, with option to be consistent for the
        # same context. See https://cloud.google.com/dlp/docs/concepts-date-shifting
        # to learn more.
        # @!attribute [rw] upper_bound_days
        #   @return [Integer]
        #     Range of shift in days. Actual shift will be selected at random within this
        #     range (inclusive ends). Negative means shift to earlier in time. Must not
        #     be more than 365250 days (1000 years) each direction.
        #
        #     For example, 3 means shift date to at most 3 days into the future.
        #     [Required]
        # @!attribute [rw] lower_bound_days
        #   @return [Integer]
        #     For example, -5 means shift date to at most 5 days back in the past.
        #     [Required]
        # @!attribute [rw] context
        #   @return [Google::Privacy::Dlp::V2::FieldId]
        #     Points to the field that contains the context, for example, an entity id.
        #     If set, must also set method. If set, shift will be consistent for the
        #     given context.
        # @!attribute [rw] crypto_key
        #   @return [Google::Privacy::Dlp::V2::CryptoKey]
        #     Causes the shift to be computed based on this key and the context. This
        #     results in the same shift for the same context and crypto_key.
        class DateShiftConfig; end

        # A type of transformation that will scan unstructured text and
        # apply various +PrimitiveTransformation+s to each finding, where the
        # transformation is applied to only values that were identified as a specific
        # info_type.
        # @!attribute [rw] transformations
        #   @return [Array<Google::Privacy::Dlp::V2::InfoTypeTransformations::InfoTypeTransformation>]
        #     Transformation for each infoType. Cannot specify more than one
        #     for a given infoType. [required]
        class InfoTypeTransformations
          # A transformation to apply to text that is identified as a specific
          # info_type.
          # @!attribute [rw] info_types
          #   @return [Array<Google::Privacy::Dlp::V2::InfoType>]
          #     InfoTypes to apply the transformation to. An empty list will cause
          #     this transformation to apply to all findings that correspond to
          #     infoTypes that were requested in +InspectConfig+.
          # @!attribute [rw] primitive_transformation
          #   @return [Google::Privacy::Dlp::V2::PrimitiveTransformation]
          #     Primitive transformation to apply to the infoType. [required]
          class InfoTypeTransformation; end
        end

        # The transformation to apply to the field.
        # @!attribute [rw] fields
        #   @return [Array<Google::Privacy::Dlp::V2::FieldId>]
        #     Input field(s) to apply the transformation to. [required]
        # @!attribute [rw] condition
        #   @return [Google::Privacy::Dlp::V2::RecordCondition]
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
        #   @return [Google::Privacy::Dlp::V2::PrimitiveTransformation]
        #     Apply the transformation to the entire field.
        # @!attribute [rw] info_type_transformations
        #   @return [Google::Privacy::Dlp::V2::InfoTypeTransformations]
        #     Treat the contents of the field as free text, and selectively
        #     transform content that matches an +InfoType+.
        class FieldTransformation; end

        # A type of transformation that is applied over structured data such as a
        # table.
        # @!attribute [rw] field_transformations
        #   @return [Array<Google::Privacy::Dlp::V2::FieldTransformation>]
        #     Transform the record by applying various field transformations.
        # @!attribute [rw] record_suppressions
        #   @return [Array<Google::Privacy::Dlp::V2::RecordSuppression>]
        #     Configuration defining which records get suppressed entirely. Records that
        #     match any suppression rule are omitted from the output [optional].
        class RecordTransformations; end

        # Configuration to suppress records whose suppression conditions evaluate to
        # true.
        # @!attribute [rw] condition
        #   @return [Google::Privacy::Dlp::V2::RecordCondition]
        #     A condition that when it evaluates to true will result in the record being
        #     evaluated to be suppressed from the transformed content.
        class RecordSuppression; end

        # A condition for determining whether a transformation should be applied to
        # a field.
        # @!attribute [rw] expressions
        #   @return [Google::Privacy::Dlp::V2::RecordCondition::Expressions]
        #     An expression.
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
          #   @return [Google::Privacy::Dlp::V2::FieldId]
          #     Field within the record this condition is evaluated against. [required]
          # @!attribute [rw] operator
          #   @return [Google::Privacy::Dlp::V2::RelationalOperator]
          #     Operator used to compare the field or infoType to the value. [required]
          # @!attribute [rw] value
          #   @return [Google::Privacy::Dlp::V2::Value]
          #     Value to compare against. [Required, except for +EXISTS+ tests.]
          class Condition; end

          # A collection of conditions.
          # @!attribute [rw] conditions
          #   @return [Array<Google::Privacy::Dlp::V2::RecordCondition::Condition>]
          class Conditions; end

          # An expression, consisting or an operator and conditions.
          # @!attribute [rw] logical_operator
          #   @return [Google::Privacy::Dlp::V2::RecordCondition::Expressions::LogicalOperator]
          #     The operator to apply to the result of conditions. Default and currently
          #     only supported value is +AND+.
          # @!attribute [rw] conditions
          #   @return [Google::Privacy::Dlp::V2::RecordCondition::Conditions]
          class Expressions
            module LogicalOperator
              LOGICAL_OPERATOR_UNSPECIFIED = 0

              AND = 1
            end
          end
        end

        # Overview of the modifications that occurred.
        # @!attribute [rw] transformed_bytes
        #   @return [Integer]
        #     Total size in bytes that were transformed in some way.
        # @!attribute [rw] transformation_summaries
        #   @return [Array<Google::Privacy::Dlp::V2::TransformationSummary>]
        #     Transformations applied to the dataset.
        class TransformationOverview; end

        # Summary of a single tranformation.
        # Only one of 'transformation', 'field_transformation', or 'record_suppress'
        # will be set.
        # @!attribute [rw] info_type
        #   @return [Google::Privacy::Dlp::V2::InfoType]
        #     Set if the transformation was limited to a specific info_type.
        # @!attribute [rw] field
        #   @return [Google::Privacy::Dlp::V2::FieldId]
        #     Set if the transformation was limited to a specific FieldId.
        # @!attribute [rw] transformation
        #   @return [Google::Privacy::Dlp::V2::PrimitiveTransformation]
        #     The specific transformation these stats apply to.
        # @!attribute [rw] field_transformations
        #   @return [Array<Google::Privacy::Dlp::V2::FieldTransformation>]
        #     The field transformation that was applied.
        #     If multiple field transformations are requested for a single field,
        #     this list will contain all of them; otherwise, only one is supplied.
        # @!attribute [rw] record_suppress
        #   @return [Google::Privacy::Dlp::V2::RecordSuppression]
        #     The specific suppression option these stats apply to.
        # @!attribute [rw] results
        #   @return [Array<Google::Privacy::Dlp::V2::TransformationSummary::SummaryResult>]
        # @!attribute [rw] transformed_bytes
        #   @return [Integer]
        #     Total size in bytes that were transformed in some way.
        class TransformationSummary
          # A collection that informs the user the number of times a particular
          # +TransformationResultCode+ and error details occurred.
          # @!attribute [rw] count
          #   @return [Integer]
          # @!attribute [rw] code
          #   @return [Google::Privacy::Dlp::V2::TransformationSummary::TransformationResultCode]
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

        # Schedule for triggeredJobs.
        # @!attribute [rw] recurrence_period_duration
        #   @return [Google::Protobuf::Duration]
        #     With this option a job is started a regular periodic basis. For
        #     example: every day (86400 seconds).
        #
        #     A scheduled start time will be skipped if the previous
        #     execution has not ended when its scheduled time occurs.
        #
        #     This value must be set to a time duration greater than or equal
        #     to 1 day and can be no longer than 60 days.
        class Schedule; end

        # The inspectTemplate contains a configuration (set of types of sensitive data
        # to be detected) to be used anywhere you otherwise would normally specify
        # InspectConfig. See https://cloud.google.com/dlp/docs/concepts-templates
        # to learn more.
        # @!attribute [rw] name
        #   @return [String]
        #     The template name. Output only.
        #
        #     The template will have one of the following formats:
        #     +projects/PROJECT_ID/inspectTemplates/TEMPLATE_ID+ OR
        #     +organizations/ORGANIZATION_ID/inspectTemplates/TEMPLATE_ID+
        # @!attribute [rw] display_name
        #   @return [String]
        #     Display name (max 256 chars).
        # @!attribute [rw] description
        #   @return [String]
        #     Short description (max 256 chars).
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     The creation timestamp of a inspectTemplate, output only field.
        # @!attribute [rw] update_time
        #   @return [Google::Protobuf::Timestamp]
        #     The last update timestamp of a inspectTemplate, output only field.
        # @!attribute [rw] inspect_config
        #   @return [Google::Privacy::Dlp::V2::InspectConfig]
        #     The core content of the template. Configuration of the scanning process.
        class InspectTemplate; end

        # The DeidentifyTemplates contains instructions on how to deidentify content.
        # See https://cloud.google.com/dlp/docs/concepts-templates to learn more.
        # @!attribute [rw] name
        #   @return [String]
        #     The template name. Output only.
        #
        #     The template will have one of the following formats:
        #     +projects/PROJECT_ID/deidentifyTemplates/TEMPLATE_ID+ OR
        #     +organizations/ORGANIZATION_ID/deidentifyTemplates/TEMPLATE_ID+
        # @!attribute [rw] display_name
        #   @return [String]
        #     Display name (max 256 chars).
        # @!attribute [rw] description
        #   @return [String]
        #     Short description (max 256 chars).
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     The creation timestamp of a inspectTemplate, output only field.
        # @!attribute [rw] update_time
        #   @return [Google::Protobuf::Timestamp]
        #     The last update timestamp of a inspectTemplate, output only field.
        # @!attribute [rw] deidentify_config
        #   @return [Google::Privacy::Dlp::V2::DeidentifyConfig]
        #     ///////////// // The core content of the template  // ///////////////
        class DeidentifyTemplate; end

        # Details information about an error encountered during job execution or
        # the results of an unsuccessful activation of the JobTrigger.
        # Output only field.
        # @!attribute [rw] details
        #   @return [Google::Rpc::Status]
        # @!attribute [rw] timestamps
        #   @return [Array<Google::Protobuf::Timestamp>]
        #     The times the error occurred.
        class Error; end

        # Contains a configuration to make dlp api calls on a repeating basis.
        # See https://cloud.google.com/dlp/docs/concepts-job-triggers to learn more.
        # @!attribute [rw] name
        #   @return [String]
        #     Unique resource name for the triggeredJob, assigned by the service when the
        #     triggeredJob is created, for example
        #     +projects/dlp-test-project/triggeredJobs/53234423+.
        # @!attribute [rw] display_name
        #   @return [String]
        #     Display name (max 100 chars)
        # @!attribute [rw] description
        #   @return [String]
        #     User provided description (max 256 chars)
        # @!attribute [rw] inspect_job
        #   @return [Google::Privacy::Dlp::V2::InspectJobConfig]
        # @!attribute [rw] triggers
        #   @return [Array<Google::Privacy::Dlp::V2::JobTrigger::Trigger>]
        #     A list of triggers which will be OR'ed together. Only one in the list
        #     needs to trigger for a job to be started. The list may contain only
        #     a single Schedule trigger and must have at least one object.
        # @!attribute [rw] errors
        #   @return [Array<Google::Privacy::Dlp::V2::Error>]
        #     A stream of errors encountered when the trigger was activated. Repeated
        #     errors may result in the JobTrigger automaticaly being paused.
        #     Will return the last 100 errors. Whenever the JobTrigger is modified
        #     this list will be cleared. Output only field.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     The creation timestamp of a triggeredJob, output only field.
        # @!attribute [rw] update_time
        #   @return [Google::Protobuf::Timestamp]
        #     The last update timestamp of a triggeredJob, output only field.
        # @!attribute [rw] last_run_time
        #   @return [Google::Protobuf::Timestamp]
        #     The timestamp of the last time this trigger executed, output only field.
        # @!attribute [rw] status
        #   @return [Google::Privacy::Dlp::V2::JobTrigger::Status]
        #     A status for this trigger. [required]
        class JobTrigger
          # What event needs to occur for a new job to be started.
          # @!attribute [rw] schedule
          #   @return [Google::Privacy::Dlp::V2::Schedule]
          #     Create a job on a repeating basis based on the elapse of time.
          class Trigger; end

          # Whether the trigger is currently active. If PAUSED or CANCELLED, no jobs
          # will be created with this configuration. The service may automatically
          # pause triggers experiencing frequent errors. To restart a job, set the
          # status to HEALTHY after correcting user errors.
          module Status
            STATUS_UNSPECIFIED = 0

            # Trigger is healthy.
            HEALTHY = 1

            # Trigger is temporarily paused.
            PAUSED = 2

            # Trigger is cancelled and can not be resumed.
            CANCELLED = 3
          end
        end

        # A task to execute on the completion of a job.
        # See https://cloud.google.com/dlp/docs/concepts-actions to learn more.
        # @!attribute [rw] save_findings
        #   @return [Google::Privacy::Dlp::V2::Action::SaveFindings]
        #     Save resulting findings in a provided location.
        # @!attribute [rw] pub_sub
        #   @return [Google::Privacy::Dlp::V2::Action::PublishToPubSub]
        #     Publish a notification to a pubsub topic.
        # @!attribute [rw] publish_summary_to_cscc
        #   @return [Google::Privacy::Dlp::V2::Action::PublishSummaryToCscc]
        #     Publish summary to Cloud Security Command Center (Alpha).
        class Action
          # If set, the detailed findings will be persisted to the specified
          # OutputStorageConfig. Only a single instance of this action can be
          # specified.
          # Compatible with: Inspect, Risk
          # @!attribute [rw] output_config
          #   @return [Google::Privacy::Dlp::V2::OutputStorageConfig]
          class SaveFindings; end

          # Publish the results of a DlpJob to a pub sub channel.
          # Compatible with: Inspect, Risk
          # @!attribute [rw] topic
          #   @return [String]
          #     Cloud Pub/Sub topic to send notifications to. The topic must have given
          #     publishing access rights to the DLP API service account executing
          #     the long running DlpJob sending the notifications.
          #     Format is projects/{project}/topics/{topic}.
          class PublishToPubSub; end

          # Publish the result summary of a DlpJob to the Cloud Security
          # Command Center (CSCC Alpha).
          # This action is only available for projects which are parts of
          # an organization and whitelisted for the alpha Cloud Security Command
          # Center.
          # The action will publish count of finding instances and their info types.
          # The summary of findings will be persisted in CSCC and are governed by CSCC
          # service-specific policy, see https://cloud.google.com/terms/service-terms
          # Only a single instance of this action can be specified.
          # Compatible with: Inspect
          class PublishSummaryToCscc; end
        end

        # Request message for CreateInspectTemplate.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name, for example projects/my-project-id or
        #     organizations/my-org-id.
        # @!attribute [rw] inspect_template
        #   @return [Google::Privacy::Dlp::V2::InspectTemplate]
        #     The InspectTemplate to create.
        # @!attribute [rw] template_id
        #   @return [String]
        #     The template id can contain uppercase and lowercase letters,
        #     numbers, and hyphens; that is, it must match the regular
        #     expression: +[a-zA-Z\\d-]++. The maximum length is 100
        #     characters. Can be empty to allow the system to generate one.
        class CreateInspectTemplateRequest; end

        # Request message for UpdateInspectTemplate.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of organization and inspectTemplate to be updated, for
        #     example +organizations/433245324/inspectTemplates/432452342+ or
        #     projects/project-id/inspectTemplates/432452342.
        # @!attribute [rw] inspect_template
        #   @return [Google::Privacy::Dlp::V2::InspectTemplate]
        #     New InspectTemplate value.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Mask to control which fields get updated.
        class UpdateInspectTemplateRequest; end

        # Request message for GetInspectTemplate.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the organization and inspectTemplate to be read, for
        #     example +organizations/433245324/inspectTemplates/432452342+ or
        #     projects/project-id/inspectTemplates/432452342.
        class GetInspectTemplateRequest; end

        # Request message for ListInspectTemplates.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name, for example projects/my-project-id or
        #     organizations/my-org-id.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional page token to continue retrieval. Comes from previous call
        #     to +ListInspectTemplates+.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional size of the page, can be limited by server. If zero server returns
        #     a page of max size 100.
        class ListInspectTemplatesRequest; end

        # Response message for ListInspectTemplates.
        # @!attribute [rw] inspect_templates
        #   @return [Array<Google::Privacy::Dlp::V2::InspectTemplate>]
        #     List of inspectTemplates, up to page_size in ListInspectTemplatesRequest.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     If the next page is available then the next page token to be used
        #     in following ListInspectTemplates request.
        class ListInspectTemplatesResponse; end

        # Request message for DeleteInspectTemplate.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the organization and inspectTemplate to be deleted, for
        #     example +organizations/433245324/inspectTemplates/432452342+ or
        #     projects/project-id/inspectTemplates/432452342.
        class DeleteInspectTemplateRequest; end

        # Request message for CreateJobTrigger.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name, for example projects/my-project-id.
        # @!attribute [rw] job_trigger
        #   @return [Google::Privacy::Dlp::V2::JobTrigger]
        #     The JobTrigger to create.
        # @!attribute [rw] trigger_id
        #   @return [String]
        #     The trigger id can contain uppercase and lowercase letters,
        #     numbers, and hyphens; that is, it must match the regular
        #     expression: +[a-zA-Z\\d-]++. The maximum length is 100
        #     characters. Can be empty to allow the system to generate one.
        class CreateJobTriggerRequest; end

        # Request message for UpdateJobTrigger.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the project and the triggeredJob, for example
        #     +projects/dlp-test-project/jobTriggers/53234423+.
        # @!attribute [rw] job_trigger
        #   @return [Google::Privacy::Dlp::V2::JobTrigger]
        #     New JobTrigger value.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Mask to control which fields get updated.
        class UpdateJobTriggerRequest; end

        # Request message for GetJobTrigger.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the project and the triggeredJob, for example
        #     +projects/dlp-test-project/jobTriggers/53234423+.
        class GetJobTriggerRequest; end

        # Request message for CreateDlpJobRequest. Used to initiate long running
        # jobs such as calculating risk metrics or inspecting Google Cloud
        # Storage.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name, for example projects/my-project-id.
        # @!attribute [rw] inspect_job
        #   @return [Google::Privacy::Dlp::V2::InspectJobConfig]
        # @!attribute [rw] risk_job
        #   @return [Google::Privacy::Dlp::V2::RiskAnalysisJobConfig]
        # @!attribute [rw] job_id
        #   @return [String]
        #     The job id can contain uppercase and lowercase letters,
        #     numbers, and hyphens; that is, it must match the regular
        #     expression: +[a-zA-Z\\d-]++. The maximum length is 100
        #     characters. Can be empty to allow the system to generate one.
        class CreateDlpJobRequest; end

        # Request message for ListJobTriggers.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name, for example +projects/my-project-id+.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional page token to continue retrieval. Comes from previous call
        #     to ListJobTriggers. +order_by+ field must not
        #     change for subsequent calls.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional size of the page, can be limited by a server.
        # @!attribute [rw] order_by
        #   @return [String]
        #     Optional comma separated list of triggeredJob fields to order by,
        #     followed by +asc+ or +desc+ postfix. This list is case-insensitive,
        #     default sorting order is ascending, redundant space characters are
        #     insignificant.
        #
        #     Example: +name asc,update_time, create_time desc+
        #
        #     Supported fields are:
        #
        #     * +create_time+: corresponds to time the triggeredJob was created.
        #     * +update_time+: corresponds to time the triggeredJob was last updated.
        #     * +name+: corresponds to JobTrigger's name.
        class ListJobTriggersRequest; end

        # Response message for ListJobTriggers.
        # @!attribute [rw] job_triggers
        #   @return [Array<Google::Privacy::Dlp::V2::JobTrigger>]
        #     List of triggeredJobs, up to page_size in ListJobTriggersRequest.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     If the next page is available then the next page token to be used
        #     in following ListJobTriggers request.
        class ListJobTriggersResponse; end

        # Request message for DeleteJobTrigger.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the project and the triggeredJob, for example
        #     +projects/dlp-test-project/jobTriggers/53234423+.
        class DeleteJobTriggerRequest; end

        # @!attribute [rw] storage_config
        #   @return [Google::Privacy::Dlp::V2::StorageConfig]
        #     The data to scan.
        # @!attribute [rw] inspect_config
        #   @return [Google::Privacy::Dlp::V2::InspectConfig]
        #     How and what to scan for.
        # @!attribute [rw] inspect_template_name
        #   @return [String]
        #     If provided, will be used as the default for all values in InspectConfig.
        #     +inspect_config+ will be merged into the values persisted as part of the
        #     template.
        # @!attribute [rw] actions
        #   @return [Array<Google::Privacy::Dlp::V2::Action>]
        #     Actions to execute at the completion of the job. Are executed in the order
        #     provided.
        class InspectJobConfig; end

        # Combines all of the information about a DLP job.
        # @!attribute [rw] name
        #   @return [String]
        #     The server-assigned name.
        # @!attribute [rw] type
        #   @return [Google::Privacy::Dlp::V2::DlpJobType]
        #     The type of job.
        # @!attribute [rw] state
        #   @return [Google::Privacy::Dlp::V2::DlpJob::JobState]
        #     State of a job.
        # @!attribute [rw] risk_details
        #   @return [Google::Privacy::Dlp::V2::AnalyzeDataSourceRiskDetails]
        #     Results from analyzing risk of a data source.
        # @!attribute [rw] inspect_details
        #   @return [Google::Privacy::Dlp::V2::InspectDataSourceDetails]
        #     Results from inspecting a data source.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     Time when the job was created.
        # @!attribute [rw] start_time
        #   @return [Google::Protobuf::Timestamp]
        #     Time when the job started.
        # @!attribute [rw] end_time
        #   @return [Google::Protobuf::Timestamp]
        #     Time when the job finished.
        # @!attribute [rw] job_trigger_name
        #   @return [String]
        #     If created by a job trigger, the resource name of the trigger that
        #     instantiated the job.
        # @!attribute [rw] errors
        #   @return [Array<Google::Privacy::Dlp::V2::Error>]
        #     A stream of errors encountered running the job.
        class DlpJob
          module JobState
            JOB_STATE_UNSPECIFIED = 0

            # The job has not yet started.
            PENDING = 1

            # The job is currently running.
            RUNNING = 2

            # The job is no longer running.
            DONE = 3

            # The job was canceled before it could complete.
            CANCELED = 4

            # The job had an error and did not complete.
            FAILED = 5
          end
        end

        # The request message for {DlpJobs::GetDlpJob}.
        # @!attribute [rw] name
        #   @return [String]
        #     The name of the DlpJob resource.
        class GetDlpJobRequest; end

        # The request message for listing DLP jobs.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name, for example projects/my-project-id.
        # @!attribute [rw] filter
        #   @return [String]
        #     Optional. Allows filtering.
        #
        #     Supported syntax:
        #
        #     * Filter expressions are made up of one or more restrictions.
        #     * Restrictions can be combined by +AND+ or +OR+ logical operators. A
        #       sequence of restrictions implicitly uses +AND+.
        #     * A restriction has the form of +<field> <operator> <value>+.
        #     * Supported fields/values for inspect jobs:
        #       * +state+ - PENDING|RUNNING|CANCELED|FINISHED|FAILED
        #         * +inspected_storage+ - DATASTORE|CLOUD_STORAGE|BIGQUERY
        #         * +trigger_name+ - The resource name of the trigger that created job.
        #       * Supported fields for risk analysis jobs:
        #         * +state+ - RUNNING|CANCELED|FINISHED|FAILED
        #       * The operator must be +=+ or +!=+.
        #
        #       Examples:
        #
        #     * inspected_storage = cloud_storage AND state = done
        #     * inspected_storage = cloud_storage OR inspected_storage = bigquery
        #     * inspected_storage = cloud_storage AND (state = done OR state = canceled)
        #
        #     The length of this field should be no more than 500 characters.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     The standard list page size.
        # @!attribute [rw] page_token
        #   @return [String]
        #     The standard list page token.
        # @!attribute [rw] type
        #   @return [Google::Privacy::Dlp::V2::DlpJobType]
        #     The type of job. Defaults to +DlpJobType.INSPECT+
        class ListDlpJobsRequest; end

        # The response message for listing DLP jobs.
        # @!attribute [rw] jobs
        #   @return [Array<Google::Privacy::Dlp::V2::DlpJob>]
        #     A list of DlpJobs that matches the specified filter in the request.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     The standard List next-page token.
        class ListDlpJobsResponse; end

        # The request message for canceling a DLP job.
        # @!attribute [rw] name
        #   @return [String]
        #     The name of the DlpJob resource to be cancelled.
        class CancelDlpJobRequest; end

        # The request message for deleting a DLP job.
        # @!attribute [rw] name
        #   @return [String]
        #     The name of the DlpJob resource to be deleted.
        class DeleteDlpJobRequest; end

        # Request message for CreateDeidentifyTemplate.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name, for example projects/my-project-id or
        #     organizations/my-org-id.
        # @!attribute [rw] deidentify_template
        #   @return [Google::Privacy::Dlp::V2::DeidentifyTemplate]
        #     The DeidentifyTemplate to create.
        # @!attribute [rw] template_id
        #   @return [String]
        #     The template id can contain uppercase and lowercase letters,
        #     numbers, and hyphens; that is, it must match the regular
        #     expression: +[a-zA-Z\\d-]++. The maximum length is 100
        #     characters. Can be empty to allow the system to generate one.
        class CreateDeidentifyTemplateRequest; end

        # Request message for UpdateDeidentifyTemplate.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of organization and deidentify template to be updated, for
        #     example +organizations/433245324/deidentifyTemplates/432452342+ or
        #     projects/project-id/deidentifyTemplates/432452342.
        # @!attribute [rw] deidentify_template
        #   @return [Google::Privacy::Dlp::V2::DeidentifyTemplate]
        #     New DeidentifyTemplate value.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Mask to control which fields get updated.
        class UpdateDeidentifyTemplateRequest; end

        # Request message for GetDeidentifyTemplate.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the organization and deidentify template to be read, for
        #     example +organizations/433245324/deidentifyTemplates/432452342+ or
        #     projects/project-id/deidentifyTemplates/432452342.
        class GetDeidentifyTemplateRequest; end

        # Request message for ListDeidentifyTemplates.
        # @!attribute [rw] parent
        #   @return [String]
        #     The parent resource name, for example projects/my-project-id or
        #     organizations/my-org-id.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional page token to continue retrieval. Comes from previous call
        #     to +ListDeidentifyTemplates+.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional size of the page, can be limited by server. If zero server returns
        #     a page of max size 100.
        class ListDeidentifyTemplatesRequest; end

        # Response message for ListDeidentifyTemplates.
        # @!attribute [rw] deidentify_templates
        #   @return [Array<Google::Privacy::Dlp::V2::DeidentifyTemplate>]
        #     List of deidentify templates, up to page_size in
        #     ListDeidentifyTemplatesRequest.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     If the next page is available then the next page token to be used
        #     in following ListDeidentifyTemplates request.
        class ListDeidentifyTemplatesResponse; end

        # Request message for DeleteDeidentifyTemplate.
        # @!attribute [rw] name
        #   @return [String]
        #     Resource name of the organization and deidentify template to be deleted,
        #     for example +organizations/433245324/deidentifyTemplates/432452342+ or
        #     projects/project-id/deidentifyTemplates/432452342.
        class DeleteDeidentifyTemplateRequest; end

        # Options describing which parts of the provided content should be scanned.
        module ContentOption
          # Includes entire content of a file or a data stream.
          CONTENT_UNSPECIFIED = 0

          # Text content within the data, excluding any metadata.
          CONTENT_TEXT = 1

          # Images found in the data.
          CONTENT_IMAGE = 2
        end

        # Parts of the APIs which use certain infoTypes.
        module InfoTypeSupportedBy
          ENUM_TYPE_UNSPECIFIED = 0

          # Supported by the inspect operations.
          INSPECT = 1

          # Supported by the risk analysis operations.
          RISK_ANALYSIS = 2
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

        # An enum to represent the various type of DLP jobs.
        module DlpJobType
          DLP_JOB_TYPE_UNSPECIFIED = 0

          # The job inspected Google Cloud for sensitive data.
          INSPECT_JOB = 1

          # The job executed a Risk Analysis computation.
          RISK_ANALYSIS_JOB = 2
        end
      end
    end
  end
end