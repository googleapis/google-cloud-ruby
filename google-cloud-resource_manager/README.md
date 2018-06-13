# google-cloud-resource_manager

[Google Cloud Resource Manager](https://cloud.google.com/resource-manager/) ([docs](https://cloud.google.com/resource-manager/reference/rest/)) enables you to
programmatically manage  container resources such as Organizations and Projects, that allow you to group and hierarchically organize other Cloud Platform resources. This hierarchical organization lets you easily manage common aspects of your resources such as access control and configuration settings. You may be familiar with managing projects in the [Developers Console](https://developers.google.com/console/help/new/). With this API you can do the following:

* Get a list of all projects associated with an account
* Create new projects
* Update existing projects
* Delete projects
* Undelete, or recover, projects that you don't want to delete

- [google-cloud-resource_manager API documentation](http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-resource_manager/latest)
- [google-cloud-resource_manager on RubyGems](https://rubygems.org/gems/google-cloud-resource_manager)
- [Google Cloud Resource Manager documentation](https://cloud.google.com/resource-manager/)

## Quick Start

```sh
$ gem install google-cloud-resource_manager
```

## Authentication

The Resource Manager API currently requires authentication of a [User
Account](https://developers.google.com/identity/protocols/OAuth2), and
cannot currently be accessed with a [Service
Account](https://developers.google.com/identity/protocols/OAuth2ServiceAccount).
To use a User Account install the [Google Cloud
SDK](http://cloud.google.com/sdk) and authenticate with the following:

```
$ gcloud auth login
```

Also make sure all environment variables are cleared of any
service account credentials. Then google-cloud-resource_manager will be able to detect the user
authentication and connect with those credentials.

Instructions and configuration options are covered in the [Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-resource_manager/guides/authentication).

## Example

```ruby
require "google/cloud/resource_manager"

resource_manager = Google::Cloud::ResourceManager.new

# List all projects
resource_manager.projects.each do |project|
  puts projects.project_id
end

# Label a project as production
project = resource_manager.project "tokyo-rain-123"
project.update do |p|
  p.labels["env"] = "production"
end

# List only projects with the "production" label
projects = resource_manager.projects filter: "labels.env:production"
```

## Enabling Logging

To enable logging for this library, set the logger for the underlying [Google API Client](https://github.com/google/google-api-ruby-client/blob/master/README.md#logging) library. The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html) as shown below, or a [`Google::Cloud::Logging::Logger`](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest/google/cloud/logging/logger) that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/).

If you do not set the logger explicitly and your application is running in a Rails environment, it will default to `Rails.logger`. Otherwise, if you do not set the logger and you are not using Rails, logging is disabled by default.

Configuring a Ruby stdlib logger:

```ruby
require "logger"

my_logger = Logger.new $stderr
my_logger.level = Logger::WARN

# Set the Google API Client logger
Google::Apis.logger = my_logger
```

## Supported Ruby Versions

This library is supported on Ruby 2.3+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Currently, this means Ruby 2.3
and later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.

## Versioning

This library follows [Semantic Versioning](http://semver.org/).

It is currently in major version zero (0.y.z), which means that anything may change at any time and the public API should not be considered stable.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See the [Contributing Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/contributing) for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](../CODE_OF_CONDUCT.md) for more information.

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE).

## Support

Please [report bugs at the project on Github](https://github.com/GoogleCloudPlatform/google-cloud-ruby/issues).
Don't hesitate to [ask questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby) about the client or APIs on [StackOverflow](http://stackoverflow.com).
