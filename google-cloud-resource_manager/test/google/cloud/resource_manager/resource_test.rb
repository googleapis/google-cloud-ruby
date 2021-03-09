# Copyright 2019 Google LLC
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

require "helper"

describe Google::Cloud::ResourceManager::Resource do
  it "creates a resource" do
    folder = Google::Cloud::ResourceManager::Resource.new "folder", "1234"
    _(folder).must_be_kind_of Google::Cloud::ResourceManager::Resource
    _(folder.type).must_equal "folder"
    _(folder.id).must_equal "1234"
    _(folder).must_be :folder?
    _(folder).wont_be :organization?

    organization = Google::Cloud::ResourceManager::Resource.new "organization", "7890"
    _(organization).must_be_kind_of Google::Cloud::ResourceManager::Resource
    _(organization.type).must_equal "organization"
    _(organization.id).must_equal "7890"
    _(organization).wont_be :folder?
    _(organization).must_be :organization?
  end

  it "creating a resource without type or id raises" do
    error = expect do
      Google::Cloud::ResourceManager::Resource.new "folder", nil
    end.must_raise ArgumentError
    _(error.message).must_equal "id is required"

    error = expect do
      Google::Cloud::ResourceManager::Resource.new nil, "1234"
    end.must_raise ArgumentError
    _(error.message).must_equal "type is required"
  end

  it "creates a folder" do
    folder = Google::Cloud::ResourceManager::Resource.folder "1234"
    _(folder).must_be_kind_of Google::Cloud::ResourceManager::Resource
    _(folder.type).must_equal "folder"
    _(folder.id).must_equal "1234"
    _(folder).must_be :folder?
    _(folder).wont_be :organization?
  end

  it "creates an organization" do
    organization = Google::Cloud::ResourceManager::Resource.organization "7890"
    _(organization).must_be_kind_of Google::Cloud::ResourceManager::Resource
    _(organization.type).must_equal "organization"
    _(organization.id).must_equal "7890"
    _(organization).wont_be :folder?
    _(organization).must_be :organization?
  end
end
