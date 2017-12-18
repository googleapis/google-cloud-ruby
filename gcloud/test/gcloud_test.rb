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
    Gcloud.must_equal Google::Cloud
  end

  it "can require BigQuery" do
    require "gcloud/bigquery"

    Gcloud::Bigquery.must_equal Google::Cloud::Bigquery
  end

  it "can require Datastore" do
    require "gcloud/datastore"

    Gcloud::Datastore.must_equal Google::Cloud::Datastore
  end

  it "can require DNS" do
    require "gcloud/dns"

    Gcloud::Dns.must_equal Google::Cloud::Dns
  end

  it "can require Logging" do
    require "gcloud/logging"

    Gcloud::Logging.must_equal Google::Cloud::Logging
  end

  it "can require Pub/Sub" do
    require "gcloud/pubsub"

    Gcloud::Pubsub.must_equal Google::Cloud::Pubsub
  end

  it "can require Resource Manager" do
    require "gcloud/resource_manager"

    Gcloud::ResourceManager.must_equal Google::Cloud::ResourceManager
  end

  it "can require Storage" do
    require "gcloud/storage"

    Gcloud::Storage.must_equal Google::Cloud::Storage
  end

  it "can require Translate" do
    require "gcloud/translate"

    Gcloud::Translate.must_equal Google::Cloud::Translate

  end

  it "can require Vision" do
    require "gcloud/vision"

    Gcloud::Vision.must_equal Google::Cloud::Vision
  end
end
