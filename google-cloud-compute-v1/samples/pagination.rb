# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START compute_images_list_page]
# [START compute_images_list]

require "google/cloud/compute/v1"

# [END compute_images_list]
# [END compute_images_list_page]

# [START compute_images_list]
# Prints a list of all non-deprecated image names available in given project.
#
# @param [String] project project ID or project number of the Cloud project you want to list images from.
def print_images_list project:
  client = ::Google::Cloud::Compute::V1::Images::Rest::Client.new

  # Make the request to list all non-deprecated images in a project.
  request = {
    project: project,
    # max_results indicates the maximum number of items that will be returned per page.
    max_results: 100,
    # Listing only non-deprecated images to reduce the size of the reply.
    filter: "deprecated.state != DEPRECATED"
  }

  # Although the `max_results` parameter is specified in the request, the iterable returned
  # by the `list` method hides the pagination mechanic. The library makes multiple
  # requests to the API for you, so you can simply iterate over all the images.
  client.list(request).each do |image|
    puts " - #{image.name}"
  end
end
# [END compute_images_list]

# [START compute_images_list_page]
# Prints a list of all non-deprecated image names available in a given project,
# divided into pages as returned by the Compute Engine API.
#
# @param [String] project ID or project number of the Cloud project you want to list images from.
# @param [Number] size of the pages you want the API to return on each call.
def print_images_list_by_page project:, page_size: 10
  client = ::Google::Cloud::Compute::V1::Images::Rest::Client.new

  # Make the request to list all non-deprecated images in a project.
  request = {
    project: project,
    # max_results indicates the maximum number of items that will be returned per page.
    max_results: page_size,
    # Listing only non-deprecated images to reduce the size of the reply.
    filter: "deprecated.state != DEPRECATED"
  }

  # Call the each_page method of the returned enumerable to have more granular control
  # of iteration over paginated results from the API. Each time you access the next
  # page, the library retrieves that page from the API.
  page_index = 0
  client.list(request).each_page do |page|
    puts "Page index: #{page_index}"
    page_index += 1
    page.each do |image|
      puts " - #{image.name}"
    end
  end
end
# [END compute_images_list_page]
