# Copyright 2020 Google, LLC
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

require "google/cloud/automl"
require "google/cloud/storage"
require "minitest/autorun"
require "minitest/focus"
require "securerandom"

require_relative "../delete_dataset"
require_relative "../delete_model"
require_relative "../deploy_model"
require_relative "../export_dataset"
require_relative "../get_dataset"
require_relative "../get_model"
require_relative "../get_model_evaluation"
require_relative "../import_dataset"
require_relative "../language_batch_predict"
require_relative "../language_entity_extraction_create_dataset"
require_relative "../language_entity_extraction_create_model"
require_relative "../language_entity_extraction_predict"
require_relative "../language_sentiment_analysis_create_dataset"
require_relative "../language_sentiment_analysis_create_model"
require_relative "../language_sentiment_analysis_predict"
require_relative "../language_text_classification_create_dataset"
require_relative "../language_text_classification_create_model"
require_relative "../language_text_classification_predict"
require_relative "../list_datasets"
require_relative "../list_model_evaluations"
require_relative "../list_models"
require_relative "../translate_create_dataset"
require_relative "../translate_create_model"
require_relative "../translate_predict"
require_relative "../undeploy_model"
require_relative "../vision_batch_predict"
require_relative "../vision_classification_create_dataset"
require_relative "../vision_classification_create_model"
require_relative "../vision_classification_deploy_model_node_count"
require_relative "../vision_classification_predict"
require_relative "../vision_object_detection_create_dataset"
require_relative "../vision_object_detection_create_model"
require_relative "../vision_object_detection_deploy_model_node_count"
require_relative "../vision_object_detection_predict"

def automl_service
  Google::Cloud::AutoML.auto_ml
end

def project_id
  ENV["GOOGLE_CLOUD_PROJECT"]
end

def location_path
  automl_service.location_path project: project_id, location: "us-central1"
end

def create_dataset_helper name
  dataset = {
    name: name,
    display_name: "test_dataset",
    description: "test dataset for ruby samples",
    translation_dataset_metadata: {
      source_language_code: "en",
      target_language_code: "ja"
    }
  }
  operation = automl_service.create_dataset parent: location_path, dataset: dataset
  operation.wait_until_done!
  operation.response
end

def import_data_helper dataset_name
  automl_service.import_dataset name: dataset_name, input_config: input_config
end

def create_model_helper name, dataset_id, input_location
  input_config = {
    gcs_source: {
      input_uris: [input_location]
    }
  }
  model = {
    name: name,
    display_name: "test_model",
    dataset_id: dataset_id,
    translation_model_metadata: {
      source_language_code: "en",
      target_language_code: "ja"
    }
  }
  operation = automl_service.create_model parent: location_path, model: model
  operation.wait_until_done!
  operation.response
end

def create_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new

  retry_resource_exhaustion do
    return storage_client.create_bucket bucket_name
  end
end

def delete_bucket_helper bucket_name
  storage_client = Google::Cloud::Storage.new

  retry_resource_exhaustion do
    bucket = storage_client.bucket bucket_name
    return unless bucket

    bucket.files.each(&:delete)
    bucket.delete
  end
end

def retry_resource_exhaustion
  5.times do
    begin
      yield
      return
    rescue Google::Cloud::ResourceExhaustedError => e
      puts "\n#{e} Gonna try again"
      sleep rand(3..5)
    end
  end
  raise Google::Cloud::ResourceExhaustedError, "Maybe take a break from creating and deleting buckets for a bit"
end
