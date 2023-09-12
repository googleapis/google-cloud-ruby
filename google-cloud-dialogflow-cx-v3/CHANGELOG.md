# Changelog

### 0.21.0 (2023-09-12)

#### Features

* Support for AGENT_TRANSITION_ROUTE_GROUP resources 
* Support for Gen App Builder settings for agents 
* Support for get_generative_settings and update_generative_settings calls ([#22878](https://github.com/googleapis/google-cloud-ruby/issues/22878)) 
* Support for Knowledge Connector settings for flows and pages 
* Support for the description field of TransitionRoute 
* Support for the endpointing_timeout field of CloudConversationDebuggingInfo 
* Support for the knowledge_info_card field of ResponseMessage 
* Support for the retention_strategy field of SecuritySettings 
* Support for channel pool configuration ([#22919](https://github.com/googleapis/google-cloud-ruby/issues/22919)) 
#### Bug Fixes

* Fixed the namespace for ImportStrategy 

### 0.20.0 (2023-08-15)

#### Features

* added agent level route group ([#22764](https://github.com/googleapis/google-cloud-ruby/issues/22764)) 
* added flow import strategy 

### 0.19.0 (2023-07-11)

#### Features

* Support for specifying agent git integration settings 
* Support for specifying the git branch for export_agent and restore_agent ([#22512](https://github.com/googleapis/google-cloud-ruby/issues/22512)) 
* The response for export_agent provides the commit SHA 

### 0.18.0 (2023-06-20)

#### Features

* add include_bigquery_export_settings to ExportAgentRequest ([#22426](https://github.com/googleapis/google-cloud-ruby/issues/22426)) 

### 0.17.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21674](https://github.com/googleapis/google-cloud-ruby/issues/21674)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.16.0 (2023-05-09)

#### Features

* add debug info to StreamingDetectIntent 
* add dtmf digits to WebhookRequest 
* add FLOW as a new DiffType in TestRunDifference 
* extended CreateAgent timeout to 180 seconds 
* extended CreateAgent timeout to 180 seconds ([#21559](https://github.com/googleapis/google-cloud-ruby/issues/21559)) 

### 0.15.1 (2023-03-15)

#### Documentation

* Update quota usage information ([#20894](https://github.com/googleapis/google-cloud-ruby/issues/20894)) 

### 0.15.0 (2023-03-08)

#### Features

* Support REST transport ([#20626](https://github.com/googleapis/google-cloud-ruby/issues/20626)) 

### 0.14.0 (2023-02-28)

#### Features

* Support the persist_parameter_changes parameter to match_intent ([#20546](https://github.com/googleapis/google-cloud-ruby/issues/20546)) 

### 0.13.0 (2023-02-23)

#### Features

* Support for audio export destination in Google Cloud Storage ([#20493](https://github.com/googleapis/google-cloud-ruby/issues/20493)) 
* Support for text-to-speech settings for an Agent 

### 0.12.0 (2023-01-26)

#### Features

* Added JSON_PACKAGE data format for ExportAgentRequest ([#20065](https://github.com/googleapis/google-cloud-ruby/issues/20065)) 

### 0.11.0 (2023-01-15)

#### Features

* Include channel information in ResponseMessage ([#20014](https://github.com/googleapis/google-cloud-ruby/issues/20014)) 
* Specify channel in query parameters 

### 0.10.2 (2022-10-24)

#### Documentation

* Clarified TTL as time-to-live ([#19334](https://github.com/googleapis/google-cloud-ruby/issues/19334)) 

### 0.10.1 (2022-10-03)

#### Documentation

* Update SecuritySettings#gcs_bucket description ([#19244](https://github.com/googleapis/google-cloud-ruby/issues/19244)) 

### 0.10.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 
#### Documentation

* Clarify several field descriptions 

### 0.9.0 (2022-06-15)

#### Features

* Added support for the location mixin client
* Added support for webhook configuration

### 0.8.1 (2022-05-09)

#### Documentation

* Expand  documentation for diagnostic_info

### 0.8.0 (2022-04-28)

#### Features

* Support audio export settings

### 0.7.1 (2022-04-19)

#### Bug Fixes

* Remove unused requires
#### Documentation

* fix typos and add reference for Fulfilment tag

### 0.7.0 / 2022-03-30

#### Features

* Support for locking an agent for changes and setting the data format of an exported agent

#### Documentation

* Change documentation format

### 0.6.0 / 2022-03-09

#### Features

* provide option to add page in test config

### 0.5.0 / 2022-01-11

#### Features

* Added the display name of the current page in webhook requests

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.4.0 / 2021-12-07

#### Features

* Inform the client when a phone call should be transferred to a third-party endpoint
* Support for the compare_versions call

### 0.3.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.3.0 / 2021-10-21

#### Features

* Added support for changelogs

### 0.2.0 / 2021-10-18

#### Features

* Support for the deployment API

### 0.1.1 / 2021-08-30

#### Documentation

* Updated documentation for long-running calls

### 0.1.0 / 2021-08-23

#### Features

* Initial generation of google-cloud-dialogflow-cx-v3
