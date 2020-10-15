<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Natural Language API Ruby Samples

The [Google Cloud Natural Language API][language_docs] provides natural language
understanding technologies to developers, including sentiment analysis, entity
recognition, and syntax analysis.

[language_docs]: https://cloud.google.com/natural-language/docs/

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

       gcloud auth application-default login

1. When running on App Engine or Compute Engine, credentials are already set-up.
However, you may need to configure your Compute Engine instance with
[additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts).
This file can be used to authenticate to Google Cloud Platform services from
any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
environment variable to the path to the key file, for example:

       export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json

### Set Project ID

Next, set the `GOOGLE_CLOUD_PROJECT` environment variable to the project name
set in the
[Google Cloud Platform Developer Console](https://console.cloud.google.com):

    export GOOGLE_CLOUD_PROJECT="YOUR-PROJECT-ID"

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

       bundle install

## Run samples

Run the sample:

    bundle exec ruby language_samples.rb

Usage:

    Usage: ruby language_samples.rb <text-to-analyze>

Example:

    bundle exec ruby language_samples.rb "Google, headquartered in Mountain View, unveiled the new Android phone at the Consumer Electronic Show. Sundar Pichai said in his keynote that users love their new Android phones."

    Sentiment:
    Overall document sentiment: (0.30000001192092896)
    Sentence level sentiment:
    Google, headquartered in Mountain View, unveiled the new Android phone at the Consumer Electronic Show.: (0.0)
    Sundar Pichai said in his keynote that users love their new Android phones.: (0.6000000238418579)

    Entities:
    Entity Google ORGANIZATION
    URL: https://en.wikipedia.org/wiki/Google
    Entity users PERSON
    Entity phone CONSUMER_GOOD
    Entity Android CONSUMER_GOOD
    URL: https://en.wikipedia.org/wiki/Android_(operating_system)
    Entity Sundar Pichai PERSON
    URL: https://en.wikipedia.org/wiki/Sundar_Pichai
    Entity Mountain View LOCATION
    URL: https://en.wikipedia.org/wiki/Mountain_View,_California
    Entity Consumer Electronic Show EVENT
    URL: https://en.wikipedia.org/wiki/Consumer_Electronics_Show
    Entity phones CONSUMER_GOOD
    Entity keynote OTHER

    Syntax:
    Sentences: 2
    Tokens: 32
    NOUN Google
    PUNCT ,
    VERB headquartered
    ADP in
    NOUN Mountain
    NOUN View
    PUNCT ,
    VERB unveiled
    DET the
    ADJ new
    NOUN Android
    NOUN phone
    ADP at
    DET the
    NOUN Consumer
    NOUN Electronic
    NOUN Show
    PUNCT .
    NOUN Sundar
    NOUN Pichai
    VERB said
    ADP in
    PRON his
    NOUN keynote
    ADP that
    NOUN users
    VERB love
    PRON their
    ADJ new
    NOUN Android
    NOUN phones
    PUNCT .

    Classify:
    Name: /Computers & Electronics Confidence: 0.6100000143051147
    Name: /Internet & Telecom/Mobile & Wireless Confidence: 0.5299999713897705
    Name: /News Confidence: 0.5299999713897705

## Run tests

Run the acceptance tests for these samples:

    bundle exec rake test
