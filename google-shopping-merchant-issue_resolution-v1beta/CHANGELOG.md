# Changelog

### 0.4.0 (2025-11-19)

#### Features

* Added `VERIFY_BUSINESS_VIDEO_IN_MERCHANT_CENTER` as a new enum value to `ExternalAction.Type`. This supports redirecting to Merchant Center for business video verification 
* Added the `product_id_base64_url_encoded` field to `RenderProductIssuesRequest`. This allows for product IDs containing special characters to be correctly handled when unpadded base64url-encoded ([#32168](https://github.com/googleapis/google-cloud-ruby/issues/32168)) 
#### Bug Fixes

* removing parameters before stable version ([#32198](https://github.com/googleapis/google-cloud-ruby/issues/32198)) 

### 0.3.1 (2025-10-27)

#### Documentation

* add warning about loading unvalidated credentials 

### 0.3.0 (2025-09-11)

#### Features

* update gapic-common dependency for generated libraries to 1.2 which requires google-protobuf v4.26+ ([#31009](https://github.com/googleapis/google-cloud-ruby/issues/31009)) 

### 0.2.0 (2025-06-24)

#### Features

* Support for the list_aggregate_product_statuses RPC ([#30501](https://github.com/googleapis/google-cloud-ruby/issues/30501)) 

### 0.1.0 (2025-05-27)

#### Features

* Initial generation of google-shopping-merchant-issue_resolution-v1beta ([#30438](https://github.com/googleapis/google-cloud-ruby/issues/30438)) 

## Release History
