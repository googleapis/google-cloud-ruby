# Release History

### 0.5.0 / 2019-08-22

#### Features

* Add path helpers
  * Add company_without_tenant_path, job_without_tenant_path, and project_path.
* Add Profile#derived_addresses

#### Performance Improvements

* Update timeout_millis in client configs

#### Documentation

* Update documentation

### 0.4.0 / 2019-07-09

* Remove dead files related to resume service
* Add candidate_availability_filter and result_set_id
    * Add ProfileQuery#candidate_availability_filter (CandidateAvailabilityFilter)
    * Add result_set_id argument to ProfileServiceClient#search_profiles
    * Add SearchProfilesRequest#result_set_id
    * Add SearchProfilesResponse#result_set_id
    * Update documentation
* Support overriding service host and port.
* Update github link in the PostalAddress docs
* Add Batch Jobs
    * BREAKING CHANGE: Remove JobEventType::NOT_INTERESTED
    * Add JobServiceClient#batch_create_jobs
    * Add JobServiceClient#batch_update_jobs
    * Add JobOperationResult and BatchOperationMetadata
    * Add JobEvent#profile
    * Add SkillProficiencyLevel::UNSKILLED
* Update ProfileServiceClient#search_profiles documentation
* Replace incorrect return type HistogramQueryResult with SummarizedProfile

### 0.3.0 / 2019-05-10

This is a breaking change.

* Add Resume resource
* Add Profile#resume
* Remove Profile#resume_hrxml (Breaking change)
* Add PersonStructuredName#preferred_name
* Add Tenant#keyword_searchable_profile_custom_attributes
* Update generated documentation

### 0.2.0 / 2019-04-29

This is a breaking change.

* Client Changes:
  * Add ApplicationServiceClient
  * Update CompanyServiceClient
    * Remove project_path helper method
    * Add tenant_path helper method
  * Update CompletionClient
    * Remove project_path helper method
    * Add tenant_path helper method
    * Rename complete_query company named argument (was company_name)
  * Update EventServiceClient
    * Remove project_path helper method
    * Add tenant_path helper method
  * Update JobServiceClient
    * Remove project_path helper method
    * Add tenant_path helper method
  * Update ProfileServiceClient
    * Rename list_profiles read_mask argument (was field_mask)
* Resource Changes:
  * Remove JobApplication
  * Remove ApplicationOutcomeReasonFilter
  * Remove RecruitingNote
  * Add Application
  * Add Interview
  * Add Rating
  * Add Outcome
  * Add SkillProficiencyLevel
  * Add ApplicationOutcomeNotesFilter
  * Remove Profile#job_applications
  * Remove Profile#recruiting_notes
  * Add Profile#applications
  * Add Profile#assignments
  * Rename Address#current (was is_current)
  * Rename EmploymentRecord#is_supervisor (was is_supervised_position)
  * Remove CommuteMethod::TRANSIT_ACCESSIBLE
  * Rename Job#company (was company_name)
  * Rename JobQuery#companies (was company_names)
  * Rename ProfileQuery#application_outcome_notes_filters (was application_outcome_reason_filters)
  * Rename ApplicationJobFilter#job (was job_name)
  * Rename CompleteQueryRequest#parent (was name)
  * Rename CompleteQueryRequest#company (was company_name)
* Update Job resource path:
  * Now: projects/{project_id}/tenants/{tenant_id}/jobs/{job_id}
  * Was: projects/{project_id}/jobs/{job_id}"
* Rename ProfileQuery#custom_attribute_filter (was custom_field_filter)
* Remove ProfileQuery#application_last_stage_filters
* Remove ProfileQuery#application_status_filters
* Remove ApplicationJobFilter#job
* Remove ApplicationLastStageFilter
* Remove ApplicationStatusFilter
* Add AUTHENTICATION.md guide.
* Update documentation
* Update documentation for common types.
* Update generated code examples.
* Correct management tools URL.
* Remove Python code example from documentation.

### 0.1.0 / 2019-03-11

* Initial release
