require_relative "helper"

describe "Job Search Samples" do
  parallelize_me!

  let(:prefix) { "talent_samples_" }
  let(:rando) { SecureRandom.hex }
  let(:rando_two) { SecureRandom.hex }

  let(:tenant) { create_tenant_helper "#{prefix}tenant_#{rando}", rando }
  let(:tenant_id) { tenant.name.split("/").last }

  let(:company_name) { "#{prefix}company_#{rando}" }
  let(:company_name_two) { "#{prefix}company_#{rando_two}" }
  let(:company) { create_company_helper tenant_id, company_name, rando }
  let(:company_two) { create_company_helper tenant_id, company_name_two, rando_two }
  let(:company_id) { company.name.split("/").last }
  let(:company_id_two) { company.name.split("/").last }

  let(:job_name) { "#{prefix}job_#{rando}" }
  let(:job_name_two) { "#{prefix}job_#{rando_two}" }
  let(:job) { create_job_helper tenant_id, company_id, job_name, rando }
  let(:job_two) { create_job_helper tenant_id, company_id, job_name_two, rando_two }
  let(:job_id) { job.name.split("/").last }
  let(:job_id_two) { job_two.name.split("/").last }

  let(:language_code) { "en" }
  let(:address) { "1600 Ampitheatre Parkway" }
  let(:url) { "https://github.com/GoogleCloudPlatform/ruby-docs-samples" }

  describe "autocomplete_job_title" do
    after { delete_tenant_helper tenant }

    it "puts completion suggestions for job and company titles" do
      # It takes a while for anything created to show up in
      # autocomplete suggestions, so just check for a response.
      out, _err = capture_io do
        complete_query project_id,
                       nil,
                       "Talent",
                       100,
                       language_code
      end
      match = out.match(/Suggested title: Talent/)
      assert match
      job_match = out.match(/Suggestion type: JOB_TITLE/)
      co_match = out.match(/Suggestion type: COMPANY_NAME/)
      assert(job_match || co_match)
    end
  end

  describe "batch_create_jobs" do
    after { delete_tenant_helper tenant }

    it "creates two jobs" do
      company_path_one = company_service.company_path project: project_id, tenant: tenant_id, company: company_id
      company_path_two = company_service.company_path project: project_id, tenant: tenant_id, company: company_id_two
      requisition_id = rando
      requisition_id_two = rando_two
      title_one = "ruby_sample_title_#{rando}"
      title_two = "ruby_sample_title_#{rando_two}"
      description = "doing stuff for money"
      out, _err = capture_io do
        sample_batch_create_jobs project_id,
                                 tenant_id,
                                 company_path_one,
                                 requisition_id,
                                 title_one,
                                 description,
                                 url,
                                 address,
                                 language_code,
                                 company_path_two,
                                 requisition_id_two,
                                 title_two,
                                 description,
                                 url,
                                 address,
                                 language_code
      end
      matches = out.scan(/\sname:\s\"([^\"]*)\"/).flatten
      assert_equal matches.size, 2
      matches.each { |job_match| assert get_job_helper(job_match) }
    end
  end

  describe "batch_delete_job" do
    after { delete_tenant_helper tenant }

    it "deletes jobs matching a filter" do
      filter = "companyName = \"#{company.name}\" AND requisitionId = \"#{job.requisition_id}\""
      assert_output "Batch deleted jobs from filter\n" do
        sample_batch_delete_jobs project_id, tenant_id, filter
      end
      assert_raises(Google::Cloud::NotFoundError) { get_job_helper job.name }
    end
  end

  describe "batch_update_jobs" do
    after { delete_tenant_helper tenant }

    it "updates two jobs" do
      out, _err = capture_io do
        sample_batch_update_jobs project_id,
                                 tenant_id,
                                 job.name,
                                 company.name,
                                 job.requisition_id,
                                 job.title,
                                 job.description,
                                 url,
                                 address,
                                 language_code,
                                 job_two.name,
                                 company.name,
                                 job_two.requisition_id,
                                 job_two.title,
                                 job_two.description,
                                 url,
                                 address,
                                 language_code
      end
      job1 = get_job_helper job.name
      job2 = get_job_helper job_two.name

      assert_includes out, job1.name
      assert_includes out, job2.name
      assert_includes job1.application_info.uris, url
      assert_includes job2.application_info.uris, url
    end
  end

  describe "commute_search" do
    after { delete_tenant_helper tenant }

    it "finds jobs nearby" do
      get_job_helper job.name
      out = ""
      5.times do
        next if out.include? "Job name: #{job.name}"

        sleep 5
        out, _err = capture_io do
          sample_commute_search_jobs project_id, tenant_id
        end
      end
      assert_includes out, "Job name: #{job.name}"
    end
  end

  describe "create_client_event" do
    after { delete_tenant_helper tenant }

    it "creates a client event" do
      request_id = rando
      event_id = rando
      out, _err = capture_io do
        sample_create_client_event project_id,
                                   tenant_id,
                                   request_id,
                                   event_id,
                                   job.name,
                                   job_two.name
      end
      assert_includes out, "Created client event: #{event_id}\n"
    end
  end

  describe "create_company" do
    after { delete_tenant_helper tenant }

    it "creates a company" do
      display_name = "Cool Co #{rando}"
      external_id = rando
      out, _err = capture_io do
        sample_create_company project_id, tenant_id, display_name, external_id
      end
      assert_includes out, "Display Name: #{display_name}"
      assert_includes out, "External ID: #{external_id}"
      match = out.match %r{Name: ([\w/-]*)}
      assert match[1]
      matched_company = get_company_helper match[1]
      assert_instance_of Google::Cloud::Talent::V4::Company, matched_company
    end
  end

  describe "create_job" do
    after { delete_tenant_helper tenant }

    it "creates a job" do
      out, _err = capture_io do
        sample_create_job project_id,
                          tenant_id,
                          company.name,
                          rando,
                          "Cool Job #{rando}",
                          "working",
                          url,
                          address,
                          language_code
      end
      match = out.match %r{Created job: ([\w/-]*)}
      assert match[1]
      matched_job = get_job_helper match[1]
      assert_instance_of Google::Cloud::Talent::V4::Job, matched_job
    end
  end

  describe "create_job_custom_attributes" do
    after { delete_tenant_helper tenant }

    it "creates a job with custom attributes" do
      out, _err = capture_io do
        sample_create_job_with_custom_attributes project_id,
                                                 tenant_id,
                                                 company.name,
                                                 rando,
                                                 language_code,
                                                 "job title",
                                                 "working"
      end
      match = out.match %r{Created job: ([\w/-]*)}
      assert match[1]
      matched_job = get_job_helper match[1]
      assert_instance_of Google::Cloud::Talent::V4::Job, matched_job
    end
  end

  describe "create_tenant" do
    it "creates a tenant" do
      out, _err = capture_io do
        sample_create_tenant project_id, rando
      end
      match = out.match %r{Name: ([\w/-]*)}
      assert match[1]
      matched_tenant = get_tenant_helper match[1]
      assert_instance_of Google::Cloud::Talent::V4::Tenant, matched_tenant
      delete_tenant_helper matched_tenant
    end
  end

  describe "custom_ranking_search" do
    after { delete_tenant_helper tenant }

    it "searches for jobs" do
      get_job_helper job.name
      out = ""
      5.times do
        next if out.include? job.title

        sleep 5
        out, _err = capture_io do
          sample_custom_ranking_search project_id, tenant_id
        end
      end
      assert_includes out, "Job name: #{job.name}"
      assert_includes out, "Job title: #{job.title}"
    end
  end

  describe "delete_company" do
    after { delete_tenant_helper tenant }

    it "deletes a company" do
      out, _err = capture_io do
        sample_delete_company project_id, tenant_id, company_id
      end
      assert_includes out, "Deleted company\n"
    end
  end

  describe "delete_job" do
    after { delete_tenant_helper tenant }

    it "deletes a job" do
      out, _err = capture_io do
        sample_delete_job project_id, tenant_id, job_id
      end
      assert_includes out, "Deleted job.\n"
    end
  end

  describe "delete_tenant" do
    it "deletes a tenant" do
      out, _err = capture_io do
        sample_delete_tenant project_id, tenant_id
      end
      assert_includes out, "Deleted Tenant.\n"
    end
  end

  describe "get_company" do
    after { delete_tenant_helper tenant }

    it "gets a company" do
      out, _err = capture_io do
        sample_get_company project_id, tenant_id, company_id
      end
      assert_includes out, "Company name: #{company.name}"
      assert_includes out, "Display name: #{company.display_name}"
    end
  end

  describe "get_job" do
    after { delete_tenant_helper tenant }

    it "gets a job" do
      out, _err = capture_io do
        sample_get_job project_id, tenant_id, job_id
      end
      assert_includes out, "Job name: #{job.name}"
      assert_includes out, "Requisition ID: #{job.requisition_id}"
      assert_includes out, "Title: #{job.title}"
      assert_includes out, "Description: #{job.description}"
      assert_includes out, "Posting language: #{job.language_code}"
      assert_includes out, "Address: #{job.addresses.first}"
      assert_includes out, "Email: #{job.application_info.emails.first}"
    end
  end

  describe "get_tenant" do
    after { delete_tenant_helper tenant }

    it "gets a tenant" do
      out, _err = capture_io do
        sample_get_tenant project_id, tenant_id
      end
      assert_includes out, "Name: #{tenant.name}"
      assert_includes out, "External ID: #{tenant.external_id}"
    end
  end

  describe "histogram_search" do
    after { delete_tenant_helper tenant }

    it "searches jobs with a histogram query" do
      get_job_helper job.name
      out = ""
      query = "count(base_compensation, [bucket(12, 20)])"
      5.times do
        next if out.include? "Job name: #{job.name}"

        sleep 5
        out, _err = capture_io do
          sample_search_jobs project_id, tenant_id, query
        end
      end

      assert_includes out, "Job name: #{job.name}"
      assert_includes out, "Job title: #{job.title}"
    end
  end

  describe "list_companies" do
    after { delete_tenant_helper tenant }

    it "gets a list of companies for a tenant" do
      job
      out, _err = capture_io do
        sample_list_companies project_id, tenant_id
      end
      assert_includes out, "Company Name: #{company.name}"
      assert_includes out, "Display Name: #{company.display_name}"
      assert_includes out, "External ID: #{company.external_id}"
    end
  end

  describe "list_jobs" do
    after { delete_tenant_helper tenant }

    it "gets a list of jobs" do
      get_job_helper job.name
      filter = "companyName=\"#{company.name}\""
      out, _err = capture_io do
        sample_list_jobs project_id, tenant_id, filter
      end
      assert_includes out, "Job name: #{job.name}"
      assert_includes out, "Job requisition ID: #{job.requisition_id}"
      assert_includes out, "Job title: #{job.title}"
      assert_includes out, "Job description: #{job.description}"
    end
  end

  describe "list_tenants" do
    after { delete_tenant_helper tenant }

    it "lists the tenants" do
      tenant
      out, _err = capture_io do
        sample_list_tenants project_id
      end
      assert_includes out, "Tenant Name: #{tenant.name}"
      assert_includes out, "External ID: #{tenant.external_id}"
    end
  end
end
