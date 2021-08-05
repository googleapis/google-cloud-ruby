# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def create_namespace project:, location:, namespace:
  # [START servicedirectory_create_namespace]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the new namespace"
  # namespace = "The name of the namespace you are creating"

  require "google/cloud/service_directory"

  # Initialize the client
  registration_service = Google::Cloud::ServiceDirectory.registration_service

  # The parent path of the namespace
  parent = registration_service.location_path(
    project: project, location: location
  )

  # Use the Service Directory API to create the namespace
  response = registration_service.create_namespace(
    parent: parent, namespace_id: namespace
  )
  puts "Created namespace: #{response.name}"
  # [END servicedirectory_create_namespace]
end

def delete_namespace project:, location:, namespace:
  # [START servicedirectory_delete_namespace]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the namespace"
  # namespace = "The name of the namespace"

  require "google/cloud/service_directory"

  # Initialize the client
  registration_service = Google::Cloud::ServiceDirectory.registration_service

  # The path of the namespace
  namespace_name = registration_service.namespace_path(
    project: project, location: location, namespace: namespace
  )

  # Use the Service Directory API to delete the namespace
  registration_service.delete_namespace name: namespace_name
  puts "Deleted namespace: #{namespace_name}"
  # [END servicedirectory_delete_namespace]
end

def create_service project:, location:, namespace:, service:
  # [START servicedirectory_create_service]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the namespace"
  # namespace = "The name of the parent namespace"
  # service   = "The name of the service you are creating"

  require "google/cloud/service_directory"

  # Initialize the client
  registration_service = Google::Cloud::ServiceDirectory.registration_service

  # The parent path of the service
  parent = registration_service.namespace_path(
    project: project, location: location, namespace: namespace
  )

  # Use the Service Directory API to create the service
  response = registration_service.create_service parent: parent, service_id: service
  puts "Created service: #{response.name}"
  # [END servicedirectory_create_service]
end

def delete_service project:, location:, namespace:, service:
  # [START servicedirectory_delete_service]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the namespace"
  # namespace = "The name of the parent namespace"
  # service   = "The name of the service"

  require "google/cloud/service_directory"

  # Initialize the client
  registration_service = Google::Cloud::ServiceDirectory.registration_service

  # The path of the service
  service_path = registration_service.service_path(
    project:   project,
    location:  location,
    namespace: namespace,
    service:   service
  )

  # Use the Service Directory API to delete the service
  registration_service.delete_service name: service_path
  puts "Deleted service: #{service_path}"
  # [END servicedirectory_delete_service]
end

def create_endpoint project:, location:, namespace:, service:, endpoint:
  # [START servicedirectory_create_endpoint]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the namespace"
  # namespace = "The name of the parent namespace"
  # service   = "The name of the parent service"
  # endpoint  = "The name of the endpoint you are creating"

  require "google/cloud/service_directory"

  # Initialize the client
  registration_service = Google::Cloud::ServiceDirectory.registration_service

  # The parent path of the endpoint
  parent = registration_service.service_path(
    project:   project,
    location:  location,
    namespace: namespace,
    service:   service
  )

  # Set the IP Address and Port on the Endpoint
  endpoint_data = Google::Cloud::ServiceDirectory::V1::Endpoint.new(
    address: "10.0.0.1",
    port:    443
  )

  # Use the Service Directory API to create the endpoint
  response = registration_service.create_endpoint(
    parent: parent, endpoint_id: endpoint, endpoint: endpoint_data
  )
  puts "Created endpoint: #{response.name}"
  # [END servicedirectory_create_endpoint]
end

def delete_endpoint project:, location:, namespace:, service:, endpoint:
  # [START servicedirectory_delete_endpoint]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the namespace"
  # namespace = "The name of the parent namespace"
  # service   = "The name of the parent service"
  # endpoint  = "The name of the endpoint"

  require "google/cloud/service_directory"

  # Initialize the client
  registration_service = Google::Cloud::ServiceDirectory.registration_service

  # The path of the endpoint
  endpoint_path = registration_service.endpoint_path(
    project:   project,
    location:  location,
    namespace: namespace,
    service:   service,
    endpoint:  endpoint
  )

  # Use the Service Directory API to delete the endpoint
  registration_service.delete_endpoint name: endpoint_path
  puts "Deleted endpoint: #{endpoint_path}"
  # [END servicedirectory_delete_endpoint]
end

def resolve_service project:, location:, namespace:, service:
  # [START servicedirectory_resolve_service]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the namespace"
  # namespace = "The name of the parent namespace"
  # service   = "The name of the service"

  require "google/cloud/service_directory"

  # Initialize the client
  lookup_service = Google::Cloud::ServiceDirectory.lookup_service

  # The name of the service
  service_path = lookup_service.service_path(
    project:   project,
    location:  location,
    namespace: namespace,
    service:   service
  )

  # Use the Service Directory API to resolve the service
  response = lookup_service.resolve_service name: service_path
  puts "Resolved service: #{response.service.name}"
  puts "Endpoints: "
  response.service.endpoints.each do |endpoint|
    puts "#{endpoint.name} #{endpoint.address} #{endpoint.port}"
  end
  # [END servicedirectory_resolve_service]
end


if $PROGRAM_NAME == __FILE__
  project = ENV["GOOGLE_CLOUD_PROJECT"]
  command = ARGV.shift

  case command
  when "create_namespace"
    create_namespace(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift
    )
  when "delete_namespace"
    delete_namespace(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift
    )
  when "create_service"
    create_service(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift,
      service:   ARGV.shift
    )
  when "delete_service"
    delete_service(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift,
      service:   ARGV.shift
    )
  when "create_endpoint"
    create_endpoint(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift,
      service:   ARGV.shift,
      endpoint:  ARGV.shift
    )
  when "delete_endpoint"
    delete_endpoint(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift,
      service:   ARGV.shift,
      endpoint:  ARGV.shift
    )
  when "resolve_service"
    resolve_service(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift,
      service:   ARGV.shift
    )
  else
    puts <<~USAGE
      Usage: bundle exec ruby servicedirectory.rb [command] [arguments]

      Commands:
        create_namespace    <location> <namespace>
        delete_namespace    <location> <namespace>
        create_service      <location> <namespace> <service>
        delete_service      <location> <namespace> <service>
        create_endpoint     <location> <namespace> <service> <endpoint>
        delete_endpoint     <location> <namespace> <service> <endpoint>
        resolve_service     <location> <namespace> <service>

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud Project ID
    USAGE
  end

end
