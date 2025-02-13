# frozen_string_literal: true

# Copyright 2021 Google LLC
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
    module Dialogflow
      module CX
        module V3
          # The request message for
          # {::Google::Cloud::Dialogflow::CX::V3::SecuritySettingsService::Client#get_security_settings SecuritySettingsService.GetSecuritySettings}.
          # @!attribute [rw] name
          #   @return [::String]
          #     Required. Resource name of the settings.
          #     Format:
          #     `projects/<ProjectID>/locations/<LocationID>/securitySettings/<securitysettingsID>`.
          class GetSecuritySettingsRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # The request message for
          # {::Google::Cloud::Dialogflow::CX::V3::SecuritySettingsService::Client#update_security_settings SecuritySettingsService.UpdateSecuritySettings}.
          # @!attribute [rw] security_settings
          #   @return [::Google::Cloud::Dialogflow::CX::V3::SecuritySettings]
          #     Required. [SecuritySettings] object that contains values for each of the
          #     fields to update.
          # @!attribute [rw] update_mask
          #   @return [::Google::Protobuf::FieldMask]
          #     Required. The mask to control which fields get updated. If the mask is not
          #     present, all fields will be updated.
          class UpdateSecuritySettingsRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # The request message for [SecuritySettings.ListSecuritySettings][].
          # @!attribute [rw] parent
          #   @return [::String]
          #     Required. The location to list all security settings for.
          #     Format: `projects/<ProjectID>/locations/<LocationID>`.
          # @!attribute [rw] page_size
          #   @return [::Integer]
          #     The maximum number of items to return in a single page. By default 20 and
          #     at most 100.
          # @!attribute [rw] page_token
          #   @return [::String]
          #     The next_page_token value returned from a previous list request.
          class ListSecuritySettingsRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # The response message for [SecuritySettings.ListSecuritySettings][].
          # @!attribute [rw] security_settings
          #   @return [::Array<::Google::Cloud::Dialogflow::CX::V3::SecuritySettings>]
          #     The list of security settings.
          # @!attribute [rw] next_page_token
          #   @return [::String]
          #     Token to retrieve the next page of results, or empty if there are no more
          #     results in the list.
          class ListSecuritySettingsResponse
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # The request message for [SecuritySettings.CreateSecuritySettings][].
          # @!attribute [rw] parent
          #   @return [::String]
          #     Required. The location to create an
          #     {::Google::Cloud::Dialogflow::CX::V3::SecuritySettings SecuritySettings} for.
          #     Format: `projects/<ProjectID>/locations/<LocationID>`.
          # @!attribute [rw] security_settings
          #   @return [::Google::Cloud::Dialogflow::CX::V3::SecuritySettings]
          #     Required. The security settings to create.
          class CreateSecuritySettingsRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # The request message for [SecuritySettings.DeleteSecuritySettings][].
          # @!attribute [rw] name
          #   @return [::String]
          #     Required. The name of the
          #     {::Google::Cloud::Dialogflow::CX::V3::SecuritySettings SecuritySettings} to
          #     delete. Format:
          #     `projects/<ProjectID>/locations/<LocationID>/securitySettings/<SecuritySettingsID>`.
          class DeleteSecuritySettingsRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Represents the settings related to security issues, such as data redaction
          # and data retention. It may take hours for updates on the settings to
          # propagate to all the related components and take effect.
          # @!attribute [rw] name
          #   @return [::String]
          #     Resource name of the settings.
          #     Required for the
          #     {::Google::Cloud::Dialogflow::CX::V3::SecuritySettingsService::Client#update_security_settings SecuritySettingsService.UpdateSecuritySettings}
          #     method.
          #     {::Google::Cloud::Dialogflow::CX::V3::SecuritySettingsService::Client#create_security_settings SecuritySettingsService.CreateSecuritySettings}
          #     populates the name automatically. Format:
          #     `projects/<ProjectID>/locations/<LocationID>/securitySettings/<SecuritySettingsID>`.
          # @!attribute [rw] display_name
          #   @return [::String]
          #     Required. The human-readable name of the security settings, unique within
          #     the location.
          # @!attribute [rw] redaction_strategy
          #   @return [::Google::Cloud::Dialogflow::CX::V3::SecuritySettings::RedactionStrategy]
          #     Strategy that defines how we do redaction.
          # @!attribute [rw] redaction_scope
          #   @return [::Google::Cloud::Dialogflow::CX::V3::SecuritySettings::RedactionScope]
          #     Defines the data for which Dialogflow applies redaction. Dialogflow does
          #     not redact data that it does not have access to – for example, Cloud
          #     logging.
          # @!attribute [rw] inspect_template
          #   @return [::String]
          #     [DLP](https://cloud.google.com/dlp/docs) inspect template name. Use this
          #     template to define inspect base settings.
          #
          #     The `DLP Inspect Templates Reader` role is needed on the Dialogflow
          #     service identity service account (has the form
          #     `service-PROJECT_NUMBER@gcp-sa-dialogflow.iam.gserviceaccount.com`)
          #     for your agent's project.
          #
          #     If empty, we use the default DLP inspect config.
          #
          #     The template name will have one of the following formats:
          #     `projects/<ProjectID>/locations/<LocationID>/inspectTemplates/<TemplateID>`
          #     OR
          #     `organizations/<OrganizationID>/locations/<LocationID>/inspectTemplates/<TemplateID>`
          #
          #     Note: `inspect_template` must be located in the same region as the
          #     `SecuritySettings`.
          # @!attribute [rw] deidentify_template
          #   @return [::String]
          #     [DLP](https://cloud.google.com/dlp/docs) deidentify template name. Use this
          #     template to define de-identification configuration for the content.
          #
          #     The `DLP De-identify Templates Reader` role is needed on the Dialogflow
          #     service identity service account (has the form
          #     `service-PROJECT_NUMBER@gcp-sa-dialogflow.iam.gserviceaccount.com`)
          #     for your agent's project.
          #
          #     If empty, Dialogflow replaces sensitive info with `[redacted]` text.
          #
          #     The template name will have one of the following formats:
          #     `projects/<ProjectID>/locations/<LocationID>/deidentifyTemplates/<TemplateID>`
          #     OR
          #     `organizations/<OrganizationID>/locations/<LocationID>/deidentifyTemplates/<TemplateID>`
          #
          #     Note: `deidentify_template` must be located in the same region as the
          #     `SecuritySettings`.
          # @!attribute [rw] retention_window_days
          #   @return [::Integer]
          #     Retains the data for the specified number of days.
          #     User must set a value lower than Dialogflow's default 365d TTL (30 days
          #     for Agent Assist traffic), higher value will be ignored and use default.
          #     Setting a value higher than that has no effect. A missing value or
          #     setting to 0 also means we use default TTL.
          #     When data retention configuration is changed, it only applies to the data
          #     created after the change; the TTL of existing data created before the
          #     change stays intact.
          #
          #     Note: The following fields are mutually exclusive: `retention_window_days`, `retention_strategy`. If a field in that set is populated, all other fields in the set will automatically be cleared.
          # @!attribute [rw] retention_strategy
          #   @return [::Google::Cloud::Dialogflow::CX::V3::SecuritySettings::RetentionStrategy]
          #     Specifies the retention behavior defined by
          #     {::Google::Cloud::Dialogflow::CX::V3::SecuritySettings::RetentionStrategy SecuritySettings.RetentionStrategy}.
          #
          #     Note: The following fields are mutually exclusive: `retention_strategy`, `retention_window_days`. If a field in that set is populated, all other fields in the set will automatically be cleared.
          # @!attribute [rw] purge_data_types
          #   @return [::Array<::Google::Cloud::Dialogflow::CX::V3::SecuritySettings::PurgeDataType>]
          #     List of types of data to remove when retention settings triggers purge.
          # @!attribute [rw] audio_export_settings
          #   @return [::Google::Cloud::Dialogflow::CX::V3::SecuritySettings::AudioExportSettings]
          #     Controls audio export settings for post-conversation analytics when
          #     ingesting audio to conversations via [Participants.AnalyzeContent][] or
          #     [Participants.StreamingAnalyzeContent][].
          #
          #     If
          #     {::Google::Cloud::Dialogflow::CX::V3::SecuritySettings#retention_strategy retention_strategy}
          #     is set to REMOVE_AFTER_CONVERSATION or [audio_export_settings.gcs_bucket][]
          #     is empty, audio export is disabled.
          #
          #     If audio export is enabled, audio is recorded and saved to
          #     [audio_export_settings.gcs_bucket][], subject to retention policy of
          #     [audio_export_settings.gcs_bucket][].
          #
          #     This setting won't effect audio input for implicit sessions via
          #     {::Google::Cloud::Dialogflow::CX::V3::Sessions::Client#detect_intent Sessions.DetectIntent}
          #     or
          #     {::Google::Cloud::Dialogflow::CX::V3::Sessions::Client#streaming_detect_intent Sessions.StreamingDetectIntent}.
          # @!attribute [rw] insights_export_settings
          #   @return [::Google::Cloud::Dialogflow::CX::V3::SecuritySettings::InsightsExportSettings]
          #     Controls conversation exporting settings to Insights after conversation is
          #     completed.
          #
          #     If
          #     {::Google::Cloud::Dialogflow::CX::V3::SecuritySettings#retention_strategy retention_strategy}
          #     is set to REMOVE_AFTER_CONVERSATION, Insights export is disabled no matter
          #     what you configure here.
          class SecuritySettings
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods

            # Settings for exporting audio.
            # @!attribute [rw] gcs_bucket
            #   @return [::String]
            #     Cloud Storage bucket to export audio record to.
            #     Setting this field would grant the Storage Object Creator role to
            #     the Dialogflow Service Agent.
            #     API caller that tries to modify this field should have the permission of
            #     storage.buckets.setIamPolicy.
            # @!attribute [rw] audio_export_pattern
            #   @return [::String]
            #     Filename pattern for exported audio.
            # @!attribute [rw] enable_audio_redaction
            #   @return [::Boolean]
            #     Enable audio redaction if it is true.
            #     Note that this only redacts end-user audio data;
            #     Synthesised audio from the virtual agent is not redacted.
            # @!attribute [rw] audio_format
            #   @return [::Google::Cloud::Dialogflow::CX::V3::SecuritySettings::AudioExportSettings::AudioFormat]
            #     File format for exported audio file. Currently only in telephony
            #     recordings.
            # @!attribute [rw] store_tts_audio
            #   @return [::Boolean]
            #     Whether to store TTS audio. By default, TTS audio from the virtual agent
            #     is not exported.
            class AudioExportSettings
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods

              # File format for exported audio file. Currently only in telephony
              # recordings.
              module AudioFormat
                # Unspecified. Do not use.
                AUDIO_FORMAT_UNSPECIFIED = 0

                # G.711 mu-law PCM with 8kHz sample rate.
                MULAW = 1

                # MP3 file format.
                MP3 = 2

                # OGG Vorbis.
                OGG = 3
              end
            end

            # Settings for exporting conversations to
            # [Insights](https://cloud.google.com/contact-center/insights/docs).
            # @!attribute [rw] enable_insights_export
            #   @return [::Boolean]
            #     If enabled, we will automatically exports
            #     conversations to Insights and Insights runs its analyzers.
            class InsightsExportSettings
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods
            end

            # Defines how we redact data.
            module RedactionStrategy
              # Do not redact.
              REDACTION_STRATEGY_UNSPECIFIED = 0

              # Call redaction service to clean up the data to be persisted.
              REDACT_WITH_SERVICE = 1
            end

            # Defines what types of data to redact.
            module RedactionScope
              # Don't redact any kind of data.
              REDACTION_SCOPE_UNSPECIFIED = 0

              # On data to be written to disk or similar devices that are capable of
              # holding data even if power is disconnected. This includes data that are
              # temporarily saved on disk.
              REDACT_DISK_STORAGE = 2
            end

            # Defines how long we retain persisted data that contains sensitive info.
            module RetentionStrategy
              # Retains the persisted data with Dialogflow's internal default 365d TTLs.
              RETENTION_STRATEGY_UNSPECIFIED = 0

              # Removes data when the conversation ends. If there is no [Conversation][]
              # explicitly established, a default conversation ends when the
              # corresponding Dialogflow session ends.
              REMOVE_AFTER_CONVERSATION = 1
            end

            # Type of data we purge after retention settings triggers purge.
            module PurgeDataType
              # Unspecified. Do not use.
              PURGE_DATA_TYPE_UNSPECIFIED = 0

              # Dialogflow history. This does not include Cloud logging, which is
              # owned by the user - not Dialogflow.
              DIALOGFLOW_HISTORY = 1
            end
          end
        end
      end
    end
  end
end
