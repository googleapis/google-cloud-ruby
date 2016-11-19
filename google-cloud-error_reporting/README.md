Stackdriver Clouderrorreporting API for Ruby
=================================================

google-cloud-error_reporting uses [Google API extensions][google-gax] to provide an
easy-to-use client library for the [Stackdriver Clouderrorreporting API][] (v1beta1) defined in the [googleapis][] git repository


[googleapis]: https://github.com/googleapis/googleapis/tree/master/google/google/devtools/clouderrorreporting/v1beta1
[google-gax]: https://github.com/googleapis/gax-ruby
[Stackdriver Clouderrorreporting API]: https://developers.google.com/apis-explorer/#p/clouderrorreporting/v1beta1/

Getting started
---------------

google-cloud-error_reporting will allow you to connect to the [Stackdriver Clouderrorreporting API][] and access all its methods.

In order to achieve so you need to set up authentication as well as install the library locally.


Setup Authentication
--------------------

To authenticate all your API calls, first install and setup the [Google Cloud SDK][].
Once done, you can then run the following command in your terminal:

    $ gcloud beta auth application-default login

or

    $ gcloud auth login

Please see [gcloud beta auth application-default login][] document for the difference between these commands.

[Google Cloud SDK]: https://cloud.google.com/sdk/
[gcloud beta auth application-default login]: https://cloud.google.com/sdk/gcloud/reference/beta/auth/application-default/login


Installation
-------------------

Install this library using gem:

    $ [sudo] gem install google-cloud-error_reporting
    

Rails Integration
---------------

This library also provides a built in Railtie for Ruby on Rails integration. To do this, simply add this line to config/application.rb:
```ruby
require "google/cloud/error_reporting/rails"
```
Then the library can be configured through this set of Rails parameters in config/environments/*.rb:
```ruby
# Sharing authentication parameters
config.google_cloud.project_id = "gcp-project-id"
config.google_cloud.keyfile = "/path/to/gcp/secret.json"
# Or more specificly for ErrorReporting
config.google_cloud.error_reporting.project_id = "gcp-project-id"
config.google_cloud.error_reporting.keyfile = "/path/to/gcp/sercret.json"
 
# Explicitly enable or disable ErrorReporting
config.google_cloud.use_error_reporting = true
 
# Set Stackdriver Error Reporting service context
config.google_cloud.error_reporting.service_name = "my-app-name"
config.google_cloud.error_reporting.service_version = "my-app-version"
```

Alternatively, check out [stackdriver](../stackdriver) gem, which includes this Railtie by default.

Rack Integration
---------------

Other Rack base framework can also directly leverage the built-in Middleware.
```ruby
require "google/cloud/error_reporting/v1beta1"

use Google::Cloud::ErrorReporting::Middleware
```

At this point you are all set to continue.
