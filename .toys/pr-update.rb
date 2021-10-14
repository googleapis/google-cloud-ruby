# frozen_string_literal: true

# Copyright 2021 Google LLC
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

desc "Merges primary branch into the given pull request"

required_arg :pr_number
flag :remote, "--remote=NAME", default: "origin"
flag :no_push
flag :rebase

static :repo_name, "googleapis/google-cloud-ruby"

include :exec, e: true

def run
  require "json"
  check_preconditions
  save_state
  setup_branch base_branch
  setup_branch head_branch
  rebase ? rebase_branches : merge_branches
  push_branch
  cleanup
end

def check_preconditions
  unless pr["head"]["repo"]["full_name"] == repo_name
    error "Pull request #{pr_number} is from a separate repo"
  end
  unless capture(["git", "status", "-s"]).strip.empty?
    error "Git status is not clean"
  end
end

def save_state
  @current_branch = capture(["git", "branch", "--show-current"]).strip
  @current_branch = nil if @current_branch.empty?
end

def cleanup
  exec ["git", "switch", @current_branch || base_branch]
  exec ["git", "branch", "-D", head_branch]
end

def setup_branch branch
  shallow = capture(["git", "rev-parse", "--is-shallow-repository"]).strip == "true"
  fetch_options = shallow ? ["--unshallow"] : []
  exec(["git", "fetch"] + fetch_options + [remote, branch])
  exec ["git", "switch", branch]
  exec ["git", "pull", remote, branch]
end

def merge_branches
  exec ["git", "switch", head_branch]
  result = exec ["git", "merge", "-m", "Merge the latest #{base_branch} branch", base_branch], e: false
  unless result.success?
    exec ["git", "merge", "--abort"]
    error "Merge failed"
  end
end

def rebase_branches
  exec ["git", "switch", head_branch]
  result = exec ["git", "rebase", base_branch], e: false
  unless result.success?
    exec ["git", "rebase", "--abort"]
    error "Rebase failed"
  end
end

def push_branch
  return if no_push
  exec ["git", "switch", head_branch]
  push_options = rebase ? ["-f"] : []
  exec(["git", "push"] + push_options + [remote, head_branch])
end

def base_branch
  @base_branch ||= pr["base"]["ref"]
end

def head_branch
  @head_branch ||= pr["head"]["ref"]
end

def pr
  @pr ||= begin
    cmd = [
      "gh", "api", "repos/#{repo_name}/pulls/#{pr_number}",
      "-H", "Accept: application/vnd.github.v3+json"
    ]
    result = exec cmd, out: :capture, e: false
    error "No such pull request #{pr_number}" unless result.success?
    ::JSON.parse result.captured_out
  end
end

def error msg
  logger.error msg
  exit 1
end
