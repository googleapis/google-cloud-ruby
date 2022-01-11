# Release History

### 1.3.4 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.3.3 / 2021-08-24

#### Documentation

* Updated gem description to clarify this client is for Dialogflow ES

### 1.3.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.3.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.3.0 / 2021-05-19

#### Features

* Support for management of fulfillments, environments, and versions

### 1.2.0 / 2021-03-08

#### Features

* Added clients for Contact Center AI
* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.1.3 / 2021-02-02

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.1.2 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.1.1 / 2020-05-26

#### Documentation

* Cover exception changes in the migration guide

### 1.1.0 / 2020-05-20

#### Features

* The endpoint, scope, and quota_project can be set via configuration

### 1.0.0 / 2020-05-06

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.
* An expanded, standardized streaming interface.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.15.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.14.0 / 2020-03-02

#### Features

* Add AgentsClient#get_validation_result (ValidationResult)
  * Add DetectIntentRequest#output_audio_config_mask (FieldMask)
  * Add StreamingDetectIntentRequest#output_audio_config_mask (FieldMask)

### 0.13.0 / 2020-02-10

#### ⚠ BREAKING CHANGES

* Change language_code from a required positional argument to an optional keyword argument

### 0.12.3 / 2020-02-06

#### Documentation

* Update audio_encoding description

### 0.12.2 / 2020-02-04

#### Documentation

* Update documentation

### 0.12.1 / 2020-01-23

#### Documentation

* Update copyright year
* Update entity documentation
* Update Status documentation

### 0.12.0 / 2019-12-20

#### Features

* Add attributes to InputAudioConfig and StreamingRecognitionResult
  * Add InputAudioConfig#enable_word_info
  * Add InputAudioConfig#speech_contexts (SpeechContext)
  * Add InputAudioConfig#model
  * Add StreamingRecognitionResult#speech_word_info (SpeechWordInfo)
  * Add StreamingRecognitionResult#speech_end_offset
  * Update documentation

### 0.11.1 / 2019-11-19

#### Documentation

* Update OutputAudioEncoding documentation

### 0.11.0 / 2019-11-12

#### Features

* Add new card types to the intent
  * Add Intent#browse_carousel_card to support a browse carousel
  * Add Intent#table_card to support a Table card for Actions on
  * Add Intent#media_content to support the media content card

### 0.10.0 / 2019-11-06

#### Features

* Add ListSelect#subtitle

#### Bug Fixes

* Update minimum runtime dependencies

#### Documentation

* Update Intent#priority documentation

### 0.9.0 / 2019-10-29

This release require Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.8.0 / 2019-10-15

#### Features

* WebhookResponse includes the session_entity_types field

#### Performance Improvements

* Update timeouts for detect_indent

### 0.7.0 / 2019-10-01

#### Features

* Support for fuzzy extraction
  * Add EntityType#enable_fuzzy_extraction
  * Add Kind::KIND_REGEXP
* Documentation updates

### 0.6.0 / 2019-08-23

#### Features

* Add InputAudioConfig#single_utterance

#### Documentation

* Update documentation

### 0.5.0 / 2019-07-08

* Add AgentsClient#set_agent and AgentsClient#delete_agent 
* Add Agent#api_version and Agent#tier
* Update documentation and product links
* Support overriding service host and port.

### 0.4.0 / 2019-06-12

* Add SpeechModelVariant
* Add InputAudioConfig#model_variant
* Add Intent::Message::Platform::GOOGLE_HANGOUTS
* Add VERSION constant

### 0.3.0 / 2019-04-29

* Client changes:
  * SessionsClient#detect_intent adds output_audio_config named argument
  * DetectIntentRequest adds #output_audio_config
  * DetectIntentResponse adds #output_audio and #output_audio_config
  * QueryParameters adds #sentiment_analysis_request_config
  * QueryResult adds #sentiment_analysis_result
* Resource changes
  * DetectIntentResponse#output_audio is added
  * OutputAudioConfig is added
  * Sentiment is added
  * SentimentAnalysisResult is added
  * SentimentAnalysisRequestConfig is added
* Generated documentation updates
* Add AUTHENTICATION.md guide.
* Update generated documentation.
* Update generated code examples.
* Extract gRPC header values from request.

### 0.2.3 / 2018-11-15

* Update network configuration.

### 0.2.2 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.2.1 / 2018-09-10

* Update documentation.

### 0.2.0 / 2018-08-21

* Move Credentials location:
  * Add Google::Cloud::Dialogflow::V2::Credentials
  * Remove Google::Cloud::Dialogflow::Credentials
* Update dependencies.
* Update documentation.

### 0.1.0 / 2018-04-16

* Initial release
