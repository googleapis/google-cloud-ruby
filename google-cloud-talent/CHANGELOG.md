# Release History

### 1.1.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.1.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.1.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.1.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.0.2 / 2021-02-03

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.0.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.0.0 / 2020-10-16

#### ⚠ BREAKING CHANGES

* Now connects to version v4 of the service by default. See https://cloud.google.com/talent-solution/job-search/docs/migrate for more information. Version v4beta1 is now deprecated but can still be selected manually when constructing a client object.

### 0.20.0 / 2020-06-01

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.10.0 / 2020-03-16

#### Features

* update path helpers
  * Add ApplicationServiceClient.company_without_tenant_path
  * Add ApplicationServiceClient.company_path
  * Add CompletionClient.project_path
  * Add EventServiceClient.project_path
  * Add JobServiceClient.project_path
  * Deprecate CompletionClient.tenant_path
  * Deprecate EventServiceClient.tenant_path
  * Deprecate JobServiceClient.tenant_path

### 0.9.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

#### Documentation

* Update description of update field mask

### 0.8.3 / 2020-01-23

#### Performance Improvements

* Update network configuration

#### Documentation

* Reformat documentation for longer line length
* Update copyright year
* Update Status documentation

### 0.8.2 / 2019-12-19

#### Documentation

* Update docs for DiversificationLevel::SIMPLE
* Update PostalAddress#revision documentation

### 0.8.1 / 2019-11-19

#### Documentation

* Minor corrections to descriptions of several constants

### 0.8.1 / 2019-11-12

#### Documentation

* Minor corrections to descriptions of several constants

### 0.8.0 / 2019-11-06

#### Features

* Add JobQuery#query_language_code

#### Bug Fixes

* Update minimum runtime dependencies

### 0.7.0 / 2019-10-29

This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.6.1 / 2019-10-15

#### Documentation

* Update documentation (no visible changes)

### 0.6.0 / 2019-10-03

#### Features

* Add support for availability filters
  * Add filter argument to ProfileServiceClient#list_profiles
  * Add Profile#candidate_update_time field
  * Add Profile#resume_update_time field
  * Add Profile#availability_signals field
  * Add ProfileQuery#availability_filters field
  * Add AvailabilitySignal type
  * Add AvailabilityFilter type
  * Update documentation

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
