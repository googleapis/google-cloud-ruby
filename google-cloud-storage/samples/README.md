<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Storage Ruby Samples

This directory contains samples for google-cloud-storage. [Google Cloud Storage][storage_docs] allows world-wide storage
and retrieval of any amount of data at any time.

[storage_docs]: https://cloud.google.com/storage/docs/

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

    `gcloud auth application-default login`

1. When running on App Engine or Compute Engine, credentials are already set-up.
However, you may need to configure your Compute Engine instance with
[additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)
. This file can be used to authenticate to Google Cloud Platform services from
any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
environment variable to the path to the key file, for example:

    `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json`

### Set Project ID

Next, set the *GOOGLE_CLOUD_PROJECT* environment variable to the project name
set in the
[Google Cloud Platform Developer Console](https://console.cloud.google.com):

    `export GOOGLE_CLOUD_PROJECT="YOUR-PROJECT-ID"`

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

    `bundle install`

## Run samples

**Usage:** `ruby sample.rb [arguments]`

##### List of executable samples files and their arguments

| File | Args | Description |
| --- | --- | --- |
| generate_signed_url.rb | `bucket` `file` | Generate a V2 signed url for a file |
| storage_activate_hmac_key.rb | `access_id` | Activate an HMAC Key |
| storage_add_bucket_conditional_iam_binding.rb | `bucket` `iam_role` `iam_member` `cond_title` `cond_description` `cond_expr` | Add a conditional bucket-level binding |
| storage_add_bucket_iam_member.rb | `bucket` `iam_role` `iam_member` | Add a bucket-level IAM member |
| storage_add_bucket_label.rb | `bucket` `label_key` `label_value` | Add bucket label |
| storage_copy_file.rb | `src_bucket` `src_file` `dest_bucket` `dest_file` | Copy file to other bucket |
| storage_create_bucket.rb | `bucket` | Create a new bucket with default storage class and location |
| storage_create_bucket_class_location.rb | `bucket` `location` `storage_class` | Create a new bucket with specific storage class and location |
| storage_create_hmac_key.rb | `service_account_email` | Create HMAC Key |
| storage_deactivate_hmac_key.rb | `access_id` | Deactivate an HMAC Key |
| storage_delete_bucket.rb | `bucket` | Delete bucket with the provided name |
| storage_delete_file.rb | `bucket` `file` | Delete a file from a bucket |
| storage_delete_hmac_key.rb | `access_id` | Delete a deactivated HMAC key |
| storage_disable_default_event_based_hold.rb | `bucket` | Disable event-based hold for a bucket |
| storage_disable_requester_pays.rb | `bucket` | Disable requester pays for a bucket |
| storage_disable_uniform_bucket_level_access.rb | `bucket` | Disable uniform bucket-level access for a bucket |
| storage_download_encrypted_file.rb | `bucket` `file` `path` `encryption_key` | Download an encrypted file from a bucket |
| storage_download_file.rb | `bucket` `file` `path` | Download a file from a bucket |
| storage_download_file_requester_pays.rb | `project` `bucket` `file` `path` | Download a file from a requester pays enabled bucket |
| storage_download_public_file.rb | `bucket` `file` `path` | Download a publically accessible file from a bucket |
| storage_enable_default_event_based_hold.rb | `bucket` | Enable event-based hold for a bucket |
| storage_enable_requester_pays.rb | `bucket` | Enable requester pays for a bucket |
| storage_enable_uniform_bucket_level_access.rb | `bucket` | Enable uniform bucket-level access for a bucket |
| storage_generate_encryption_key.rb | | Generate a sample encryption key |
| storage_generate_signed_post_policy_v4.rb | `bucket` `file` | Generate a V4 signed post policy for a file and print HTML form |
| storage_generate_signed_url_v4.rb | `bucket` `file` | Generate a V4 signed get url for a file |
| storage_generate_upload_signed_url_v4.rb | `bucket` `file` | Generate a V4 signed put url for a file |
| storage_get_default_event_based_hold.rb | `bucket` | Get state of event-based hold for a bucket |
| storage_get_hmac_key | `access_id` | Get HMAC Key metadata |
| storage_get_metadata.rb | `bucket` `file` | Display metadata for a file in a bucket |
| storage_get_retention_policy.rb | `bucket` | Get retention policy for a bucket |
| storage_get_uniform_bucket_level_access.rb | `bucket` | Get uniform bucket-level access for a bucket |
| storage_list_buckets.rb | | List all buckets in the authenticated project |
| storage_list_files.rb | `bucket` | List all files in the bucket |
| storage_list_hmac_keys.rb | | List all HMAC keys for a project |
| storage_lock_retention_policy.rb | `bucket` | Lock retention policy |
| storage_make_public.rb | `bucket` `file` | Make a file in a bucket public |
| storage_move_file.rb | `bucket` `file` `new` | Rename a file in a bucket |
| storage_release_event_based_hold.rb | `bucket` `file` | Relase an event-based hold on a file |
| storage_release_temporary_hold.rb | `bucket` `file` | Release a temporary hold on a file |
| storage_remove_bucket_conditional_iam_binding.rb | `bucket` `iam_member` `cond_title` `cond_description` `cond_expr` | Remove a conditional bucket-level binding |
| storage_remove_bucket_iam_member.rb | `bucket` `iam_role` `iam_member` | Remove a bucket-level IAM member |
| storage_remove_bucket_label.rb | `bucket` `label_key` | Delete bucket label |
| storage_remove_retention_policy.rb | `bucket` | Remove a retention policy from a bucket if policy is not locked |
| storage_rotate_encryption_key.rb | `bucket` `file` `base64_current_encryption_key` `base64_new_encryption_key` | Update encryption key of an encrypted file. |
| storage_set_bucket_default_kms_key.rb | `bucket` `kms_key` | Enable default KMS encryption for bucket |
| storage_set_event_based_hold.rb | `bucket` `file` | Set an event-based hold on a file |
| storage_set_retention_policy.rb | `bucket` `retention_period` | Set a retention policy on bucket with a retention period determined in seconds |
| storage_set_temporary_hold.rb | `bucket` `file` | Set a temporary hold on a file |
| storage_upload_encrypted_file.rb | `bucket` `file` `dest_path` `encryption_key` | Upload local file as an encrypted file to a bucket |
| storage_upload_file.rb | `bucket` `file` `dest_path` | Upload local file to a bucket |
| storage_upload_with_kms_key.rb | `bucket` `file` `dest_path` `kms_key` | Upload local file and encrypt service side using a KMS key |
| storage_view_bucket_iam_members.rb | `bucket` | View bucket-level IAM members |

## Run tests

Run the tests for these samples by running `bundle exec rake test`.
