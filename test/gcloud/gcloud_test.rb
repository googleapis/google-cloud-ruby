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
    stubbed_datastore = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal nil
      keyfile.must_equal nil
      scope.must_be :nil?
      retries.must_be :nil?
      "datastore-project-object-empty"
    }
    Gcloud.stub :datastore, stubbed_datastore do
      dataset = gcloud.datastore
      dataset.must_equal "datastore-project-object-empty"
    end
  end

  it "passes project and keyfile to Gcloud.datastore" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_datastore = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_be :nil?
      retries.must_be :nil?
      "datastore-project-object"
    }
    Gcloud.stub :datastore, stubbed_datastore do
      dataset = gcloud.datastore
      dataset.must_equal "datastore-project-object"
    end
  end

  it "passes project and keyfile and options to Gcloud.datastore" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_datastore = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_equal "http://example.com/scope"
      retries.must_equal 5
      "datastore-project-object-scoped"
    }
    Gcloud.stub :datastore, stubbed_datastore do
      dataset = gcloud.datastore scope: "http://example.com/scope", retries: 5
      dataset.must_equal "datastore-project-object-scoped"
    end
  end

  it "calls out to Gcloud.storage" do
    gcloud = Gcloud.new
    stubbed_storage = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal nil
      keyfile.must_equal nil
      scope.must_be :nil?
      retries.must_be :nil?
      "storage-project-object-empty"
    }
    Gcloud.stub :storage, stubbed_storage do
      dataset = gcloud.storage
      dataset.must_equal "storage-project-object-empty"
    end
  end

  it "passes project and keyfile to Gcloud.storage" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_storage = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_be :nil?
      retries.must_be :nil?
      "storage-project-object"
    }
    Gcloud.stub :storage, stubbed_storage do
      dataset = gcloud.storage
      dataset.must_equal "storage-project-object"
    end
  end

  it "passes project and keyfile and options to Gcloud.storage" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_storage = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_equal "http://example.com/scope"
      retries.must_equal 5
      "storage-project-object-scoped"
    }
    Gcloud.stub :storage, stubbed_storage do
      dataset = gcloud.storage scope: "http://example.com/scope", retries: 5
      dataset.must_equal "storage-project-object-scoped"
    end
  end

  it "calls out to Gcloud.pubsub" do
    gcloud = Gcloud.new
    stubbed_pubsub = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal nil
      keyfile.must_equal nil
      scope.must_be :nil?
      retries.must_be :nil?
      "pubsub-project-object-empty"
    }
    Gcloud.stub :pubsub, stubbed_pubsub do
      dataset = gcloud.pubsub
      dataset.must_equal "pubsub-project-object-empty"
    end
  end

  it "passes project and keyfile to Gcloud.pubsub" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_pubsub = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_be :nil?
      retries.must_be :nil?
      "pubsub-project-object"
    }
    Gcloud.stub :pubsub, stubbed_pubsub do
      dataset = gcloud.pubsub
      dataset.must_equal "pubsub-project-object"
    end
  end

  it "passes project and keyfile and options to Gcloud.pubsub" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_pubsub = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_equal "http://example.com/scope"
      retries.must_equal 5
      "pubsub-project-object-scoped"
    }
    Gcloud.stub :pubsub, stubbed_pubsub do
      dataset = gcloud.pubsub scope: "http://example.com/scope", retries: 5
      dataset.must_equal "pubsub-project-object-scoped"
    end
  end

  it "calls out to Gcloud.bigquery" do
    gcloud = Gcloud.new
    stubbed_bigquery = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal nil
      keyfile.must_equal nil
      scope.must_be :nil?
      retries.must_be :nil?
      "bigquery-project-object-empty"
    }
    Gcloud.stub :bigquery, stubbed_bigquery do
      dataset = gcloud.bigquery
      dataset.must_equal "bigquery-project-object-empty"
    end
  end

  it "passes project and keyfile to Gcloud.bigquery" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_bigquery = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_be :nil?
      retries.must_be :nil?
      "bigquery-project-object"
    }
    Gcloud.stub :bigquery, stubbed_bigquery do
      dataset = gcloud.bigquery
      dataset.must_equal "bigquery-project-object"
    end
  end

  it "passes project and keyfile and options to Gcloud.bigquery" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_bigquery = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_equal "http://example.com/scope"
      retries.must_equal 5
      "bigquery-project-object-scoped"
    }
    Gcloud.stub :bigquery, stubbed_bigquery do
      dataset = gcloud.bigquery scope: "http://example.com/scope", retries: 5
      dataset.must_equal "bigquery-project-object-scoped"
    end
  end

  it "calls out to Gcloud.dns" do
    gcloud = Gcloud.new
    stubbed_dns = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal nil
      keyfile.must_equal nil
      scope.must_be :nil?
      retries.must_be :nil?
      "dns-project-object-empty"
    }
    Gcloud.stub :dns, stubbed_dns do
      dataset = gcloud.dns
      dataset.must_equal "dns-project-object-empty"
    end
  end

  it "passes project and keyfile to Gcloud.dns" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_dns = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_be :nil?
      retries.must_be :nil?
      "dns-project-object"
    }
    Gcloud.stub :dns, stubbed_dns do
      dataset = gcloud.dns
      dataset.must_equal "dns-project-object"
    end
  end

  it "passes project and keyfile and options to Gcloud.dns" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_dns = ->(project, keyfile, scope: nil, retries: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_equal "http://example.com/scope"
      retries.must_equal 5
      "dns-project-object-scoped"
    }
    Gcloud.stub :dns, stubbed_dns do
      dataset = gcloud.dns scope: "http://example.com/scope", retries: 5
      dataset.must_equal "dns-project-object-scoped"
    end
  end
end
