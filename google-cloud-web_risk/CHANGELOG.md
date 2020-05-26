# Release History

### 1.1.1 / 2020-05-24

#### Documentation

* Cover exception changes in the migration guide

### 1.1.0 / 2020-05-21

#### Features

* The endpoint, scope, and quota_project can be set via configuration

### 1.0.0 / 2020-05-07

This is a major update over the older google-cloud-webrisk gem, with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Support for version V1 of the service.
* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.
* More consistent spelling of module names.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from google-cloud-webrisk.
