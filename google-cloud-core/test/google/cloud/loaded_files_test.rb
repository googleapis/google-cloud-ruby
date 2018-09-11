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


require "helper"

describe Google::Cloud, :loaded_files do
  let(:parent_dir) { File.expand_path(File.dirname(__FILE__)) }
  let :loaded_files do
    [
      "#{parent_dir}/../../../lib/google/cloud.rb:123:in `require'",
      "#{parent_dir}/../../../../google-cloud-core/lib/google/cloud/config.rb:123:in `require'",
      File.realpath("#{parent_dir}/../../../lib/google/cloud/credentials.rb") + ":123:in `require'",
      "-e:1:in `<main>'"
    ]
  end

  it "gives real paths of files that exist" do
    Google::Cloud.stub :caller, loaded_files do
      Google::Cloud.loaded_files.must_equal [
        File.realpath("#{parent_dir}/../../../lib/google/cloud.rb"),
        File.realpath("#{parent_dir}/../../../lib/google/cloud/config.rb"),
        File.realpath("#{parent_dir}/../../../lib/google/cloud/credentials.rb")
      ]
    end
  end
end
