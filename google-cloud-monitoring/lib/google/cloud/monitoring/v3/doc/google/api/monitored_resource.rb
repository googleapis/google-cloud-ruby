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
  module Api
    # An object that describes the schema of a {Google::Api::MonitoredResource MonitoredResource} object using a
    # type name and a set of labels.  For example, the monitored resource
    # descriptor for Google Compute Engine VM instances has a type of
    # `"gce_instance"` and specifies the use of the labels `"instance_id"` and
    # `"zone"` to identify particular VM instances.
    #
    # Different APIs can support different monitored resource types. APIs generally
    # provide a `list` method that returns the monitored resource descriptors used
    # by the API.
    # @!attribute [rw] name
    #   @return [String]
    #     Optional. The resource name of the monitored resource descriptor:
    #     `"projects/{project_id}/monitoredResourceDescriptors/{type}"` where
    #     \\{type} is the value of the `type` field in this object and
    #     \\{project_id} is a project ID that provides API-specific context for
    #     accessing the type.  APIs that do not use project information can use the
    #     resource name format `"monitoredResourceDescriptors/{type}"`.
    # @!attribute [rw] type
    #   @return [String]
    #     Required. The monitored resource type. For example, the type
    #     `"cloudsql_database"` represents databases in Google Cloud SQL.
    #     The maximum length of this value is 256 characters.
    # @!attribute [rw] display_name
    #   @return [String]
    #     Optional. A concise name for the monitored resource type that might be
    #     displayed in user interfaces. It should be a Title Cased Noun Phrase,
    #     without any article or other determiners. For example,
    #     `"Google Cloud SQL Database"`.
    # @!attribute [rw] description
    #   @return [String]
    #     Optional. A detailed description of the monitored resource type that might
    #     be used in documentation.
    # @!attribute [rw] labels
    #   @return [Array<Google::Api::LabelDescriptor>]
    #     Required. A set of labels used to describe instances of this monitored
    #     resource type. For example, an individual Google Cloud SQL database is
    #     identified by values for the labels `"database_id"` and `"zone"`.
    class MonitoredResourceDescriptor; end

    # An object representing a resource that can be used for monitoring, logging,
    # billing, or other purposes. Examples include virtual machine instances,
    # databases, and storage devices such as disks. The `type` field identifies a
    # {Google::Api::MonitoredResourceDescriptor MonitoredResourceDescriptor} object that describes the resource's
    # schema. Information in the `labels` field identifies the actual resource and
    # its attributes according to the schema. For example, a particular Compute
    # Engine VM instance could be represented by the following object, because the
    # {Google::Api::MonitoredResourceDescriptor MonitoredResourceDescriptor} for `"gce_instance"` has labels
    # `"instance_id"` and `"zone"`:
    #
    #     { "type": "gce_instance",
    #       "labels": { "instance_id": "12345678901234",
    #                   "zone": "us-central1-a" }}
    # @!attribute [rw] type
    #   @return [String]
    #     Required. The monitored resource type. This field must match
    #     the `type` field of a {Google::Api::MonitoredResourceDescriptor MonitoredResourceDescriptor} object. For
    #     example, the type of a Compute Engine VM instance is `gce_instance`.
    # @!attribute [rw] labels
    #   @return [Hash{String => String}]
    #     Required. Values for all of the labels listed in the associated monitored
    #     resource descriptor. For example, Compute Engine VM instances use the
    #     labels `"project_id"`, `"instance_id"`, and `"zone"`.
    class MonitoredResource; end

    # Auxiliary metadata for a {Google::Api::MonitoredResource MonitoredResource} object.
    # {Google::Api::MonitoredResource MonitoredResource} objects contain the minimum set of information to
    # uniquely identify a monitored resource instance. There is some other useful
    # auxiliary metadata. Google Stackdriver Monitoring & Logging uses an ingestion
    # pipeline to extract metadata for cloud resources of all types , and stores
    # the metadata in this message.
    # @!attribute [rw] system_labels
    #   @return [Google::Protobuf::Struct]
    #     Output only. Values for predefined system metadata labels.
    #     System labels are a kind of metadata extracted by Google Stackdriver.
    #     Stackdriver determines what system labels are useful and how to obtain
    #     their values. Some examples: "machine_image", "vpc", "subnet_id",
    #     "security_group", "name", etc.
    #     System label values can be only strings, Boolean values, or a list of
    #     strings. For example:
    #
    #         { "name": "my-test-instance",
    #           "security_group": ["a", "b", "c"],
    #           "spot_instance": false }
    # @!attribute [rw] user_labels
    #   @return [Hash{String => String}]
    #     Output only. A map of user-defined metadata labels.
    class MonitoredResourceMetadata; end
  end
end