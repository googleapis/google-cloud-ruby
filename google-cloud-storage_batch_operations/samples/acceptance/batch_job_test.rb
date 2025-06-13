# Copyright 2025 Google LLC
# Licensed under the Apache License, Version 2.0

require_relative "helper"
require_relative "../storage_batch_create_job"
require_relative "../storage_batch_delete_job"
require_relative "../storage_batch_cancel_job"
require_relative "../storage_batch_list_job"
require_relative "../storage_batch_get_job"

describe "Batch jobs Snippets" do
  let(:storage_client) { Google::Cloud::Storage.new }
  let(:project_name)   { storage_client.project }
  let(:bucket)         { @bucket }
  let(:file_content)   { "some content" }
  let(:remote_file_name) { "ruby_file_#{SecureRandom.hex}" }
  let(:job_name) { @job_name }


  before :all do
    @bucket = create_bucket_helper random_bucket_name
  end

  after :all do
    delete_bucket_helper @bucket.name
  end

  def create_test_job my_job
    bucket.create_file StringIO.new(file_content), remote_file_name
    create_job bucket_name: bucket.name, prefix: "ruby_file", job_name: my_job, project_name: project_name
  end

  describe "storage batch manage operations" do
    before do
      @job_name = "ruby-sbo-job-#{SecureRandom.hex}"
      create_test_job job_name
    end

    it "lists jobs and includes the created job" do
      out, _err = capture_io { list_job project_name: project_name }
      assert_includes out, @job_name, "Expected job name not found in the result list"
    end

    it "fetches the details of a job" do
      result = get_job project_name: project_name, job_name: job_name
      assert_includes result, @job_name, "Expected job name not found in the result"
    end

    it "cancels a job" do
      assert_output "The job is canceled.\n" do
        cancel_job project_name: project_name, job_name: @job_name
      end
    end
  end

  describe "Delete storage batch ops" do
    before do
      @job_name = "ruby-sbo-job-#{SecureRandom.hex}"
      create_test_job job_name
    end
    it "deletes a job" do
      retry_job_status do
        get_job project_name: project_name, job_name: @job_name
      end
      assert_output "The job is deleted.\n" do
        delete_job project_name: project_name, job_name: @job_name
      end
    end
  end

  describe "creates a storage batch ops" do
    it "creates a job" do
      @job_name = "ruby-sbo-job-#{SecureRandom.hex}"

      assert_output "The job is created.\n" do
        create_test_job job_name
      end
    end
  end
end
