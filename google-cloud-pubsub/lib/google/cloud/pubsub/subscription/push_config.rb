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


require "google/pubsub/v1/pubsub_pb"

module Google
  module Cloud
    module PubSub
      class Subscription
        ##
        # Configuration for a push delivery endpoint.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   sub = pubsub.subscription "my-topic-sub"
        #   sub.push_config.endpoint #=> "http://example.com/callback"
        #   sub.push_config.authentication.email #=> "user@example.com"
        #   sub.push_config.authentication.audience #=> "client-12345"
        #
        # @example Update the push configuration by passing a block:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   sub = pubsub.subscription "my-subscription"
        #
        #   sub.push_config do |pc|
        #     pc.endpoint = "http://example.net/callback"
        #     pc.set_oidc_token "user@example.net", "client-67890"
        #   end
        #
        # @example Create a push subscription by passing a push config:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   topic = pubsub.topic "my-topic"
        #
        #   push_config = Google::Cloud::PubSub::Subscription::PushConfig.new
        #   push_config.endpoint = "http://example.net/callback"
        #   push_config.set_oidc_token(
        #     "service-account@example.net", "audience-header-value"
        #   )
        #   sub = topic.subscribe "my-subscription", push_config: push_config
        #
        class PushConfig
          ##
          # Creates an empty configuration for a push subscription.
          # @param [String] endpoint URL to where the subscription will push data to.
          # @param [String] auth_email The GCP service account email associated with the push subscription.
          #  Push requests carry the identity of this service account.
          # @param [String] auth_audience A single, case-insensitive string that can be used by
          #  the webhook to validate the intended audience of this particular token.
          # @return [PushConfig]
          def initialize endpoint: nil, auth_email: nil, auth_audience: nil
            @grpc = Google::Cloud::PubSub::V1::PushConfig.new

            self.endpoint = endpoint unless endpoint.nil?
            set_oidc_token auth_email, auth_audience if auth_email && auth_audience
          end

          ##
          # A URL locating the endpoint to which messages should be pushed. For
          # example, a Webhook endpoint might use `https://example.com/push`.
          #
          # @return [String]
          def endpoint
            @grpc.push_endpoint
          end

          ##
          # Sets the URL locating the endpoint to which messages should be
          # pushed. For example, a Webhook endpoint might use
          # `https://example.com/push`.
          #
          # @param [String, nil] new_endpoint New URL value
          def endpoint= new_endpoint
            @grpc.push_endpoint = String new_endpoint
          end

          ##
          # The authentication method used by push endpoints to verify the
          # source of push requests.
          #
          # @return [OidcToken, nil] An OIDC JWT token if specified, `nil`
          #   otherwise.
          def authentication
            return nil unless @grpc.authentication_method == :oidc_token

            OidcToken.from_grpc @grpc.oidc_token
          end

          ##
          # Sets the authentication method used by push endpoints to verify the
          # source of push requests.
          #
          # @param [OidcToken, nil] new_auth An authentication value.
          def authentication= new_auth
            if new_auth.nil?
              @grpc.oidc_token = nil
            else
              raise ArgumentError unless new_auth.is_a? OidcToken

              @grpc.oidc_token = new_auth.to_grpc
            end
          end

          ##
          # Checks whether authentication is an {OidcToken}.
          #
          # @return [Boolean]
          def oidc_token?
            authentication.is_a? OidcToken
          end

          ##
          # Sets the authentication method to use an {OidcToken}.
          #
          # @param [String] email Service account email.
          # @param [String] audience Audience to be used.
          def set_oidc_token email, audience
            oidc_token = OidcToken.new.tap do |token|
              token.email = email
              token.audience = audience
            end
            self.authentication = oidc_token
          end

          ##
          # The format of the pushed message. This attribute indicates the
          # version of the data expected by the endpoint. This controls the
          # shape of the pushed message (i.e., its fields and metadata). The
          # endpoint version is based on the version of the Pub/Sub API.
          #
          # If not present during the Subscription creation, it will default to
          # the version of the API used to make such call.
          #
          # The possible values for this attribute are:
          #
          # * `v1beta1`: uses the push format defined in the v1beta1 Pub/Sub
          #   API.
          # * `v1` or `v1beta2`: uses the push format defined in the v1 Pub/Sub
          #   API.
          #
          # @return [String]
          def version
            @grpc.attributes["x-goog-version"]
          end

          ##
          # Sets the format of the pushed message.
          #
          # The possible values for this attribute are:
          #
          # * `v1beta1`: uses the push format defined in the v1beta1 Pub/Sub
          #   API.
          # * `v1` or `v1beta2`: uses the push format defined in the v1 Pub/Sub
          #   API.
          #
          # @param [String, nil] new_version The new version value.
          def version= new_version
            if new_version.nil?
              @grpc.attributes.delete "x-goog-version"
            else
              @grpc.attributes["x-goog-version"] = new_version
            end
          end

          ##
          # @private
          def to_grpc
            @grpc
          end

          ##
          # @private
          def self.from_grpc grpc
            new.tap do |pc|
              pc.instance_variable_set :@grpc, grpc.dup if grpc
            end
          end

          ##
          # Contains information needed for generating an [OpenID Connect
          # token](https://developers.google.com/identity/protocols/OpenIDConnect).
          class OidcToken
            ##
            # @private
            def initialize
              @grpc = Google::Cloud::PubSub::V1::PushConfig::OidcToken.new
            end

            ##
            # Service account email to be used for generating the OIDC token.
            #
            # @return [String]
            def email
              @grpc.service_account_email
            end

            ##
            # Service account email to be used for generating the OIDC token.
            #
            # @param [String] new_email New service account email value.
            def email= new_email
              @grpc.service_account_email = new_email
            end

            ##
            # Audience to be used when generating OIDC token. The audience claim
            # identifies the recipients that the JWT is intended for. The
            # audience value is a single case-sensitive string.
            #
            # Having multiple values (array) for the audience field is not
            # supported.
            #
            # More info about the OIDC JWT token audience here:
            # https://tools.ietf.org/html/rfc7519#section-4.1.3
            #
            # @return [String]
            def audience
              @grpc.audience
            end

            ##
            # Sets the audience to be used when generating OIDC token.
            #
            # @param [String] new_audience New audience value.
            def audience= new_audience
              @grpc.audience = new_audience
            end

            ##
            # @private
            def to_grpc
              @grpc
            end

            ##
            # @private
            def self.from_grpc grpc
              grpc ||= Google::Cloud::PubSub::V1::PushConfig::OidcToken.new

              new.tap do |pc|
                pc.instance_variable_set :@grpc, grpc.dup
              end
            end
          end
        end
      end
    end
  end
end
