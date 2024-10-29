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

class RepoContext
  @loaded_env = false

  def self.load_kokoro_env
    return if @loaded_env
    @loaded_env = true

    gfile_dir = ::ENV["KOKORO_GFILE_DIR"]
    return unless gfile_dir

    filename = "#{gfile_dir}/ruby_env_vars.json"
    raise "#{filename} is not a file" unless ::File.file? filename
    env_vars = ::JSON.parse ::File.read filename
    env_vars.each { |k, v| ::ENV[k] ||= v }

    filename = "#{gfile_dir}/secret_manager/ruby-main-ci-service-account"
    if ::File.file? filename
      ::ENV["GOOGLE_APPLICATION_CREDENTIALS"] = filename
      ::ENV["GCLOUD_TEST_KEYFILE_JSON"] = File.read filename
    end

    filename = "#{gfile_dir}/secret_manager/ruby-firestore-ci-service-account"
    if ::File.file? filename
      ::ENV["FIRESTORE_TEST_KEYFILE_JSON"] = File.read filename
    end
  end
end
