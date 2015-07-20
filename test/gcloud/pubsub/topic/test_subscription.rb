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

require "helper"

describe Gcloud::Pubsub::Topic, :subscription, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_gapi JSON.parse(topic_json(topic_name)),
                                                pubsub.connection }
  let(:found_sub_name) { "found-sub-#{Time.now.to_i}" }
  let(:not_found_sub_name) { "not-found-sub-#{Time.now.to_i}" }

  it "gets lazy sub for an existing subscription" do
    sub = topic.subscription found_sub_name
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.must_be :lazy?
  end

  it "returns lazy sub when getting an non-existant subscription" do
    sub = topic.subscription not_found_sub_name
    sub.must_be_kind_of Gcloud::Pubsub::Subscription
    sub.must_be :lazy?
  end

  describe "lazy topic that exists" do
    describe "created with autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: true }

      it "gets lazy sub for an existing subscription" do
        sub = topic.subscription found_sub_name
        sub.must_be_kind_of Gcloud::Pubsub::Subscription
        sub.must_be :lazy?
      end

      it "returns lazy sub when getting an non-existant subscription" do
        sub = topic.subscription not_found_sub_name
        sub.must_be_kind_of Gcloud::Pubsub::Subscription
        sub.must_be :lazy?
      end
    end

    describe "created without autocomplete" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: false }

      it "gets lazy sub for an existing subscription" do
        sub = topic.subscription found_sub_name
        sub.must_be_kind_of Gcloud::Pubsub::Subscription
        sub.must_be :lazy?
      end

      it "returns lazy sub when getting an non-existant subscription" do
        sub = topic.subscription not_found_sub_name
        sub.must_be_kind_of Gcloud::Pubsub::Subscription
        sub.must_be :lazy?
      end
    end
  end

  describe "lazy topic that does not exist" do
    describe "created with autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: true }

      it "gets lazy sub for an existing subscription" do
        sub = topic.subscription found_sub_name
        sub.must_be_kind_of Gcloud::Pubsub::Subscription
        sub.must_be :lazy?
      end
    end

    describe "created without autocomplete" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: false }

      it "returns lazy sub when getting an non-existant subscription" do
        sub = topic.subscription not_found_sub_name
        sub.must_be_kind_of Gcloud::Pubsub::Subscription
        sub.must_be :lazy?
      end
    end
  end
end
