# Copyright 2014 Google Inc. All rights reserved.
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

namespace :pages do
  desc "Updates the documentation on the gh-pages branch"
  task :master do
    branch = `git symbolic-ref --short HEAD`.chomp
    if "master" != branch
      puts "You are on the #{branch} branch. You must be on the master branch to run this rake task."
      exit
    end

    unless `git status --porcelain`.chomp.empty?
      puts "The master branch is not clean. Unable to update gh-pages."
      exit
    end

    commit_hash = `git rev-parse --short HEAD`.chomp

    puts `git checkout gh-pages`
    puts `git rm -rf docs/master`
    puts `git commit -am "Update documentation for #{commit_hash}"`
    puts `git checkout #{branch}`
    puts `rake docs`
    puts `mkdir docs`
    puts `mv doc docs/master`
    puts `git add docs/master`
    puts `git checkout gh-pages`
    puts `git add docs/master`
    puts `git commit --amend --no-edit`
    puts `git checkout #{branch}`
  end
end
