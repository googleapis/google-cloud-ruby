# Release History

### 0.4.0 / 2021-07-30

#### Features

* Significant new features involving search, autocomplete, inventory, fulfillment, and more
  * feat(retail-v2): Added a new SearchService client to support product search
  * feat(retail-v2): Added a new CompletionService client to support auto-completion
  * feat(retail-v2): Support for default branches in the CatalogService client
  * feat(retail-v2): Support for listing products using the ProductService client
  * feat(retail-v2): Support for managing inventory using the ProductService client
  * feat(retail-v2): Support for managing fulfillment places using the ProductService client
  * feat(retail-v2): Added partition date support to bigquery import
  * feat(retail-v2): Support user-provided identifiers and reconcilation mode when importing products
  * feat(retail-v2): Support pubsub notifications on import completion
  * feat(retail-v2): Support for many additional product properties, including TTL, variants, rating, and fulfillment info.
  * docs(retail-v2): Fixed some broken links and made other documentation updates

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
