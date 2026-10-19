# frozen_string_literal: true

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

expand :clean, paths: :gitignore

if ENV["RUBY_COMMON_TOOLS"]
  common_tools_dir = File.expand_path ENV["RUBY_COMMON_TOOLS"]
  load File.join(common_tools_dir, "toys", "yoshi")
else
  load_git remote: "https://github.com/googleapis/ruby-common-tools.git",
           path: "toys/yoshi",
           update: true
end

# Work around two Bundler 4.0 + toys-core 0.22.0 issues during `toys test`:
# 1. `load_git` (`Toys::Utils::GitCache`) requires `json` before any bundle is
#    set up, activating the newest `json` in GEM_HOME (e.g. 3.1.0), which
#    `modified_gemfile_content` then injects into the temporary Gemfile over the
#    gem's locked `json` version.
# 2. `delete_modified_gemfile` deletes the temporary lockfile in `setup_bundle`'s
#    `ensure` block before the tool spawns its child ruby process, while Bundler
#    4.0+ leaves `ENV["BUNDLE_LOCKFILE"]` pointing at that deleted lockfile.
require "toys/utils/gems"
unless Toys::Utils::Gems.private_method_defined? :configure_lockfile
  Toys::Utils::Gems.prepend(
    Module.new do
      private

      def create_modified_gemfile gemfile_path
        ::Gem.loaded_specs.delete "json"
        super
      end

      def delete_modified_gemfile modified_gemfile_path
        ::FileUtils.rm_f modified_gemfile_path
        modified_lockfile_path = find_lockfile_path modified_gemfile_path
        ::Toys::Utils::Gems.delete_at_exit modified_lockfile_path
      end
    end
  )
end
