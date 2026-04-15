# Changelog

### 0.6.0 (2026-04-14)

#### Features

* a new field `base64_encoded_name` is added to the `Product` message ([#33819](https://github.com/googleapis/google-cloud-ruby/issues/33819)) 

### 0.5.1 (2026-04-08)

#### Documentation

* update SelectiveGapicGeneration usage doc ([#33485](https://github.com/googleapis/google-cloud-ruby/issues/33485)) 

### 0.5.0 (2026-03-31)

#### Features

* Upgrade dependencies for Ruby v4.0 and drop Ruby v3.1 support
* update products_common fields to include `handling_cutoff_timezone `, `shipping_handling_business_days`, `shipping_transit_business_days` 
* upgrade protobuf from v25.7 to v31.0 ([#32822](https://github.com/googleapis/google-cloud-ruby/issues/32822)) 
#### Documentation

* comment for messages for products_common are changed 

### 0.4.1 (2025-11-19)

#### Bug Fixes

* removing parameters before stable release ([#32200](https://github.com/googleapis/google-cloud-ruby/issues/32200)) 

### 0.4.0 (2025-11-12)

#### Features

* Added several fields to enhance shipping configurations: 
* Added the `product_id_base64_url_encoded` field to `InsertProductInputRequest`, `DeleteProductInputRequest`, and `GetProductRequest`. This allows for product IDs containing special characters to be correctly handled when unpadded base64url-encoded ([#32177](https://github.com/googleapis/google-cloud-ruby/issues/32177)) 

### 0.3.1 (2025-10-27)

#### Documentation

* add warning about loading unvalidated credentials 

### 0.3.0 (2025-10-07)

#### Features

* Include CarrierShipping field inside the Products attribute ([#31573](https://github.com/googleapis/google-cloud-ruby/issues/31573)) 

### 0.2.0 (2025-09-11)

#### Features

* update gapic-common dependency for generated libraries to 1.2 which requires google-protobuf v4.26+ ([#31009](https://github.com/googleapis/google-cloud-ruby/issues/31009)) 

### 0.1.0 (2025-08-07)

#### Features

* Initial generation of google-shopping-merchant-products-v1 ([#30769](https://github.com/googleapis/google-cloud-ruby/issues/30769)) 

## Release History
