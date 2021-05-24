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

    if ::ENV["KOKORO_GFILE_DIR"]
      service_account = "#{::ENV['KOKORO_GFILE_DIR']}/service-account.json"
      raise "#{service_account} is not a file" unless ::File.file? service_account
      ::ENV["GOOGLE_APPLICATION_CREDENTIALS"] = service_account

      filename = "#{::ENV['KOKORO_GFILE_DIR']}/ruby_env_vars.json"
      raise "#{filename} is not a file" unless ::File.file? filename
      env_vars = ::JSON.parse ::File.read filename
      env_vars.each { |k, v| ::ENV[k] ||= v }
    end

    if ::ENV["KOKORO_KEYSTORE_DIR"]
      ::ENV["DOCS_CREDENTIALS"] ||= "#{::ENV['KOKORO_KEYSTORE_DIR']}/73713_docuploader_service_account"
      ::ENV["GITHUB_TOKEN"] ||= "#{::ENV['KOKORO_KEYSTORE_DIR']}/73713_yoshi-automation-github-key"
    end

    @loaded_env = true
  end
end
