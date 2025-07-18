# frozen_string_literal: true

# Copyright 2025 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!


module Google
  module Cloud
    module NetworkServices
      module V1
        # `WasmPlugin` is a resource representing a service executing
        # a customer-provided Wasm module.
        # @!attribute [rw] name
        #   @return [::String]
        #     Identifier. Name of the `WasmPlugin` resource in the following format:
        #     `projects/{project}/locations/{location}/wasmPlugins/{wasm_plugin}`.
        # @!attribute [r] create_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The timestamp when the resource was created.
        # @!attribute [r] update_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The timestamp when the resource was updated.
        # @!attribute [rw] description
        #   @return [::String]
        #     Optional. A human-readable description of the resource.
        # @!attribute [rw] labels
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Optional. Set of labels associated with the `WasmPlugin` resource.
        #
        #     The format must comply with [the following
        #     requirements](/compute/docs/labeling-resources#requirements).
        # @!attribute [rw] main_version_id
        #   @return [::String]
        #     Optional. The ID of the `WasmPluginVersion` resource that is the
        #     currently serving one. The version referred to must be a child of this
        #     `WasmPlugin` resource.
        # @!attribute [rw] log_config
        #   @return [::Google::Cloud::NetworkServices::V1::WasmPlugin::LogConfig]
        #     Optional. Specifies the logging options for the activity performed by this
        #     plugin. If logging is enabled, plugin logs are exported to
        #     Cloud Logging.
        #     Note that the settings relate to the logs generated by using
        #     logging statements in your Wasm code.
        # @!attribute [rw] versions
        #   @return [::Google::Protobuf::Map{::String => ::Google::Cloud::NetworkServices::V1::WasmPlugin::VersionDetails}]
        #     Optional. All versions of this `WasmPlugin` resource in the key-value
        #     format. The key is the resource ID, and the value is the `VersionDetails`
        #     object.
        #
        #     Lets you create or update a `WasmPlugin` resource and its versions in a
        #     single request. When the `main_version_id` field is not empty, it must
        #     point to one of the `VersionDetails` objects in the map.
        #
        #     If provided in a `PATCH` request, the new versions replace the
        #     previous set. Any version omitted from the `versions` field is removed.
        #     Because the `WasmPluginVersion` resource is immutable, if a
        #     `WasmPluginVersion` resource with the same name already exists and differs,
        #     the request fails.
        #
        #     Note: In a `GET` request, this field is populated only if the field
        #     `GetWasmPluginRequest.view` is set to `WASM_PLUGIN_VIEW_FULL`.
        # @!attribute [r] used_by
        #   @return [::Array<::Google::Cloud::NetworkServices::V1::WasmPlugin::UsedBy>]
        #     Output only. List of all
        #     [extensions](https://cloud.google.com/service-extensions/docs/overview)
        #     that use this `WasmPlugin` resource.
        class WasmPlugin
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Details of a `WasmPluginVersion` resource to be inlined in the
          # `WasmPlugin` resource.
          # @!attribute [rw] plugin_config_data
          #   @return [::String]
          #     Configuration for the plugin.
          #     The configuration is provided to the plugin at runtime through
          #     the `ON_CONFIGURE` callback. When a new
          #     `WasmPluginVersion` version is created, the digest of the
          #     contents is saved in the `plugin_config_digest` field.
          #
          #     Note: The following fields are mutually exclusive: `plugin_config_data`, `plugin_config_uri`. If a field in that set is populated, all other fields in the set will automatically be cleared.
          # @!attribute [rw] plugin_config_uri
          #   @return [::String]
          #     URI of the plugin configuration stored in the Artifact Registry.
          #     The configuration is provided to the plugin at runtime through
          #     the `ON_CONFIGURE` callback. The container image must
          #     contain only a single file with the name
          #     `plugin.config`. When a new `WasmPluginVersion`
          #     resource is created, the digest of the container image is saved in the
          #     `plugin_config_digest` field.
          #
          #     Note: The following fields are mutually exclusive: `plugin_config_uri`, `plugin_config_data`. If a field in that set is populated, all other fields in the set will automatically be cleared.
          # @!attribute [r] create_time
          #   @return [::Google::Protobuf::Timestamp]
          #     Output only. The timestamp when the resource was created.
          # @!attribute [r] update_time
          #   @return [::Google::Protobuf::Timestamp]
          #     Output only. The timestamp when the resource was updated.
          # @!attribute [rw] description
          #   @return [::String]
          #     Optional. A human-readable description of the resource.
          # @!attribute [rw] labels
          #   @return [::Google::Protobuf::Map{::String => ::String}]
          #     Optional. Set of labels associated with the `WasmPluginVersion`
          #     resource.
          # @!attribute [rw] image_uri
          #   @return [::String]
          #     Optional. URI of the container image containing the Wasm module, stored
          #     in the Artifact Registry. The container image must contain only a single
          #     file with the name `plugin.wasm`. When a new `WasmPluginVersion` resource
          #     is created, the URI gets resolved to an image digest and saved in the
          #     `image_digest` field.
          # @!attribute [r] image_digest
          #   @return [::String]
          #     Output only. The resolved digest for the image specified in `image`.
          #     The digest is resolved during the creation of a
          #     `WasmPluginVersion` resource.
          #     This field holds the digest value regardless of whether a tag or
          #     digest was originally specified in the `image` field.
          # @!attribute [r] plugin_config_digest
          #   @return [::String]
          #     Output only. This field holds the digest (usually checksum) value for the
          #     plugin configuration. The value is calculated based on the contents of
          #     the `plugin_config_data` field or the container image defined by the
          #     `plugin_config_uri` field.
          class VersionDetails
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods

            # @!attribute [rw] key
            #   @return [::String]
            # @!attribute [rw] value
            #   @return [::String]
            class LabelsEntry
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods
            end
          end

          # Specifies the logging options for the activity performed by this
          # plugin. If logging is enabled, plugin logs are exported to
          # Cloud Logging.
          # @!attribute [rw] enable
          #   @return [::Boolean]
          #     Optional. Specifies whether to enable logging for activity by this
          #     plugin.
          #
          #     Defaults to `false`.
          # @!attribute [rw] sample_rate
          #   @return [::Float]
          #     Non-empty default. Configures the sampling rate of activity logs, where
          #     `1.0` means all logged activity is reported and `0.0` means no activity
          #     is reported. A floating point value between `0.0` and `1.0` indicates
          #     that a percentage of log messages is stored.
          #
          #     The default value when logging is enabled is `1.0`. The value of the
          #     field must be between `0` and `1` (inclusive).
          #
          #     This field can be specified only if logging is enabled for this plugin.
          # @!attribute [rw] min_log_level
          #   @return [::Google::Cloud::NetworkServices::V1::WasmPlugin::LogConfig::LogLevel]
          #     Non-empty default. Specificies the lowest level of the plugin logs that
          #     are exported to Cloud Logging. This setting relates to the logs generated
          #     by using logging statements in your Wasm code.
          #
          #     This field is can be set only if logging is enabled for the plugin.
          #
          #     If the field is not provided when logging is enabled, it is set to
          #     `INFO` by default.
          class LogConfig
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods

            # Possible values to specify the lowest level of logs to be exported to
            # Cloud Logging.
            module LogLevel
              # Unspecified value. Defaults to `LogLevel.INFO`.
              LOG_LEVEL_UNSPECIFIED = 0

              # Report logs with TRACE level and above.
              TRACE = 1

              # Report logs with DEBUG level and above.
              DEBUG = 2

              # Report logs with INFO level and above.
              INFO = 3

              # Report logs with WARN level and above.
              WARN = 4

              # Report logs with ERROR level and above.
              ERROR = 5

              # Report logs with CRITICAL level only.
              CRITICAL = 6
            end
          end

          # Defines a resource that uses the `WasmPlugin` resource.
          # @!attribute [r] name
          #   @return [::String]
          #     Output only. Full name of the resource
          #     https://google.aip.dev/122#full-resource-names, for example
          #     `//networkservices.googleapis.com/projects/{project}/locations/{location}/lbRouteExtensions/{extension}`
          class UsedBy
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class LabelsEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::Google::Cloud::NetworkServices::V1::WasmPlugin::VersionDetails]
          class VersionsEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # A single immutable version of a `WasmPlugin` resource.
        # Defines the Wasm module used and optionally its runtime config.
        # @!attribute [rw] plugin_config_data
        #   @return [::String]
        #     Configuration for the plugin.
        #     The configuration is provided to the plugin at runtime through
        #     the `ON_CONFIGURE` callback. When a new
        #     `WasmPluginVersion` resource is created, the digest of the
        #     contents is saved in the `plugin_config_digest` field.
        #
        #     Note: The following fields are mutually exclusive: `plugin_config_data`, `plugin_config_uri`. If a field in that set is populated, all other fields in the set will automatically be cleared.
        # @!attribute [rw] plugin_config_uri
        #   @return [::String]
        #     URI of the plugin configuration stored in the Artifact Registry.
        #     The configuration is provided to the plugin at runtime through
        #     the `ON_CONFIGURE` callback. The container image must contain
        #     only a single file with the name `plugin.config`. When a
        #     new `WasmPluginVersion` resource is created, the digest of the
        #     container image is saved in the `plugin_config_digest` field.
        #
        #     Note: The following fields are mutually exclusive: `plugin_config_uri`, `plugin_config_data`. If a field in that set is populated, all other fields in the set will automatically be cleared.
        # @!attribute [rw] name
        #   @return [::String]
        #     Identifier. Name of the `WasmPluginVersion` resource in the following
        #     format: `projects/{project}/locations/{location}/wasmPlugins/{wasm_plugin}/
        #     versions/\\{wasm_plugin_version}`.
        # @!attribute [r] create_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The timestamp when the resource was created.
        # @!attribute [r] update_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The timestamp when the resource was updated.
        # @!attribute [rw] description
        #   @return [::String]
        #     Optional. A human-readable description of the resource.
        # @!attribute [rw] labels
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Optional. Set of labels associated with the `WasmPluginVersion`
        #     resource.
        # @!attribute [rw] image_uri
        #   @return [::String]
        #     Optional. URI of the container image containing the plugin, stored in the
        #     Artifact Registry.
        #     When a new `WasmPluginVersion` resource is created, the digest
        #     of the container image is saved in the `image_digest` field.
        #     When downloading an image, the digest value is used instead of an
        #     image tag.
        # @!attribute [r] image_digest
        #   @return [::String]
        #     Output only. The resolved digest for the image specified in the `image`
        #     field. The digest is resolved during the creation of `WasmPluginVersion`
        #     resource. This field holds the digest value, regardless of whether a tag or
        #     digest was originally specified in the `image` field.
        # @!attribute [r] plugin_config_digest
        #   @return [::String]
        #     Output only. This field holds the digest (usually checksum) value for the
        #     plugin configuration. The value is calculated based on the contents of
        #     `plugin_config_data` or the container image defined by
        #     the `plugin_config_uri` field.
        class WasmPluginVersion
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class LabelsEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # Request used with the `ListWasmPlugins` method.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The project and location from which the `WasmPlugin` resources
        #     are listed, specified in the following format:
        #     `projects/{project}/locations/global`.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Maximum number of `WasmPlugin` resources to return per call.
        #     If not specified, at most 50 `WasmPlugin` resources are returned.
        #     The maximum value is 1000; values above 1000 are coerced to 1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     The value returned by the last `ListWasmPluginsResponse` call.
        #     Indicates that this is a continuation of a prior
        #     `ListWasmPlugins` call, and that the
        #     next page of data is to be returned.
        class ListWasmPluginsRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Response returned by the `ListWasmPlugins` method.
        # @!attribute [rw] wasm_plugins
        #   @return [::Array<::Google::Cloud::NetworkServices::V1::WasmPlugin>]
        #     List of `WasmPlugin` resources.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     If there might be more results than those appearing in this response, then
        #     `next_page_token` is included. To get the next set of results,
        #     call this method again using the value of `next_page_token` as
        #     `page_token`.
        # @!attribute [rw] unreachable
        #   @return [::Array<::String>]
        #     Unreachable resources. Populated when the request attempts to list all
        #     resources across all supported locations, while some locations are
        #     temporarily unavailable.
        class ListWasmPluginsResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request used by the `GetWasmPlugin` method.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. A name of the `WasmPlugin` resource to get. Must be in the
        #     format `projects/{project}/locations/global/wasmPlugins/{wasm_plugin}`.
        # @!attribute [rw] view
        #   @return [::Google::Cloud::NetworkServices::V1::WasmPluginView]
        #     Determines how much data must be returned in the response. See
        #     [AIP-157](https://google.aip.dev/157).
        class GetWasmPluginRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request used by the `CreateWasmPlugin` method.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent resource of the `WasmPlugin` resource. Must be in the
        #     format `projects/{project}/locations/global`.
        # @!attribute [rw] wasm_plugin_id
        #   @return [::String]
        #     Required. User-provided ID of the `WasmPlugin` resource to be created.
        # @!attribute [rw] wasm_plugin
        #   @return [::Google::Cloud::NetworkServices::V1::WasmPlugin]
        #     Required. `WasmPlugin` resource to be created.
        class CreateWasmPluginRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request used by the `UpdateWasmPlugin` method.
        # @!attribute [rw] update_mask
        #   @return [::Google::Protobuf::FieldMask]
        #     Optional. Used to specify the fields to be overwritten in the
        #     `WasmPlugin` resource by the update.
        #     The fields specified in the `update_mask` field are relative to the
        #     resource, not the full request.
        #     An omitted `update_mask` field is treated as an implied `update_mask`
        #     field equivalent to all fields that are populated (that have a non-empty
        #     value).
        #     The `update_mask` field supports a special value `*`, which means that
        #     each field in the given `WasmPlugin` resource (including the empty ones)
        #     replaces the current value.
        # @!attribute [rw] wasm_plugin
        #   @return [::Google::Cloud::NetworkServices::V1::WasmPlugin]
        #     Required. Updated `WasmPlugin` resource.
        class UpdateWasmPluginRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request used by the `DeleteWasmPlugin` method.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. A name of the `WasmPlugin` resource to delete. Must be in the
        #     format `projects/{project}/locations/global/wasmPlugins/{wasm_plugin}`.
        class DeleteWasmPluginRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request used with the `ListWasmPluginVersions` method.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The `WasmPlugin` resource whose `WasmPluginVersion`s
        #     are listed, specified in the following format:
        #     `projects/{project}/locations/global/wasmPlugins/{wasm_plugin}`.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Maximum number of `WasmPluginVersion` resources to return per
        #     call. If not specified, at most 50 `WasmPluginVersion` resources are
        #     returned. The maximum value is 1000; values above 1000 are coerced to
        #     1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     The value returned by the last `ListWasmPluginVersionsResponse` call.
        #     Indicates that this is a continuation of a prior
        #     `ListWasmPluginVersions` call, and that the
        #     next page of data is to be returned.
        class ListWasmPluginVersionsRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Response returned by the `ListWasmPluginVersions` method.
        # @!attribute [rw] wasm_plugin_versions
        #   @return [::Array<::Google::Cloud::NetworkServices::V1::WasmPluginVersion>]
        #     List of `WasmPluginVersion` resources.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     If there might be more results than those appearing in this response, then
        #     `next_page_token` is included. To get the next set of results,
        #     call this method again using the value of `next_page_token` as
        #     `page_token`.
        # @!attribute [rw] unreachable
        #   @return [::Array<::String>]
        #     Unreachable resources. Populated when the request attempts to list all
        #     resources across all supported locations, while some locations are
        #     temporarily unavailable.
        class ListWasmPluginVersionsResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request used by the `GetWasmPluginVersion` method.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. A name of the `WasmPluginVersion` resource to get. Must be in
        #     the format
        #     `projects/{project}/locations/global/wasmPlugins/{wasm_plugin}/versions/{wasm_plugin_version}`.
        class GetWasmPluginVersionRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request used by the `CreateWasmPluginVersion` method.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent resource of the `WasmPluginVersion` resource. Must be
        #     in the format
        #     `projects/{project}/locations/global/wasmPlugins/{wasm_plugin}`.
        # @!attribute [rw] wasm_plugin_version_id
        #   @return [::String]
        #     Required. User-provided ID of the `WasmPluginVersion` resource to be
        #     created.
        # @!attribute [rw] wasm_plugin_version
        #   @return [::Google::Cloud::NetworkServices::V1::WasmPluginVersion]
        #     Required. `WasmPluginVersion` resource to be created.
        class CreateWasmPluginVersionRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request used by the `DeleteWasmPluginVersion` method.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. A name of the `WasmPluginVersion` resource to delete. Must be in
        #     the format
        #     `projects/{project}/locations/global/wasmPlugins/{wasm_plugin}/versions/{wasm_plugin_version}`.
        class DeleteWasmPluginVersionRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Determines the information that should be returned by the server.
        module WasmPluginView
          # Unspecified value. Do not use.
          WASM_PLUGIN_VIEW_UNSPECIFIED = 0

          # If specified in the `GET` request for a `WasmPlugin` resource, the server's
          # response includes just the `WasmPlugin` resource.
          WASM_PLUGIN_VIEW_BASIC = 1

          # If specified in the `GET` request for a `WasmPlugin` resource, the server's
          # response includes the `WasmPlugin` resource with all its versions.
          WASM_PLUGIN_VIEW_FULL = 2
        end
      end
    end
  end
end
