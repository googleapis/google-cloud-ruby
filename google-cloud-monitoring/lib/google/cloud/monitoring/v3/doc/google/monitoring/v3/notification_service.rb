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
  module Monitoring
    module V3
      # The +ListNotificationChannelDescriptors+ request.
      # @!attribute [rw] name
      #   @return [String]
      #     The REST resource name of the parent from which to retrieve
      #     the notification channel descriptors. The expected syntax is:
      #
      #         projects/[PROJECT_ID]
      #
      #     Note that this names the parent container in which to look for the
      #     descriptors; to retrieve a single descriptor by name, use the
      #     {Google::Monitoring::V3::NotificationChannelService::GetNotificationChannelDescriptor GetNotificationChannelDescriptor}
      #     operation, instead.
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     The maximum number of results to return in a single response. If
      #     not set to a positive number, a reasonable value will be chosen by the
      #     service.
      # @!attribute [rw] page_token
      #   @return [String]
      #     If non-empty, +page_token+ must contain a value returned as the
      #     +next_page_token+ in a previous response to request the next set
      #     of results.
      class ListNotificationChannelDescriptorsRequest; end

      # The +ListNotificationChannelDescriptors+ response.
      # @!attribute [rw] channel_descriptors
      #   @return [Array<Google::Monitoring::V3::NotificationChannelDescriptor>]
      #     The monitored resource descriptors supported for the specified
      #     project, optionally filtered.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     If not empty, indicates that there may be more results that match
      #     the request. Use the value in the +page_token+ field in a
      #     subsequent request to fetch the next set of results. If empty,
      #     all results have been returned.
      class ListNotificationChannelDescriptorsResponse; end

      # The +GetNotificationChannelDescriptor+ response.
      # @!attribute [rw] name
      #   @return [String]
      #     The channel type for which to execute the request. The format is
      #     +projects/[PROJECT_ID]/notificationChannelDescriptors/\\{channel_type}+.
      class GetNotificationChannelDescriptorRequest; end

      # The +CreateNotificationChannel+ request.
      # @!attribute [rw] name
      #   @return [String]
      #     The project on which to execute the request. The format is:
      #
      #         projects/[PROJECT_ID]
      #
      #     Note that this names the container into which the channel will be
      #     written. This does not name the newly created channel. The resulting
      #     channel's name will have a normalized version of this field as a prefix,
      #     but will add +/notificationChannels/[CHANNEL_ID]+ to identify the channel.
      # @!attribute [rw] notification_channel
      #   @return [Google::Monitoring::V3::NotificationChannel]
      #     The definition of the +NotificationChannel+ to create.
      class CreateNotificationChannelRequest; end

      # The +ListNotificationChannels+ request.
      # @!attribute [rw] name
      #   @return [String]
      #     The project on which to execute the request. The format is
      #     +projects/[PROJECT_ID]+. That is, this names the container
      #     in which to look for the notification channels; it does not name a
      #     specific channel. To query a specific channel by REST resource name, use
      #     the
      #     {Google::Monitoring::V3::NotificationChannelService::GetNotificationChannel +GetNotificationChannel+} operation.
      # @!attribute [rw] filter
      #   @return [String]
      #     If provided, this field specifies the criteria that must be met by
      #     notification channels to be included in the response.
      #
      #     For more details, see [sorting and
      #     filtering](/monitoring/api/v3/sorting-and-filtering).
      # @!attribute [rw] order_by
      #   @return [String]
      #     A comma-separated list of fields by which to sort the result. Supports
      #     the same set of fields as in +filter+. Entries can be prefixed with
      #     a minus sign to sort in descending rather than ascending order.
      #
      #     For more details, see [sorting and
      #     filtering](/monitoring/api/v3/sorting-and-filtering).
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     The maximum number of results to return in a single response. If
      #     not set to a positive number, a reasonable value will be chosen by the
      #     service.
      # @!attribute [rw] page_token
      #   @return [String]
      #     If non-empty, +page_token+ must contain a value returned as the
      #     +next_page_token+ in a previous response to request the next set
      #     of results.
      class ListNotificationChannelsRequest; end

      # The +ListNotificationChannels+ response.
      # @!attribute [rw] notification_channels
      #   @return [Array<Google::Monitoring::V3::NotificationChannel>]
      #     The notification channels defined for the specified project.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     If not empty, indicates that there may be more results that match
      #     the request. Use the value in the +page_token+ field in a
      #     subsequent request to fetch the next set of results. If empty,
      #     all results have been returned.
      class ListNotificationChannelsResponse; end

      # The +GetNotificationChannel+ request.
      # @!attribute [rw] name
      #   @return [String]
      #     The channel for which to execute the request. The format is
      #     +projects/[PROJECT_ID]/notificationChannels/[CHANNEL_ID]+.
      class GetNotificationChannelRequest; end

      # The +UpdateNotificationChannel+ request.
      # @!attribute [rw] update_mask
      #   @return [Google::Protobuf::FieldMask]
      #     The fields to update.
      # @!attribute [rw] notification_channel
      #   @return [Google::Monitoring::V3::NotificationChannel]
      #     A description of the changes to be applied to the specified
      #     notification channel. The description must provide a definition for
      #     fields to be updated; the names of these fields should also be
      #     included in the +update_mask+.
      class UpdateNotificationChannelRequest; end

      # The +DeleteNotificationChannel+ request.
      # @!attribute [rw] name
      #   @return [String]
      #     The channel for which to execute the request. The format is
      #     +projects/[PROJECT_ID]/notificationChannels/[CHANNEL_ID]+.
      # @!attribute [rw] force
      #   @return [true, false]
      #     If true, the notification channel will be deleted regardless of its
      #     use in alert policies (the policies will be updated to remove the
      #     channel). If false, channels that are still referenced by an existing
      #     alerting policy will fail to be deleted in a delete operation.
      class DeleteNotificationChannelRequest; end

      # The +SendNotificationChannelVerificationCode+ request.
      # @!attribute [rw] name
      #   @return [String]
      #     The notification channel to which to send a verification code.
      class SendNotificationChannelVerificationCodeRequest; end

      # The +GetNotificationChannelVerificationCode+ request.
      # @!attribute [rw] name
      #   @return [String]
      #     The notification channel for which a verification code is to be generated
      #     and retrieved. This must name a channel that is already verified; if
      #     the specified channel is not verified, the request will fail.
      # @!attribute [rw] expire_time
      #   @return [Google::Protobuf::Timestamp]
      #     The desired expiration time. If specified, the API will guarantee that
      #     the returned code will not be valid after the specified timestamp;
      #     however, the API cannot guarantee that the returned code will be
      #     valid for at least as long as the requested time (the API puts an upper
      #     bound on the amount of time for which a code may be valid). If omitted,
      #     a default expiration will be used, which may be less than the max
      #     permissible expiration (so specifying an expiration may extend the
      #     code's lifetime over omitting an expiration, even though the API does
      #     impose an upper limit on the maximum expiration that is permitted).
      class GetNotificationChannelVerificationCodeRequest; end

      # The +GetNotificationChannelVerificationCode+ request.
      # @!attribute [rw] code
      #   @return [String]
      #     The verification code, which may be used to verify other channels
      #     that have an equivalent identity (i.e. other channels of the same
      #     type with the same fingerprint such as other email channels with
      #     the same email address or other sms channels with the same number).
      # @!attribute [rw] expire_time
      #   @return [Google::Protobuf::Timestamp]
      #     The expiration time associated with the code that was returned. If
      #     an expiration was provided in the request, this is the minimum of the
      #     requested expiration in the request and the max permitted expiration.
      class GetNotificationChannelVerificationCodeResponse; end

      # The +VerifyNotificationChannel+ request.
      # @!attribute [rw] name
      #   @return [String]
      #     The notification channel to verify.
      # @!attribute [rw] code
      #   @return [String]
      #     The verification code that was delivered to the channel as
      #     a result of invoking the +SendNotificationChannelVerificationCode+ API
      #     method or that was retrieved from a verified channel via
      #     +GetNotificationChannelVerificationCode+. For example, one might have
      #     "G-123456" or "TKNZGhhd2EyN3I1MnRnMjRv" (in general, one is only
      #     guaranteed that the code is valid UTF-8; one should not
      #     make any assumptions regarding the structure or format of the code).
      class VerifyNotificationChannelRequest; end
    end
  end
end