# Copyright 2014 Google Inc. All rights reserved.
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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "gcloud/storage"
require "gcloud/pubsub"
require "gcloud/bigquery"
require "gcloud/dns"
require "gcloud/resource_manager"

class MockStorage < Minitest::Spec
  let(:project) { storage.connection.project }
  let(:credentials) { storage.connection.credentials }
  let(:storage) { $gcloud_storage_global ||= Gcloud::Storage::Project.new("test", OpenStruct.new) }

  def setup
    @connection = Faraday::Adapter::Test::Stubs.new
    connection = storage.instance_variable_get "@connection"
    client = connection.instance_variable_get "@client"
    client.connection = Faraday.new do |builder|
      # builder.options.params_encoder = Faraday::FlatParamsEncoder
      builder.adapter :test, @connection
    end
  end

  def teardown
    @connection.verify_stubbed_calls
  end

  def mock_connection
    @connection
  end

  def random_bucket_hash(name=random_bucket_name,
    url_root="https://www.googleapis.com/storage/v1", location="US",
    storage_class="STANDARD", versioning=nil, logging_bucket=nil,
    logging_prefix=nil, website_main=nil, website_404=nil, cors=[])
    versioning_config = { "enabled" => versioning } if versioning
    { "kind" => "storage#bucket",
      "id" => name,
      "selfLink" => "#{url_root}/b/#{name}",
      "projectNumber" => "1234567890",
      "name" => name,
      "timeCreated" => Time.now,
      "metageneration" => "1",
      "owner" => { "entity" => "project-owners-1234567890" },
      "location" => location,
      "cors" => cors,
      "logging" => logging_hash(logging_bucket, logging_prefix),
      "storageClass" => storage_class,
      "versioning" => versioning_config,
      "website" => website_hash(website_main, website_404),
      "etag" => "CAE=" }.delete_if { |_, v| v.nil? }
  end

  def logging_hash(bucket, prefix)
    {
      "logBucket" => bucket,
      "logObjectPrefix" => prefix,
    }.delete_if { |_, v| v.nil? }  if bucket || prefix
  end

  def website_hash(website_main, website_404)
    {
      "mainPageSuffix" => website_main,
      "notFoundPage" => website_404,
    }.delete_if { |_, v| v.nil? }  if website_main || website_404
  end

  def random_file_hash bucket=random_bucket_name, name=random_file_path, generation="1234567890"
    { "kind" => "storage#object",
      "id" => "#{bucket}/#{name}/1234567890",
      "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket}/o/#{name}",
      "name" => "#{name}",
      "timeCreated" => Time.now,
      "bucket" => "#{bucket}",
      "generation" => generation,
      "metageneration" => "1",
      "cacheControl" => "public, max-age=3600",
      "contentDisposition" => "attachment; filename=filename.ext",
      "contentEncoding" => "gzip",
      "contentLanguage" => "en",
      "contentType" => "text/plain",
      "updated" => Time.now,
      "storageClass" => "STANDARD",
      "size" => rand(10_000),
      "md5Hash" => "HXB937GQDFxDFqUGi//weQ==",
      "mediaLink" => "https://www.googleapis.com/download/storage/v1/b/#{bucket}/o/#{name}?generation=1234567890&alt=media",
      "metadata" => { "player" => "Alice", "score" => "101" },
      "owner" => { "entity" => "user-1234567890", "entityId" => "abc123" },
      "crc32c" => "Lm1F3g==",
      "etag" => "CKih16GjycICEAE=" }
  end

  def random_bucket_name
    (0...50).map { ("a".."z").to_a[rand(26)] }.join
  end

  def random_file_path
    [(0...10).map { ("a".."z").to_a[rand(26)] }.join,
     (0...10).map { ("a".."z").to_a[rand(26)] }.join,
     (0...10).map { ("a".."z").to_a[rand(26)] }.join + ".txt"].join "/"
  end

  def invalid_bucket_name_error_json bucket_name
    {
      "error" => {
        "code" => 400,
        "message" => "Invalid bucket name: '#{bucket_name}'.",
        "errors" => [
          {
            "message" => "Invalid bucket name: '#{bucket_name}'.",
            "domain" => "global",
            "reason" => "invalidParameter"
          }
        ]
      }
    }.to_json
  end

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_storage
  end
end

class MockPubsub < Minitest::Spec
  let(:project) { pubsub.connection.project }
  let(:credentials) { pubsub.connection.credentials }
  let(:pubsub) { $gcloud_pubsub_global ||= Gcloud::Pubsub::Project.new("test", OpenStruct.new) }

  def setup
    @connection = Faraday::Adapter::Test::Stubs.new
    connection = pubsub.instance_variable_get "@connection"
    client = connection.instance_variable_get "@client"
    client.connection = Faraday.new do |builder|
      # builder.options.params_encoder = Faraday::FlatParamsEncoder
      builder.adapter :test, @connection
    end
  end

  def teardown
    @connection.verify_stubbed_calls
  end

  def mock_connection
    @connection
  end

  def topics_json num_topics, token = nil
    topics = num_topics.times.map do
      JSON.parse(topic_json("topic-#{rand 1000}"))
    end
    data = { "topics" => topics }
    data["nextPageToken"] = token unless token.nil?
    data.to_json
  end

  def topic_json topic_name
    { "name" => topic_path(topic_name) }.to_json
  end

  def subscriptions_json topic_name, num_subs, token = nil
    subs = num_subs.times.map do
      JSON.parse(subscription_json(topic_name, "sub-#{rand 1000}"))
    end
    data = { "subscriptions" => subs }
    data["nextPageToken"] = token unless token.nil?
    data.to_json
  end

  def subscription_json topic_name, sub_name,
                        deadline = 60,
                        endpoint = "http://example.com/callback"
    { "name" => subscription_path(sub_name),
      "topic" => topic_path(topic_name),
      "pushConfig" => { "pushEndpoint" => endpoint },
      "ackDeadlineSeconds" => deadline,
    }.to_json
  end

  def rec_message_json message, id = rand(1000000)
    {
      "ackId" => "ack-id-#{id}",
      "message" => {
        "data" => [message].pack("m"),
        "attributes" => {},
        "messageId" => "msg-id-#{id}",
      }
    }.to_json
  end

  def rec_messages_json message
    {
      "receivedMessages" => [
        JSON.parse(rec_message_json(message))
      ]
    }.to_json
  end

  def already_exists_error_json resource_name
    {
      "error" => {
        "code" => 409,
        "message" => "Resource already exists in the project (resource=#{resource_name}).",
        "errors" => [
          {
            "message" => "Resource already exists in the project (resource=#{resource_name}).",
            "domain" => "global",
            "reason" => "alreadyExists"
          }
        ],
        "status" => "ALREADY_EXISTS"
      }
    }.to_json
  end

  def not_found_error_json resource_name
    {
      "error" => {
        "code" => 404,
        "message" => "Resource not found (resource=#{resource_name}).",
        "errors" => [
          {
            "message" => "Resource not found (resource=#{resource_name}).",
            "domain" => "global",
            "reason" => "notFound"
          }
        ],
        "status" => "NOT_FOUND"
      }
    }.to_json
  end

  def project_path
    "projects/#{project}"
  end

  def topic_path topic_name
    "#{project_path}/topics/#{topic_name}"
  end

  def subscription_path subscription_name
    "#{project_path}/subscriptions/#{subscription_name}"
  end

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_pubsub
  end
end

class MockBigquery < Minitest::Spec
  let(:project) { bigquery.connection.project }
  let(:credentials) { bigquery.connection.credentials }
  let(:bigquery) { $gcloud_bigquery_global ||= Gcloud::Bigquery::Project.new("test-project", OpenStruct.new) }

  def setup
    @connection = Faraday::Adapter::Test::Stubs.new
    connection = bigquery.instance_variable_get "@connection"
    client = connection.instance_variable_get "@client"
    client.connection = Faraday.new do |builder|
      # builder.options.params_encoder = Faraday::FlatParamsEncoder
      builder.adapter :test, @connection
    end
  end

  def teardown
    @connection.verify_stubbed_calls
  end

  def mock_connection
    @connection
  end

  def random_dataset_hash id = nil, name = nil, description = nil, default_expiration = nil
    id ||= "my_dataset"
    name ||= "My Dataset"
    description ||= "This is my dataset"
    default_expiration ||= 100

    {
      "kind" => "bigquery#dataset",
      "etag" => "etag123456789",
      "id" => "id",
      "selfLink" => "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{id}",
      "datasetReference" => {
        "datasetId" => id,
        "projectId" => project
      },
      "friendlyName" => name,
      "description" => description,
      "defaultTableExpirationMs" => default_expiration,
      "access" => [],
      "creationTime" => Time.now.to_i*1000,
      "lastModifiedTime" => Time.now.to_i*1000,
      "location" => "US"
    }
  end

  def random_dataset_small_hash id = nil, name = nil
    id ||= "my_dataset"
    name ||= "My Dataset"

    {
      "kind" => "bigquery#dataset",
      "id" => "#{project}:#{id}",
      "datasetReference" => {
        "datasetId" => id,
        "projectId" => project
      },
      "friendlyName" => name
    }
  end

  def invalid_dataset_id_error_json id
    {
      "error" => {
        "code" => 400,
        "message" => "Invalid dataset ID \"#{id}\". Dataset IDs must be alphanumeric (plus underscores, dashes, and colons) and must be at most 1024 characters long.",
        "errors" => [
          {
            "message" => "Invalid dataset ID \"#{id}\". Dataset IDs must be alphanumeric (plus underscores, dashes, and colons) and must be at most 1024 characters long.",
            "domain" => "global",
            "reason" => "invalid"
          }
        ]
      }
    }.to_json
  end

  def random_table_hash dataset, id = nil, name = nil, description = nil, project_id = nil
    id ||= "my_table"
    name ||= "Table Name"

    {
      "kind" => "bigquery#table",
      "etag" => "etag123456789",
      "id" => "#{project}:#{dataset}.#{id}",
      "selfLink" => "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{id}",
      "tableReference" => {
        "projectId" => (project_id || project),
        "datasetId" => dataset,
        "tableId" => id
      },
      "friendlyName" => name,
      "description" => description,
      "schema" => {
        "fields" => [
          {
            "name" => "name",
            "type" => "STRING",
            "mode" => "REQUIRED"
          },
          {
            "name" => "age",
            "type" => "INTEGER"
          },
          {
            "name" => "score",
            "type" => "FLOAT",
            "description" => "A score from 0.0 to 10.0"
          },
          {
            "name" => "active",
            "type" => "BOOLEAN"
          }
        ]
      },
      "numBytes" => 1000,
      "numRows" => 100,
      "creationTime" => (Time.now.to_f * 1000).floor,
      "expirationTime" => (Time.now.to_f * 1000).floor,
      "lastModifiedTime" => (Time.now.to_f * 1000).floor,
      "type" => "TABLE",
      "location" => "US"
    }
  end

  def random_table_small_hash dataset, id = nil, name = nil
    id ||= "my_table"
    name ||= "Table Name"

    {
      "kind" => "bigquery#table",
      "id" => "#{project}:#{dataset}.#{id}",
      "tableReference" => {
        "projectId" => project,
        "datasetId" => dataset,
        "tableId" => id
      },
      "friendlyName" => name,
      "type" => "TABLE"
    }
  end

  def random_view_hash dataset, id = nil, name = nil, description = nil
    id ||= "my_view"
    name ||= "View Name"

    {
      "kind" => "bigquery#table",
      "etag" => "etag123456789",
      "id" => "#{project}:#{dataset}.#{id}",
      "selfLink" => "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{id}",
      "tableReference" => {
        "projectId" => project,
        "datasetId" => dataset,
        "tableId" => id
      },
      "friendlyName" => name,
      "description" => description,
      "schema" => {
        "fields" => [
          {
            "name" => "name",
            "type" => "STRING",
            "mode" => "NULLABLE"
          },
          {
            "name" => "age",
            "type" => "INTEGER",
            "mode" => "NULLABLE"
          },
          {
            "name" => "score",
            "type" => "FLOAT",
            "mode" => "NULLABLE"
          },
          {
            "name" => "active",
            "type" => "BOOLEAN",
            "mode" => "NULLABLE"
          }
        ]
      },
      "creationTime" => (Time.now.to_f * 1000).floor,
      "expirationTime" => (Time.now.to_f * 1000).floor,
      "lastModifiedTime" => (Time.now.to_f * 1000).floor,
      "type" => "VIEW",
      "view" => {
        "query" => "SELECT name, age, score, active FROM [external:publicdata.users]"
      },
      "location" => "US"
    }
  end

  def random_view_small_hash dataset, id = nil, name = nil
    id ||= "my_view"
    name ||= "View Name"

    {
      "kind" => "bigquery#table",
      "id" => "#{project}:#{dataset}.#{id}",
      "tableReference" => {
        "projectId" => project,
        "datasetId" => dataset,
        "tableId" => id
      },
      "friendlyName" => name,
      "type" => "VIEW"
    }
  end

  def random_job_hash id = "1234567890", state = "running"
    {
      "kind" => "bigquery#job",
      "etag" => "etag",
      "id" => "#{project}:#{id}",
      "selfLink" => "http://bigquery/projects/#{project}/jobs/#{id}",
      "jobReference" => {
        "projectId" => project,
        "jobId" => id
      },
      "configuration" => {
        # config call goes here
        "dryRun" => false
      },
      "status" => {
        "state" => state,
        "errorResult" => nil,
        "errors" => nil
      },
      "statistics" => {
        "creationTime" => (Time.now.to_f * 1000).floor,
        "startTime" => (Time.now.to_f * 1000).floor,
        "endTime" => (Time.now.to_f * 1000).floor
      },
      "user_email" => "user@example.com"
    }
  end

  def query_data_json
    query_data_hash.to_json
  end

  def query_data_hash
    {
      "kind" => "bigquery#getQueryResultsResponse",
      "etag" => "etag1234567890",
      "jobReference" => {
        "projectId" => project,
        "jobId" => "job9876543210"
      },
      "schema" => {
        "fields" => [
          {
            "name" => "name",
            "type" => "STRING",
            "mode" => "NULLABLE"
          },
          {
            "name" => "age",
            "type" => "INTEGER",
            "mode" => "NULLABLE"
          },
          {
            "name" => "score",
            "type" => "FLOAT",
            "mode" => "NULLABLE"
          },
          {
            "name" => "active",
            "type" => "BOOLEAN",
            "mode" => "NULLABLE"
          }
        ]
      },
      "rows" => [
        {
          "f" => [
            {
              "v" => "Heidi"
            },
            {
              "v" => "36"
            },
            {
              "v" => "7.65"
            },
            {
              "v" => "true"
            }
          ]
        },
        {
          "f" => [
            {
              "v" => "Aaron"
            },
            {
              "v" => "42"
            },
            {
              "v" => "8.15"
            },
            {
              "v" => "false"
            }
          ]
        },
        {
          "f" => [
            {
              "v" => "Sally"
            },
            {
              "v" => nil
            },
            {
              "v" => nil
            },
            {
              "v" => nil
            }
          ]
        }
      ],
      "pageToken" => "token1234567890",
      "totalRows" => 3,
      "totalBytesProcessed" => 456789,
      "jobComplete" => true,
      "cacheHit" => false
    }
  end

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_bigquery
  end
end

class MockDns < Minitest::Spec
  let(:project) { dns.connection.project }
  let(:credentials) { dns.connection.credentials }
  let(:dns) { $gcloud_dns_global ||= Gcloud::Dns::Project.new("test", OpenStruct.new) }

  def setup
    @connection = Faraday::Adapter::Test::Stubs.new
    connection = dns.instance_variable_get "@connection"
    client = connection.instance_variable_get "@client"
    client.connection = Faraday.new do |builder|
      # builder.options.params_encoder = Faraday::FlatParamsEncoder
      builder.adapter :test, @connection
    end
  end

  def teardown
    @connection.verify_stubbed_calls
  end

  def mock_connection
    @connection
  end

  def random_project_hash
    {
      "kind" => "dns#project",
      "number" => 123456789,
      "id" => project,
      "quota" => {
        "kind" => "dns#quota",
        "managedZones" => 101,
        "rrsetsPerManagedZone" => 1002,
        "rrsetAdditionsPerChange" => 103,
        "rrsetDeletionsPerChange" => 104,
        "totalRrdataSizePerChange" => 8000,
        "resourceRecordsPerRrset" => 105
      }
    }
  end

  def random_zone_hash zone_name, zone_dns
    {
      "kind" => "dns#managedZone",
      "name" => zone_name,
      "dnsName" => zone_dns,
      "description" => "",
      "id" => 123456789,
      "nameServers" => [ "virtual-dns-1.google.example",
                         "virtual-dns-2.google.example" ],
      "creationTime" => "2015-01-01T00:00:00-00:00"
    }
  end

  def random_change_hash
    {
      "kind" => "dns#change",
      "id" => "dns-change-1234567890",
      "additions" => [],
      "deletions" => [],
      "startTime" => "2015-01-01T00:00:00-00:00",
      "status" => "done"
    }
  end

  def random_record_hash name, type, ttl, data
    {
      "kind" => "dns#resourceRecordSet",
      "name" => name,
      "rrdatas" => data,
      "ttl" => ttl,
      "type" => type
    }
  end

  def done_change_hash change_id = nil
    hash = random_change_hash
    hash["id"] = change_id if change_id
    hash["additions"] = [{ "name" => "example.net.", "ttl" => 18600, "type" => "A", "rrdatas" => ["example.com."] }]
    hash["deletions"] = [{ "name" => "example.net.", "ttl" => 18600, "type" => "A", "rrdatas" => ["example.org."] }]
    hash
  end

  def pending_change_hash change_id = nil
    hash = done_change_hash change_id
    hash["status"] = "pending"
    hash
  end

  def done_change_json change_id = nil
    done_change_hash(change_id).to_json
  end

  def pending_change_json change_id = nil
    pending_change_hash(change_id).to_json
  end

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_dns
  end
end

class MockResourceManager < Minitest::Spec
  let(:credentials) { OpenStruct.new }
  let(:resource_manager) { $gcloud_resource_manager_global ||= Gcloud::ResourceManager::Manager.new(OpenStruct.new) }

  def setup
    @connection = Faraday::Adapter::Test::Stubs.new
    connection = resource_manager.instance_variable_get "@connection"
    client = connection.instance_variable_get "@client"
    client.connection = Faraday.new do |builder|
      # builder.options.params_encoder = Faraday::FlatParamsEncoder
      builder.adapter :test, @connection
    end
  end

  def teardown
    @connection.verify_stubbed_calls
  end

  def mock_connection
    @connection
  end

  def random_project_hash seed, name = nil, labels = nil
    seed ||= rand(9999)
    name ||= "Example Project #{seed}"
    labels = { "env" => "production" } if labels.nil?
    {
      "projectNumber" => "123456789#{seed}",
      "projectId" => "example-project-#{seed}",
      "lifecycleState" => "ACTIVE",
      "name" => name,
      "createTime" => "2015-09-01T12:00:00.00Z",
      "labels" => labels
    }
  end

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_res_man
  end
end
