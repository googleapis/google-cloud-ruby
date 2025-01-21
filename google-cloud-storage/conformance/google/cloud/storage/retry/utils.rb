# Copyright 2022 Google LLC
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

require "securerandom"

module MethodMapping

  CONF_TEST_SERVICE_ACCOUNT_EMAIL = "my-service-account@test.iam.gserviceaccount.com"
  CONF_TEST_ACL_ENTITY = "my-entity@example.net"
  CONF_TEST_PUBSUB_TOPIC_NAME = "yet-another-topic"
  CONF_TEST_FILE_CONTENT = "my-test-file"
  CONF_TEST_FILE_PATH = "my-test-file.txt"

  #############################################################################
  ### Method Invocation Mapping ###############################################
  #############################################################################

  # Method invocation mapping is a map whose keys are a string describing a standard
  # API call (e.g. storage.objects.get) and values are a list of functions which
  # wrap library methods that implement these calls. There may be multiple values
  # because multiple library methods may use the same call (e.g. get could be a
  # read or just a metadata get).

  def self.get
  {
    "storage.bucket_acl.delete" => [
      :delete_acl,
      :delete_bucket_acl
    ],
    "storage.bucket_acl.insert" => [
      :insert_acl,
      :insert_bucket_acl
    ],
    "storage.bucket_acl.list" => [:list_bucket_acls],
    "storage.buckets.delete" => [:delete_bucket],
    "storage.buckets.get" => [
      :bucket_reload,
      :get_bucket
    ],
    "storage.buckets.getIamPolicy" => [:get_bucket_policy],
    "storage.buckets.insert" => [:insert_bucket],
    "storage.buckets.list" => [:list_buckets],
    "storage.buckets.lockRetentionPolicy" => [:bucket_lock_retention_policy],
    "storage.buckets.patch" => [
      :bucket_acl_private,
      :bucket_acl_public,
      :default_acl_owner_full,
      :patch_bucket
    ],
    "storage.buckets.setIamPolicy" => [:set_bucket_policy],
    "storage.buckets.testIamPermissions" => [
      :test_bucket_permissions,
      :test_permissions
    ],
    "storage.default_object_acl.delete" => [
      :delete_bucket_default_acl,
      :delete_default_acl
    ],
    "storage.default_object_acl.insert" => [
      :insert_bucket_default_acl,
      :insert_default_acl
    ],
    "storage.default_object_acl.list" => [:list_default_acls],
    "storage.hmacKey.create" => [:create_hmac_key],
    "storage.hmacKey.delete" => [:delete_hmac_key],
    "storage.hmacKey.get" => [
      :get_hmac_key,
      :hmac_key_reload
    ],
    "storage.hmacKey.list" => [:list_hmac_keys],
    "storage.hmacKey.update" => [:update_hmac_key],
    "storage.notifications.delete" => [:delete_notification],
    "storage.notifications.get" => [
      :bucket_get_notification,
      :get_notification,
    ],
    "storage.notifications.insert" => [
      :create_notification,
      :insert_notification
    ],
    "storage.notifications.list" => [
      :bucket_notifications,
      :list_notifications
    ],
    "storage.object_acl.delete" => [:delete_file_acl],
    "storage.object_acl.insert" => [:insert_file_acl],
    "storage.object_acl.list" => [:list_file_acls],
    "storage.objects.compose" => [:compose_file],
    "storage.objects.delete" => [:delete_file],
    "storage.objects.get" => [
      :download_file,
      :get_file,
      :get_object
    ],
    "storage.objects.insert" => [
      :insert_object
    ],
    "storage.objects.list" => [:list_files],
    "storage.objects.patch" => [:patch_file],
    "storage.objects.rewrite" => [:rewrite_file],
    "storage.serviceaccount.get" => [:project_service_account]
  }
  end

  #############################################################################
  ### Library methods for mapping #############################################
  #############################################################################

  def self.delete_acl client, _preconditions, **resources
    acl = resources[:bucket].acl
    acl.delete "allAuthenticatedUsers"
  end

  def self.delete_bucket_acl client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    entity = "allAuthenticatedUsers"
    client.delete_bucket_acl bucket_name, entity
  end

  def self.insert_acl client, _preconditions, **resources
    acl = resources[:bucket].acl
    acl.add_writer CONF_TEST_ACL_ENTITY
  end

  def self.insert_bucket_acl client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    entity = CONF_TEST_ACL_ENTITY
    role = "READER"
    client.insert_bucket_acl bucket_name, entity, role
  end

  def self.list_bucket_acls client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    client.list_bucket_acls bucket_name
  end

  def self.delete_bucket client, _preconditions, **resources
    bucket = resources[:bucket]
    bucket.files.all { |f| f.delete rescue nil }
    bucket.delete
  end

  def self.bucket_reload client, _preconditions, **resources
    bucket = resources[:bucket]
    bucket.reload!
  end

  def self.get_bucket client, _preconditions, **resources
    client.get_bucket resources[:bucket].name
  end

  def self.get_bucket_policy client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    client.get_bucket_policy bucket_name
  end

  def self.insert_bucket client, _preconditions, **resources
    bucket_name = "new-bucket-" + Time.now.to_i.to_s + "-" + SecureRandom.hex(4)
    new_bucket = Google::Apis::StorageV1::Bucket.new name: bucket_name
    client.insert_bucket(new_bucket)
  end

  def self.list_buckets client, _preconditions, **resources
    client.list_buckets
  end

  def self.bucket_lock_retention_policy client, _preconditions, **resources
    bucket = resources[:bucket]
    bucket.retention_period = 60
    bucket.lock_retention_policy!
  end

  def self.bucket_acl_private client, preconditions, **resources
    bucket = resources[:bucket]
    if preconditions
      bucket.acl.private! if_metageneration_match: bucket.metageneration
    else
      bucket.acl.private!
    end
  end

  def self.bucket_acl_public client, preconditions, **resources
    bucket = resources[:bucket]
    if preconditions
      bucket.acl.public! if_metageneration_match: bucket.metageneration
    else
      bucket.acl.public!
    end
  end

  def self.default_acl_owner_full client, preconditions, **resources
    bucket = resources[:bucket]
    if preconditions
      bucket.default_acl.owner_full! if_metageneration_match: bucket.metageneration
    else
      bucket.default_acl.owner_full!
    end
  end

  def self.patch_bucket client, preconditions, **resources
    bucket = resources[:bucket]
    metageneration = resources[:bucket].metageneration
    bucket_gapi = Google::Apis::StorageV1::Bucket.new storage_class: "COLDLINE"
    if preconditions
      client.patch_bucket bucket.name, bucket_gapi, if_metageneration_match: metageneration
    else
      client.patch_bucket bucket.name, bucket_gapi
    end
  end

  def self.set_bucket_policy client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    role = "roles/storage.objectViewer"
    member = "serviceAccount:#{CONF_TEST_SERVICE_ACCOUNT_EMAIL}"

    policy = client.get_bucket_policy bucket_name, requested_policy_version: 3
    policy.bindings.append({"role": role, "members": [member]})

    # IAM policies have no metageneration, clear ETag to avoid checking that it matches.
    policy.etag = nil unless _preconditions
    client.set_bucket_policy bucket_name, policy
  end

  def self.test_bucket_permissions client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    permissions = ["storage.buckets.get", "storage.buckets.create"]
    client.test_bucket_permissions bucket_name, permissions
  end

  def self.test_permissions client, _preconditions, **resources
    bucket = resources[:bucket]
    permissions = ["storage.buckets.get", "storage.buckets.create"]
    bucket.test_permissions permissions
  end

  def self.delete_bucket_default_acl client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    entity = "allAuthenticatedUsers"
    client.delete_default_acl bucket_name, entity
  end

  def self.delete_default_acl client, _preconditions, **resources
    default_acl = resources[:bucket].default_acl
    entity = "allAuthenticatedUsers"
    default_acl.delete entity
  end

  def self.insert_bucket_default_acl client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    entity = CONF_TEST_ACL_ENTITY
    role = "READER"
    client.insert_default_acl bucket_name, entity, role
  end

  def self.insert_default_acl client, _preconditions, **resources
    default_acl = resources[:bucket].default_acl
    entity = CONF_TEST_ACL_ENTITY
    default_acl.add_owner entity
  end

  def self.list_default_acls client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    client.list_default_acls bucket_name
  end

  def self.create_hmac_key client, _preconditions, **resources
    client.create_hmac_key CONF_TEST_SERVICE_ACCOUNT_EMAIL
  end

  def self.delete_hmac_key client, _preconditions, **resources
    access_id = resources[:hmac_key].access_id
    client.delete_hmac_key access_id
  end

  def self.get_hmac_key client, _preconditions, **resources
    access_id = resources[:hmac_key].access_id
    client.get_hmac_key access_id
  end

  def self.hmac_key_reload client, _preconditions, **resources
    hmac_key = resources[:hmac_key]
    hmac_key.reload!
  end

  def self.list_hmac_keys client, _preconditions, **resources
    hmac_keys = client.list_hmac_keys
    hmac_keys.items.each do |hmac_key|
      next
    end
  end

  def self.update_hmac_key client, preconditions, **resources
    access_id = resources[:hmac_key].access_id
    etag = resources[:hmac_key].etag

    hmac_key = Google::Apis::StorageV1::HmacKeyMetadata.new access_id: access_id, state: "INACTIVE"
    hmac_key.etag = etag if preconditions
    client.update_hmac_key access_id, hmac_key
  end

  def self.delete_notification client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    notification_id = resources[:notification].id
    client.delete_notification bucket_name, notification_id
  end

  def self.bucket_get_notification client, _preconditions, **resources
    bucket = resources[:bucket]
    notification_id = resources[:notification].id
    bucket.notification notification_id
  end

  def self.get_notification client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    notification_id = resources[:notification].id
    client.get_notification bucket_name, notification_id
  end

  def self.create_notification client, _preconditions, **resources
    bucket = resources[:bucket]
    pubsub_topic_name = CONF_TEST_PUBSUB_TOPIC_NAME
    bucket.create_notification pubsub_topic_name
  end

  def self.insert_notification client, preconditions, **resources
    bucket_name = resources[:bucket].name
    pubsub_topic_name = CONF_TEST_PUBSUB_TOPIC_NAME
    client.insert_notification bucket_name, pubsub_topic_name
  end

  def self.bucket_notifications client, _preconditions, **resources
    bucket = resources[:bucket]
    notifications = bucket.notifications
    notifications.each do |notification|
      next
    end
  end

  def self.list_notifications client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    notifications = client.list_notifications bucket_name
    notifications.items.each do |notification|
      next
    end
  end

  def self.delete_file_acl client, _preconditions, **resources
    bucket = resources[:bucket]
    object = resources[:object]
    entity = "allAuthenticatedUsers"
    client.delete_file_acl bucket.name, object.name, entity
  end

  def self.insert_file_acl client, _preconditions, **resources
    bucket = resources[:bucket]
    object = resources[:object]
    entity = "allAuthenticatedUsers"
    role = "READER"
    client.insert_file_acl bucket.name, object.name, entity, role
  end

  def self.list_file_acls client, _preconditions, **resources
    bucket_name = resources[:bucket].name
    object_name = resources[:object].name
    client.list_file_acls bucket_name, object_name
  end

  def self.compose_file client, preconditions, **resources
    bucket = resources[:bucket]
    object = resources[:object]
    object_2 = bucket.create_file StringIO.new(CONF_TEST_FILE_CONTENT), "my-test-file-2"
    destination = "new-composite-object"
    if preconditions
      bucket.compose [object.name, object_2.name], destination, if_generation_match: 0 do |f|
        f.content_type = "text/plain"
      end
    else
      bucket.compose [object.name, object_2.name], destination do |f|
        f.content_type = "text/plain"
      end
    end
  end

  def self.delete_file client, preconditions, **resources
    bucket = resources[:bucket]
    object = resources[:object]
    if preconditions
      client.delete_file bucket.name, object.name, if_generation_match: object.generation
    else
      client.delete_file bucket.name, object.name
    end
  end

  def self.download_file client, _preconditions, **resources
    bucket = resources[:bucket]
    object = resources[:object]
    object.download
  end

  def self.get_file client, _preconditions, **resources
    bucket = resources[:bucket]
    object = resources[:object]
    client.get_file bucket.name, object.name
  end

  def self.get_object client, _preconditions, **resources
    bucket = resources[:bucket]
    object = resources[:object]
    bucket.file object.name
  end

  def self.insert_object client, preconditions, **resources
    bucket = resources[:bucket]
    file = StringIO.new CONF_TEST_FILE_CONTENT * 1024 * 1024 # 12MB
    if preconditions
      bucket.create_file file, CONF_TEST_FILE_PATH, if_generation_match: 0
    else
      bucket.create_file file, CONF_TEST_FILE_PATH
    end
  end

  def self.list_files client, _preconditions, **resources
    bucket = resources[:bucket]
    client.list_files bucket.name
  end

  def self.patch_file client, preconditions, **resources
    bucket = resources[:bucket]
    object = resources[:object]
    if preconditions
      client.patch_file bucket.name, object.name, if_metageneration_match: object.metageneration
    else
      client.patch_file bucket.name, object.name
    end
  end

  def self.rewrite_file client, preconditions, **resources
    bucket = resources[:bucket]
    object = resources[:object]
    if preconditions
      client.rewrite_file bucket.name, object.name, bucket.name, "destination-object", if_generation_match: 0
    else
      client.rewrite_file bucket.name, object.name, bucket.name, "destination-object"
    end
  end

  def self.project_service_account client, _preconditions, **resources
    client.project_service_account
  end
end
