# Copyright 2020 Google LLC
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

require "google-cloud-dialogflow"

module Google
  module Cloud
    ##
    # # Ruby Client for Dialogflow API
    #
    module Dialogflow
      ##
      # Create a new `Agents::Client` object.
      #
      # Agents are best described as Natural Language Understanding (NLU) modules
      # that transform user requests into actionable data. You can include agents
      # in your app, product, or service to determine user intent and respond to the
      # user in a natural way.
      #
      # After you create an agent, you can add Intents, Contexts, Entity Types,
      # Webhooks, and so on to manage the flow of a conversation and match user
      # input to predefined intents and actions.
      #
      # You can create an agent using both Dialogflow Standard Edition and
      # Dialogflow Enterprise Edition. For details, see
      # [Dialogflow Editions](https://cloud.google.com/dialogflow/docs/editions).
      #
      # You can save your agent for backup or versioning by exporting the agent by
      # using the `export_agent` method. You can import a saved
      # agent by using the `import_agent` method.
      #
      # Dialogflow provides several
      # [prebuilt agents](https://cloud.google.com/dialogflow/docs/agents-prebuilt)
      # for common conversation scenarios such as determining a date and time,
      # converting currency, and so on.
      #
      # For more information about agents, see the
      # [Dialogflow documentation](https://cloud.google.com/dialogflow/docs/agents-overview).
      #
      # @param version [String, Symbol] The API version to create the client instance.
      #   Optional. If not provided defaults to `:v2`, which will return an instance of
      #   [Google::Cloud::Dialogflow::V2::Agents::Client](https://googleapis.dev/ruby/google-cloud-dialogflow-v2/latest/Google/Cloud/Dialogflow/V2/Agents/Client.html).
      #
      # @return [Agents::Client] A client object for the specified version.
      #
      def self.agents version: :v2, &block
        require "google/cloud/dialogflow/#{version.to_s.downcase}"

        package_name = Google::Cloud::Dialogflow
                       .constants
                       .select { |sym| sym.to_s.downcase == version.to_s.downcase.tr("_", "") }
                       .first
        package_module = Google::Cloud::Dialogflow.const_get package_name
        package_module.const_get(:Agents).const_get(:Client).new(&block)
      end

      ##
      # Create a new `Contexts::Client` object.
      #
      # A context represents additional information included with user input or with
      # an intent returned by the Dialogflow API. Contexts are helpful for
      # differentiating user input which may be vague or have a different meaning
      # depending on additional details from your application such as user setting
      # and preferences, previous user input, where the user is in your application,
      # geographic location, and so on.
      #
      # You can include contexts as input parameters of a `DetectIntent` (or
      # `StreamingDetectIntent`) request, or as output contexts included in the returned intent.
      # Contexts expire when an intent is matched, after the number of `DetectIntent`
      # requests specified by the `lifespan_count` parameter, or after 20 minutes
      # if no intents are matched for a `DetectIntent` request.
      #
      # For more information about contexts, see the
      # [Dialogflow documentation](https://cloud.google.com/dialogflow/docs/contexts-overview).
      #
      # @param version [String, Symbol] The API version to create the client instance.
      #   Optional. If not provided defaults to `:v2`, which will return an instance of
      #   [Google::Cloud::Dialogflow::V2::Contexts::Client](https://googleapis.dev/ruby/google-cloud-dialogflow-v2/latest/Google/Cloud/Dialogflow/V2/Contexts/Client.html).
      #
      # @return [Contexts::Client] A client object for the specified version.
      #
      def self.contexts version: :v2, &block
        require "google/cloud/dialogflow/#{version.to_s.downcase}"

        package_name = Google::Cloud::Dialogflow
                       .constants
                       .select { |sym| sym.to_s.downcase == version.to_s.downcase.tr("_", "") }
                       .first
        package_module = Google::Cloud::Dialogflow.const_get package_name
        package_module.const_get(:Contexts).const_get(:Client).new(&block)
      end

      ##
      # Create a new `EntityTypes::Client` object.
      #
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
      # * **Custom** - entities that are defined by you that represent
      #   actionable data that is meaningful to your application. For example,
      #   you could define a `pizza.sauce` entity for red or white pizza sauce,
      #   a `pizza.cheese` entity for the different types of cheese on a pizza,
      #   a `pizza.topping` entity for different toppings, and so on. A custom
      #   entity is represented by the `EntityType` type.
      #
      # * **User** - entities that are built for an individual user such as
      #   favorites, preferences, playlists, and so on. A user entity is
      #   represented by the `SessionEntityType` type.
      #
      # For more information about entity types, see the
      # [Dialogflow documentation](https://cloud.google.com/dialogflow/docs/entities-overview).
      #
      # @param version [String, Symbol] The API version to create the client instance.
      #   Optional. If not provided defaults to `:v2`, which will return an instance of
      #   [Google::Cloud::Dialogflow::V2::EntityTypes::Client](https://googleapis.dev/ruby/google-cloud-dialogflow-v2/latest/Google/Cloud/Dialogflow/V2/EntityTypes/Client.html).
      #
      # @return [EntityTypes::Client] A client object for the specified version.
      #
      def self.entity_types version: :v2, &block
        require "google/cloud/dialogflow/#{version.to_s.downcase}"

        package_name = Google::Cloud::Dialogflow
                       .constants
                       .select { |sym| sym.to_s.downcase == version.to_s.downcase.tr("_", "") }
                       .first
        package_module = Google::Cloud::Dialogflow.const_get package_name
        package_module.const_get(:EntityTypes).const_get(:Client).new(&block)
      end

      ##
      # Create a new `Intents::Client` object.
      #
      # An intent represents a mapping between input from a user and an action to
      # be taken by your application. When you pass user input to the `DetectIntent`
      # (or `StreamingDetectIntent`) method, the Dialogflow API analyzes the input and
      # searches for a matching intent. If no match is found, the Dialogflow API returns
      # a fallback intent (`is_fallback` = true).
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
      # [Dialogflow documentation](https://cloud.google.com/dialogflow/docs/intents-overview).
      #
      # @param version [String, Symbol] The API version to create the client instance.
      #   Optional. If not provided defaults to `:v2`, which will return an instance of
      #   [Google::Cloud::Dialogflow::V2::Intents::Client](https://googleapis.dev/ruby/google-cloud-dialogflow-v2/latest/Google/Cloud/Dialogflow/V2/Intents/Client.html).
      #
      # @return [Intents::Client] A client object for the specified version.
      #
      def self.intents version: :v2, &block
        require "google/cloud/dialogflow/#{version.to_s.downcase}"

        package_name = Google::Cloud::Dialogflow
                       .constants
                       .select { |sym| sym.to_s.downcase == version.to_s.downcase.tr("_", "") }
                       .first
        package_module = Google::Cloud::Dialogflow.const_get package_name
        package_module.const_get(:Intents).const_get(:Client).new(&block)
      end

      ##
      # Create a new `SessionEntityTypes::Client` object.
      #
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
      # [Dialogflow documentation](https://cloud.google.com/dialogflow/docs/entities-overview).
      #
      # @param version [String, Symbol] The API version to create the client instance.
      #   Optional. If not provided defaults to `:v2`, which will return an instance of
      #   [Google::Cloud::Dialogflow::V2::SessionEntityTypes::Client](https://googleapis.dev/ruby/google-cloud-dialogflow-v2/latest/Google/Cloud/Dialogflow/V2/SessionEntityTypes/Client.html).
      #
      # @return [SessionEntityTypes::Client] A client object for the specified version.
      #
      def self.session_entity_types version: :v2, &block
        require "google/cloud/dialogflow/#{version.to_s.downcase}"

        package_name = Google::Cloud::Dialogflow
                       .constants
                       .select { |sym| sym.to_s.downcase == version.to_s.downcase.tr("_", "") }
                       .first
        package_module = Google::Cloud::Dialogflow.const_get package_name
        package_module.const_get(:SessionEntityTypes).const_get(:Client).new(&block)
      end

      ##
      # Create a new `Sessions::Client` object.
      #
      # A session represents an interaction with a user. You retrieve user input
      # and pass it to the `DetectIntent` (or `StreamingDetectIntent`) method to determine
      # user intent and respond.
      #
      # @param version [String, Symbol] The API version to create the client instance.
      #   Optional. If not provided defaults to `:v2`, which will return an instance of
      #   [Google::Cloud::Dialogflow::V2::Sessions::Client](https://googleapis.dev/ruby/google-cloud-dialogflow-v2/latest/Google/Cloud/Dialogflow/V2/Sessions/Client.html).
      #
      # @return [Sessions::Client] A client object for the specified version.
      #
      def self.sessions version: :v2, &block
        require "google/cloud/dialogflow/#{version.to_s.downcase}"

        package_name = Google::Cloud::Dialogflow
                       .constants
                       .select { |sym| sym.to_s.downcase == version.to_s.downcase.tr("_", "") }
                       .first
        package_module = Google::Cloud::Dialogflow.const_get package_name
        package_module.const_get(:Sessions).const_get(:Client).new(&block)
      end

      ##
      # Configure the dialogflow library.
      #
      # The following configuration parameters are supported:
      #
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to the keyfile as a String, the contents of
      #   the keyfile as a Hash, or a Google::Auth::Credentials object.
      # * `lib_name` (String)
      # * `lib_version` (String)
      # * `interceptors` (Array)
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `metadata` (Hash)
      # * `retry_policy` (Hash, Proc)
      #
      # @return [Google::Cloud::Config] The configuration object the Google::Cloud::Dialogflow library uses.
      #
      def self.configure
        yield Google::Cloud.configure.dialogflow if block_given?

        Google::Cloud.configure.dialogflow
      end
    end
  end
end
