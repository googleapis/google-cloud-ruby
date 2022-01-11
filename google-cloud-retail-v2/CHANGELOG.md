# Release History

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
