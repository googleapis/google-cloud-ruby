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

require "google/cloud/dialogflow/v2/conversation_participant_pb"
require "google/cloud/dialogflow/v2/conversation_participants_client"


module Google
  module Cloud
    module Dialogflow
      module V2
        module Agents
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              service_address: nil,
              service_port: nil,
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
              service_address: service_address,
              service_port: service_port,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Dialogflow::V2::AgentsClient.new(**kwargs)
          end
        end

        module Contexts
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              service_address: nil,
              service_port: nil,
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
              service_address: service_address,
              service_port: service_port,
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
          #   represented by the `EntityType` type.
          #
          # * **Developer** - entities that are defined by you that represent
          #   actionable data that is meaningful to your application. For example,
          #   you could define a `pizza.sauce` entity for red or white pizza sauce,
          #   a `pizza.cheese` entity for the different types of cheese on a pizza,
          #   a `pizza.topping` entity for different toppings, and so on. A developer
          #   entity is represented by the `EntityType` type.
          #
          # * **User** - entities that are built for an individual user such as
          #   favorites, preferences, playlists, and so on. A user entity is
          #   represented by the {Google::Cloud::Dialogflow::V2::SessionEntityType SessionEntityType} type.
          #
          # For more information about entity types, see the
          # [Dialogflow
          # documentation](https://cloud.google.com/dialogflow/docs/entities-overview).
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
          # @param service_address [String]
          #   Override for the service hostname, or `nil` to leave as the default.
          # @param service_port [Integer]
          #   Override for the service port, or `nil` to leave as the default.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              service_address: nil,
              service_port: nil,
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
              service_address: service_address,
              service_port: service_port,
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
          # fallback intent (`is_fallback` = true).
          #
          # You can provide additional information for the Dialogflow API to use to
          # match user input to an intent by adding the following to your intent.
          #
          # * **Contexts** - provide additional context for intent analysis. For
          #   example, if an intent is related to an object in your application that
          #   plays music, you can provide a context to determine when to match the
          #   intent if the user input is "turn it off". You can include a context
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
          # [Dialogflow
          # documentation](https://cloud.google.com/dialogflow/docs/intents-overview).
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
          # @param service_address [String]
          #   Override for the service hostname, or `nil` to leave as the default.
          # @param service_port [Integer]
          #   Override for the service port, or `nil` to leave as the default.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              service_address: nil,
              service_port: nil,
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
              service_address: service_address,
              service_port: service_port,
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
          # Session entity methods do not work with Google Assistant integration.
          # Contact Dialogflow support if you need to use session entities
          # with Google Assistant integration.
          #
          # For more information about entity types, see the
          # [Dialogflow
          # documentation](https://cloud.google.com/dialogflow/docs/entities-overview).
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
          # @param service_address [String]
          #   Override for the service hostname, or `nil` to leave as the default.
          # @param service_port [Integer]
          #   Override for the service port, or `nil` to leave as the default.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              service_address: nil,
              service_port: nil,
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
              service_address: service_address,
              service_port: service_port,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Dialogflow::V2::SessionEntityTypesClient.new(**kwargs)
          end
        end

        module Sessions
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              service_address: nil,
              service_port: nil,
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
              service_address: service_address,
              service_port: service_port,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Dialogflow::V2::SessionsClient.new(**kwargs)
          end
        end

        module ConversationParticipants
          def self.new \
              credentials: nil,
              scopes: nil,
              client_config: nil,
              timeout: nil,
              metadata: nil,
              service_address: nil,
              service_port: nil,
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
              service_address: service_address,
              service_port: service_port,
              lib_version: lib_version
            }.select { |_, v| v != nil }
            Google::Cloud::Dialogflow::V2::ConversationParticipantsClient.new(**kwargs)
          end
        end
      end
    end
  end
end
