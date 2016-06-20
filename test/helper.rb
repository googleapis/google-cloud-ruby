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

##
# Monkey-Patch Google API Client to support Mocks
module Google::Apis::Core::Hashable
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, the Google API Client objects do not match with ===.
  # Therefore, we must add this capability.
  # This module seems like as good a place as any...
  def === other
    return(to_h === other.to_h) if other.respond_to? :to_h
    super
  end
end

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
  let(:project) { dns.service.project }
  let(:credentials) { dns.service.credentials }
  let(:dns) { $gcloud_dns_global ||= Gcloud::Dns::Project.new("test", OpenStruct.new) }

  def random_project_gapi
    Google::Apis::DnsV1::Project.new(
      kind: "dns#project",
      number: 123456789,
      id: project,
      quota: Google::Apis::DnsV1::Quota.new(
        kind: "dns#quota",
        managed_zones: 101,
        rrsets_per_managed_zone: 1002,
        rrset_additions_per_change: 103,
        rrset_deletions_per_change: 104,
        total_rrdata_size_per_change: 8000,
        resource_records_per_rrset: 105
      )
    )
  end

  def random_zone_gapi zone_name, zone_dns
    Google::Apis::DnsV1::ManagedZone.new(
      kind: "dns#managedZone",
      name: zone_name,
      dns_name: zone_dns,
      description: "",
      id: 123456789,
      name_servers: [ "virtual-dns-1.google.example",
                     "virtual-dns-2.google.example" ],
      creation_time: "2015-01-01T00:00:00-00:00"
    )
  end

  def random_change_gapi
    Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      id: "dns-change-1234567890",
      additions: [],
      deletions: [],
      start_time: "2015-01-01T00:00:00-00:00",
      status: "done"
    )
  end

  def random_record_gapi name, type, ttl, data
    Google::Apis::DnsV1::ResourceRecordSet.new(
      kind: "dns#resourceRecordSet",
      name: name,
      rrdatas: data,
      ttl: ttl,
      type: type
    )
  end

  def done_change_gapi change_id = nil
    change = random_change_gapi
    change.id = change_id if change_id
    change.additions = [ random_record_gapi("example.net.", "A", 18600, ["example.com."]) ]
    change.deletions = [ random_record_gapi("example.net.", "A", 18600, ["example.org."]) ]
    change
  end

  def pending_change_gapi change_id = nil
    change = done_change_gapi change_id
    change.status = "pending"
    change
  end

  def create_change_gapi to_add, to_remove
    change = random_change_gapi
    change.id = "dns-change-created"
    change.additions = Array(to_add).map(&:to_gapi)
    change.deletions = Array(to_remove).map(&:to_gapi)
    change
  end

  def lookup_records_gapi record
    Google::Apis::DnsV1::ListResourceRecordSetsResponse.new rrsets: [record.to_gapi]
  end

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_dns
  end
end

class MockResourceManager < Minitest::Spec
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:resource_manager) { $gcloud_resource_manager_global ||= Gcloud::ResourceManager::Manager.new(credentials) }

  # Register this spec type for when :mock_res_man is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_res_man
  end

  def random_project_gapi seed = nil, name = nil, labels = nil
    seed ||= rand(9999)
    name ||= "Example Project #{seed}"
    labels = { "env" => "production" } if labels.nil?
    { project_number: "123456789#{seed}",
      project_id:     "example-project-#{seed}",
      name:           name,
      labels:         labels,
      create_time:    "2015-09-01T12:00:00.00Z",
      lifecycle_state: "ACTIVE" }
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

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_translate
  end
end

class MockVision < Minitest::Spec
  API = Google::Apis::VisionV1
  let(:project) { vision.service.project }
  let(:credentials) { vision.service.credentials }
  let(:vision) { $gcloud_vision_global ||= Gcloud::Vision::Project.new("test", OpenStruct.new) }

  # Register this spec type for when :vision is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_vision
  end

  def bounding_poly
    API::BoundingPoly.new(
      vertices: [
        API::Vertex.new(x: 1, y: 0),
        API::Vertex.new(x: 295, y: 0),
        API::Vertex.new(x: 295, y: 301),
        API::Vertex.new(x: 1, y: 301)
      ]
    )
  end

  def face_annotation_response
    API::FaceAnnotation.new(
      bounding_poly: bounding_poly,
      fd_bounding_poly: API::BoundingPoly.new(
        vertices: [
          API::Vertex.new(x: 28, y: 40),
          API::Vertex.new(x: 250, y: 40),
          API::Vertex.new(x: 250, y: 262),
          API::Vertex.new(x: 28, y: 262)
        ]
      ),
      landmarks: [
        API::Landmark.new(type: "LEFT_EYE", position: API::Position.new(x: 83.707092, y: 128.34, z: -0.00013388535)),
        API::Landmark.new(type: "RIGHT_EYE", position: API::Position.new(x: 181.17694, y: 115.16437, z: -12.82961)),
        API::Landmark.new(type: "LEFT_OF_LEFT_EYEBROW", position: API::Position.new(x: 58.790176, y: 113.28249, z: 17.89735)),
        API::Landmark.new(type: "RIGHT_OF_LEFT_EYEBROW", position: API::Position.new(x: 106.14151, y: 98.593758, z: -13.116687)),
        API::Landmark.new(type: 'LEFT_OF_RIGHT_EYEBROW', position: API::Position.new(x: 148.61565, y: 92.294594, z: -18.804882)),
        API::Landmark.new(type: "RIGHT_OF_RIGHT_EYEBROW", position: API::Position.new(x: 204.40808, y: 94.300117, z: -2.0009689)),
        API::Landmark.new(type: "MIDPOINT_BETWEEN_EYES", position: API::Position.new(x: 127.83745, y: 110.17557, z: -22.650913)),
        API::Landmark.new(type: "NOSE_TIP", position: API::Position.new(x: 128.14919, y: 153.68129, z: -63.198204)),
        API::Landmark.new(type: "UPPER_LIP", position: API::Position.new(x: 134.74164, y: 192.50438, z: -53.876408)),
        API::Landmark.new(type: "LOWER_LIP", position: API::Position.new(x: 137.28528, y: 219.23564, z: -56.663128)),
        API::Landmark.new(type: "MOUTH_LEFT", position: API::Position.new(x: 104.53558, y: 214.05037, z: -30.056231)),
        API::Landmark.new(type: "MOUTH_RIGHT", position: API::Position.new(x: 173.79134, y: 204.99333, z: -39.725758)),
        API::Landmark.new(type: "MOUTH_CENTER", position: API::Position.new(x: 136.43481, y: 204.37952, z: -51.620205)),
        API::Landmark.new(type: "NOSE_BOTTOM_RIGHT", position: API::Position.new(x: 161.31354, y: 168.24527, z: -36.1628)),
        API::Landmark.new(type: "NOSE_BOTTOM_LEFT", position: API::Position.new(x: 110.98372, y: 173.61331, z: -29.7784)),
        API::Landmark.new(type: "NOSE_BOTTOM_CENTER", position: API::Position.new(x: 133.81947, y: 173.16437, z: -48.287724)),
        API::Landmark.new(type: "LEFT_EYE_TOP_BOUNDARY", position: API::Position.new(x: 86.706947, y: 119.47144, z: -4.1606765)),
        API::Landmark.new(type: "LEFT_EYE_RIGHT_CORNER", position: API::Position.new(x: 105.28892, y: 125.57655, z: -2.51554)),
        API::Landmark.new(type: "LEFT_EYE_BOTTOM_BOUNDARY", position: API::Position.new(x: 84.883934, y: 134.59479, z: -2.8677137)),
        API::Landmark.new(type: "LEFT_EYE_LEFT_CORNER", position: API::Position.new(x: 72.213913, y: 132.04138, z: 9.6985674)),
        API::Landmark.new(type: "RIGHT_EYE_TOP_BOUNDARY", position: API::Position.new(x: 173.99446, y: 107.94287, z: -16.050705)),
        API::Landmark.new(type: "RIGHT_EYE_RIGHT_CORNER", position: API::Position.new(x: 194.59413, y: 115.91954, z: -6.952745)),
        API::Landmark.new(type: "RIGHT_EYE_BOTTOM_BOUNDARY", position: API::Position.new(x: 179.30353, y: 121.03307, z: -14.843414)),
        API::Landmark.new(type: "RIGHT_EYE_LEFT_CORNER", position: API::Position.new(x: 158.2863, y: 118.491, z: -9.723031)),
        API::Landmark.new(type: "LEFT_EYEBROW_UPPER_MIDPOINT", position: API::Position.new(x: 80.248711, y: 94.04303, z: 0.21131183)),
        API::Landmark.new(type: "RIGHT_EYEBROW_UPPER_MIDPOINT", position: API::Position.new(x: 174.70135, y: 81.580917, z: -12.702137)),
        API::Landmark.new(type: "LEFT_EAR_TRAGION", position: API::Position.new(x: 54.872219, y: 207.23712, z: 97.030685)),
        API::Landmark.new(type: "RIGHT_EAR_TRAGION", position: API::Position.new(x: 252.67567, y: 180.43124, z: 70.15992)),
        API::Landmark.new(type: "LEFT_EYE_PUPIL", position: API::Position.new(x: 86.531624, y: 126.49807, z: -2.2496929)),
        API::Landmark.new(type: "RIGHT_EYE_PUPIL", position: API::Position.new(x: 175.99976, y: 114.64407, z: -14.53744)),
        API::Landmark.new(type: "FOREHEAD_GLABELLA", position: API::Position.new(x: 126.53813, y: 93.812057, z: -18.863352)),
        API::Landmark.new(type: "CHIN_GNATHION", position: API::Position.new(x: 143.34183, y: 262.22998, z: -57.388493)),
        API::Landmark.new(type: "CHIN_LEFT_GONION", position: API::Position.new(x: 63.102425, y: 248.99081, z: 44.207638)),
        API::Landmark.new(type: "CHIN_RIGHT_GONION", position: API::Position.new(x: 241.72728, y: 225.53488, z: 19.758242))
      ],
      roll_angle: -0.050002542,
      pan_angle: -0.081090336,
      tilt_angle: 0.18012161,
      detection_confidence: 0.56748849,
      landmarking_confidence: 34.489909,
      joy_likelihood:          "LIKELY",
      sorrow_likelihood:       "UNLIKELY",
      anger_likelihood:        "VERY_UNLIKELY",
      surprise_likelihood:     "UNLIKELY",
      under_exposed_likelihood: "VERY_UNLIKELY",
      blurred_likelihood:      "VERY_UNLIKELY",
      headwear_likelihood:     "VERY_UNLIKELY",
    )
  end

  def landmark_annotation_response
    API::EntityAnnotation.new(
      mid: "/m/019dvv",
      description: "Mount Rushmore",
      score: 0.91912264,
      bounding_poly: bounding_poly,
      locations: [
        API::LocationInfo.new(
          lat_lng: API::LatLng.new(latitude: 43.878264, longitude: -103.45700740814209)
        )
     ]
    )
  end

  def logo_annotation_response
    API::EntityAnnotation.new(
      mid: "/m/045c7b",
      description: "Google",
      score: 0.6435439,
      bounding_poly: bounding_poly
    )
  end

  def label_annotation_response
    API::EntityAnnotation.new(
      mid: "/m/02wtjj",
      description: "stone carving",
      score: 0.9859733
    )
  end

  def text_annotation_response
    API::EntityAnnotation.new(
      locale: "en",
      description: "Google Cloud Client Library for Ruby an idiomatic, intuitive, and\nnatural way for Ruby developers to integrate with Google Cloud\nPlatform services, like Cloud Datastore and Cloud Storage.\n",
      bounding_poly: bounding_poly
    )
  end

  def text_annotation_responses
    [ text_annotation_response,
      API::EntityAnnotation.new(description: "Google", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 13, y: 8), API::Vertex.new(x: 53, y: 8), API::Vertex.new(x: 53, y: 23), API::Vertex.new(x: 13, y: 23)])),
      API::EntityAnnotation.new(description: "Cloud", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 59, y: 8), API::Vertex.new(x: 89, y: 8), API::Vertex.new(x: 89, y: 23), API::Vertex.new(x: 59, y: 23)])),
      API::EntityAnnotation.new(description: "Client", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 96, y: 8), API::Vertex.new(x: 128, y: 8), API::Vertex.new(x: 128, y: 23), API::Vertex.new(x: 96, y: 23)])),
      API::EntityAnnotation.new(description: "Library", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 132, y: 8), API::Vertex.new(x: 170, y: 8), API::Vertex.new(x: 170, y: 23), API::Vertex.new(x: 132, y: 23)])),
      API::EntityAnnotation.new(description: "for", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 175, y: 8), API::Vertex.new(x: 191, y: 8), API::Vertex.new(x: 191, y: 23), API::Vertex.new(x: 175, y: 23)])),
      API::EntityAnnotation.new(description: "Ruby", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 195, y: 8), API::Vertex.new(x: 221, y: 8), API::Vertex.new(x: 221, y: 23), API::Vertex.new(x: 195, y: 23)])),
      API::EntityAnnotation.new(description: "an", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 236, y: 8), API::Vertex.new(x: 245, y: 8), API::Vertex.new(x: 245, y: 23), API::Vertex.new(x: 236, y: 23)])),
      API::EntityAnnotation.new(description: "idiomatic,", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 250, y: 8), API::Vertex.new(x: 307, y: 8), API::Vertex.new(x: 307, y: 23), API::Vertex.new(x: 250, y: 23)])),
      API::EntityAnnotation.new(description: "intuitive,", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 311, y: 8), API::Vertex.new(x: 360, y: 8), API::Vertex.new(x: 360, y: 23), API::Vertex.new(x: 311, y: 23)])),
      API::EntityAnnotation.new(description: "and", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 363, y: 8), API::Vertex.new(x: 385, y: 8), API::Vertex.new(x: 385, y: 23), API::Vertex.new(x: 363, y: 23)])),
      API::EntityAnnotation.new(description: "natural", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 13, y: 33), API::Vertex.new(x: 52, y: 33), API::Vertex.new(x: 52, y: 49), API::Vertex.new(x: 13, y: 49)])),
      API::EntityAnnotation.new(description: "way", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 56, y: 33), API::Vertex.new(x: 77, y: 33), API::Vertex.new(x: 77, y: 49), API::Vertex.new(x: 56, y: 49)])),
      API::EntityAnnotation.new(description: "for", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 82, y: 33), API::Vertex.new(x: 98, y: 33), API::Vertex.new(x: 98, y: 49), API::Vertex.new(x: 82, y: 49)])),
      API::EntityAnnotation.new(description: "Ruby", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 102, y: 33), API::Vertex.new(x: 130, y: 33), API::Vertex.new(x: 130, y: 49), API::Vertex.new(x: 102, y: 49)])),
      API::EntityAnnotation.new(description: "developers", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 135, y: 33), API::Vertex.new(x: 196, y: 33), API::Vertex.new(x: 196, y: 49), API::Vertex.new(x: 135, y: 49)])),
      API::EntityAnnotation.new(description: "to", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 201, y: 33), API::Vertex.new(x: 212, y: 33), API::Vertex.new(x: 212, y: 49), API::Vertex.new(x: 201, y: 49)])),
      API::EntityAnnotation.new(description: "integrate", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 215, y: 33), API::Vertex.new(x: 265, y: 33), API::Vertex.new(x: 265, y: 49), API::Vertex.new(x: 215, y: 49)])),
      API::EntityAnnotation.new(description: "with", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 270, y: 33), API::Vertex.new(x: 293, y: 33), API::Vertex.new(x: 293, y: 49), API::Vertex.new(x: 270, y: 49)])),
      API::EntityAnnotation.new(description: "Google", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 299, y: 33), API::Vertex.new(x: 339, y: 33), API::Vertex.new(x: 339, y: 49), API::Vertex.new(x: 299, y: 49)])),
      API::EntityAnnotation.new(description: "Cloud", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 345, y: 33), API::Vertex.new(x: 376, y: 33), API::Vertex.new(x: 376, y: 49), API::Vertex.new(x: 345, y: 49)])),
      API::EntityAnnotation.new(description: "Platform", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 13, y: 59), API::Vertex.new(x: 59, y: 59), API::Vertex.new(x: 59, y: 74), API::Vertex.new(x: 13, y: 74)])),
      API::EntityAnnotation.new(description: "services,", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 67, y: 59), API::Vertex.new(x: 117, y: 59), API::Vertex.new(x: 117, y: 74), API::Vertex.new(x: 67, y: 74)])),
      API::EntityAnnotation.new(description: "like", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 121, y: 59), API::Vertex.new(x: 138, y: 59), API::Vertex.new(x: 138, y: 74), API::Vertex.new(x: 121, y: 74)])),
      API::EntityAnnotation.new(description: "Cloud", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 145, y: 59), API::Vertex.new(x: 177, y: 59), API::Vertex.new(x: 177, y: 74), API::Vertex.new(x: 145, y: 74)])),
      API::EntityAnnotation.new(description: "Datastore", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 181, y: 59), API::Vertex.new(x: 236, y: 59), API::Vertex.new(x: 236, y: 74), API::Vertex.new(x: 181, y: 74)])),
      API::EntityAnnotation.new(description: "and", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 242, y: 59), API::Vertex.new(x: 260, y: 59), API::Vertex.new(x: 260, y: 74), API::Vertex.new(x: 242, y: 74)])),
      API::EntityAnnotation.new(description: "Cloud", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 267, y: 59), API::Vertex.new(x: 298, y: 59), API::Vertex.new(x: 298, y: 74), API::Vertex.new(x: 267, y: 74)])),
      API::EntityAnnotation.new(description: "Storage.", bounding_poly: API::BoundingPoly.new(vertices: [API::Vertex.new(x: 304, y: 59), API::Vertex.new(x: 351, y: 59), API::Vertex.new(x: 351, y: 74), API::Vertex.new(x: 304, y: 74)]))
    ]
  end

  def safe_search_annotation_response
    API::SafeSearchAnnotation.new(
      adult:    "VERY_UNLIKELY",
      spoof:    "UNLIKELY",
      medical:  "POSSIBLE",
      violence: "LIKELY"
    )
  end

  def properties_annotation_response
    API::ImageProperties.new(
      dominant_colors: API::DominantColorsAnnotation.new(
        colors: [
          API::ColorInfo.new(color: API::Color.new(red: 145, green: 193, blue: 254),
                             score: 0.65757853,
                             pixel_fraction: 0.16903226),
          API::ColorInfo.new(color: API::Color.new(red: 0, green: 0, blue: 0),
                             score: 0.09256918,
                             pixel_fraction: 0.19258064),
          API::ColorInfo.new(color: API::Color.new(red: 255, green: 255, blue: 255),
                             score: 0.1002003,
                             pixel_fraction: 0.022258064),
          API::ColorInfo.new(color: API::Color.new(red: 3, green: 4, blue: 254),
                             score: 0.089072376,
                             pixel_fraction: 0.054516129),
          API::ColorInfo.new(color: API::Color.new(red: 168, green: 215, blue: 255),
                             score: 0.019252902,
                             pixel_fraction: 0.0070967744),
          API::ColorInfo.new(color: API::Color.new(red: 127, green: 177, blue: 255),
                             score: 0.017626688,
                             pixel_fraction: 0.0045161289),
          API::ColorInfo.new(color: API::Color.new(red: 178, green: 223, blue: 255),
                             score: 0.015010362,
                             pixel_fraction: 0.0022580645),
          API::ColorInfo.new(color: API::Color.new(red: 172, green: 224, blue: 255),
                             score: 0.0049617039,
                             pixel_fraction: 0.0012903226),
          API::ColorInfo.new(color: API::Color.new(red: 160, green: 218, blue: 255),
                             score: 0.0027604031,
                             pixel_fraction: 0.0022580645),
          API::ColorInfo.new(color: API::Color.new(red: 156, green: 214, blue: 255),
                             score: 0.00096750073,
                             pixel_fraction: 0.00064516132)
        ]
      )
    )
  end
end
