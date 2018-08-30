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


require "google/cloud/dialogflow/v2/agents_client"
require "google/cloud/dialogflow/v2/contexts_client"
require "google/cloud/dialogflow/v2/entity_types_client"
require "google/cloud/dialogflow/v2/intents_client"
require "google/cloud/dialogflow/v2/session_entity_types_client"
require "google/cloud/dialogflow/v2/sessions_client"
require "google/cloud/dialogflow/v2/agent_pb"
require "google/cloud/dialogflow/v2/entity_type_pb"
require "google/cloud/dialogflow/v2/intent_pb"
require "google/cloud/dialogflow/v2/webhook_pb"

module Google
  module Cloud
    module Dialogflow
      # rubocop:disable LineLength

      ##
      # # Ruby Client for Dialogflow API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
      #
      # [Dialogflow API][Product Documentation]:
      # An end-to-end development suite for conversational interfaces (e.g.,
      # chatbots, voice-powered apps and devices).
      # - [Product Documentation][]
      #
      # ## Quick Start
      # In order to use this library, you first need to go through the following
      # steps:
      #
      # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
      # 2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
      # 3. [Enable the Dialogflow API.](https://console.cloud.google.com/apis/library/dialogflow.googleapis.com)
      # 4. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
      #
      # ### Installation
      # ```
      # $ gem install google-cloud-dialogflow
      # ```
      #
      # ### Next Steps
      # - Read the [Dialogflow API Product documentation][Product Documentation]
      #   to learn more about the product and see How-to Guides.
      # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
      #   to see the full list of Cloud APIs that we cover.
      #
      # [Product Documentation]: https://cloud.google.com/dialogflow
      #
      # ## Enabling Logging
      #
      # To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library.
      # The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as shown below,
      # or a [`Google::Cloud::Logging::Logger`](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest/google/cloud/logging/logger)
      # that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb)
      # and the gRPC [spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb) for additional information.
      #
      # Configuring a Ruby stdlib logger:
      #
      # ```ruby
      # require "logger"
      #
      # module MyLogger
      #   LOGGER = Logger.new $stderr, level: Logger::WARN
      #   def logger
      #     LOGGER
      #   end
      # end
      #
      # # Define a gRPC module-level logger method before grpc/logconfig.rb loads.
      # module GRPC
      #   extend MyLogger
      # end
      # ```
      #
      module V2
        # rubocop:enable LineLength

        module Agents
          ##
          # Agents are best described as Natural Language Understanding (NLU) modules
          # that transform user requests into actionable data. You can include agents
          # in your app, product, or service to determine user intent and respond to the
          # user in a natural way.
          #
          # After you create an agent, you can add {Google::Cloud::Dialogflow::V2::Intents Intents}, {Google::Cloud::Dialogflow::V2::Contexts Contexts},
          # {Google::Cloud::Dialogflow::V2::EntityTypes Entity Types}, {Google::Cloud::Dialogflow::V2::WebhookRequest Webhooks}, and so on to
          # manage the flow of a conversation and match user input to predefined intents
          # and actions.
          #
          # You can create an agent using both Dialogflow Standard Edition and
          # Dialogflow Enterprise Edition. For details, see
          # [Dialogflow Editions](https://cloud.google.com/dialogflow-enterprise/docs/editions).
          #
          # You can save your agent for backup or versioning by exporting the agent by
          # using the {Google::Cloud::Dialogflow::V2::Agents::ExportAgent ExportAgent} method. You can import a saved
          # agent by using the {Google::Cloud::Dialogflow::V2::Agents::ImportAgent ImportAgent} method.
          #
          # Dialogflow provides several
          # [prebuilt agents](https://dialogflow.com/docs/prebuilt-agents) for common
          # conversation scenarios such as determining a date and time, converting
          # currency, and so on.
          #
          # For more information about agents, see the
          # [Dialogflow documentation](https://dialogflow.com/docs/agents).
          #
          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: nil
            kwargs = {
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              metadata: metadata,
              exception_transformer: exception_transformer,
              lib_name: lib_name,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Dialogflow::V2::AgentsClient.new(**kwargs)
          end
        end

        module Contexts
          ##
          # A context represents additional information included with user input or with
          # an intent returned by the Dialogflow API. Contexts are helpful for
          # differentiating user input which may be vague or have a different meaning
          # depending on additional details from your application such as user setting
          # and preferences, previous user input, where the user is in your application,
          # geographic location, and so on.
          #
          # You can include contexts as input parameters of a
          # {Google::Cloud::Dialogflow::V2::Sessions::DetectIntent DetectIntent} (or
          # {Google::Cloud::Dialogflow::V2::Sessions::StreamingDetectIntent StreamingDetectIntent}) request,
          # or as output contexts included in the returned intent.
          # Contexts expire when an intent is matched, after the number of +DetectIntent+
          # requests specified by the +lifespan_count+ parameter, or after 10 minutes
          # if no intents are matched for a +DetectIntent+ request.
          #
          # For more information about contexts, see the
          # [Dialogflow documentation](https://dialogflow.com/docs/contexts).
          #
          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: nil
            kwargs = {
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              metadata: metadata,
              exception_transformer: exception_transformer,
              lib_name: lib_name,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Dialogflow::V2::ContextsClient.new(**kwargs)
          end
        end

        module EntityTypes
          ##
          # Entities are extracted from user input and represent parameters that are
          # meaningful to your application. For example, a date range, a proper name
          # such as a geographic location or landmark, and so on. Entities represent
          # actionable data for your application.
          #
          # When you define an entity, you can also include synonyms that all map to
          # that entity. For example, "soft drink", "soda", "pop", and so on.
          #
          # There are three types of entities:
          #
          # * **System** - entities that are defined by the Dialogflow API for common
          #   data types such as date, time, currency, and so on. A system entity is
          #   represented by the +EntityType+ type.
          #
          # * **Developer** - entities that are defined by you that represent
          #   actionable data that is meaningful to your application. For example,
          #   you could define a +pizza.sauce+ entity for red or white pizza sauce,
          #   a +pizza.cheese+ entity for the different types of cheese on a pizza,
          #   a +pizza.topping+ entity for different toppings, and so on. A developer
          #   entity is represented by the +EntityType+ type.
          #
          # * **User** - entities that are built for an individual user such as
          #   favorites, preferences, playlists, and so on. A user entity is
          #   represented by the {Google::Cloud::Dialogflow::V2::SessionEntityType SessionEntityType} type.
          #
          # For more information about entity types, see the
          # [Dialogflow documentation](https://dialogflow.com/docs/entities).
          #
          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: nil
            kwargs = {
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              metadata: metadata,
              exception_transformer: exception_transformer,
              lib_name: lib_name,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Dialogflow::V2::EntityTypesClient.new(**kwargs)
          end
        end

        module Intents
          ##
          # An intent represents a mapping between input from a user and an action to
          # be taken by your application. When you pass user input to the
          # {Google::Cloud::Dialogflow::V2::Sessions::DetectIntent DetectIntent} (or
          # {Google::Cloud::Dialogflow::V2::Sessions::StreamingDetectIntent StreamingDetectIntent}) method, the
          # Dialogflow API analyzes the input and searches
          # for a matching intent. If no match is found, the Dialogflow API returns a
          # fallback intent (+is_fallback+ = true).
          #
          # You can provide additional information for the Dialogflow API to use to
          # match user input to an intent by adding the following to your intent.
          #
          # * **Contexts** - provide additional context for intent analysis. For
          #   example, if an intent is related to an object in your application that
          #   plays music, you can provide a context to determine when to match the
          #   intent if the user input is “turn it off”.  You can include a context
          #   that matches the intent when there is previous user input of
          #   "play music", and not when there is previous user input of
          #   "turn on the light".
          #
          # * **Events** - allow for matching an intent by using an event name
          #   instead of user input. Your application can provide an event name and
          #   related parameters to the Dialogflow API to match an intent. For
          #   example, when your application starts, you can send a welcome event
          #   with a user name parameter to the Dialogflow API to match an intent with
          #   a personalized welcome message for the user.
          #
          # * **Training phrases** - provide examples of user input to train the
          #   Dialogflow API agent to better match intents.
          #
          # For more information about intents, see the
          # [Dialogflow documentation](https://dialogflow.com/docs/intents).
          #
          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: nil
            kwargs = {
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              metadata: metadata,
              exception_transformer: exception_transformer,
              lib_name: lib_name,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Dialogflow::V2::IntentsClient.new(**kwargs)
          end
        end

        module SessionEntityTypes
          ##
          # Entities are extracted from user input and represent parameters that are
          # meaningful to your application. For example, a date range, a proper name
          # such as a geographic location or landmark, and so on. Entities represent
          # actionable data for your application.
          #
          # Session entity types are referred to as **User** entity types and are
          # entities that are built for an individual user such as
          # favorites, preferences, playlists, and so on. You can redefine a session
          # entity type at the session level.
          #
          # For more information about entity types, see the
          # [Dialogflow documentation](https://dialogflow.com/docs/entities).
          #
          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: nil
            kwargs = {
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              metadata: metadata,
              exception_transformer: exception_transformer,
              lib_name: lib_name,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Dialogflow::V2::SessionEntityTypesClient.new(**kwargs)
          end
        end

        module Sessions
          ##
          # A session represents an interaction with a user. You retrieve user input
          # and pass it to the {Google::Cloud::Dialogflow::V2::Sessions::DetectIntent DetectIntent} (or
          # {Google::Cloud::Dialogflow::V2::Sessions::StreamingDetectIntent StreamingDetectIntent}) method to determine
          # user intent and respond.
          #
          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: nil
            kwargs = {
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              metadata: metadata,
              exception_transformer: exception_transformer,
              lib_name: lib_name,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Dialogflow::V2::SessionsClient.new(**kwargs)
          end
        end
      end
    end
  end
end
