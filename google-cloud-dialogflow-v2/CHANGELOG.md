# Release History

### 1.10.1 (2025-07-15)

#### Documentation

* Clarify documentation for cases when multiple parameters are mutually exclusive for an RPC method ([#30624](https://github.com/googleapis/google-cloud-ruby/issues/30624)) 

### 1.10.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 1.9.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 1.9.0 (2025-03-11)

#### Features

* Add new RPC IngestContextReferences, GenerateSuggestions ([#29300](https://github.com/googleapis/google-cloud-ruby/issues/29300)) 

### 1.8.0 (2025-03-05)

#### Features

* Support for ControlPoint 
* Support for conversation summarization agent assistant 
* Support for country code in a conversation phone number 
* Support for telephony connection information 
* Support for the audio_input parameter to analyze_content 
* The streaming_analyze_content RPC returns the name of the cloud speech model used for speech recognition 

### 1.7.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 1.6.0 (2025-01-08)

#### Features

* Support for delivering intermediate transcriptions through PubSub ([#28112](https://github.com/googleapis/google-cloud-ruby/issues/28112)) 

### 1.5.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 1.4.1 (2024-12-05)

#### Documentation

* various documentation and linking updates ([#27721](https://github.com/googleapis/google-cloud-ruby/issues/27721)) 

### 1.4.0 (2024-11-14)

#### Features

* add options of query_source, search_config, end_user_metadata and exact_search ([#27597](https://github.com/googleapis/google-cloud-ruby/issues/27597)) 
* expose metadata in AnswerSource 

### 1.3.0 (2024-11-13)

#### Features

* add options of query_source, search_config and context_size 
* added support for ALAW encoding 

### 1.2.0 (2024-09-30)

#### Features

* Support for PCMU/a-law 
* Support for Zone Isolation and Zone Separation compliance status 

### 1.1.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 1.1.0 (2024-08-05)

#### Features

* Add GenerateStatelessSuggestion related endpoints and types 
* Add Generator related services and types 
* Add Proactive Generative Knowledge Assist endpoints and types ([#26573](https://github.com/googleapis/google-cloud-ruby/issues/26573)) 
#### Bug Fixes

* Changed field behavior for an existing field `parent` in message `.google.cloud.dialogflow.v2.SearchKnowledgeRequest` 
* Changed field behavior for an existing field `session_id` in message `.google.cloud.dialogflow.v2.SearchKnowledgeRequest` 
#### Documentation

* A comment for field `assist_query_params` in message `.google.cloud.dialogflow.v2.SuggestConversationSummaryRequest` is changed 
* A comment for field `audio` in message `.google.cloud.dialogflow.v2.AudioInput` is changed 
* A comment for field `context_size` in message `.google.cloud.dialogflow.v2.SuggestConversationSummaryRequest` is changed 
* A comment for field `conversation_stage` in message `.google.cloud.dialogflow.v2.Conversation` is changed 
* A comment for field `conversation` in message `.google.cloud.dialogflow.v2.SearchKnowledgeRequest` is changed 
* A comment for field `filter` in message `.google.cloud.dialogflow.v2.ListConversationsRequest` is changed 
* A comment for field `latest_message` in message `.google.cloud.dialogflow.v2.GenerateStatelessSummaryRequest` is changed 
* A comment for field `latest_message` in message `.google.cloud.dialogflow.v2.SearchKnowledgeRequest` is changed 
* A comment for field `latest_message` in message `.google.cloud.dialogflow.v2.SuggestConversationSummaryRequest` is changed 
* A comment for field `live_person_config` in message `.google.cloud.dialogflow.v2.HumanAgentHandoffConfig` is changed 
* A comment for field `max_context_size` in message `.google.cloud.dialogflow.v2.GenerateStatelessSummaryRequest` is changed 
* A comment for field `name` in message `.google.cloud.dialogflow.v2.Conversation` is changed 
* A comment for field `parent` in message `.google.cloud.dialogflow.v2.SearchKnowledgeRequest` is changed 
* A comment for field `session_id` in message `.google.cloud.dialogflow.v2.SearchKnowledgeRequest` is changed 
* A comment for message `HumanAgentHandoffConfig` is changed 

### 1.0.0 (2024-07-08)

#### Features

* Bump version to 1.0.0 

### 0.34.0 (2024-03-14)

#### Features

* Support opt_out_conformer_model_migration field to InputAudioConfig ([#25371](https://github.com/googleapis/google-cloud-ruby/issues/25371)) 
* Support text_sections field to SummarizationFeedback ([#25371](https://github.com/googleapis/google-cloud-ruby/issues/25371)) 

### 0.33.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24869](https://github.com/googleapis/google-cloud-ruby/issues/24869)) 

### 0.32.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.32.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.32.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23778](https://github.com/googleapis/google-cloud-ruby/issues/23778)) 

### 0.31.0 (2024-01-03)

#### Features

* add enable_conversation_augmented_query field to HumanAgentAssistantConfig.SuggestionFeatureConfig message 
* add INTENT field in enum SearchKnowledgeAnswer.AnswerType message 
* add rewritten_query in field in SearchKnowledgeResponse message 
* add sections field to HumanAgentAssistantConfig.SuggestionQueryConfig ([#23669](https://github.com/googleapis/google-cloud-ruby/issues/23669)) 
#### Documentation

* improved comments on audio_config proto 

### 0.30.0 (2023-10-03)

#### Features

* add enable_extended_streaming for StreamingAnalyzeContentRequest 

### 0.29.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22919](https://github.com/googleapis/google-cloud-ruby/issues/22919)) 

### 0.28.0 (2023-09-05)

#### Features

* Support Search Knowledge ([#22865](https://github.com/googleapis/google-cloud-ruby/issues/22865)) 

### 0.27.0 (2023-08-15)

#### Features

* Query parameters no include the platform of virtual agent response messages 
* Support for the baseline model version used to generate a summary ([#22775](https://github.com/googleapis/google-cloud-ruby/issues/22775)) 

### 0.26.2 (2023-08-04)

#### Documentation

* Improve documentation format ([#22706](https://github.com/googleapis/google-cloud-ruby/issues/22706)) 

### 0.26.1 (2023-08-03)

#### Documentation

* Improve documentation format ([#22678](https://github.com/googleapis/google-cloud-ruby/issues/22678)) 

### 0.26.0 (2023-06-23)

#### Features

* support session_ttl for AutomatedAgentConfig 

### 0.25.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21674](https://github.com/googleapis/google-cloud-ruby/issues/21674)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.24.0 (2023-05-16)

#### Features

* add baseline model configuration for conversation summarization ([#21568](https://github.com/googleapis/google-cloud-ruby/issues/21568)) 

### 0.23.0 (2023-03-08)

#### Features

* Support REST transport ([#20626](https://github.com/googleapis/google-cloud-ruby/issues/20626)) 

### 0.22.0 (2023-02-17)

#### Features

* Support for text-to-speech configuration in ConversationProfile 
* Support for the assist_query_params argument to the suggest_conversation_summary RPC ([#20437](https://github.com/googleapis/google-cloud-ruby/issues/20437)) 

### 0.21.0 (2023-01-15)

#### Features

* Include a human eval template in ConversationModelEvaluation 
* Support for the suggest_conversation_summary RPC ([#20023](https://github.com/googleapis/google-cloud-ruby/issues/20023)) 
* Support summarization feedback in AgentAssistantFeedback 

### 0.20.0 (2022-12-09)

#### Features

* Added cx_current_page field to AutomatedAgentReply ([#19464](https://github.com/googleapis/google-cloud-ruby/issues/19464)) 

### 0.19.0 (2022-11-01)

#### Features

* Added obfuscated_external_user_id to Participant 
* Added support for the streaming_analyze_content call ([#19340](https://github.com/googleapis/google-cloud-ruby/issues/19340)) 
* Can directly set Cloud Speech model on the SpeechToTextConfig 

### 0.18.0 (2022-10-03)

#### Features

* Include the conversation dataset name with dataset creation metadata ([#19247](https://github.com/googleapis/google-cloud-ruby/issues/19247)) 

### 0.17.1 (2022-07-28)

#### Documentation

* Minor reference documentation updates ([#18866](https://github.com/googleapis/google-cloud-ruby/issues/18866)) 

### 0.17.0 (2022-07-02)

#### Features

* Added support for the locations mixin ([#18565](https://github.com/googleapis/google-cloud-ruby/issues/18565)) 
* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.16.0 (2022-05-09)

#### Features

* Support setting CX session parameters in the analyze_content call

### 0.15.2 / 2022-03-31

#### Documentation

* Clarify the use of SuggestionResult error fields

### 0.15.1 / 2022-03-09

#### Documentation

* update docs to clarify the permissions needed on Cloud storage object

### 0.15.0 / 2022-03-07

#### Features

* Add ConversationDataset and ConversationModel

### 0.14.0 / 2022-01-21

#### Features

* Add support for ConversationProcessConfig, ImportDocument and SuggestSmarReplies.

### 0.13.0 / 2022-01-11

#### Features

* Added support for the export_document call
* Added support for passing filters to the list_documents and list_knowledge_bases calls
* Added support for importing custom metadata from Google Cloud Storage in the reload_document call
* Added support for applying partial update to the smart messaging allowlist in the reload_document call

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Clarifications and formatting fixes in the reference documentation
* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.12.0 / 2021-12-07

#### Features

* Support for document metadata filters and human assist query parameters

### 0.11.5 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.11.4 / 2021-10-28

#### Documentation

* Clarify some of the reference documentation

### 0.11.3 / 2021-10-18

#### Documentation

* Recommend use of the analyze_content call over detect_intent

### 0.11.2 / 2021-09-07

#### Documentation

* Updated documentation for long-running calls

### 0.11.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

#### Documentation

* Document root_followup_intent_name and followup_intent_info fields of Intent as read-only

### 0.11.0 / 2021-08-05

#### Features

* Include the detected language code in StreamingRecognitionResult

### 0.10.1 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.10.0 / 2021-06-22

#### Features

* Provide a helper for agent version paths

### 0.9.0 / 2021-06-17

#### Features

* Added automated agent reply type, and allow cancellation flag for partial response feature
* Report whether a query cancels slot filling

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.8.1 / 2021-05-21

#### Documentation

* Document location-aware intent parent paths

### 0.8.0 / 2021-05-06

#### Features

* Support for management of fulfillments, environments, and versions

### 0.7.0 / 2021-04-06

#### Features

* Added clients for Contact Center AI
* Support for webhook headers
* Expose MP3_64_KBPS and MULAW for output audio encodings.
* Use self-signed JWT credentials when possible
* Drop support for Ruby 2.4 and add support for Ruby 3.0

#### Bug Fixes

* Allow special symbolic credentials in client configs
* Fix retry logic by checking the correct numeric error codes

#### Documentation

* Fixed references from SentimentAnalysisResult description
* Minor updates to some parameter descriptions
* Timeout config description correctly gives the units as seconds.
* Update session argument description in detect_intent
* Update tier names in OriginalDetectIntentRequest field descriptions

### 0.6.4 / 2020-06-25

#### Bug Fixes

* Updates to retry policies

### 0.6.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.6.2 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.6.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file
* The long-running operations client honors the quota_project config

### 0.6.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

#### Documentation

* Cover multiple audio fields in intent detection responses.

### 0.5.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.
* Fix markdown formatting in SpeechContext reference.

### 0.5.0 / 2020-04-23

#### Features

* Support the ListEnvironments call.

### 0.4.1 / 2020-04-22

#### Bug Fixes

* Operations client honors its main client's custom endpoint.

### 0.4.0 / 2020-04-13

#### Features

* Support additional path helpers, and other updates.
  * Added session_path helper for the Contexts and SessionEntityTypes services.
  * Added agent_path helper for the EntityTypes and Intents services.
  * Expanded the readme to include quickstart and logging information.
  * Added documentation for package and service modules.
  * Fixed and expanded documentation for the two method calling conventions.
  * Fixed some circular require warnings.

### 0.3.0 / 2020-04-06

#### Features

* Support additional formats for context, session, and session_entity_type paths.

### 0.2.2 / 2020-04-01

#### Documentation

* Update documentation for core proto types.

### 0.2.1 / 2020-03-28

#### Bug Fixes

* set correct endpoint for long-running operations client.

### 0.2.0 / 2020-03-25

#### Features

* Path helpers can be called as module functions

#### Documentation

* Expansion and cleanup of service description text

### 0.1.0 / 2020-03-17

Initial release.
