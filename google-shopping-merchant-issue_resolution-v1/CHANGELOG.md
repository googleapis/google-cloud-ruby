# Changelog

### 0.3.0 (2025-11-19)

#### Features

* Added `VERIFY_BUSINESS_VIDEO_IN_MERCHANT_CENTER` as a new enum value to `ExternalAction.Type`. This supports redirecting to Merchant Center for business video verification 
* Added the `product_id_base64_url_encoded` field to `RenderProductIssuesRequest`. This allows for product IDs containing special characters to be correctly handled when unpadded base64url-encoded ([#32170](https://github.com/googleapis/google-cloud-ruby/issues/32170)) 
#### Bug Fixes

* removing parameters before stable release ([#32199](https://github.com/googleapis/google-cloud-ruby/issues/32199)) 

### 0.2.1 (2025-10-27)

#### Documentation

* add warning about loading unvalidated credentials 

### 0.2.0 (2025-09-11)

#### Features

* update gapic-common dependency for generated libraries to 1.2 which requires google-protobuf v4.26+ ([#31009](https://github.com/googleapis/google-cloud-ruby/issues/31009)) 

### 0.1.1 (2025-08-15)

#### Documentation

* Fixed an API documentation link ([#30828](https://github.com/googleapis/google-cloud-ruby/issues/30828)) 

### 0.1.0 (2025-08-07)

#### Features

* Initial generation of google-shopping-merchant-issue_resolution-v1 ([#30770](https://github.com/googleapis/google-cloud-ruby/issues/30770)) 

## Release History
