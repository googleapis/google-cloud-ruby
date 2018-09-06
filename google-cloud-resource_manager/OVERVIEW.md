# Google Cloud Resource Manager

The Resource Manager API provides methods that you can use to programmatically
manage your projects in the Google Cloud Platform. You may be familiar with
managing projects in the [Developers
Console](https://developers.google.com/console/help/new/). With this API you can
do the following:

* Get a list of all projects associated with an account
* Create new projects
* Update existing projects
* Delete projects
* Undelete, or recover, projects that you don't want to delete

The goal of google-cloud is to provide an API that is comfortable to Rubyists.
Your authentication credentials are detected automatically in Google Cloud
Platform environments such as Google Compute Engine, Google App Engine and
Google Kubernetes Engine. In other environments you can configure authentication
easily, either directly in your code or via environment variables. Read more
about the options for connecting in the {file:AUTHENTICATION.md Authentication
Guide}.

## Listing Projects

Project is a collection of settings, credentials, and metadata about the
application or applications you're working on. You can retrieve and
inspect all projects that you have permissions to. (See
{Google::Cloud::ResourceManager::Manager#projects Manager#projects})

```ruby
require "google/cloud/resource_manager"

resource_manager = Google::Cloud::ResourceManager.new
resource_manager.projects.each do |project|
  puts projects.project_id
end
```

## Managing Projects with Labels

Labels can be added to or removed from projects. (See
{Google::Cloud::ResourceManager::Project#labels Project#labels})

```ruby
require "google/cloud/resource_manager"

resource_manager = Google::Cloud::ResourceManager.new
project = resource_manager.project "tokyo-rain-123"
# Label the project as production
project.update do |p|
  p.labels["env"] = "production"
end
```

Projects can then be filtered by labels. (See
{Google::Cloud::ResourceManager::Manager#projects Manager#projects})

```ruby
require "google/cloud/resource_manager"

resource_manager = Google::Cloud::ResourceManager.new
# Find only the productions projects
projects = resource_manager.projects filter: "labels.env:production"
projects.each do |project|
  puts project.project_id
end
```

## Creating a Project

You can also use the API to create new projects. (See
{Google::Cloud::ResourceManager::Manager#create_project Manager#create_project})

```ruby
require "google/cloud/resource_manager"

resource_manager = Google::Cloud::ResourceManager.new
project = resource_manager.create_project "tokyo-rain-123",
                                          name: "Todos Development",
                                          labels: {env: :development}
```

## Deleting a Project

You can delete projects when they are no longer needed. (See
{Google::Cloud::ResourceManager::Manager#delete Manager#delete} and
{Google::Cloud::ResourceManager::Project#delete Project#delete})

```ruby
require "google/cloud/resource_manager"

resource_manager = Google::Cloud::ResourceManager.new
resource_manager.delete "tokyo-rain-123"
```

## Undeleting a Project

You can also restore a deleted project within the waiting period that
starts when the project was deleted. Restoring a project returns it to the
state it was in prior to being deleted. (See
{Google::Cloud::ResourceManager::Manager#undelete Manager#undelete} and
{Google::Cloud::ResourceManager::Project#undelete Project#undelete})

```ruby
require "google/cloud/resource_manager"

resource_manager = Google::Cloud::ResourceManager.new
resource_manager.undelete "tokyo-rain-123"
```

## Configuring retries and timeout

You can configure how many times API requests may be automatically retried. When
an API request fails, the response will be inspected to see if the request meets
criteria indicating that it may succeed on retry, such as `500` and `503` status
codes or a specific internal error code such as `rateLimitExceeded`. If it meets
the criteria, the request will be retried after a delay. If another error
occurs, the delay will be increased before a subsequent attempt, until the
`retries` limit is reached.

You can also set the request `timeout` value in seconds.

```ruby
require "google/cloud/resource_manager"

resource_manager = Google::Cloud::ResourceManager.new retries: 10,
                                                      timeout: 120
```

See the [Resource Manager error
messages](https://cloud.google.com/resource-manager/docs/core_errors)
for a list of error conditions.

## Managing IAM Policies

Google Cloud Identity and Access Management ([Cloud
IAM](https://cloud.google.com/iam/)) access control policies can be managed on
projects. These policies allow project owners to manage _who_ (identity) has
access to _what_ (role). See [Cloud IAM
Overview](https://cloud.google.com/iam/docs/overview) for more information.

A project's access control policy can be retrieved. (See
{Google::Cloud::ResourceManager::Project#policy Project#policy} and
{Google::Cloud::ResourceManager::Policy Policy}.)

```ruby
require "google/cloud/resource_manager"

resource_manager = Google::Cloud::ResourceManager.new
project = resource_manager.project "tokyo-rain-123"
policy = project.policy
```

A project's access control policy can also be updated:

```ruby
require "google/cloud/resource_manager"

resource_manager = Google::Cloud::ResourceManager.new
project = resource_manager.project "tokyo-rain-123"

policy = project.policy do |p|
  p.add "roles/viewer", "serviceAccount:your-service-account"
end
```

And permissions can be tested on a project. (See
{Google::Cloud::ResourceManager::Project#test_permissions
Project#test_permissions})

```ruby
require "google/cloud/resource_manager"

resource_manager = Google::Cloud::ResourceManager.new
project = resource_manager.project "tokyo-rain-123"
perms = project.test_permissions "resourcemanager.projects.get",
                                 "resourcemanager.projects.delete"
perms.include? "resourcemanager.projects.get"    #=> true
perms.include? "resourcemanager.projects.delete" #=> false
```

For more information about using access control policies see [Managing
Policies](https://cloud.google.com/iam/docs/managing-policies).

## Additional information

Resource Manager can be configured to use logging. To learn more, see the
{file:LOGGING.md Logging guide}.
