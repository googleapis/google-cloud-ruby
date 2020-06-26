<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Dialogflow API Ruby Samples

The [Google Cloud Dialogflow API](https://cloud.google.com/dialogflow/) is an end-to-end development suite for building conversational interfaces for websites, mobile applications, popular messaging platforms, and IoT devices.

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

    `gcloud auth application-default login`

1. When running on App Engine or Compute Engine, credentials are already set-up.
However, you may need to configure your Compute Engine instance with
[additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)
. This file can be used to authenticate to Google Cloud Platform services from
any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
environment variable to the path to the key file, for example:

    `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json`

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

    `bundle install`

## Run samples

Run the sample:

    bundle exec ruby context_management.rb

Usage: ruby context_management.rb [commang] [arguments]

    Commands:
      list                              List all contexts
      create  <session_id>              Create a context for a session
      delete  <sessino_id> <context_id> Delete a context

Run the sample:

    bundle exec ruby detect_intent_audio.rb

Usage: ruby detect_intent_audio.rb [audio_file_path]

    Example:
      ruby detect_intent_audio.rb resources/book_a_room.wav

Run the sample:

    bundle exec ruby detect_intent_stream.rb

Usage: ruby detect_intent_stream.rb [audio_file_path]

    Example:
      ruby detect_intent_stream.rb resources/book_a_room.wav

Run the sample:

    bundle exec ruby detect_intent_texts.rb

Usage: ruby detect_intent_texts.rb [texts]

    Example:
      ruby detect_intent_texts.rb "hello" "book a meeting room" "Mountain View"

Run the sample:

    bundle exec ruby entity_management.rb

Usage: ruby entity_management.rb [commang] [arguments]

    Commands:
      list    <entity_type_id>
      List all entities of an entity type
      create  <entity_type_id> <entity_value> [<synonym1> [<synonym2> ...]]
      Create a new entity of an entity type
      delete  <entity_type_id> <entity_value>
      Delete an entity of an entity type

Run the sample:

    bundle exec ruby entity_type_management.rb

Usage: ruby entity_type_management.rb [commang] [arguments]

    Commands:
      list                                           List all entitiy types
      create  <display_name> [KIND_MAP or KIND_LIST] Create a new entity type
      delete  <entity_type_id>                       Delete an entity type

Run the sample:

    bundle exec ruby intent_management.rb

Usage: ruby intent_management.rb [commang] [arguments]

    Commands:
      list
      List all intents
      create  <display_name> <message_text> [training_phrase1, [training_phrase2, ...]]
      Create a new intent
      delete  <intent_id>
      Delete an intent

Run the sample:

    bundle exec ruby session_entity_type_management.rb

Usage: ruby session_entity_type_management.rb [commang] [arguments]

    Commands:
      list
      List all session entity types
      create  <session_id> <entity_type_display_name> [entity_value1, [entity_value2, ...]]
      Create a session entity type
      delete  <sessino_id> <session_entity_type_id>
      Delete a session entity type

## Run tests

You will need a project with Dialogflow enabled, and a service account key with
permissions to call Dialogflow.

To run against the latest library releases:

    bundle install && \
      GOOGLE_CLOUD_PROJECT=your-project-id \
      GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/keyfile.json \
      bundle exec rake test

To run against the current git master:

    GOOGLE_CLOUD_SAMPLES_TEST=master bundle install && \
      GOOGLE_CLOUD_SAMPLES_TEST=master GOOGLE_CLOUD_PROJECT=your-project-id \
      GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/keyfile.json \
      bundle exec rake test
