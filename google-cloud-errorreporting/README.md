google-cloud-clouderrorreporting-v1beta1
=================================================

google-cloud-clouderrorreporting-v1beta1 uses [Google API extensions][google-gax] to provide an
easy-to-use client library for the [Google Clouderrorreporting API][] (v1beta1) defined in the [googleapis][] git repository


[googleapis]: https://github.com/googleapis/googleapis/tree/master/google/devtools/clouderrorreporting/v1beta1
[google-gax]: https://github.com/googleapis/gax-ruby
[Google Clouderrorreporting API]: https://developers.google.com/apis-explorer/#p/clouderrorreporting/v1beta1/

Getting started
---------------

gax-google-devtools-clouderrorreporting-v1beta1 will allow you to connect to the [Google Clouderrorreporting API][] and access all its methods. See the following classes for the actual API access.

- [Google::Cloud::Errorreporting::V1beta1::ErrorGroupServiceApi](http://www.rubydoc.info/gems/google-cloud-clouderrorreporting-v1beta1/0.6.8/Google/Cloud/Errorreporting/V1beta1/ErrorGroupServiceApi)
- [Google::Cloud::Errorreporting::V1beta1::ErrorStatsServiceApi](http://www.rubydoc.info/gems/google-cloud-clouderrorreporting-v1beta1/0.6.8/Google/Cloud/Errorreporting/V1beta1/ErrorStatsServiceApi)
- [Google::Cloud::Errorreporting::V1beta1::ReportErrorsServiceApi](http://www.rubydoc.info/gems/google-cloud-clouderrorreporting-v1beta1/0.6.8/Google/Cloud/Errorreporting/V1beta1/ReportErrorsServiceApi)

In order to achieve so you need to set up authentication as well as install the library locally.


Setup Authentication
--------------------

To authenticate all your API calls, first install and setup the [Google Cloud SDK][].
Once done, you can then run the following command in your terminal:

    $ gcloud beta auth application-default login

or

    $ gcloud auth login

Please see [[gcloud beta auth application-default login][] document for the difference between these commands.

[Google Cloud SDK]: https://cloud.google.com/sdk/
[gcloud beta auth application-default login]: https://cloud.google.com/sdk/gcloud/reference/beta/auth/application-default/login


Installation
-------------------

Install this library using gem:

    $ [sudo] gem install google-cloud-clouderrorreporting-v1beta1

At this point you are all set to continue.
