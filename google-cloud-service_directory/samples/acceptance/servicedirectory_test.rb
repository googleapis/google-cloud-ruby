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

require_relative "helper"
require_relative "../servicedirectory"

describe "Service Directory API Test" do
  def get_namespace project:, location:, namespace:
    registration_service = Google::Cloud::ServiceDirectory.registration_service
    namespace_path = registration_service.namespace_path(
      project:   project,
      location:  location,
      namespace: namespace
    )
    registration_service.get_namespace name: namespace_path
  end

  def get_service project:, location:, namespace:, service:
    registration_service = Google::Cloud::ServiceDirectory.registration_service
    service_path = registration_service.service_path(
      project:   project,
      location:  location,
      namespace: namespace,
      service:   service
    )
    registration_service.get_service name: service_path
  end

  def get_endpoint project:, location:, namespace:, service:, endpoint:
    registration_service = Google::Cloud::ServiceDirectory.registration_service
    endpoint_path = registration_service.endpoint_path(
      project:   project,
      location:  location,
      namespace: namespace,
      service:   service,
      endpoint:  endpoint
    )
    registration_service.get_endpoint name: endpoint_path
  end

  before do
    @project   = ENV["GOOGLE_CLOUD_PROJECT"]
    @location  = "us-central1"
    @namespace = "ruby-test-namespace-#{SecureRandom.uuid}"
    @service   = "test-service-#{SecureRandom.uuid}"
    @endpoint  = "test-endpoint-#{SecureRandom.uuid}"

    $VERBOSE = nil
  end

  after do
    registration_service = Google::Cloud::ServiceDirectory.registration_service
    namespace_path = registration_service.namespace_path(
      project: @project,
      location: @location,
      namespace: @namespace
    )
    # Ignore errors from delete_namespace because some tests will clean the
    # namespace up, which would cause 'NOT_FOUND' errors
    begin
      registration_service.delete_namespace name: namespace_path
    rescue StandardError
      # Do nothing
    end
  end

  it "can create namespace" do
    expect {
      create_namespace(
        project:   @project,
        location:  @location,
        namespace: @namespace
      )
    }.must_output(/#{@namespace}/)

    test_namespace = get_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )
    expect(test_namespace.name).must_include @namespace
  end

  it "can delete namespace" do
    create_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )

    expect {
      delete_namespace(
        project:   @project,
        location:  @location,
        namespace: @namespace
      )
    }.must_output(/#{@namespace}/)
  end

  it "can create service" do
    create_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )

    expect {
      create_service(
        project:   @project,
        location:  @location,
        namespace: @namespace,
        service:   @service
      )
    }.must_output(/#{@service}/)

    test_service = get_service(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service
    )
    expect(test_service.name).must_include @service
  end

  it "can delete service" do
    create_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )
    create_service(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service
    )

    expect {
      delete_service(
        project:   @project,
        location:  @location,
        namespace: @namespace,
        service:   @service
      )
    }.must_output(/#{@service}/)
  end

  it "can create endpoint" do
    create_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )
    create_service(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service
    )

    expect {
      create_endpoint(
        project:   @project,
        location:  @location,
        namespace: @namespace,
        service:   @service,
        endpoint:  @endpoint
      )
    }.must_output(/#{@endpoint}/)

    test_endpoint = get_endpoint(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service,
      endpoint:  @endpoint
    )
    expect(test_endpoint.name).must_include @endpoint
  end

  it "can delete endpoint" do
    create_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )
    create_service(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service
    )
    create_endpoint(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service,
      endpoint:  @endpoint
    )
    expect {
      delete_endpoint(
        project:   @project,
        location:  @location,
        namespace: @namespace,
        service:   @service,
        endpoint:  @endpoint
      )
    }.must_output(/#{@endpoint}/)
  end

  it "can resolve service" do
    create_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )
    create_service(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service
    )
    create_endpoint(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service,
      endpoint:  @endpoint
    )
    expect {
      resolve_service(
        project:   @project,
        location:  @location,
        namespace: @namespace,
        service:   @service
      )
    }.must_output(/#{@endpoint}/)
  end
end
