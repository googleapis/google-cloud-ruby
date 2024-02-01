# Changelog

### 0.6.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.6.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.6.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23774](https://github.com/googleapis/google-cloud-ruby/issues/23774)) 

### 0.5.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22917](https://github.com/googleapis/google-cloud-ruby/issues/22917)) 

### 0.4.1 (2023-08-04)

#### Documentation

* Improve documentation format ([#22684](https://github.com/googleapis/google-cloud-ruby/issues/22684)) 

### 0.4.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21672](https://github.com/googleapis/google-cloud-ruby/issues/21672)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.3.0 (2022-09-01)

#### Features

* Added bigquery_dataset to the Listing type 
* Include locations client ([#19096](https://github.com/googleapis/google-cloud-ruby/issues/19096)) 

#### Bug Fixes

* BREAKING CHANGE: Renamed Google::Cloud::Bigquery::DataExchange::Common::Category type to Google::Cloud::Bigquery::DataExchange::V1beta1::Listing::Category 

### 0.2.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.1.0 (2022-05-22)

#### Features

* Initial generation of google-cloud-bigquery-data_exchange-v1beta1
