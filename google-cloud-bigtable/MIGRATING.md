# Migrating to google-cloud-bigtable-admin-v2

The `google-cloud-bigtable` client is undergoing changes, which include the deprecation and migration of some functionality to another gem. Specifically, the admin operations of Bigtable are being moved to a separate client `google-cloud-bigtable-admin-v2`.

If you’re using the `google-cloud-bigtable` client for admin operations, you should migrate to using the `google-cloud-bigtable-admin-v2` client instead (see the next section on what constitutes admin operations). This document guides you to migrate your application to use `google-cloud-bigtable-admin-v2` for all the admin operations.


## What are admin & non-admin operations?

### Admin operations

Any APIs that you use in Cloud Bigtable to administer the tables and instances are admin operations. For these, you should start using the `google-cloud-bigtable-admin-v2` client. Some examples include:

* create or delete new instances & tables
* change schema of existing tables.
* manage app profiles & IAM policies
* manage backups of tables & instances.

### Non-admin operations

In contrast, the below operations don’t constitute admin operations. For them, you should continue to use the existing `google-cloud-bigtable` client as usual.

* read & write data from tables.
* import data into tables.

## How is google-cloud-bigtable-admin-v2 different?

The `google-cloud-bigtable-admin-v2` is based on a next-gen code generator, and includes substantial interface changes. The code generator creates Ruby clients from a protocol buffer description of an API. This ensures that the API usage is consistent & uniform across all the Google Cloud services.

In contrast, the existing `google-cloud-bigtable` client is an idiomatic handwritten library. This will continue to serve the non-admin operations of Cloud Bigtable.

## Overview of google-cloud-bigtable-admin-v2 gem

The below is a high level overview of the google-cloud-bigtable-admin-v2 client. The rest of the guide goes into the detail and helps you understand how to migrate to the newer client.

* **Library Structure** - The handwritten client google-cloud-bigtable contains APIs to read & write data into the tables, whereas the auto-generated client google-cloud-bigtable-admin-v2 contains APIs to manage the administration of instances, tables, etc. See the section Library Structure for more info.
* **Class Namespaces** - All the classes in google-cloud-bigtable-admin-v2 are accessed through different namespaces. See Class Namespaces for more info.
* **Creation & Configuration** - The library uses a new configuration mechanism giving you closer control over endpoint address, network timeouts, and retry. See Client Configuration for more info. When creating a client object, you can customize its configuration in a block. See the section Creating Clients for more info.
* **Passing arguments** -  Previously, positional arguments were used to indicate required arguments. Now, all method arguments are keyword arguments, with documentation that specifies whether they are required or optional. Additionally, you can pass a proto request object instead of separate arguments. See the section Passing Arguments for more info.
* **Resource paths** - The auto-generated client includes helper methods for generating the resource path strings passed to many calls. See Resource Path Helpers for more info.
* **API differences** - The APIs are 
* **Errors** - All the RPCs errors in the client google-cloud-bigtable-admin-v2 are of type `Google::Cloud::Error` and its subclasses. See the section Handling Errors for more info.