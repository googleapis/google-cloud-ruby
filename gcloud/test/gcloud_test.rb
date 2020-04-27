# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Gcloud do

  it "is an alias to Google::Cloud" do
    assert_equal Google::Cloud, Gcloud
  end

  it "can require BigQuery" do
    require "gcloud/bigquery"

    assert_equal Google::Cloud::Bigquery, Gcloud::Bigquery
  end

  it "can require Datastore" do
    require "gcloud/datastore"

    assert_equal Google::Cloud::Datastore, Gcloud::Datastore
  end

  it "can require DNS" do
    require "gcloud/dns"

    assert_equal Google::Cloud::Dns, Gcloud::Dns
  end

  it "can require Logging" do
    require "gcloud/logging"

    assert_equal Google::Cloud::Logging, Gcloud::Logging
  end

  it "can require Pub/Sub" do
    require "gcloud/pubsub"

    assert_equal Google::Cloud::Pubsub, Gcloud::Pubsub
  end

  it "can require Resource Manager" do
    require "gcloud/resource_manager"

    assert_equal Google::Cloud::ResourceManager, Gcloud::ResourceManager
  end

  it "can require Storage" do
    require "gcloud/storage"

    assert_equal Google::Cloud::Storage, Gcloud::Storage
  end

  it "can require Translate" do
    require "gcloud/translate"

    assert_equal Google::Cloud::Translate, Gcloud::Translate
  end

  it "can require Vision" do
    require "gcloud/vision"

    assert_equal Google::Cloud::Vision, Gcloud::Vision
  end
end
