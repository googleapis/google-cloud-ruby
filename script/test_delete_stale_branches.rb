# frozen_string_literal: true

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

require "minitest/autorun"
require_relative "delete-stale-branches"

class StaleBranchCleanerTest < Minitest::Test
  def setup
    @cleaner = StaleBranchCleaner.new(dry_run: true, min_age_days: 30)
  end

  def test_base_branches_are_protected
    branches = @cleaner.send(:instance_variable_get, :@branches_data)
    branches["main"] = { name: "main", status: :unclassified }
    branches["gh-pages"] = { name: "gh-pages", status: :unclassified }

    @cleaner.send(:inspect_branch_metadata)

    assert_equal :protected, branches["main"][:status]
    assert_equal :protected, branches["gh-pages"][:status]
  end

  def test_open_pr_branches_are_strictly_protected
    branches = @cleaner.send(:instance_variable_get, :@branches_data)
    open_prs = @cleaner.send(:instance_variable_get, :@open_prs)

    branches["feat/active-work"] = { name: "feat/active-work", status: :unclassified }
    open_prs["feat/active-work"] = { number: 1234, title: "Active Feature", updatedAt: Time.now.iso8601 }

    @cleaner.send(:inspect_branch_metadata)

    assert_equal :protected, branches["feat/active-work"][:status]
    assert_match(/Active Open PR #1234/, branches["feat/active-work"][:reason])
  end

  def test_recent_commits_within_grace_period_are_protected
    branches = @cleaner.send(:instance_variable_get, :@branches_data)
    recent_date = (Time.now - (5 * 86_400)).iso8601 # 5 days ago

    branches["experiment/fresh"] = {
      name: "experiment/fresh",
      status: :unclassified,
      commit_date: recent_date,
      pr_state: "NO_PR"
    }

    @cleaner.send(:classify_branches)

    assert_equal :protected, branches["experiment/fresh"][:status]
    assert_match(/Active work: commit within last 30 days/, branches["experiment/fresh"][:reason])
  end

  def test_stale_bot_branches_are_categorized_as_bot
    branches = @cleaner.send(:instance_variable_get, :@branches_data)
    old_date = (Time.now - (400 * 86_400)).iso8601 # 400 days ago

    branches["owl-bot-12345"] = {
      name: "owl-bot-12345",
      status: :unclassified,
      commit_date: old_date,
      pr_state: "CLOSED",
      pr_number: 999
    }

    branches["autosynth-pkg"] = {
      name: "autosynth-pkg",
      status: :unclassified,
      commit_date: old_date,
      pr_state: "MERGED",
      pr_number: 888
    }

    @cleaner.send(:classify_branches)

    assert_equal :stale, branches["owl-bot-12345"][:status]
    assert_equal :bot, branches["owl-bot-12345"][:category]

    assert_equal :stale, branches["autosynth-pkg"][:status]
    assert_equal :bot, branches["autosynth-pkg"][:category]
  end

  def test_stale_merged_human_branches_are_categorized_as_merged
    branches = @cleaner.send(:instance_variable_get, :@branches_data)
    old_date = (Time.now - (100 * 86_400)).iso8601

    branches["feature/done"] = {
      name: "feature/done",
      status: :unclassified,
      commit_date: old_date,
      pr_state: "MERGED",
      pr_number: 456
    }

    @cleaner.send(:classify_branches)

    assert_equal :stale, branches["feature/done"][:status]
    assert_equal :merged, branches["feature/done"][:category]
  end

  def test_stale_closed_human_branches_are_categorized_as_closed
    branches = @cleaner.send(:instance_variable_get, :@branches_data)
    old_date = (Time.now - (120 * 86_400)).iso8601

    branches["fix/abandoned"] = {
      name: "fix/abandoned",
      status: :unclassified,
      commit_date: old_date,
      pr_state: "CLOSED",
      pr_number: 789
    }

    @cleaner.send(:classify_branches)

    assert_equal :stale, branches["fix/abandoned"][:status]
    assert_equal :closed, branches["fix/abandoned"][:category]
  end

  def test_stale_no_pr_branches_are_categorized_as_no_pr
    branches = @cleaner.send(:instance_variable_get, :@branches_data)
    old_date = (Time.now - (200 * 86_400)).iso8601

    branches["scratch/test-idea"] = {
      name: "scratch/test-idea",
      status: :unclassified,
      commit_date: old_date,
      pr_state: "NO_PR"
    }

    @cleaner.send(:classify_branches)

    assert_equal :stale, branches["scratch/test-idea"][:status]
    assert_equal :no_pr, branches["scratch/test-idea"][:category]
  end
end
