# Google Parameter Manager API Samples

Parameter Manager provides a centralized storage for all configuration parameters related to your workload deployments.
Parameters are variables, often in the form of key-value pairs, which customize how an application functions.

## Description

These samples show how to use the [Google Parameter Manager API]
(https://cloud.google.com/secret-manager/parameter-manager/docs/overview).

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1.  When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

    gcloud auth application-default login

1.  When running on App Engine or Compute Engine, credentials are already set-up.
    However, you may need to configure your Compute Engine instance with
    [additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1.  You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)
    . This file can be used to authenticate to Google Cloud Platform services from
    any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
    environment variable to the path to the key file, for example:

           export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json

## Build and Run

1.  **Enable APIs** - [Enable the Parameter Manager API](https://console.cloud.google.com/flows/enableapi?apiid=parametermanager.googleapis.com)
    and create a new project or select an existing project.

1.  **Install and Initialize Cloud SDK**
    Follow instructions from the available [quickstarts](https://cloud.google.com/sdk/docs/quickstarts)

1.  **Clone the repo** and cd into this directory

    ```text
    $ git clone https://github.com/googleapis/google-cloud-ruby
    $ cd google-cloud-ruby/google-cloud-parameter_manager/samples
    ```

1.  **Install Dependencies** via [Bundler](https://bundler.io).

    ```text
    $ bundle install
    ```

1.  **Set Environment Variables**

    ```text
    $ export GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"
    $ export GOOGLE_CLOUD_LOCATION="YOUR_LOCATION_ID"
    $ export GOOGLE_CLOUD_TAG_KEY="YOUR_TAG_KEY_ID"
    $ export GOOGLE_CLOUD_TAG_VALUE="YOUR_TAG_VALUE_ID"
    ```

    `GOOGLE_CLOUD_TAG_KEY` and `GOOGLE_CLOUD_TAG_VALUE` (for example `tagKeys/123456789` and `tagValues/123456789`)
    must refer to an existing tag key and tag value. They are only used by the tag samples and their tests.

## Run Tests

1. **Test only global samples using the Project ID configured above**

   ```
   bundle exec rake global_test
   ```

1. **Test only regional samples using the Project ID & Location ID configured above**

   ```
   bundle exec rake regional_test
   ```

1. **Test all samples using the Project ID & Location ID configured above**
   ```
   bundle exec rake test
   ```

## Run Samples

**Usage:** `ruby sample.rb [arguments]`

### Run global samples

##### List of executable samples files and their arguments

| File                                | Args                                         | Description                                                                        |
| ----------------------------------- | -------------------------------------------- | ---------------------------------------------------------------------------------- |
| create_param.rb                     | `parameter_id`                               | Creates a global parameter.                                                        |
| create_structured_param.rb          | `parameter_id`                               | Creates a global parameter with JSON format.                                       |
| create_param_version.rb             | `parameter_id`, `version_id`, `payload`      | Creates a global parameter version.                                                |
| create_structured_param_version.rb  | `parameter_id`, `version_id`, `json_payload` | Creates a global parameter version with JSON format.                               |
| create_param_version_with_secret.rb | `parameter_id`, `version_id`, `secret_id`    | Creates a global parameter version with a secret.                                  |
| get_param.rb                        | `parameter_id`                               | Retrieves a global parameter.                                                      |
| get_param_version.rb                | `parameter_id`, `version_id`                 | Retrieves a global parameter version.                                              |
| render_param_version.rb             | `parameter_id`, `version_id`                 | Renders a global parameter version.                                                |
| list_params.rb                      |                                              | Lists all global parameters.                                                       |
| list_param_versions.rb              | `parameter_id`                               | Lists all global parameter versions.                                               |
| disable_param_version.rb            | `parameter_id`, `version_id`                 | Disables a global parameter version.                                               |
| enable_param_version.rb             | `parameter_id`, `version_id`                 | Enables a global parameter version.                                                |
| delete_param.rb                     | `parameter_id`                               | Deletes a global parameter.                                                        |
| delete_param_version.rb             | `parameter_id`, `version_id`                 | Deletes a global parameter version.                                                |
| create_param_with_kms_key.rb        | `parameter_id`, `kms_key`                    | Creates a global parameter with kms_key.                                           |
| update_param_kms_key.rb             | `parameter_id`, `kms_key`                    | Updates a global parameter kms_key.                                           |
| remove_param_kms_key.rb             | `parameter_id`                               | Removes a kms_key for global parameter.                                       |
| quickstart.rb                       | `parameter_id`, `version_id`                 | Creates a global parameter, parameter version and retrieves the parameter version. |
| create_param_template.rb | `template_id` | Creates a global template with JSON format. |
| create_param_template_version.rb | `template_id`, `version_id` | Creates a global template version with placeholders. |
| get_param_template.rb | `template_id` | Retrieves a global template. |
| get_param_template_version.rb | `template_id`, `version_id` | Retrieves a global template version. |
| list_param_templates.rb |  | Lists all global templates. |
| list_param_template_versions.rb | `template_id` | Lists all global template versions. |
| update_param_template_labels.rb | `template_id`, `label_key`, `label_value` | Updates the labels of a global template. |
| delete_param_template.rb | `template_id` | Deletes a global template. |
| disable_param_template_version.rb | `template_id`, `version_id` | Disables a global template version. |
| enable_param_template_version.rb | `template_id`, `version_id` | Enables a global template version. |
| delete_param_template_version.rb | `template_id`, `version_id` | Deletes a global template version. |
| render_param_template_version.rb | `template_id`, `version_id`, `parameter_id`, `parameter_version_id` | Renders a global template version. |
| create_param_with_tags.rb | `parameter_id`, `tag_key`, `tag_value` | Creates a global parameter with tags. |
| bind_tags_to_param.rb | `parameter_id`, `tag_value` | Creates a global parameter and binds a tag to it. |
| get_param_tags.rb | `parameter_id` | Lists the tags bound to a global parameter. |
| create_param_version_with_checksum.rb | `parameter_id`, `version_id` | Creates a global parameter version with a checksum. |
| get_param_version_verify_checksum.rb | `parameter_id`, `version_id` | Retrieves a global parameter version and verifies its checksum. |
| template_quickstart.rb | `template_id`, `parameter_id`, `version_id` | Creates a global template, a global parameter and renders the template. |

### Run regional samples

##### List of executable samples files and their arguments

| File                                         | Args                                         | Description                                                                          |
| -------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------------------------------ |
| create_regional_param.rb                     | `parameter_id`                               | Creates a regional parameter.                                                        |
| create_structured_regional_param.rb          | `parameter_id`                               | Creates a regional parameter with JSON format.                                       |
| create_regional_param_version.rb             | `parameter_id`, `version_id`, `payload`      | Creates a regional parameter version.                                                |
| create_structured_regional_param_version.rb  | `parameter_id`, `version_id`, `json_payload` | Creates a regional parameter version with JSON format.                               |
| create_regional_param_version_with_secret.rb | `parameter_id`, `version_id`, `secret_id`    | Creates a regional parameter version with a secret.                                  |
| get_regional_param.rb                        | `parameter_id`                               | Retrieves a regional parameter.                                                      |
| get_regional_param_version.rb                | `parameter_id`, `version_id`                 | Retrieves a regional parameter version.                                              |
| render_regional_param_version.rb             | `parameter_id`, `version_id`                 | Renders a regional parameter version.                                                |
| list_regional_params.rb                      |                                              | Lists all regional parameters.                                                       |
| list_regional_param_versions.rb              | `parameter_id`                               | Lists all regional parameter versions.                                               |
| disable_regional_param_version.rb            | `parameter_id`, `version_id`                 | Disables a regional parameter version.                                               |
| enable_regional_param_version.rb             | `parameter_id`, `version_id`                 | Enables a regional parameter version.                                                |
| delete_regional_param.rb                     | `parameter_id`                               | Deletes a regional parameter.                                                        |
| delete_regional_param_version.rb             | `parameter_id`, `version_id`                 | Deletes a regional parameter version.                                                |
| create_regional_param_with_kms_key.rb        | `parameter_id`, `kms_key`                    | Creates a regional parameter with kms_key.                                           |
| update_regional_param_kms_key.rb             | `parameter_id`, `kms_key`                    | Updates a regional parameter kms_key.                                           |
| remove_regional_param_kms_key.rb             | `parameter_id`                               | Removes a kms_key for regional parameter.                                       |
| regional_quickstart.rb                       | `parameter_id`, `version_id`                 | Creates a regional parameter, parameter version and retrieves the parameter version. |
| create_regional_param_template.rb | `template_id` | Creates a regional template with JSON format. |
| create_regional_param_template_version.rb | `template_id`, `version_id` | Creates a regional template version with placeholders. |
| get_regional_param_template.rb | `template_id` | Retrieves a regional template. |
| get_regional_param_template_version.rb | `template_id`, `version_id` | Retrieves a regional template version. |
| list_regional_param_templates.rb |  | Lists all regional templates. |
| list_regional_param_template_versions.rb | `template_id` | Lists all regional template versions. |
| update_regional_param_template_labels.rb | `template_id`, `label_key`, `label_value` | Updates the labels of a regional template. |
| delete_regional_param_template.rb | `template_id` | Deletes a regional template. |
| disable_regional_param_template_version.rb | `template_id`, `version_id` | Disables a regional template version. |
| enable_regional_param_template_version.rb | `template_id`, `version_id` | Enables a regional template version. |
| delete_regional_param_template_version.rb | `template_id`, `version_id` | Deletes a regional template version. |
| render_regional_param_template_version.rb | `template_id`, `version_id`, `parameter_id`, `parameter_version_id` | Renders a regional template version. |
| create_regional_param_with_tags.rb | `parameter_id`, `tag_key`, `tag_value` | Creates a regional parameter with tags. |
| bind_tags_to_regional_param.rb | `parameter_id`, `tag_value` | Creates a regional parameter and binds a tag to it. |
| get_regional_param_tags.rb | `parameter_id` | Lists the tags bound to a regional parameter. |
| create_regional_param_version_with_checksum.rb | `parameter_id`, `version_id` | Creates a regional parameter version with a checksum. |
| get_regional_param_version_verify_checksum.rb | `parameter_id`, `version_id` | Retrieves a regional parameter version and verifies its checksum. |
| regional_template_quickstart.rb | `template_id`, `parameter_id`, `version_id` | Creates a regional template, a regional parameter and renders the template. |
