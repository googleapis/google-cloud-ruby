# Copyright 2026 Google LLC
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

require "storage_helper"

describe Google::Cloud::Storage::Bucket, :contexts, :storage do
  let(:bucket_name) { $bucket_names[0] }
  let :bucket do
    storage.bucket(bucket_name) ||
    storage.create_bucket(bucket_name) 
  end
  let(:custom_context_key1) { "my-custom-key" }
  let(:custom_context_value1) { "my-custom-value" }
  let(:custom_context_key2) { "my-custom-key-2" }
  let(:custom_context_value2) { "my-custom-value-2" }

  let(:local_file) { "acceptance/data/CloudPlatform_128px_Retina.png" }
  let(:file_name) { "CloudLogo1" }
  let(:file_name2) { "CloudLogo2" }

  before(:all) do
    bucket.create_file local_file, file_name
    bucket.create_file local_file, file_name2
    custom_hash1 = context_custom_hash custom_context_key: custom_context_key1, custom_context_value: custom_context_value1
    custom_hash2 = context_custom_hash custom_context_key: custom_context_key2, custom_context_value: custom_context_value2
    set_object_contexts bucket_name: bucket.name, file_name: file_name, custom_context_key: custom_context_key1, custom_context_value: custom_context_value1
    set_object_contexts bucket_name: bucket.name, file_name: file_name2, custom_context_key: custom_context_key2, custom_context_value: custom_context_value2
  end

  it "lists objects with a specific context key and value" do
    list = bucket.files filter: "contexts.\"#{custom_context_key1}\"=\"#{custom_context_value1}\""
    list.each do |file|
      _(file.name).must_equal file_name
    end
  end

  it "lists objects with a specific context key" do
    list = bucket.files filter: "contexts.\"#{custom_context_key1}\":*"
    list.each do |file|
      _(file.name).must_equal file_name
    end
  end

  it "lists objects that do not have a specific context key" do
    list = bucket.files filter: "-contexts.\"#{custom_context_key1}\":*"
    list.each do |file|
      _(file.name).wont_equal file_name
    end
  end

  it "lists objects that do not have a specific context key and value" do
    list = bucket.files filter: "-contexts.\"#{custom_context_key2}\"=\"#{custom_context_value2}\""
    list.each do |file|
      _(file.name).must_equal file_name
      _(file.name).wont_equal file_name2
    end
  end

end
