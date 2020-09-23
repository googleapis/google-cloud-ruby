<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Storage Ruby Samples

[Cloud Storage][storage_docs] allows world-wide storage and retrieval of any
amount of data at any time.

[storage_docs]: https://cloud.google.com/storage/docs/

## Run sample

To run the sample, first install dependencies:

    bundle install

Run the sample:

    bundle exec ruby buckets.rb
    bundle exec ruby files.rb
    bundle exec ruby acls.rb

## Samples

### Buckets

**Usage:** `bundle exec ruby buckets.rb [command] [arguments]`

```
Usage: bundle exec ruby buckets.rb [command] [arguments]

Commands:
  list                                                                 List all buckets in the authenticated project
  enable_requester_pays               <bucket>                            Enable requester pays for a bucket
  disable_requester_pays              <bucket>                            Disable requester pays for a bucket
  check_requester_pays                <bucket>                            Check status of requester pays for a bucket
  enable_default_kms_key              <bucket> <kms_key>                  Enable default KMS encryption for bucket
  create                              <bucket>                            Create a new bucket with default storage class and location
  create                              <bucket> <location> <storage_class> Create a new bucket with specific storage class and location
  add_bucket_label                    <bucket> <label_key> <label_value>  Add bucket label
  delete_bucket_label                 <bucket> <label_key>                Delete bucket label
  delete                              <bucket>                            Delete bucket with the provided name
  set_retention_policy                <bucket> <retention_period>         Set a retention policy on bucket with a retention period determined in seconds
  remove_retention_policy             <bucket>                            Remove a retention policy from a bucket if policy is not locked
  lock_retention_policy               <bucket>                            Lock retention policy
  get_retention_policy                <bucket>                            Get retention policy for a bucket
  enable_default_event_based_hold     <bucket>                            Enable event-based hold for a bucket
  disable_default_event_based_hold    <bucket>                            Disable event-based hold for a bucket
  get_default_event_based_hold        <bucket>                            Get state of event-based hold for a bucket
  enable_uniform_bucket_level_access  <bucket>                            Enable uniform bucket-level access for a bucket
  disable_uniform_bucket_level_access <bucket>                            Disable uniform bucket-level access for a bucket
  get_uniform_bucket_level_access     <bucket>                            Get uniform bucket-level access for a bucket

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
```

### Files

**Usage:** `bundle exec ruby files.rb [command] [arguments]`

```
Usage: bundle exec ruby files.rb [command] [arguments]

Commands:
  list                 <bucket>                                     List all files in the bucket
  upload               <bucket> <file> <dest_path>                  Upload local file to a bucket
  encrypted_upload     <bucket> <file> <dest_path> <encryption_key> Upload local file as an encrypted file to a bucket
  kms_upload           <bucket> <file> <dest_path> <kms_key>        Upload local file and encrypt service side using a KMS key
  download             <bucket> <file> <path>                       Download a file from a bucket
  download_public_file <bucket> <file> <path>                       Download a publically accessible file from a bucket
  encrypted_download <bucket> <file> <path> <encryption_key>        Download an encrypted file from a bucket
  download_with_requester_pays <project> <bucket> <file> <path>     Download a file from a requester pays enabled bucket
  rotate_encryption_key <bucket> <file> <base64_current_encryption_key> <base64_new_encryption_key> Update encryption key of an encrypted file.
  generate_encryption_key                                           Generate a sample encryption key
  delete       <bucket> <file>                                      Delete a file from a bucket
  metadata     <bucket> <file>                                      Display metadata for a file in a bucket
  make_public  <bucket> <file>                                      Make a file in a bucket public
  rename       <bucket> <file> <new>                                Rename a file in a bucket
  copy <srcBucket> <srcFile> <destBucket> <destFile>                Copy file to other bucket
  generate_signed_url <bucket> <file>                               Generate a V2 signed url for a file
  generate_signed_get_url_v4 <bucket> <file>                        Generate a V4 signed get url for a file
  generate_signed_put_url_v4 <bucket> <file>                        Generate a V4 signed put url for a file
  generate_signed_post_policy_v4 <bucket> <file>                    Generate a V4 signed post policy for a file and print HTML form
  set_event_based_hold       <bucket> <file>                        Set an event-based hold on a file
  release_event_based_hold   <bucket> <file>                        Relase an event-based hold on a file
  set_temporary_hold         <bucket> <file>                        Set a temporary hold on a file
  release_temporary_hold     <bucket> <file>                        Release a temporary hold on a file

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
```

### Access Control List

**Usage:** `bundle exec ruby acls.rb [command] [arguments]`

```
Usage: bundle exec ruby acls.rb [command] [arguments]

Commands:
  print_bucket_acl <bucket>                  Print bucket Access Control List
  print_bucket_acl_for_user <bucket> <email> Print bucket ACL for an email
  add_bucket_owner <bucket> <email>          Add a new OWNER to a bucket
  remove_bucket_acl <bucket> <email>         Remove an entity from a bucket ACL
  add_bucket_default_owner <bucket> <email>  Add a default OWNER for a bucket
  remove_bucket_default_acl <bucket> <email> Remove an entity from default bucket ACL
  print_file_acl <bucket> <file>             Print file ACL
  print_file_acl_for_user <bucket> <file> <email> Print file ACL for an email
  add_file_owner <bucket> <file> <email>          Add an OWNER to a file
  remove_file_acl <bucket> <file> <email>         Remove an entity from a file ACL

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
```

### Cloud Storage Bucket-level Identity & Access Management

**Usage:** `bundle exec ruby iam.rb [command] [arguments]`

```
Usage: bundle exec ruby iam.rb [command] [arguments]

Commands:
  view_bucket_iam_members  <bucket>                                                                                View bucket-level IAM members
  add_bucket_iam_member    <bucket> <iam_role> <iam_member>                                                        Add a bucket-level IAM member
  add_bucket_conditional_iam_binding <bucket> <iam_role> <iam_member> <cond_title> <cond_description> <cond_expr>  Add a conditional bucket-level binding
  remove_bucket_iam_member <bucket> <iam_role> <iam_member>                                                        Remove a bucket-level IAM member
  remove_bucket_conditional_iam_binding <bucket> <iam_member> <cond_title> <cond_description> <cond_expr>          Remove a conditional bucket-level binding

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
```

### Cloud Storage Service Account HMAC Key Management

**Usage:** `bundle exec ruby hmac.rb [commmand] [arguments]`

```
Usage: bundle exec ruby hmac.rb [command] [arguments]

Commands:
  list_hmac_keys                               List all HMAC keys for a project
  create_hmac_key     <serviceAccountEmail>    Create HMAC Key
  get_hmac_key        <accessId>               Get HMAC Key metadata
  activate_hmac_key   <accessId>               Activate an HMAC Key
  deactivate_hmac_key <accessId>               Deactivate an HMAC Key
  delete_hmac_key     <accessId>               Delete a deactivated HMAC key

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
```
