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
require "gcloud/datastore"
require "gcloud/storage"
require "gcloud/pubsub"

describe Gcloud do
  it "calls out to Gcloud.datastore" do
    gcloud = Gcloud.new
    Gcloud.stub :datastore, "datastore-project-object" do
      dataset = gcloud.datastore
      dataset.must_equal "datastore-project-object"
    end
  end

  it "passes project and keyfile to Gcloud.datastore" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    Gcloud.stub :datastore, "datastore-project-object", ["project-id", "keyfile-path"] do
      dataset = gcloud.datastore
      dataset.must_equal "datastore-project-object"
    end
  end

  it "calls out to Gcloud.storage" do
    gcloud = Gcloud.new
    Gcloud.stub :storage, "storage-project-object" do
      dataset = gcloud.storage
      dataset.must_equal "storage-project-object"
    end
  end

  it "passes project and keyfile to Gcloud.storage" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    Gcloud.stub :storage, "storage-project-object", ["project-id", "keyfile-path"] do
      dataset = gcloud.storage
      dataset.must_equal "storage-project-object"
    end
  end

  it "calls out to Gcloud.pubsub" do
    gcloud = Gcloud.new
    Gcloud.stub :pubsub, "pubsub-project-object" do
      dataset = gcloud.pubsub
      dataset.must_equal "pubsub-project-object"
    end
  end

  it "passes project and keyfile to Gcloud.pubsub" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    Gcloud.stub :pubsub, "pubsub-project-object", ["project-id", "keyfile-path"] do
      dataset = gcloud.pubsub
      dataset.must_equal "pubsub-project-object"
    end
  end
end
