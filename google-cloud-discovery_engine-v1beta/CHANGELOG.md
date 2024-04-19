# Changelog

### 0.11.0 (2024-04-19)

#### Features

* Support advanced search boosting and advanced engine model 
* Support answer generation API 
* Support data import from Cloud Spanner, BigTable, SQL and Firestore ([#25671](https://github.com/googleapis/google-cloud-ruby/issues/25671)) 
* Support standalone grounding and standalone ranking 

### 0.10.0 (2024-03-18)

#### Features

* add document processing config services ([#25354](https://github.com/googleapis/google-cloud-ruby/issues/25354)) 
* add search tuning services ([#25354](https://github.com/googleapis/google-cloud-ruby/issues/25354)) 
* allow setting schema on schema creation ([#25354](https://github.com/googleapis/google-cloud-ruby/issues/25354)) 
* support boost in multi-turn search ([#25354](https://github.com/googleapis/google-cloud-ruby/issues/25354)) 
#### Documentation

* keep the API doc up-to-date with recent changes ([#25354](https://github.com/googleapis/google-cloud-ruby/issues/25354)) 

### 0.9.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24869](https://github.com/googleapis/google-cloud-ruby/issues/24869)) 

### 0.8.0 (2024-02-10)

#### Features

* add engine support for multi-turn search and search APIs ([#24790](https://github.com/googleapis/google-cloud-ruby/issues/24790)) 
* add suggestion deny list import/purge APIs ([#24790](https://github.com/googleapis/google-cloud-ruby/issues/24790)) 
* support search summarization with citations and references ([#24790](https://github.com/googleapis/google-cloud-ruby/issues/24790)) 
#### Documentation

* keep the API doc up-to-date with recent changes ([#24790](https://github.com/googleapis/google-cloud-ruby/issues/24790)) 

### 0.7.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.7.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.7.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23778](https://github.com/googleapis/google-cloud-ruby/issues/23778)) 

### 0.6.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22919](https://github.com/googleapis/google-cloud-ruby/issues/22919)) 

### 0.5.0 (2023-09-07)

#### Features

* Support embedding_spec field in search request ([#22869](https://github.com/googleapis/google-cloud-ruby/issues/22869)) 
* Support Local Client ([#22869](https://github.com/googleapis/google-cloud-ruby/issues/22869)) 
* Support user_labels in converse conversations ([#22869](https://github.com/googleapis/google-cloud-ruby/issues/22869)) 

### 0.4.0 (2023-07-28)

#### Features

* add include_tail_suggestions to query 
* support conversational search service 

### 0.3.0 (2023-06-20)

#### Features

* support extractive content in search 

### 0.2.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 
#### Documentation

* Fixed the product documentation link ([#22071](https://github.com/googleapis/google-cloud-ruby/issues/22071)) 

### 0.2.0 (2023-05-31)

#### Features

* Support for auto_generate_ids and id_field when importing documents ([#21684](https://github.com/googleapis/google-cloud-ruby/issues/21684)) 
* Uses binary protobuf definitions for better forward compatibility 
#### Bug Fixes

* Fixes to HTTP bindings 

### 0.1.0 (2023-05-23)

#### Features

* Initial generation of google-cloud-discovery_engine-v1beta
