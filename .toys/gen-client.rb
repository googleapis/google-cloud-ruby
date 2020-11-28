# frozen_string_literal: true

# Copyright 2020 Google LLC
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

required_arg :gem_name
flag :editor, default: ENV["EDITOR"]
flag :branch_name, "--branch=NAME"
flag :git_remote, "--remote=NAME"

include :exec, e: true
include :fileutils
include :terminal

def run
  require "new_client_generator"
  generator = NewClientGenerator.new context: self,
                                     gem_name: gem_name,
                                     editor: editor,
                                     branch_name: branch_name,
                                     git_remote: git_remote
  generator.generate
end
