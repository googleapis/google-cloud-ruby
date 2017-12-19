# Copyright 2017, Google LLC All rights reserved.
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
        # Type of information detected by the API.
        # @!attribute [rw] name
        #   @return [String]
        #     Name of the information type.
        class InfoType; end

        # Custom information type provided by the user. Used to find domain-specific
        # sensitive information configurable to the data in question.
        # @!attribute [rw] info_type
        #   @return [Google::Privacy::Dlp::V2beta1::InfoType]
        #     Info type configuration. All custom info types must have configurations
        #     that do not conflict with built-in info types or other custom info types.
        # @!attribute [rw] dictionary
        #   @return [Google::Privacy::Dlp::V2beta1::CustomInfoType::Dictionary]
        #     Dictionary-based custom info type.
        class CustomInfoType
          # Custom information type based on a dictionary of words or phrases. This can
          # be used to match sensitive information specific to the data, such as a list
          # of employee IDs or job titles.
          #
          # Dictionary words are case-insensitive and all characters other than letters
          # and digits in the unicode [Basic Multilingual
          # Plane](https://en.wikipedia.org/wiki/Plane_%28Unicode%29#Basic_Multilingual_Plane)
          # will be replaced with whitespace when scanning for matches, so the
          # dictionary phrase "Sam Johnson" will match all three phrases "sam johnson",
          # "Sam, Johnson", and "Sam (Johnson)". Additionally, the characters
          # surrounding any match must be of a different type than the adjacent
          # characters within the word, so letters must be next to non-letters and
          # digits next to non-digits. For example, the dictionary word "jen" will
          # match the first three letters of the text "jen123" but will return no
          # matches for "jennifer".
          #
          # Dictionary words containing a large number of characters that are not
          # letters or digits may result in unexpected findings because such characters
          # are treated as whitespace.
          # @!attribute [rw] word_list
          #   @return [Google::Privacy::Dlp::V2beta1::CustomInfoType::Dictionary::WordList]
          #     List of words or phrases to search for.
          class Dictionary
            # Message defining a list of words or phrases to search for in the data.
            # @!attribute [rw] words
            #   @return [Array<String>]
            #     Words or phrases defining the dictionary. The dictionary must contain
            #     at least one phrase and every phrase must contain at least 2 characters
            #     that are letters or digits. [required]
            class WordList; end
          end
        end

        # General identifier of a data field in a storage service.
        # @!attribute [rw] column_name
        #   @return [String]
        #     Name describing the field.
        class FieldId; end

        # Datastore partition ID.
        # A partition ID identifies a grouping of entities. The grouping is always
        # by project and namespace, however the namespace ID may be empty.
        #
        # A partition ID contains several dimensions:
        # project ID and namespace ID.
        # @!attribute [rw] project_id
        #   @return [String]
        #     The ID of the project to which the entities belong.
        # @!attribute [rw] namespace_id
        #   @return [String]
        #     If not empty, the ID of the namespace to which the entities belong.
        class PartitionId; end

        # A representation of a Datastore kind.
        # @!attribute [rw] name
        #   @return [String]
        #     The name of the kind.
        class KindExpression; end

        # A reference to a property relative to the Datastore kind expressions.
        # @!attribute [rw] name
        #   @return [String]
        #     The name of the property.
        #     If name includes "."s, it may be interpreted as a property name path.
        class PropertyReference; end

        # A representation of a Datastore property in a projection.
        # @!attribute [rw] property
        #   @return [Google::Privacy::Dlp::V2beta1::PropertyReference]
        #     The property to project.
        class Projection; end

        # Options defining a data set within Google Cloud Datastore.
        # @!attribute [rw] partition_id
        #   @return [Google::Privacy::Dlp::V2beta1::PartitionId]
        #     A partition ID identifies a grouping of entities. The grouping is always
        #     by project and namespace, however the namespace ID may be empty.
        # @!attribute [rw] kind
        #   @return [Google::Privacy::Dlp::V2beta1::KindExpression]
        #     The kind to process.
        # @!attribute [rw] projection
        #   @return [Array<Google::Privacy::Dlp::V2beta1::Projection>]
        #     Properties to scan. If none are specified, all properties will be scanned
        #     by default.
        class DatastoreOptions; end

        # Options defining a file or a set of files (path ending with *) within
        # a Google Cloud Storage bucket.
        # @!attribute [rw] file_set
        #   @return [Google::Privacy::Dlp::V2beta1::CloudStorageOptions::FileSet]
        class CloudStorageOptions
          # Set of files to scan.
          # @!attribute [rw] url
          #   @return [String]
          #     The url, in the format +gs://<bucket>/<path>+. Trailing wildcard in the
          #     path is allowed.
          class FileSet; end
        end

        # A location in Cloud Storage.
        # @!attribute [rw] path
        #   @return [String]
        #     The url, in the format of +gs://bucket/<path>+.
        class CloudStoragePath; end

        # Options defining BigQuery table and row identifiers.
        # @!attribute [rw] table_reference
        #   @return [Google::Privacy::Dlp::V2beta1::BigQueryTable]
        #     Complete BigQuery table reference.
        # @!attribute [rw] identifying_fields
        #   @return [Array<Google::Privacy::Dlp::V2beta1::FieldId>]
        #     References to fields uniquely identifying rows within the table.
        #     Nested fields in the format, like +person.birthdate.year+, are allowed.
        class BigQueryOptions; end

        # Shared message indicating Cloud storage type.
        # @!attribute [rw] datastore_options
        #   @return [Google::Privacy::Dlp::V2beta1::DatastoreOptions]
        #     Google Cloud Datastore options specification.
        # @!attribute [rw] cloud_storage_options
        #   @return [Google::Privacy::Dlp::V2beta1::CloudStorageOptions]
        #     Google Cloud Storage options specification.
        # @!attribute [rw] big_query_options
        #   @return [Google::Privacy::Dlp::V2beta1::BigQueryOptions]
        #     BigQuery options specification.
        class StorageConfig; end

        # Record key for a finding in a Cloud Storage file.
        # @!attribute [rw] file_path
        #   @return [String]
        #     Path to the file.
        # @!attribute [rw] start_offset
        #   @return [Integer]
        #     Byte offset of the referenced data in the file.
        class CloudStorageKey; end

        # Record key for a finding in Cloud Datastore.
        # @!attribute [rw] entity_key
        #   @return [Google::Privacy::Dlp::V2beta1::Key]
        #     Datastore entity key.
        class DatastoreKey; end

        # A unique identifier for a Datastore entity.
        # If a key's partition ID or any of its path kinds or names are
        # reserved/read-only, the key is reserved/read-only.
        # A reserved/read-only key is forbidden in certain documented contexts.
        # @!attribute [rw] partition_id
        #   @return [Google::Privacy::Dlp::V2beta1::PartitionId]
        #     Entities are partitioned into subsets, currently identified by a project
        #     ID and namespace ID.
        #     Queries are scoped to a single partition.
        # @!attribute [rw] path
        #   @return [Array<Google::Privacy::Dlp::V2beta1::Key::PathElement>]
        #     The entity path.
        #     An entity path consists of one or more elements composed of a kind and a
        #     string or numerical identifier, which identify entities. The first
        #     element identifies a _root entity_, the second element identifies
        #     a _child_ of the root entity, the third element identifies a child of the
        #     second entity, and so forth. The entities identified by all prefixes of
        #     the path are called the element's _ancestors_.
        #
        #     A path can never be empty, and a path can have at most 100 elements.
        class Key
          # A (kind, ID/name) pair used to construct a key path.
          #
          # If either name or ID is set, the element is complete.
          # If neither is set, the element is incomplete.
          # @!attribute [rw] kind
          #   @return [String]
          #     The kind of the entity.
          #     A kind matching regex +__.*__+ is reserved/read-only.
          #     A kind must not contain more than 1500 bytes when UTF-8 encoded.
          #     Cannot be +""+.
          # @!attribute [rw] id
          #   @return [Integer]
          #     The auto-allocated ID of the entity.
          #     Never equal to zero. Values less than zero are discouraged and may not
          #     be supported in the future.
          # @!attribute [rw] name
          #   @return [String]
          #     The name of the entity.
          #     A name matching regex +__.*__+ is reserved/read-only.
          #     A name must not be more than 1500 bytes when UTF-8 encoded.
          #     Cannot be +""+.
          class PathElement; end
        end

        # Message for a unique key indicating a record that contains a finding.
        # @!attribute [rw] cloud_storage_key
        #   @return [Google::Privacy::Dlp::V2beta1::CloudStorageKey]
        # @!attribute [rw] datastore_key
        #   @return [Google::Privacy::Dlp::V2beta1::DatastoreKey]
        class RecordKey; end

        # Message defining the location of a BigQuery table. A table is uniquely
        # identified  by its project_id, dataset_id, and table_name. Within a query
        # a table is often referenced with a string in the format of:
        # +<project_id>:<dataset_id>.<table_id>+ or
        # +<project_id>.<dataset_id>.<table_id>+.
        # @!attribute [rw] project_id
        #   @return [String]
        #     The Google Cloud Platform project ID of the project containing the table.
        #     If omitted, project ID is inferred from the API call.
        # @!attribute [rw] dataset_id
        #   @return [String]
        #     Dataset ID of the table.
        # @!attribute [rw] table_id
        #   @return [String]
        #     Name of the table.
        class BigQueryTable; end

        # An entity in a dataset is a field or set of fields that correspond to a
        # single person. For example, in medical records the +EntityId+ might be
        # a patient identifier, or for financial records it might be an account
        # identifier. This message is used when generalizations or analysis must be
        # consistent across multiple rows pertaining to the same entity.
        # @!attribute [rw] field
        #   @return [Google::Privacy::Dlp::V2beta1::FieldId]
        #     Composite key indicating which field contains the entity identifier.
        class EntityId; end
      end
    end
  end
end