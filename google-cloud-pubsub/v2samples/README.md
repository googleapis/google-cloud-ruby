<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Pub/Sub Ruby Samples

[Google Cloud Pub/Sub][language_docs] is a simple, reliable, scalable foundation for stream analytics 
and event-driven computing systems.

[language_docs]: https://cloud.google.com/pubsub/docs/

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

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)
. This file can be used to authenticate to Google Cloud Platform services from
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

If using the `topics.rb create_push_subscription` command (see below), first deploy the push listener
App Engine app defined in `listener.rb` and configured in `app.yaml`. The `endpoint` argument to
`create_push_subscription` should look like `https://my-project.appspot.com/push`. You can see messages
pushed to the listener in [Google Cloud Logging](https://cloud.google.com/logging/docs/), or simply
run `tail` on the logs as shown below.

    gcloud app deploy --promote
    gcloud app logs tail -s default

Run the quickstart sample to create a topic:

    bundle exec ruby quickstart.rb <topic_id>

Run the sample for using topics:

    bundle exec ruby topics.rb

Usage:

    bundle exec ruby topics.rb [command] [arguments]

    Commands:
    create_topic                                    <project_id> <topic_id>                              Create a topic
    list_topics                                     <project_id>                                         List topics in a project
    list_topic_subscriptions                        <project_id> <topic_id>                              List subscriptions in a topic
    delete_topic                                    <project_id> <topic_id>                              Delete topic policies
    get_topic_policy                                <project_id> <topic_id>                              Get topic policies
    set_topic_policy                                <project_id> <topic_id>                              Set topic policies
    test_topic_permissions                          <project_id> <topic_id>                              Test topic permissions
    create_pull_subscription                        <project_id> <topic_id> <subscription_id>            Create a pull subscription
    create_push_subscription                        <project_id> <topic_id> <subscription_id> <endpoint> Create a push subscription
    publish_message                                 <project_id> <topic_id>                              Publish message
    publish_message_async                           <project_id> <topic_id>                              Publish messages asynchronously
    publish_messages_async_with_batch_settings      <project_id> <topic_id>                              Publish messages asynchronously in batch
    publish_message_async_with_custom_attributes    <project_id> <topic_id>                              Publish messages asynchronously with custom attributes
    publish_messages_async_with_concurrency_control <project_id> <topic_id>                              Publish messages asynchronously with concurrency control

Example:

    bundle exec ruby topics.rb create_topic my-new-topic

    Topic my-new-topic created.

Run the sample for using subscriptions:

    bundle exec ruby subscriptions.rb

Usage:

    bundle exec ruby subscriptions.rb [command] [arguments]

    Commands:
    update_push_configuration                    <project_id> <subscription_id> <endpoint> Update the endpoint of a push subscription
    list_subscriptions                           <project_id>                              List subscriptions of a project
    delete_subscription                          <project_id> <subscription_id>            Delete a subscription
    get_subscription_policy                      <project_id> <subscription_id>            Get policies of a subscription
    set_subscription_policy                      <project_id> <subscription_id>            Set policies of a subscription
    test_subscription_policy                     <project_id> <subscription_id>            Test policies of a subscription
    listen_for_messages                          <project_id> <subscription_id>            Listen for messages
    listen_for_messages_with_custom_attributes   <project_id> <subscription_id>            Listen for messages with custom attributes
    pull_messages                                <project_id> <subscription_id>            Pull messages
    listen_for_messages_with_error_handler       <project_id> <subscription_id>            Listen for messages with an error handler
    listen_for_messages_with_flow_control        <project_id> <subscription_id>            Listen for messages with flow control
    listen_for_messages_with_concurrency_control <project_id> <subscription_id>            Listen for messages with concurrency control

Example:

    bundle exec ruby subscriptions.rb list_subscriptions

    Subscriptions:
    YOUR-SUBSCRIPTION


## Test samples

Test the samples using the Project ID configured above:

    bundle exec rake test
