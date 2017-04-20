Google Longrunning API for Ruby
=================================================

google-cloud-longrunning uses [Google API extensions][google-gax] to provide an
easy-to-use client library for the [Google Longrunning API][] (longrunning) defined in the [googleapis][] git repository


[googleapis]: https://github.com/googleapis/googleapis/tree/master/google/longrunning
[google-gax]: https://github.com/googleapis/gax-ruby
[Google Google API]: https://developers.google.com/apis-explorer/#p/google/longrunning/

Getting started
---------------

google-cloud-longrunning will allow you to connect to the [Google Longrunning API][] and access all its methods.

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

    $ [sudo] gem install google-cloud-longrunning

At this point you are all set to continue.
