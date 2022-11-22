# Release History

### 0.11.0 (2022-08-24)

#### Features

* Support adding and removing controls for serving configs 
* Support adding, removing, and replacing of catalog attributes 
* Support CRUD operations on control resources 
* Support CRUD operations on serving configs 
* Support getting and updating of attributes config 
* Support getting and updating of completion config ([#19051](https://github.com/googleapis/google-cloud-ruby/issues/19051)) 

### 0.10.0 (2022-08-03)

#### Features

* support case insensitive match and min max in facets search 

### 0.9.0 (2022-07-07)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.8.0 (2022-06-08)

#### Features

* Support for configuring spell correction in search requests
* Support for searching by label

### 0.7.0 / 2022-03-30

#### Features

* Support for adding and removing local inventories
* Support for fulfillment types and other attributes in local inventory
* Support for force-switching default branches
* Support for setting personalization spec when searching
* Deprecated the request ID when importing products, as the field no longer has any effect
* Return the applied controls and invalid condition boost specs with search results

### 0.6.4 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.6.3 / 2021-12-07

#### Bug Fixes

* Update the timeout for import_user_events

### 0.6.2 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.6.1 / 2021-11-02

#### Documentation

* Formatting fixes in the reference documentation

### 0.6.0 / 2021-10-21

#### Features

* Support for limiting searches to either product or faceted search

#### Documentation

* Some documentation formatting fixes

### 0.5.1 / 2021-08-26

#### Bug Fixes

* Adjusted timeout settings

### 0.5.0 / 2021-08-23

#### Features

* Support for pinned search results

### 0.4.2 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.4.1 / 2021-08-05

#### Documentation

* Various formatting fixes

### 0.4.0 / 2021-07-30

#### Features

* Added a new SearchService client to support product search
* Added a new CompletionService client to support auto-completion
* Support for default branches in the CatalogService client
* Support for listing products using the ProductService client
* Support for managing inventory using the ProductService client
* Support for managing fulfillment places using the ProductService client
* Added partition date support to bigquery import
* Support user-provided identifiers and reconcilation mode when importing products
* Support pubsub notifications on import completion
* Support for many additional product properties, including TTL, variants, rating, and fulfillment info.

#### Documentation

* Fixed some broken links
* Additional documentation updates

### 0.3.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.3.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.3.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.2.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.1.2 / 2021-01-26

#### Documentation

* Fixed some broken links and formatting of resource names

### 0.1.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.0 / 2021-01-12

Initial release.
