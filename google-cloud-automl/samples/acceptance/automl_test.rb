require_relative "helper"

describe "Automl Samples" do
  parallelize_me!

  let(:rando) { SecureRandom.hex }
  let(:prefix) { "ruby_bqdt_test_" }

  let(:dataset) { create_dataset_helper "#{prefix}#{rando}" }
  let(:dataset_id) { dataset.name.split("/").last }

  let(:model) { create_model_helper "#{prefix}#{rando}", dataset_id }
  let(:model_id) { model.name.split("/").last }

  let(:bucket) { create_bucket_helper "#{prefix}#{rando}" }

  let(:translate_train) { "ruby-automl-samples-test.txt" }
  let :data_file_path do
    "gs://#{bucket.name}/#{translate_train}"
  end

  describe "delete_dataset" do
    it "deletes a dataset" do
      assert_output "Dataset deleted.\n" do
        delete_dataset project_id: project_id, dataset_id: dataset_id
      end
    end
  end

  describe "delete_model" do
    after do
      capture_io { delete_dataset project_id: project_id, dataset_id: dataset_id }
      delete_bucket_helper bucket.name
    end
    focus
    # As model creation can take many hours, instead try to delete a
    # nonexistent model and confirm that the model was not found, but other
    # elements of the request were valid.
    # fake_model_id = "TRL0000000000000000000"

    it "deletes a model" do
      fake_model_id = "TRL0000000000000000000"


      # require "pry"
      # binding.pry
      assert_raises Google::Gax::NotFoundError, /The model does not exist/ do
        delete_model project_id: project_id, model_id: fake_model_id
      end


    end
    
  end

  describe "deploy_model" do
    it "" do
    end
  end

  describe "export_dataset" do
    it "" do
    end
  end

  describe "get_dataset" do
    it "" do
    end
  end

  describe "get_model" do
    it "" do
    end
  end

  describe "get_model_evaluation" do
    it "" do
    end
  end

  describe "import_dataset" do
    it "" do
    end
  end

  describe "language_batch_predict" do
    it "" do
    end
  end

  describe "language_entity_extraction_create_dataset" do
    it "" do
    end
  end

  describe "language_entity_extraction_create_model" do
    it "" do
    end
  end

  describe "language_entity_extraction_predict" do
    it "" do
    end
  end

  describe "language_sentiment_analysis_create_dataset" do
    it "" do
    end
  end

  describe "language_sentiment_analysis_create_model" do
    it "" do
    end
  end

  describe "language_sentiment_analysis_predict" do
    it "" do
    end
  end

  describe "language_text_classification_create_dataset" do
    it "" do
    end
  end

  describe "language_text_classification_create_model" do
    it "" do
    end
  end

  describe "language_text_classification_predict" do
    it "" do
    end
  end

  describe "list_datasets" do
    it "" do
    end
  end

  describe "list_model_evaluations" do
    it "" do
    end
  end

  describe "list_models" do
    it "" do
    end
  end

  describe "translate_create_dataset" do
    it "" do
    end
  end

  describe "translate_create_model" do
    it "" do
    end
  end

  describe "translate_predict" do
    it "" do
    end
  end

  describe "undeploy_model" do
    it "" do
    end
  end

  describe "vision_batch_predict" do
    it "" do
    end
  end

  describe "vision_classification_create_dataset" do
    it "" do
    end
  end

  describe "vision_classification_create_model" do
    it "" do
    end
  end

  describe "vision_classification_deploy_model_node_count" do
    it "" do
    end
  end

  describe "vision_classification_predict" do
    it "" do
    end
  end

  describe "vision_object_detection_create_dataset" do
    it "" do
    end
  end

  describe "vision_object_detection_create_model" do
    it "" do
    end
  end

  describe "vision_object_detection_deploy_model_node_count" do
    it "" do
    end
  end

  describe "vision_object_detection_predict" do
    it "" do
    end
  end

end