#--
# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "gcloud"
require "gcloud/pubsub/project"

#--
# Google Cloud Pub/Sub
module Gcloud
  ##
  # Creates a new object for connecting to the Pubsub service.
  # Each call creates a new connection.
  #
  # === Parameters
  #
  # +project+::
  #   Project identifier for the Pubsub service you are connecting to.
  #   (+String+)
  # +keyfile+::
  #   Keyfile downloaded from Google Cloud. If file path the file must be
  #   readable. (+String+ or +Hash+)
  #
  # === Returns
  #
  # Gcloud::Pubsub::Project
  #
  # === Example
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #
  #   topic = pubsub.topic "my-topic"
  #   topic.publish "task completed"
  #
  def self.pubsub project = nil, keyfile = nil
    project ||= Gcloud::Pubsub::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Pubsub::Credentials.default
    else
      credentials = Gcloud::Pubsub::Credentials.new keyfile
    end
    Gcloud::Pubsub::Project.new project, credentials
  end

  ##
  # = Google Cloud Pubsub
  #
  # Google Cloud Pub/Sub is designed to provide reliable, many-to-many,
  # asynchronous messaging between applications. Publisher applications can
  # send messages to a "topic" and other applications can subscribe to that
  # topic to receive the messages. By decoupling senders and receivers, Google
  # Cloud Pub/Sub allows developers to communicate between independently written
  # applications.
  #
  # Gcloud's goal is to provide a API that is familiar and comfortable to
  # Rubyists. Authentication is handled by Gcloud.pubsub. You can provide the
  # project and credential information to connect to the Pubsub service, or if
  # you are running on Google Compute Engine this configuration is taken care
  # of for you.
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #
  #   topic = pubsub.topic "my-topic"
  #   topic.publish "task completed"
  #
  # To learn more about Datastore, read the
  # {Google Cloud Pubsub Overview
  # }[https://cloud.google.com/pubsub/overview].
  #
  # == Retrieving Topics
  #
  # A Topic is a named resource to which messages are sent by publishers.
  # A Topic is found by its name. (See Project#topic)
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #   topic = pubsub.topic "my-topic"
  #
  # == Creating a Topics
  #
  # A Topic is created from a Project. (See Project#create_topic)
  #
  #   require "gcloud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #   topic = pubsub.create_topic "my-topic"
  #
  # == Publishing Messages
  #
  # Messages are published to a topic. (See Topic#publish)
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #
  #   topic = pubsub.topic "my-topic"
  #   msg = topic.publish "new-message"
  #
  # Messages can also be published with attributes:
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #
  #   topic = pubsub.topic "my-topic"
  #   msg = topic.publish "new-message",
  #                       foo: :bar,
  #                       this: :that
  #
  # Multiple messages can be published at the same time by passing a block:
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #
  #   topic = pubsub.topic "my-topic"
  #   msg = topic.publish do |batch|
  #     batch.publish "new-message-1", foo: :bar
  #     batch.publish "new-message-2", foo: :baz
  #     batch.publish "new-message-3", foo: :bif
  #   end
  #
  # == Retrieving Subscriptions
  #
  # A Subscription is a named resource representing the stream of messages from
  # a single, specific Topic, to be delivered to the subscribing application.
  # A Subscription is found by its name. (See Topic#subscription)
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #
  #   topic = pubsub.topic "my-topic"
  #   subscription = topic.subscription "my-topic-subscription"
  #   puts subscription.name
  #
  # == Creating a Subscription
  #
  # A Subscription is created from a Topic. (See Topic#subscribe)
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #
  #   topic = pubsub.topic "my-topic"
  #   sub = topic.subscribe "my-topic-sub"
  #   puts sub.name # => "my-topic-sub"
  #
  # The name is optional, and will be generated if not given.
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #
  #   topic = pubsub.topic "my-topic"
  #   sub = topic.subscribe "my-topic-sub"
  #   puts sub.name # => "generated-sub-name"
  #
  # The subscription can be created that specifies the number of seconds to
  # wait to be acknoeledged as well as an endpoint URL to push the messages to:
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #
  #   topic = pubsub.topic "my-topic"
  #   sub = topic.subscribe "my-topic-sub",
  #                         deadline: 120,
  #                         endpoint: "https://example.com/push"
  #
  # == Pulling Messages
  #
  # Messages are pulled from a Subscription.
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #
  #   sub = pubsub.subscription "my-topic-sub"
  #   msgs = sub.pull
  #
  # Results can be returned immediately with the +:immediate+ option:
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #
  #   sub = pubsub.subscription "my-topic-sub", immediate: true
  #   msgs = sub.pull
  #
  # A maximum number of messages returned can also be specified:
  #
  #   require "glcoud/pubsub"
  #
  #   pubsub = Gcloud.pubsub
  #
  #   sub = pubsub.subscription "my-topic-sub", max: 10
  #   msgs = sub.pull
  #
  # == Acknowledging a Message
  # == Modifying a Message
  #
  module Pubsub
  end
end
