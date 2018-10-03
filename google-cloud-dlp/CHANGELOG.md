# Release History

### 0.7.0 / 2018-10-03

* Add order_by argument to the following methods and resources:
  * DlpServiceClient#list_inspect_templates
  * DlpServiceClient#list_deidentify_templates
  * ListInspectTemplatesRequest#order_by
  * ListDeidentifyTemplatesRequest#order_by
  * ListStoredInfoTypesRequest#order_by
* Add InspectConfig#rule_set
  * Add InspectionRuleSet, InspectionRule, ExclusionRule,
    ExcludeInfoTypes, and MatchingType resources.
* Add CustomInfoType#exclusion_type
  * Add ExclusionType resource.
* Update documentation.
* Add new GAPIC config, which is not yet used.

### 0.6.2 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.6.1 / 2018-09-10

* Update documentation.

### 0.6.0 / 2018-08-21

* Update V2 API.
* Update documentation.

### 0.5.0 / 2018-07-10

* Documentation updates
* Credentials env_vars change

### 0.4.0 / 2018-4-26

* Documentation updates
* row_limit, cscc action
* Dictionaries via GCS
* Entity id in risk stats

### 0.3.0 / 2018-4-11

* Documentation updates
* New IMAGE type

### 0.2.0 / 2018-3-16

* Refreshed alpha release for V2 API compatibility

### 0.1.0 / 2017-12-26

* Initial release
