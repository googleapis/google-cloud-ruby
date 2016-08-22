# google-cloud-logging

The Stackdriver Logging service collects and stores logs from applications
and services on the Google Cloud Platform, giving you fine-grained,
programmatic control over your projects' logs. You can use the Stackdriver
Logging API to:

* [Read and filter log entries](#listing-log-entries)
* [Export your log entries](#exporting-log-entries) to Cloud Storage,
  BigQuery, or Cloud Pub/Sub
* [Create logs-based metrics](#creating-logs-based-metrics) for use in
  Cloud Monitoring
* [Write log entries](#writing-log-entries)

## Resources

- [google-cloud-logging API documentation](http://googlecloudplatform.github.io/gcloud-ruby/#/docs/google-cloud-logging/google/cloud/logging)
- [Stackdriver Logging documentation](https://cloud.google.com/logging/docs/)

## Authentication

This library uses Service Account credentials to connect to Google Cloud services. When running on Compute Engine the credentials will be discovered automatically. When running on other environments the Service Account credentials can be specified by providing the path to the JSON file, or the JSON itself, in environment variables.

Instructions and configuration options are covered in the [Authentication Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/google-cloud-logging/guides/authentication).

## Example

```ruby
require "google/cloud"

gcloud = Google::Cloud.new
logging = gcloud.logging

# List all log entries
logging.entries.each do |e|
  puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
end

# List only entries from a single log
entries = logging.entries filter: "log:syslog"

# Write a log entry
entry = logging.entry
entry.payload = "Job started."
entry.log_name = "my_app_log"
entry.resource.type = "gae_app"
entry.resource.labels[:module_id] = "1"
entry.resource.labels[:version_id] = "20150925t173233"

logging.write_entries entry
```

## Supported Ruby Versions

This library is supported on Ruby 2.0+.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

It is currently in major version zero (0.y.z), which means that anything may change at any time and the public API should not be considered stable.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/contributing) for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](../CODE_OF_CONDUCT.md) for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](../LICENSE).

## Support

Please [report bugs at the project on Github](https://github.com/GoogleCloudPlatform/gcloud-ruby/issues).
Don't hesitate to [ask questions](http://stackoverflow.com/questions/tagged/gcloud-ruby) about the client or APIs on [StackOverflow](http://stackoverflow.com).