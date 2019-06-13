# Release History

### 1.0.1 / 2019-06-11

* Add VERSION constant

### 1.0.0 / 2019-05-24

* GA release
* Remove Queue#log_sampling_ratio (Breaking change)
* Add Queue#stackdriver_logging_config
* Add StackdriverLoggingConfig
* Update IAM:
  * Deprecate Policy#version
  * Add Binding#condition
  * Add Google::Type::Expr

### 0.7.1 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update documentation for common types.

### 0.7.0 / 2019-04-15

* Add Queue#log_sampling_ratio
* Add HttpRequest#authorization_header
* Add HttpRequest#oauth_token
* Add HttpRequest#oidc_token
* Add OAuthToken
* Add OidcToken
* Update generated documentation

### 0.6.0 / 2019-03-28

* Add v2 api version

### 0.5.0 / 2019-03-20

* Alias the following CloudTasksClient class methods to instance methods.
  * location_path
  * project_path
  * queue_path
  * task_path

### 0.4.0 / 2019-03-12

* Add HTTP Request to V2beta3
  * Add Task#http_request
  * Add HttpMethod
* Update documentation

### 0.3.0 / 2019-02-01

* Add Task#dispatch_deadline attribute.
* Add HttpMethod::PATCH and HttpMethod::OPTIONS enumerated values.
* Update documentation.

### 0.2.6 / 2018-11-15

* Update network configuration.

### 0.2.5 / 2018-10-18

* Release v2beta3.

### 0.2.4 / 2018-09-20

* Update documentation.
* Change documentation URL to googleapis GitHub org.

### 0.2.3 / 2018-09-10

* Update documentation.

### 0.2.2 / 2018-08-21

* Update documentation.

### 0.2.1 / 2018-07-05

* Update google-gax dependency to version 1.3.

### 0.2.0 / 2018-06-28

* Add constructor arguments.
* Update documentation.

### 0.1.0 / 2018-05-29

* Initial release
