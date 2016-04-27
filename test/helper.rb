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

require "grpc"
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
require "gcloud/logging"
require "gcloud/translate"
require "gcloud/vision"

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
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:pubsub) { $gcloud_pubsub_global ||= Gcloud::Pubsub::Project.new(project, credentials) }

  def topics_json num_topics, token = nil
    topics = num_topics.times.map do
      JSON.parse(topic_json("topic-#{rand 1000}"))
    end
    data = { "topics" => topics }
    data["next_page_token"] = token unless token.nil?
    data.to_json
  end

  def topic_json topic_name
    { "name" => topic_path(topic_name) }.to_json
  end

  def topic_subscriptions_json topic_name, num_subs, token = nil
    subs = num_subs.times.map do
      subscription_path("sub-#{rand 1000}")
    end
    data = { "subscriptions" => subs }
    data["next_page_token"] = token unless token.nil?
    data.to_json
  end

  def subscriptions_json topic_name, num_subs, token = nil
    subs = num_subs.times.map do
      JSON.parse(subscription_json(topic_name, "sub-#{rand 1000}"))
    end
    data = { "subscriptions" => subs }
    data["next_page_token"] = token unless token.nil?
    data.to_json
  end

  def subscription_json topic_name, sub_name,
                        deadline = 60,
                        endpoint = "http://example.com/callback"
    { "name" => subscription_path(sub_name),
      "topic" => topic_path(topic_name),
      "push_config" => { "push_endpoint" => endpoint },
      "ack_deadline_seconds" => deadline,
    }.to_json
  end

  def rec_message_json message, id = rand(1000000)
    {
      "ack_id" => "ack-id-#{id}",
      "message" => {
        "data" => [message].pack("m"),
        "attributes" => {},
        "message_id" => "msg-id-#{id}",
      }
    }.to_json
  end

  def rec_messages_json message
    {
      "received_messages" => [
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

  def random_dataset_hash id = nil, name = nil, description = nil, default_expiration = nil, location = "US"
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
      "location" => location
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

  def random_project_hash seed = nil, name = nil, labels = nil
    seed ||= rand(9999)
    name ||= "Example Project #{seed}"
    labels = { "env" => "production" } if labels.nil?
    {
      "projectNumber" => "123456789#{seed}",
      "projectId" => "example-project-#{seed}",
      "name" => name,
      "createTime" => "2015-09-01T12:00:00.00Z",
      "labels" => labels,
      "lifecycleState" => "ACTIVE"
    }
  end

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_res_man
  end
end

class MockLogging < Minitest::Spec
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:logging) { $gcloud_logging_global ||= Gcloud::Logging::Project.new(project, credentials) }

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_logging
  end

  def random_entry_hash
    timestamp = Time.parse "2014-10-02T15:01:23.045123456Z"
    {
      "log_name"  => "projects/my-projectid/logs/syslog",
      "resource"  => random_resource_hash,
      "timestamp" => {
        "seconds" => timestamp.to_i,
        "nanos"   => timestamp.nsec
      },
      "severity"  => :DEFAULT,
      "insert_id" => "abc123",
      "labels" => {
        "env" => "production",
        "foo" => "bar"
      },
      "text_payload" => "payload",
      "http_request" => random_http_request_hash,
      "operation"    => random_operation_hash
    }
  end

  def random_http_request_hash
    {
      "request_method" => "GET",
      "request_url" => "http://test.local/foo?bar=baz",
      "request_size" => 123,
      "status" => 200,
      "response_size" => 456,
      "user_agent" => "gcloud-ruby/1.0.0",
      "remote_ip" => "127.0.0.1",
      "referer" => "http://test.local/referer",
      "cache_hit" => false,
      "validated_with_origin_server" => false
    }
  end

  def random_operation_hash
    {
      "id" => "xyz789",
      "producer" => "MyApp.MyClass#my_method",
      "first" => false,
      "last" => false
    }
  end

  def random_resource_hash
    {
      "type" => "gae_app",
      "labels" => {
        "module_id" => "1",
        "version_id" => "20150925t173233"
      }
    }
  end

  def random_resource_descriptor_hash
    {
      "type"         => "cloudsql_database",
      "display_name" => "Cloud SQL Database",
      "description"  => "This resource is a Cloud SQL Database",
      "labels"       => [
        {
         "key"          => "database_id",
         "description"  => "The ID of the database."
        },
        {
         "key"          => "zone",
         "value_type"   => :STRING,
         "description"  => "The GCP zone in which the database is running."
        },
        {
         "key"          => "active",
         "value_type"   => :BOOL,
         "description"  => "Whether the database is active."
        },
        {
         "key"          => "max_connections",
         "value_type"   => :INT64,
         "description"  => "The maximum number of connections it supports."
        }
      ]
    }
  end

  def random_sink_hash
    {
      "name"                  => "my-severe-errors-to-pubsub",
      "destination"           => "storage.googleapis.com/a-bucket",
      "filter"                => "logName:syslog AND severity>=ERROR",
      "output_version_format" => :VERSION_FORMAT_UNSPECIFIED
    }
  end

  def random_metric_hash
    {
      "name"        => "severe_errors",
      "description" => "The servere errors metric",
      "filter"      => "logName:syslog AND severity>=ERROR"
    }
  end

  def project_path
    "projects/#{project}"
  end
end

class MockTranslate < Minitest::Spec
  let(:key) { "test-api-key" }
  let(:translate) { $gcloud_translate_global ||= Gcloud::Translate::Api.new(key) }

  def setup
    @connection = Faraday::Adapter::Test::Stubs.new
    translate.connection.client.connection = Faraday.new "https://www.googleapis.com" do |builder|
      builder.options.params_encoder = Faraday::FlatParamsEncoder
      builder.adapter :test, @connection
    end
  end

  def teardown
    @connection.verify_stubbed_calls
  end

  def mock_connection
    @connection
  end

  def translate_json *pairs
    pairs = Array(pairs).flatten.each_slice(2).to_a
    translations = pairs.map do |text, language|
      { translatedText: text, detectedSourceLanguage: language }
    end
    { translations: translations }.to_json
  end

  def detect_json *languages
    detections = languages.map do |lang|
      [{ confidence: 0.123, language: lang, isReliable: false }] # isReliable is deprecated
    end
    { detections: detections }.to_json
  end

  def language_json lang = nil
    if lang == "en"
      {"languages"=>[{"language"=>"af", "name"=>"Afrikaans"}, {"language"=>"sq", "name"=>"Albanian"}, {"language"=>"am", "name"=>"Amharic"}, {"language"=>"ar", "name"=>"Arabic"}, {"language"=>"hy", "name"=>"Armenian"}, {"language"=>"az", "name"=>"Azerbaijani"}, {"language"=>"eu", "name"=>"Basque"}, {"language"=>"be", "name"=>"Belarusian"}, {"language"=>"bn", "name"=>"Bengali"}, {"language"=>"bs", "name"=>"Bosnian"}, {"language"=>"bg", "name"=>"Bulgarian"}, {"language"=>"ca", "name"=>"Catalan"}, {"language"=>"ceb", "name"=>"Cebuano"}, {"language"=>"ny", "name"=>"Chichewa"}, {"language"=>"zh", "name"=>"Chinese (Simplified)"}, {"language"=>"zh-TW", "name"=>"Chinese (Traditional)"}, {"language"=>"co", "name"=>"Corsican"}, {"language"=>"hr", "name"=>"Croatian"}, {"language"=>"cs", "name"=>"Czech"}, {"language"=>"da", "name"=>"Danish"}, {"language"=>"nl", "name"=>"Dutch"}, {"language"=>"en", "name"=>"English"}, {"language"=>"eo", "name"=>"Esperanto"}, {"language"=>"et", "name"=>"Estonian"}, {"language"=>"tl", "name"=>"Filipino"}, {"language"=>"fi", "name"=>"Finnish"}, {"language"=>"fr", "name"=>"French"}, {"language"=>"fy", "name"=>"Frisian"}, {"language"=>"gl", "name"=>"Galician"}, {"language"=>"ka", "name"=>"Georgian"}, {"language"=>"de", "name"=>"German"}, {"language"=>"el", "name"=>"Greek"}, {"language"=>"gu", "name"=>"Gujarati"}, {"language"=>"ht", "name"=>"Haitian Creole"}, {"language"=>"ha", "name"=>"Hausa"}, {"language"=>"haw", "name"=>"Hawaiian"}, {"language"=>"iw", "name"=>"Hebrew"}, {"language"=>"hi", "name"=>"Hindi"}, {"language"=>"hmn", "name"=>"Hmong"}, {"language"=>"hu", "name"=>"Hungarian"}, {"language"=>"is", "name"=>"Icelandic"}, {"language"=>"ig", "name"=>"Igbo"}, {"language"=>"id", "name"=>"Indonesian"}, {"language"=>"ga", "name"=>"Irish"}, {"language"=>"it", "name"=>"Italian"}, {"language"=>"ja", "name"=>"Japanese"}, {"language"=>"jw", "name"=>"Javanese"}, {"language"=>"kn", "name"=>"Kannada"}, {"language"=>"kk", "name"=>"Kazakh"}, {"language"=>"km", "name"=>"Khmer"}, {"language"=>"ko", "name"=>"Korean"}, {"language"=>"ku", "name"=>"Kurdish (Kurmanji)"}, {"language"=>"ky", "name"=>"Kyrgyz"}, {"language"=>"lo", "name"=>"Lao"}, {"language"=>"la", "name"=>"Latin"}, {"language"=>"lv", "name"=>"Latvian"}, {"language"=>"lt", "name"=>"Lithuanian"}, {"language"=>"lb", "name"=>"Luxembourgish"}, {"language"=>"mk", "name"=>"Macedonian"}, {"language"=>"mg", "name"=>"Malagasy"}, {"language"=>"ms", "name"=>"Malay"}, {"language"=>"ml", "name"=>"Malayalam"}, {"language"=>"mt", "name"=>"Maltese"}, {"language"=>"mi", "name"=>"Maori"}, {"language"=>"mr", "name"=>"Marathi"}, {"language"=>"mn", "name"=>"Mongolian"}, {"language"=>"my", "name"=>"Myanmar (Burmese)"}, {"language"=>"ne", "name"=>"Nepali"}, {"language"=>"no", "name"=>"Norwegian"}, {"language"=>"ps", "name"=>"Pashto"}, {"language"=>"fa", "name"=>"Persian"}, {"language"=>"pl", "name"=>"Polish"}, {"language"=>"pt", "name"=>"Portuguese"}, {"language"=>"pa", "name"=>"Punjabi"}, {"language"=>"ro", "name"=>"Romanian"}, {"language"=>"ru", "name"=>"Russian"}, {"language"=>"sm", "name"=>"Samoan"}, {"language"=>"gd", "name"=>"Scots Gaelic"}, {"language"=>"sr", "name"=>"Serbian"}, {"language"=>"st", "name"=>"Sesotho"}, {"language"=>"sn", "name"=>"Shona"}, {"language"=>"sd", "name"=>"Sindhi"}, {"language"=>"si", "name"=>"Sinhala"}, {"language"=>"sk", "name"=>"Slovak"}, {"language"=>"sl", "name"=>"Slovenian"}, {"language"=>"so", "name"=>"Somali"}, {"language"=>"es", "name"=>"Spanish"}, {"language"=>"su", "name"=>"Sundanese"}, {"language"=>"sw", "name"=>"Swahili"}, {"language"=>"sv", "name"=>"Swedish"}, {"language"=>"tg", "name"=>"Tajik"}, {"language"=>"ta", "name"=>"Tamil"}, {"language"=>"te", "name"=>"Telugu"}, {"language"=>"th", "name"=>"Thai"}, {"language"=>"tr", "name"=>"Turkish"}, {"language"=>"uk", "name"=>"Ukrainian"}, {"language"=>"ur", "name"=>"Urdu"}, {"language"=>"uz", "name"=>"Uzbek"}, {"language"=>"vi", "name"=>"Vietnamese"}, {"language"=>"cy", "name"=>"Welsh"}, {"language"=>"xh", "name"=>"Xhosa"}, {"language"=>"yi", "name"=>"Yiddish"}, {"language"=>"yo", "name"=>"Yoruba"}, {"language"=>"zu", "name"=>"Zulu"}]}.to_json
    else
      {"languages"=>[{"language"=>"af"}, {"language"=>"am"}, {"language"=>"ar"}, {"language"=>"az"}, {"language"=>"be"}, {"language"=>"bg"}, {"language"=>"bn"}, {"language"=>"bs"}, {"language"=>"ca"}, {"language"=>"ceb"}, {"language"=>"co"}, {"language"=>"cs"}, {"language"=>"cy"}, {"language"=>"da"}, {"language"=>"de"}, {"language"=>"el"}, {"language"=>"en"}, {"language"=>"eo"}, {"language"=>"es"}, {"language"=>"et"}, {"language"=>"eu"}, {"language"=>"fa"}, {"language"=>"fi"}, {"language"=>"fr"}, {"language"=>"fy"}, {"language"=>"ga"}, {"language"=>"gd"}, {"language"=>"gl"}, {"language"=>"gu"}, {"language"=>"ha"}, {"language"=>"haw"}, {"language"=>"hi"}, {"language"=>"hmn"}, {"language"=>"hr"}, {"language"=>"ht"}, {"language"=>"hu"}, {"language"=>"hy"}, {"language"=>"id"}, {"language"=>"ig"}, {"language"=>"is"}, {"language"=>"it"}, {"language"=>"iw"}, {"language"=>"ja"}, {"language"=>"jw"}, {"language"=>"ka"}, {"language"=>"kk"}, {"language"=>"km"}, {"language"=>"kn"}, {"language"=>"ko"}, {"language"=>"ku"}, {"language"=>"ky"}, {"language"=>"la"}, {"language"=>"lb"}, {"language"=>"lo"}, {"language"=>"lt"}, {"language"=>"lv"}, {"language"=>"mg"}, {"language"=>"mi"}, {"language"=>"mk"}, {"language"=>"ml"}, {"language"=>"mn"}, {"language"=>"mr"}, {"language"=>"ms"}, {"language"=>"mt"}, {"language"=>"my"}, {"language"=>"ne"}, {"language"=>"nl"}, {"language"=>"no"}, {"language"=>"ny"}, {"language"=>"pa"}, {"language"=>"pl"}, {"language"=>"ps"}, {"language"=>"pt"}, {"language"=>"ro"}, {"language"=>"ru"}, {"language"=>"sd"}, {"language"=>"si"}, {"language"=>"sk"}, {"language"=>"sl"}, {"language"=>"sm"}, {"language"=>"sn"}, {"language"=>"so"}, {"language"=>"sq"}, {"language"=>"sr"}, {"language"=>"st"}, {"language"=>"su"}, {"language"=>"sv"}, {"language"=>"sw"}, {"language"=>"ta"}, {"language"=>"te"}, {"language"=>"tg"}, {"language"=>"th"}, {"language"=>"tl"}, {"language"=>"tr"}, {"language"=>"uk"}, {"language"=>"ur"}, {"language"=>"uz"}, {"language"=>"vi"}, {"language"=>"xh"}, {"language"=>"yi"}, {"language"=>"yo"}, {"language"=>"zh"}, {"language"=>"zh-TW"}, {"language"=>"zu"}]}.to_json
    end
  end

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_translate
  end
end

class MockVision < Minitest::Spec
  let(:project) { vision.connection.project }
  let(:credentials) { vision.connection.credentials }
  let(:vision) { $gcloud_vision_global ||= Gcloud::Vision::Project.new("test", OpenStruct.new) }

  def setup
    @connection = Faraday::Adapter::Test::Stubs.new
    connection = vision.instance_variable_get "@connection"
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

  # Register this spec type for when :vision is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_vision
  end

  def face_annotation_response
    {
      boundingPoly: {
        vertices: [
          { x: 1, y: 0 },
          { x: 295, y: 0 },
          { x: 295, y: 301 },
          { x: 1, y: 301 }
        ]
      },
      fdBoundingPoly: {
        vertices: [
          { x: 28, y: 40 },
          { x: 250, y: 40 },
          { x: 250, y: 262 },
          { x: 28, y: 262 }
        ]
      },
      landmarks: [
        { type: :LEFT_EYE, position: { x: 83.707092, y: 128.34, z: -0.00013388535 } },
        { type: :RIGHT_EYE, position: { x: 181.17694, y: 115.16437, z: -12.82961 } },
        { type: :LEFT_OF_LEFT_EYEBROW, position: { x: 58.790176, y: 113.28249, z: 17.89735 } },
        { type: :RIGHT_OF_LEFT_EYEBROW, position: { x: 106.14151, y: 98.593758, z: -13.116687 } },
        { type: :LEFT_OF_RIGHT_EYEBROW, position: { x: 148.61565, y: 92.294594, z: -18.804882 } },
        { type: :RIGHT_OF_RIGHT_EYEBROW, position: { x: 204.40808, y: 94.300117, z: -2.0009689 } },
        { type: :MIDPOINT_BETWEEN_EYES, position: { x: 127.83745, y: 110.17557, z: -22.650913 } },
        { type: :NOSE_TIP, position: { x: 128.14919, y: 153.68129, z: -63.198204 } },
        { type: :UPPER_LIP, position: { x: 134.74164, y: 192.50438, z: -53.876408 } },
        { type: :LOWER_LIP, position: { x: 137.28528, y: 219.23564, z: -56.663128 } },
        { type: :MOUTH_LEFT, position: { x: 104.53558, y: 214.05037, z: -30.056231 } },
        { type: :MOUTH_RIGHT, position: { x: 173.79134, y: 204.99333, z: -39.725758 } },
        { type: :MOUTH_CENTER, position: { x: 136.43481, y: 204.37952, z: -51.620205 } },
        { type: :NOSE_BOTTOM_RIGHT, position: { x: 161.31354, y: 168.24527, z: -36.1628 } },
        { type: :NOSE_BOTTOM_LEFT, position: { x: 110.98372, y: 173.61331, z: -29.7784 } },
        { type: :NOSE_BOTTOM_CENTER, position: { x: 133.81947, y: 173.16437, z: -48.287724 } },
        { type: :LEFT_EYE_TOP_BOUNDARY, position: { x: 86.706947, y: 119.47144, z: -4.1606765 } },
        { type: :LEFT_EYE_RIGHT_CORNER, position: { x: 105.28892, y: 125.57655, z: -2.51554 } },
        { type: :LEFT_EYE_BOTTOM_BOUNDARY, position: { x: 84.883934, y: 134.59479, z: -2.8677137 } },
        { type: :LEFT_EYE_LEFT_CORNER, position: { x: 72.213913, y: 132.04138, z: 9.6985674 } },
        { type: :RIGHT_EYE_TOP_BOUNDARY, position: { x: 173.99446, y: 107.94287, z: -16.050705 } },
        { type: :RIGHT_EYE_RIGHT_CORNER, position: { x: 194.59413, y: 115.91954, z: -6.952745 } },
        { type: :RIGHT_EYE_BOTTOM_BOUNDARY, position: { x: 179.30353, y: 121.03307, z: -14.843414 } },
        { type: :RIGHT_EYE_LEFT_CORNER, position: { x: 158.2863, y: 118.491, z: -9.723031 } },
        { type: :LEFT_EYEBROW_UPPER_MIDPOINT, position: { x: 80.248711, y: 94.04303, z: 0.21131183 } },
        { type: :RIGHT_EYEBROW_UPPER_MIDPOINT, position: { x: 174.70135, y: 81.580917, z: -12.702137 } },
        { type: :LEFT_EAR_TRAGION, position: { x: 54.872219, y: 207.23712, z: 97.030685 } },
        { type: :RIGHT_EAR_TRAGION, position: { x: 252.67567, y: 180.43124, z: 70.15992 } },
        { type: :LEFT_EYE_PUPIL, position: { x: 86.531624, y: 126.49807, z: -2.2496929 } },
        { type: :RIGHT_EYE_PUPIL, position: { x: 175.99976, y: 114.64407, z: -14.53744 } },
        { type: :FOREHEAD_GLABELLA, position: { x: 126.53813, y: 93.812057, z: -18.863352 } },
        { type: :CHIN_GNATHION, position: { x: 143.34183, y: 262.22998, z: -57.388493 } },
        { type: :CHIN_LEFT_GONION, position: { x: 63.102425, y: 248.99081, z: 44.207638 } },
        { type: :CHIN_RIGHT_GONION, position: { x: 241.72728, y: 225.53488, z: 19.758242 } }
      ],
      rollAngle: -0.050002542,
      panAngle: -0.081090336,
      tiltAngle: 0.18012161,
      detectionConfidence: 0.56748849,
      landmarkingConfidence: 34.489909,
      joyLikelihood: :LIKELY,
      sorrowLikelihood: :UNLIKELY,
      angerLikelihood: :VERY_UNLIKELY,
      surpriseLikelihood: :UNLIKELY,
      underExposedLikelihood: :VERY_UNLIKELY,
      blurredLikelihood: :VERY_UNLIKELY,
      headwearLikelihood: :VERY_UNLIKELY,
    }
  end

  def landmark_annotation_response
    {
      mid: "/m/019dvv",
      description: "Mount Rushmore",
      score: 0.91912264,
      boundingPoly: {
        vertices: [
          { x: 9,   y: 35 },
          { x: 492, y: 35 },
          { x: 492, y: 325 },
          { x: 9,   y: 325 }
        ]
      },
     locations: [
       { latLng: { latitude: 43.878264, longitude: -103.45700740814209 } }
     ]
    }
  end
end
