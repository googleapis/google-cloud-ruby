# Changelog

### 1.5.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 1.4.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 1.3.0 (2024-10-28)

#### Features

* add lite search API to allow public website search with API key ([#27495](https://github.com/googleapis/google-cloud-ruby/issues/27495)) 
* add LOW_GROUNDED_ANSWER in answer skip reasons 
* support query regex in control match rules 
#### Documentation

* keep the API doc up-to-date with recent changes 

### 1.2.0 (2024-10-15)

#### Features

* Support for generate_grounded_content and stream_generate_grounded_content RPCs 
* Support for setting a site credential in the recrawl_uris RPC 
* Support for setting the maximum number of OneBox results when searching 
#### Bug Fixes

* Fixed identityMappingStores resource URLs 

### 1.1.0 (2024-09-11)

#### Features

* Support for Document index status 
* Support for jail-breaking queries 
* Support for Reference#structured_document_info 
* Support for the batch_get_documents_metadata RPC 
* Support for the gcs_source, inline_source, and error_config parameters to the purge_documents RPC 
* Support for the purge_user_events RPC 
* Support for the SearchTuningService 
* Support for the skip_default_schema_creation parameter to the create_data_store RPC 
* Support for UnstructuredDocumentInfo::ChunkContent#relevance_score 

### 1.0.2 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 1.0.1 (2024-08-08)

#### Documentation

* Formatting updates to README.md ([#26627](https://github.com/googleapis/google-cloud-ruby/issues/26627)) 

### 1.0.0 (2024-07-10)

#### Features

* Bump version to 1.0.0 

### 0.9.0 (2024-07-08)

#### Features

* add Chunk resource in the search response ([#26276](https://github.com/googleapis/google-cloud-ruby/issues/26276)) 
* add NO_RELEVANT_CONTENT to Answer API 
* support AlloyDB Connector 
#### Documentation

* keep the API doc up-to-date with recent changes 

### 0.8.0 (2024-05-29)

#### Features

* add control service APIs 
* promote answer APIs to v1 GA 
* promote grounding check APIs to v1 GA 
* promote grounding check APIs to v1 GA ([#25966](https://github.com/googleapis/google-cloud-ruby/issues/25966)) 
* promote ranking APIs to v1 GA 
* support cancelling import operations 
* Support multiple parent patterns for controls ([#25973](https://github.com/googleapis/google-cloud-ruby/issues/25973)) 
* support writing user events for blended engines 
#### Documentation

* keep the API doc up-to-date with recent changes 

### 0.7.0 (2024-04-19)

#### Features

* Promote various services to v1 (e.g. recommendation, blending & healthcare search) ([#25673](https://github.com/googleapis/google-cloud-ruby/issues/25673)) 
* Support boosting on multi-turn searches 
* Support data import from Cloud Spanner, BigTable, SQL and Firestore 

### 0.6.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24869](https://github.com/googleapis/google-cloud-ruby/issues/24869)) 

### 0.5.0 (2024-02-12)

#### Features

* add engine support for multi-turn search and search APIs ([#24790](https://github.com/googleapis/google-cloud-ruby/issues/24790)) 
* add suggestion deny list import/purge APIs ([#24790](https://github.com/googleapis/google-cloud-ruby/issues/24790)) 
* support search summarization with citations and references ([#24790](https://github.com/googleapis/google-cloud-ruby/issues/24790)) 
#### Documentation

* keep the API doc up-to-date with recent changes ([#24790](https://github.com/googleapis/google-cloud-ruby/issues/24790)) 

### 0.4.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.4.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.4.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23778](https://github.com/googleapis/google-cloud-ruby/issues/23778)) 

### 0.3.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22919](https://github.com/googleapis/google-cloud-ruby/issues/22919)) 

### 0.2.0 (2023-09-05)

#### Features

* Support conversational / multi-turn search ([#22873](https://github.com/googleapis/google-cloud-ruby/issues/22873)) 

### 0.1.0 (2023-06-12)

#### Features

* Initial release of generated google-cloud-discovery_engine-v1 client ([#22239](https://github.com/googleapis/google-cloud-ruby/issues/22239))
