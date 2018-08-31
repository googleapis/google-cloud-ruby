# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Google
  module Cloud
    module Tasks
      module V2beta2
        # Pull target.
        class PullTarget; end

        # The pull message contains data that can be used by the caller of
        # {Google::Cloud::Tasks::V2beta2::CloudTasks::LeaseTasks LeaseTasks} to process the task.
        #
        # This proto can only be used for tasks in a queue which has
        # {Google::Cloud::Tasks::V2beta2::Queue#pull_target pull_target} set.
        # @!attribute [rw] payload
        #   @return [String]
        #     A data payload consumed by the worker to execute the task.
        # @!attribute [rw] tag
        #   @return [String]
        #     The task's tag.
        #
        #     Tags allow similar tasks to be processed in a batch. If you label
        #     tasks with a tag, your worker can
        #     {Google::Cloud::Tasks::V2beta2::CloudTasks::LeaseTasks lease tasks} with the same tag using
        #     {Google::Cloud::Tasks::V2beta2::LeaseTasksRequest#filter filter}. For example, if you want to
        #     aggregate the events associated with a specific user once a day,
        #     you could tag tasks with the user ID.
        #
        #     The task's tag can only be set when the
        #     {Google::Cloud::Tasks::V2beta2::CloudTasks::CreateTask task is created}.
        #
        #     The tag must be less than 500 characters.
        #
        #     SDK compatibility: Although the SDK allows tags to be either
        #     string or [bytes](https://cloud.google.com/appengine/docs/standard/java/javadoc/com/google/appengine/api/taskqueue/TaskOptions.html#tag-byte:A-),
        #     only UTF-8 encoded tags can be used in Cloud Tasks. If a tag isn't UTF-8
        #     encoded, the tag will be empty when the task is returned by Cloud Tasks.
        class PullMessage; end

        # App Engine HTTP target.
        #
        # The task will be delivered to the App Engine application hostname
        # specified by its {Google::Cloud::Tasks::V2beta2::AppEngineHttpTarget AppEngineHttpTarget} and {Google::Cloud::Tasks::V2beta2::AppEngineHttpRequest AppEngineHttpRequest}.
        # The documentation for {Google::Cloud::Tasks::V2beta2::AppEngineHttpRequest AppEngineHttpRequest} explains how the
        # task's host URL is constructed.
        #
        # Using {Google::Cloud::Tasks::V2beta2::AppEngineHttpTarget AppEngineHttpTarget} requires
        # [+appengine.applications.get+](https://cloud.google.com/appengine/docs/admin-api/access-control)
        # Google IAM permission for the project
        # and the following scope:
        #
        # +https://www.googleapis.com/auth/cloud-platform+
        # @!attribute [rw] app_engine_routing_override
        #   @return [Google::Cloud::Tasks::V2beta2::AppEngineRouting]
        #     Overrides for the
        #     {Google::Cloud::Tasks::V2beta2::AppEngineHttpRequest#app_engine_routing task-level app_engine_routing}.
        #
        #     If set, +app_engine_routing_override+ is used for all tasks in
        #     the queue, no matter what the setting is for the
        #     {Google::Cloud::Tasks::V2beta2::AppEngineHttpRequest#app_engine_routing task-level app_engine_routing}.
        class AppEngineHttpTarget; end

        # App Engine HTTP request.
        #
        # The message defines the HTTP request that is sent to an App Engine app when
        # the task is dispatched.
        #
        # This proto can only be used for tasks in a queue which has
        # {Google::Cloud::Tasks::V2beta2::Queue#app_engine_http_target app_engine_http_target} set.
        #
        # Using {Google::Cloud::Tasks::V2beta2::AppEngineHttpRequest AppEngineHttpRequest} requires
        # [+appengine.applications.get+](https://cloud.google.com/appengine/docs/admin-api/access-control)
        # Google IAM permission for the project
        # and the following scope:
        #
        # +https://www.googleapis.com/auth/cloud-platform+
        #
        # The task will be delivered to the App Engine app which belongs to the same
        # project as the queue. For more information, see
        # [How Requests are Routed](https://cloud.google.com/appengine/docs/standard/python/how-requests-are-routed)
        # and how routing is affected by
        # [dispatch files](https://cloud.google.com/appengine/docs/python/config/dispatchref).
        #
        # The {Google::Cloud::Tasks::V2beta2::AppEngineRouting AppEngineRouting} used to construct the URL that the task is
        # delivered to can be set at the queue-level or task-level:
        #
        # * If set,
        #   {Google::Cloud::Tasks::V2beta2::AppEngineHttpTarget#app_engine_routing_override app_engine_routing_override}
        #   is used for all tasks in the queue, no matter what the setting
        #   is for the
        #   {Google::Cloud::Tasks::V2beta2::AppEngineHttpRequest#app_engine_routing task-level app_engine_routing}.
        #
        #
        # The +url+ that the task will be sent to is:
        #
        # * +url =+ {Google::Cloud::Tasks::V2beta2::AppEngineRouting#host host} +++
        #   {Google::Cloud::Tasks::V2beta2::AppEngineHttpRequest#relative_url relative_url}
        #
        # The task attempt has succeeded if the app's request handler returns
        # an HTTP response code in the range [+200+ - +299+]. +503+ is
        # considered an App Engine system error instead of an application
        # error. Requests returning error +503+ will be retried regardless of
        # retry configuration and not counted against retry counts.
        # Any other response code or a failure to receive a response before the
        # deadline is a failed attempt.
        # @!attribute [rw] http_method
        #   @return [Google::Cloud::Tasks::V2beta2::HttpMethod]
        #     The HTTP method to use for the request. The default is POST.
        #
        #     The app's request handler for the task's target URL must be able to handle
        #     HTTP requests with this http_method, otherwise the task attempt will fail
        #     with error code 405 (Method Not Allowed). See
        #     [Writing a push task request handler](https://cloud.google.com/appengine/docs/java/taskqueue/push/creating-handlers#writing_a_push_task_request_handler)
        #     and the documentation for the request handlers in the language your app is
        #     written in e.g.
        #     [Python Request Handler](https://cloud.google.com/appengine/docs/python/tools/webapp/requesthandlerclass).
        # @!attribute [rw] app_engine_routing
        #   @return [Google::Cloud::Tasks::V2beta2::AppEngineRouting]
        #     Task-level setting for App Engine routing.
        #
        #     If set,
        #     {Google::Cloud::Tasks::V2beta2::AppEngineHttpTarget#app_engine_routing_override app_engine_routing_override}
        #     is used for all tasks in the queue, no matter what the setting is for the
        #     {Google::Cloud::Tasks::V2beta2::AppEngineHttpRequest#app_engine_routing task-level app_engine_routing}.
        # @!attribute [rw] relative_url
        #   @return [String]
        #     The relative URL.
        #
        #     The relative URL must begin with "/" and must be a valid HTTP relative URL.
        #     It can contain a path and query string arguments.
        #     If the relative URL is empty, then the root path "/" will be used.
        #     No spaces are allowed, and the maximum length allowed is 2083 characters.
        # @!attribute [rw] headers
        #   @return [Hash{String => String}]
        #     HTTP request headers.
        #
        #     This map contains the header field names and values.
        #     Headers can be set when the
        #     {Google::Cloud::Tasks::V2beta2::CloudTasks::CreateTask task is created}.
        #     Repeated headers are not supported but a header value can contain commas.
        #
        #     Cloud Tasks sets some headers to default values:
        #
        #     * +User-Agent+: By default, this header is
        #       +"AppEngine-Google; (+http://code.google.com/appengine)"+.
        #       This header can be modified, but Cloud Tasks will append
        #       +"AppEngine-Google; (+http://code.google.com/appengine)"+ to the
        #       modified +User-Agent+.
        #
        #     If the task has a {Google::Cloud::Tasks::V2beta2::AppEngineHttpRequest#payload payload}, Cloud
        #     Tasks sets the following headers:
        #
        #     * +Content-Type+: By default, the +Content-Type+ header is set to
        #       +"application/octet-stream"+. The default can be overridden by explicitly
        #       setting +Content-Type+ to a particular media type when the
        #       {Google::Cloud::Tasks::V2beta2::CloudTasks::CreateTask task is created}.
        #       For example, +Content-Type+ can be set to +"application/json"+.
        #     * +Content-Length+: This is computed by Cloud Tasks. This value is
        #       output only.   It cannot be changed.
        #
        #     The headers below cannot be set or overridden:
        #
        #     * +Host+
        #     * +X-Google-*+
        #     * +X-AppEngine-*+
        #
        #     In addition, Cloud Tasks sets some headers when the task is dispatched,
        #     such as headers containing information about the task; see
        #     [request headers](https://cloud.google.com/appengine/docs/python/taskqueue/push/creating-handlers#reading_request_headers).
        #     These headers are set only when the task is dispatched, so they are not
        #     visible when the task is returned in a Cloud Tasks response.
        #
        #     Although there is no specific limit for the maximum number of headers or
        #     the size, there is a limit on the maximum size of the {Google::Cloud::Tasks::V2beta2::Task Task}. For more
        #     information, see the {Google::Cloud::Tasks::V2beta2::CloudTasks::CreateTask CreateTask} documentation.
        # @!attribute [rw] payload
        #   @return [String]
        #     Payload.
        #
        #     The payload will be sent as the HTTP message body. A message
        #     body, and thus a payload, is allowed only if the HTTP method is
        #     POST or PUT. It is an error to set a data payload on a task with
        #     an incompatible {Google::Cloud::Tasks::V2beta2::HttpMethod HttpMethod}.
        class AppEngineHttpRequest; end

        # App Engine Routing.
        #
        # For more information about services, versions, and instances see
        # [An Overview of App Engine](https://cloud.google.com/appengine/docs/python/an-overview-of-app-engine),
        # [Microservices Architecture on Google App Engine](https://cloud.google.com/appengine/docs/python/microservices-on-app-engine),
        # [App Engine Standard request routing](https://cloud.google.com/appengine/docs/standard/python/how-requests-are-routed),
        # and [App Engine Flex request routing](https://cloud.google.com/appengine/docs/flexible/python/how-requests-are-routed).
        # @!attribute [rw] service
        #   @return [String]
        #     App service.
        #
        #     By default, the task is sent to the service which is the default
        #     service when the task is attempted.
        #
        #     For some queues or tasks which were created using the App Engine
        #     Task Queue API, {Google::Cloud::Tasks::V2beta2::AppEngineRouting#host host} is not parsable
        #     into {Google::Cloud::Tasks::V2beta2::AppEngineRouting#service service},
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#version version}, and
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#instance instance}. For example, some tasks
        #     which were created using the App Engine SDK use a custom domain
        #     name; custom domains are not parsed by Cloud Tasks. If
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#host host} is not parsable, then
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#service service},
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#version version}, and
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#instance instance} are the empty string.
        # @!attribute [rw] version
        #   @return [String]
        #     App version.
        #
        #     By default, the task is sent to the version which is the default
        #     version when the task is attempted.
        #
        #     For some queues or tasks which were created using the App Engine
        #     Task Queue API, {Google::Cloud::Tasks::V2beta2::AppEngineRouting#host host} is not parsable
        #     into {Google::Cloud::Tasks::V2beta2::AppEngineRouting#service service},
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#version version}, and
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#instance instance}. For example, some tasks
        #     which were created using the App Engine SDK use a custom domain
        #     name; custom domains are not parsed by Cloud Tasks. If
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#host host} is not parsable, then
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#service service},
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#version version}, and
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#instance instance} are the empty string.
        # @!attribute [rw] instance
        #   @return [String]
        #     App instance.
        #
        #     By default, the task is sent to an instance which is available when
        #     the task is attempted.
        #
        #     Requests can only be sent to a specific instance if
        #     [manual scaling is used in App Engine Standard](https://cloud.google.com/appengine/docs/python/an-overview-of-app-engine?hl=en_US#scaling_types_and_instance_classes).
        #     App Engine Flex does not support instances. For more information, see
        #     [App Engine Standard request routing](https://cloud.google.com/appengine/docs/standard/python/how-requests-are-routed)
        #     and [App Engine Flex request routing](https://cloud.google.com/appengine/docs/flexible/python/how-requests-are-routed).
        # @!attribute [rw] host
        #   @return [String]
        #     Output only. The host that the task is sent to.
        #
        #     For more information, see
        #     [How Requests are Routed](https://cloud.google.com/appengine/docs/standard/python/how-requests-are-routed).
        #
        #     The host is constructed as:
        #
        #
        #     * +host = [application_domain_name]+</br>
        #       +| [service] + '.' + [application_domain_name]+</br>
        #       +| [version] + '.' + [application_domain_name]+</br>
        #       +| [version_dot_service]+ '.' + [application_domain_name]+</br>
        #       +| [instance] + '.' + [application_domain_name]+</br>
        #       +| [instance_dot_service] + '.' + [application_domain_name]+</br>
        #       +| [instance_dot_version] + '.' + [application_domain_name]+</br>
        #       +| [instance_dot_version_dot_service] + '.' + [application_domain_name]+
        #
        #     * +application_domain_name+ = The domain name of the app, for
        #       example <app-id>.appspot.com, which is associated with the
        #       queue's project ID. Some tasks which were created using the App Engine
        #       SDK use a custom domain name.
        #
        #     * +service =+ {Google::Cloud::Tasks::V2beta2::AppEngineRouting#service service}
        #
        #     * +version =+ {Google::Cloud::Tasks::V2beta2::AppEngineRouting#version version}
        #
        #     * +version_dot_service =+
        #       {Google::Cloud::Tasks::V2beta2::AppEngineRouting#version version} ++ '.' ++
        #       {Google::Cloud::Tasks::V2beta2::AppEngineRouting#service service}
        #
        #     * +instance =+ {Google::Cloud::Tasks::V2beta2::AppEngineRouting#instance instance}
        #
        #     * +instance_dot_service =+
        #       {Google::Cloud::Tasks::V2beta2::AppEngineRouting#instance instance} ++ '.' ++
        #       {Google::Cloud::Tasks::V2beta2::AppEngineRouting#service service}
        #
        #     * +instance_dot_version =+
        #       {Google::Cloud::Tasks::V2beta2::AppEngineRouting#instance instance} ++ '.' ++
        #       {Google::Cloud::Tasks::V2beta2::AppEngineRouting#version version}
        #
        #     * +instance_dot_version_dot_service =+
        #       {Google::Cloud::Tasks::V2beta2::AppEngineRouting#instance instance} ++ '.' ++
        #       {Google::Cloud::Tasks::V2beta2::AppEngineRouting#version version} ++ '.' ++
        #       {Google::Cloud::Tasks::V2beta2::AppEngineRouting#service service}
        #
        #     If {Google::Cloud::Tasks::V2beta2::AppEngineRouting#service service} is empty, then the task will be sent
        #     to the service which is the default service when the task is attempted.
        #
        #     If {Google::Cloud::Tasks::V2beta2::AppEngineRouting#version version} is empty, then the task will be sent
        #     to the version which is the default version when the task is attempted.
        #
        #     If {Google::Cloud::Tasks::V2beta2::AppEngineRouting#instance instance} is empty, then the task
        #     will be sent to an instance which is available when the task is
        #     attempted.
        #
        #     If {Google::Cloud::Tasks::V2beta2::AppEngineRouting#service service},
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#version version}, or
        #     {Google::Cloud::Tasks::V2beta2::AppEngineRouting#instance instance} is invalid, then the task
        #     will be sent to the default version of the default service when
        #     the task is attempted.
        class AppEngineRouting; end

        # The HTTP method used to execute the task.
        module HttpMethod
          # HTTP method unspecified
          HTTP_METHOD_UNSPECIFIED = 0

          # HTTP POST
          POST = 1

          # HTTP GET
          GET = 2

          # HTTP HEAD
          HEAD = 3

          # HTTP PUT
          PUT = 4

          # HTTP DELETE
          DELETE = 5
        end
      end
    end
  end
end