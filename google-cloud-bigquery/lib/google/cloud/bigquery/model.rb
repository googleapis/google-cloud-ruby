# Copyright 2019 Google LLC
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


require "google/cloud/errors"
require "google/cloud/bigquery/service"
require "google/cloud/bigquery/model/list"
require "google/cloud/bigquery/standard_sql"
require "google/cloud/bigquery/convert"
require "google/apis/bigquery_v2"

module Google
  module Cloud
    module Bigquery
      ##
      # # Model
      #
      # A model in BigQuery ML represents what an ML system has learned from the
      # training data.
      #
      # The following types of models are supported by BigQuery ML:
      #
      # * Linear regression for forecasting; for example, the sales of an item
      #   on a given day. Labels are real-valued (they cannot be +/- infinity or
      #   NaN).
      # * Binary logistic regression for classification; for example,
      #   determining whether a customer will make a purchase. Labels must only
      #   have two possible values.
      # * Multiclass logistic regression for classification. These models can be
      #   used to predict multiple possible values such as whether an input is
      #   "low-value," "medium-value," or "high-value." Labels can have up to 50
      #   unique values. In BigQuery ML, multiclass logistic regression training
      #   uses a multinomial classifier with a cross entropy loss function.
      # * K-means clustering for data segmentation (beta); for example,
      #   identifying customer segments. K-means is an unsupervised learning
      #   technique, so model training does not require labels nor split data
      #   for training or evaluation.
      #
      # In BigQuery ML, a model can be used with data from multiple BigQuery
      # datasets for training and for prediction.
      #
      # @see https://cloud.google.com/bigquery-ml/docs/bigqueryml-intro
      #   Introduction to BigQuery ML
      # @see https://cloud.google.com/bigquery-ml/docs/getting-model-metadata
      #   Getting model metadata
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #
      #   model = dataset.model "my_model"
      #
      class Model
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The Google API Client JSON Hash.
        attr_accessor :gapi_json

        ##
        # @private A Google API Client Model Reference object.
        attr_reader :reference

        ##
        # @private Create an empty Model object.
        def initialize
          @service = nil
          @gapi_json = nil
          @reference = nil
        end

        ##
        # A unique ID for this model.
        #
        # @return [String] The ID must contain only letters (`[A-Za-z]`), numbers
        #   (`[0-9]`), or underscores (`_`). The maximum length is 1,024 characters.
        #
        # @!group Attributes
        #
        def model_id
          return @reference.model_id if reference?
          @gapi_json[:modelReference][:modelId]
        end

        ##
        # The ID of the `Dataset` containing this model.
        #
        # @return [String] The ID must contain only letters (`[A-Za-z]`), numbers
        #   (`[0-9]`), or underscores (`_`). The maximum length is 1,024 characters.
        #
        # @!group Attributes
        #
        def dataset_id
          return @reference.dataset_id if reference?
          @gapi_json[:modelReference][:datasetId]
        end

        ##
        # The ID of the `Project` containing this model.
        #
        # @return [String] The project ID.
        #
        # @!group Attributes
        #
        def project_id
          return @reference.project_id if reference?
          @gapi_json[:modelReference][:projectId]
        end

        ##
        # @private The gapi_json fragment containing the Project ID, Dataset ID,
        # and Model ID.
        #
        # @return [Google::Apis::BigqueryV2::ModelReference]
        #
        def model_ref
          return @reference if reference?
          Google::Apis::BigqueryV2::ModelReference.new(
            project_id: project_id,
            dataset_id: dataset_id,
            model_id:   model_id
          )
        end

        ##
        # Type of the model resource. Expected to be one of the following:
        #
        # * LINEAR_REGRESSION - Linear regression model.
        # * LOGISTIC_REGRESSION - Logistic regression based classification
        #   model.
        # * KMEANS - K-means clustering model (beta).
        # * TENSORFLOW - An imported TensorFlow model (beta).
        #
        # @return [String, nil] The model type, or `nil` if the object is a
        #   reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def model_type
          return nil if reference?
          @gapi_json[:modelType]
        end

        ##
        # The name of the model.
        #
        # @return [String, nil] The friendly name, or `nil` if the object is a
        #   reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def name
          return nil if reference?
          ensure_full_data!
          @gapi_json[:friendlyName]
        end

        ##
        # Updates the name of the model.
        #
        # If the model is not a full resource representation (see
        # {#resource_full?}), the full representation will be retrieved before
        # the update to comply with ETag-based optimistic concurrency control.
        #
        # @param [String] new_name The new friendly name.
        #
        # @!group Attributes
        #
        def name= new_name
          ensure_full_data!
          patch_gapi! friendlyName: new_name
        end

        ##
        # The ETag hash of the model.
        #
        # @return [String, nil] The ETag hash, or `nil` if the object is a
        #   reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def etag
          return nil if reference?
          ensure_full_data!
          @gapi_json[:etag]
        end

        ##
        # A user-friendly description of the model.
        #
        # @return [String, nil] The description, or `nil` if the object is a
        #   reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def description
          return nil if reference?
          ensure_full_data!
          @gapi_json[:description]
        end

        ##
        # Updates the user-friendly description of the model.
        #
        # If the model is not a full resource representation (see
        # {#resource_full?}), the full representation will be retrieved before
        # the update to comply with ETag-based optimistic concurrency control.
        #
        # @param [String] new_description The new user-friendly description.
        #
        # @!group Attributes
        #
        def description= new_description
          ensure_full_data!
          patch_gapi! description: new_description
        end

        ##
        # The time when this model was created.
        #
        # @return [Time, nil] The creation time, or `nil` if the object is a
        #   reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def created_at
          return nil if reference?
          Convert.millis_to_time @gapi_json[:creationTime]
        end

        ##
        # The date when this model was last modified.
        #
        # @return [Time, nil] The last modified time, or `nil` if not present or
        #   the object is a reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def modified_at
          return nil if reference?
          Convert.millis_to_time @gapi_json[:lastModifiedTime]
        end

        ##
        # The time when this model expires.
        # If not present, the model will persist indefinitely.
        # Expired models will be deleted and their storage reclaimed.
        #
        # @return [Time, nil] The expiration time, or `nil` if not present or
        #   the object is a reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def expires_at
          return nil if reference?
          ensure_full_data!
          Convert.millis_to_time @gapi_json[:expirationTime]
        end

        ##
        # Updates time when this model expires.
        #
        # If the model is not a full resource representation (see
        # {#resource_full?}), the full representation will be retrieved before
        # the update to comply with ETag-based optimistic concurrency control.
        #
        # @param [Integer] new_expires_at The new time when this model expires.
        #
        # @!group Attributes
        #
        def expires_at= new_expires_at
          ensure_full_data!
          new_expires_millis = Convert.time_to_millis new_expires_at
          patch_gapi! expirationTime: new_expires_millis
        end

        ##
        # The geographic location where the model should reside. Possible
        # values include `EU` and `US`. The default value is `US`.
        #
        # @return [String, nil] The location code.
        #
        # @!group Attributes
        #
        def location
          return nil if reference?
          ensure_full_data!
          @gapi_json[:location]
        end

        ##
        # A hash of user-provided labels associated with this model. Labels
        # are used to organize and group models. See [Using
        # Labels](https://cloud.google.com/bigquery/docs/labels).
        #
        # The returned hash is frozen and changes are not allowed. Use
        # {#labels=} to replace the entire hash.
        #
        # @return [Hash<String, String>, nil] A hash containing key/value pairs.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model"
        #
        #   labels = model.labels
        #
        # @!group Attributes
        #
        def labels
          return nil if reference?
          m = @gapi_json[:labels]
          m = m.to_h if m.respond_to? :to_h
          m.dup.freeze
        end

        ##
        # Updates the hash of user-provided labels associated with this model.
        # Labels are used to organize and group models. See [Using
        # Labels](https://cloud.google.com/bigquery/docs/labels).
        #
        # If the model is not a full resource representation (see
        # {#resource_full?}), the full representation will be retrieved before
        # the update to comply with ETag-based optimistic concurrency control.
        #
        # @param [Hash<String, String>] new_labels A hash containing key/value
        #   pairs. The labels applied to a resource must meet the following requirements:
        #
        #   * Each resource can have multiple labels, up to a maximum of 64.
        #   * Each label must be a key-value pair.
        #   * Keys have a minimum length of 1 character and a maximum length of
        #     63 characters, and cannot be empty. Values can be empty, and have
        #     a maximum length of 63 characters.
        #   * Keys and values can contain only lowercase letters, numeric characters,
        #     underscores, and dashes. All characters must use UTF-8 encoding, and
        #     international characters are allowed.
        #   * The key portion of a label must be unique. However, you can use the
        #     same key with multiple resources.
        #   * Keys must start with a lowercase letter or international character.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model"
        #
        #   model.labels = { "env" => "production" }
        #
        # @!group Attributes
        #
        def labels= new_labels
          ensure_full_data!
          patch_gapi! labels: new_labels
        end

        ##
        # The {EncryptionConfiguration} object that represents the custom
        # encryption method used to protect this model. If not set,
        # {Dataset#default_encryption} is used.
        #
        # Present only if this model is using custom encryption.
        #
        # @see https://cloud.google.com/bigquery/docs/customer-managed-encryption
        #   Protecting Data with Cloud KMS Keys
        #
        # @return [EncryptionConfiguration, nil] The encryption configuration.
        #
        #   @!group Attributes
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model"
        #
        #   encrypt_config = model.encryption
        #
        # @!group Attributes
        #
        def encryption
          return nil if reference?
          return nil if @gapi_json[:encryptionConfiguration].nil?
          # We have to create a gapic object from the hash because that is what
          # EncryptionConfiguration is expecing.
          json_cmek = @gapi_json[:encryptionConfiguration].to_json
          gapi_cmek = Google::Apis::BigqueryV2::EncryptionConfiguration.from_json json_cmek
          EncryptionConfiguration.from_gapi(gapi_cmek).freeze
        end

        ##
        # Set the {EncryptionConfiguration} object that represents the custom
        # encryption method used to protect this model. If not set,
        # {Dataset#default_encryption} is used.
        #
        # Present only if this model is using custom encryption.
        #
        # If the model is not a full resource representation (see
        # {#resource_full?}), the full representation will be retrieved before
        # the update to comply with ETag-based optimistic concurrency control.
        #
        # @see https://cloud.google.com/bigquery/docs/customer-managed-encryption
        #   Protecting Data with Cloud KMS Keys
        #
        # @param [EncryptionConfiguration] value The new encryption config.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model"
        #
        #   key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
        #   encrypt_config = bigquery.encryption kms_key: key_name
        #
        #   model.encryption = encrypt_config
        #
        # @!group Attributes
        #
        def encryption= value
          ensure_full_data!
          # We have to create a hash from the gapic object's JSON because that
          # is what Model is expecing.
          json_cmek = JSON.parse value.to_gapi.to_json, symbolize_names: true
          patch_gapi! encryptionConfiguration: json_cmek
        end

        ##
        # The input feature columns that were used to train this model.
        #
        # @return [Array<StandardSql::Field>]
        #
        # @!group Attributes
        #
        def feature_columns
          ensure_full_data!
          Array(@gapi_json[:featureColumns]).map do |field_gapi_json|
            field_gapi = Google::Apis::BigqueryV2::StandardSqlField.from_json field_gapi_json.to_json
            StandardSql::Field.from_gapi field_gapi
          end
        end

        ##
        # The label columns that were used to train this model. The output of
        # the model will have a "predicted_" prefix to these columns.
        #
        # @return [Array<StandardSql::Field>]
        #
        # @!group Attributes
        #
        def label_columns
          ensure_full_data!
          Array(@gapi_json[:labelColumns]).map do |field_gapi_json|
            field_gapi = Google::Apis::BigqueryV2::StandardSqlField.from_json field_gapi_json.to_json
            StandardSql::Field.from_gapi field_gapi
          end
        end

        ##
        # Information for all training runs in increasing order of startTime.
        #
        # @return [Array<Google::Cloud::Bigquery::Model::TrainingRun>]
        #
        # @!group Attributes
        #
        def training_runs
          ensure_full_data!
          Array @gapi_json[:trainingRuns]
        end

        ##
        # Exports the model to Google Cloud Storage asynchronously, immediately
        # returning an {ExtractJob} that can be used to track the progress of the
        # export job. The caller may poll the service by repeatedly calling
        # {Job#reload!} and {Job#done?} to detect when the job is done, or
        # simply block until the job is done by calling #{Job#wait_until_done!}.
        # See also {#extract}.
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {ExtractJob::Updater#location=} in a block passed to this method. If
        # the model is a full resource representation (see {#resource_full?}),
        # the location of the job will automatically be set to the location of
        # the model.
        #
        # @see https://cloud.google.com/bigquery-ml/docs/exporting-models
        #   Exporting models
        #
        # @param [String] extract_url The Google Storage URI to which BigQuery
        #   should extract the model. This value should be end in an object name
        #   prefix, since multiple objects will be exported.
        # @param [String] format The exported file format. The default value is
        #   `ml_tf_saved_model`.
        #
        #   The following values are supported:
        #
        #   * `ml_tf_saved_model` - TensorFlow SavedModel
        #   * `ml_xgboost_booster` - XGBoost Booster
        # @param [String] job_id A user-defined ID for the extract job. The ID
        #   must contain only letters (`[A-Za-z]`), numbers (`[0-9]`), underscores
        #   (`_`), or dashes (`-`). The maximum length is 1,024 characters. If
        #   `job_id` is provided, then `prefix` will not be used.
        #
        #   See [Generating a job
        #   ID](https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid).
        # @param [String] prefix A string, usually human-readable, that will be
        #   prepended to a generated value to produce a unique job ID. For
        #   example, the prefix `daily_import_job_` can be given to generate a
        #   job ID such as `daily_import_job_12vEDtMQ0mbp1Mo5Z7mzAFQJZazh`. The
        #   prefix must contain only letters (`[A-Za-z]`), numbers (`[0-9]`),
        #   underscores (`_`), or dashes (`-`). The maximum length of the entire ID
        #   is 1,024 characters. If `job_id` is provided, then `prefix` will not
        #   be used.
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the job. You can use these to organize and group your jobs.
        #
        #   The labels applied to a resource must meet the following requirements:
        #
        #   * Each resource can have multiple labels, up to a maximum of 64.
        #   * Each label must be a key-value pair.
        #   * Keys have a minimum length of 1 character and a maximum length of
        #     63 characters, and cannot be empty. Values can be empty, and have
        #     a maximum length of 63 characters.
        #   * Keys and values can contain only lowercase letters, numeric characters,
        #     underscores, and dashes. All characters must use UTF-8 encoding, and
        #     international characters are allowed.
        #   * The key portion of a label must be unique. However, you can use the
        #     same key with multiple resources.
        #   * Keys must start with a lowercase letter or international character.
        #
        # @yield [job] a job configuration object
        # @yieldparam [Google::Cloud::Bigquery::ExtractJob::Updater] job a job
        #   configuration object for setting additional options.
        #
        # @return [Google::Cloud::Bigquery::ExtractJob]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model"
        #
        #   extract_job = model.extract_job "gs://my-bucket/#{model.model_id}"
        #
        #   extract_job.wait_until_done!
        #   extract_job.done? #=> true
        #
        # @!group Data
        #
        def extract_job extract_url, format: nil, job_id: nil, prefix: nil, labels: nil
          ensure_service!
          options = { format: format, job_id: job_id, prefix: prefix, labels: labels }
          updater = ExtractJob::Updater.from_options service, model_ref, extract_url, options
          updater.location = location if location # may be model reference

          yield updater if block_given?

          job_gapi = updater.to_gapi
          gapi = service.extract_table job_gapi
          Job.from_gapi gapi, service
        end

        ##
        # Exports the model to Google Cloud Storage using a synchronous method
        # that blocks for a response. Timeouts and transient errors are generally
        # handled as needed to complete the job. See also {#extract_job}.
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {ExtractJob::Updater#location=} in a block passed to this method. If
        # the model is a full resource representation (see {#resource_full?}),
        # the location of the job will automatically be set to the location of
        # the model.
        #
        # @see https://cloud.google.com/bigquery-ml/docs/exporting-models
        #   Exporting models
        #
        # @param [String] extract_url The Google Storage URI to which BigQuery
        #   should extract the model. This value should be end in an object name
        #   prefix, since multiple objects will be exported.
        # @param [String] format The exported file format. The default value is
        #   `ml_tf_saved_model`.
        #
        #   The following values are supported:
        #
        #   * `ml_tf_saved_model` - TensorFlow SavedModel
        #   * `ml_xgboost_booster` - XGBoost Booster
        # @yield [job] a job configuration object
        # @yieldparam [Google::Cloud::Bigquery::ExtractJob::Updater] job a job
        #   configuration object for setting additional options.
        #
        # @return [Boolean] Returns `true` if the extract operation succeeded.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model"
        #
        #   model.extract "gs://my-bucket/#{model.model_id}"
        #
        # @!group Data
        #
        def extract extract_url, format: nil, &block
          job = extract_job extract_url, format: format, &block
          job.wait_until_done!
          ensure_job_succeeded! job
          true
        end

        ##
        # Permanently deletes the model.
        #
        # @return [Boolean] Returns `true` if the model was deleted.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model"
        #
        #   model.delete
        #
        # @!group Lifecycle
        #
        def delete
          ensure_service!
          service.delete_model dataset_id, model_id
          # Set flag for #exists?
          @exists = false
          true
        end

        ##
        # Reloads the model with current data from the BigQuery service.
        #
        # @return [Google::Cloud::Bigquery::Model] Returns the reloaded
        #   model.
        #
        # @example Skip retrieving the model from the service, then load it:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model", skip_lookup: true
        #
        #   model.reference? #=> true
        #   model.reload!
        #   model.resource? #=> true
        #
        # @!group Lifecycle
        #
        def reload!
          ensure_service!
          @gapi_json = service.get_model dataset_id, model_id
          @reference = nil
          @exists = nil
          self
        end
        alias refresh! reload!

        ##
        # Determines whether the model exists in the BigQuery service. The
        # result is cached locally. To refresh state, set `force` to `true`.
        #
        # @param [Boolean] force Force the latest resource representation to be
        #   retrieved from the BigQuery service when `true`. Otherwise the
        #   return value of this method will be memoized to reduce the number of
        #   API calls made to the BigQuery service. The default is `false`.
        #
        # @return [Boolean] `true` when the model exists in the BigQuery
        #   service, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model", skip_lookup: true
        #   model.exists? #=> true
        #
        def exists? force: false
          return resource_exists? if force
          # If we have a value, return it
          return @exists unless @exists.nil?
          # Always true if we have a gapi_json object
          return true if resource?
          resource_exists?
        end

        ##
        # Whether the model was created without retrieving the resource
        # representation from the BigQuery service.
        #
        # @return [Boolean] `true` when the model is just a local reference
        #   object, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model", skip_lookup: true
        #
        #   model.reference? #=> true
        #   model.reload!
        #   model.reference? #=> false
        #
        def reference?
          @gapi_json.nil?
        end

        ##
        # Whether the model was created with a resource representation from
        # the BigQuery service.
        #
        # @return [Boolean] `true` when the model was created with a resource
        #   representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model", skip_lookup: true
        #
        #   model.resource? #=> false
        #   model.reload!
        #   model.resource? #=> true
        #
        def resource?
          !@gapi_json.nil?
        end

        ##
        # Whether the model was created with a partial resource representation
        # from the BigQuery service by retrieval through {Dataset#models}.
        # See [Models: list
        # response](https://cloud.google.com/bigquery/docs/reference/rest/v2/models/list#response)
        # for the contents of the partial representation. Accessing any
        # attribute outside of the partial representation will result in loading
        # the full representation.
        #
        # @return [Boolean] `true` when the model was created with a partial
        #   resource representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.models.first
        #
        #   model.resource_partial? #=> true
        #   model.description # Loads the full resource.
        #   model.resource_partial? #=> false
        #
        def resource_partial?
          resource? && !resource_full?
        end

        ##
        # Whether the model was created with a full resource representation
        # from the BigQuery service.
        #
        # @return [Boolean] `true` when the model was created with a full
        #   resource representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   model = dataset.model "my_model"
        #
        #   model.resource_full? #=> true
        #
        def resource_full?
          resource? && @gapi_json.key?(:friendlyName)
        end

        ##
        # @private New Model from a Google API Client object.
        def self.from_gapi_json gapi_json, service
          new.tap do |m|
            m.instance_variable_set :@gapi_json, gapi_json
            m.instance_variable_set :@service, service
          end
        end

        ##
        # @private New lazy Model object without making an HTTP request, for use with the skip_lookup option.
        def self.new_reference project_id, dataset_id, model_id, service
          raise ArgumentError, "project_id is required" unless project_id
          raise ArgumentError, "dataset_id is required" unless dataset_id
          raise ArgumentError, "model_id is required" unless model_id
          raise ArgumentError, "service is required" unless service

          new.tap do |m|
            reference_gapi_json = Google::Apis::BigqueryV2::ModelReference.new(
              project_id: project_id,
              dataset_id: dataset_id,
              model_id:   model_id
            )
            m.instance_variable_set :@reference, reference_gapi_json
            m.instance_variable_set :@service, service
          end
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          raise "Must have active connection" unless service
        end

        ##
        # Ensures the Google::Apis::BigqueryV2::Model object has been loaded
        # from the service.
        def ensure_gapi_json!
          ensure_service!
          return unless reference?
          reload!
        end

        ##
        # Fetch gapi_json and memoize whether resource exists.
        def resource_exists?
          reload!
          @exists = true
        rescue Google::Cloud::NotFoundError
          @exists = false
        end

        def patch_gapi! **changes
          return if changes.empty?
          ensure_service!
          patch_gapi = Google::Apis::BigqueryV2::Model.from_json changes.to_json
          patch_gapi.model_reference = model_ref
          @gapi_json = service.patch_model \
            dataset_id, model_id, patch_gapi, etag
          @reference = nil

          # TODO: restore original impl after acceptance test indicates that
          # service etag bug is fixed
          reload!
        end

        ##
        # Load the complete representation of the model if it has been
        # only partially loaded by a request to the API list method.
        def ensure_full_data!
          reload! unless resource_full?
        end

        def ensure_job_succeeded! job
          return unless job.failed?
          begin
            # raise to activate ruby exception cause handling
            raise job.gapi_error
          rescue StandardError => e
            # wrap Google::Apis::Error with Google::Cloud::Error
            raise Google::Cloud::Error.from_error(e)
          end
        end
      end
    end
  end
end
