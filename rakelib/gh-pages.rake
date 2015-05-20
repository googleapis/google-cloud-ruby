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

    puts `rm -rf html/`
    puts `rake pages:rdoc`
    puts `git add html -f`
    puts `git checkout gh-pages`
    puts `git rm -rf docs/master`
    puts `git mv html docs/master`
    puts `git commit -am "Update documentation for #{commit_hash}"`
  end

  desc "Updates the documentation for a tag (REQUIRED)"
  task :tag, :tag_name do |t, args|
    tag_name = args[:tag_name]
    if tag_name.nil?
      fail "You must provide a tag to generate the documentation for. e.g. rake pages:tag[v1.0.0]"
    end

    branch = `git symbolic-ref --short HEAD`.chomp
    if "master" != branch
      puts "You are on the #{branch} branch. You must be on the master branch to run this rake task."
      exit
    end

    puts `git checkout #{tag}`
    # TODO: Ensure the tag exists and we are on the tag.

    puts `rm -rf html/`
    puts `rake pages:rdoc`
    puts `git add html -f`
    puts `git checkout gh-pages`
    puts `git rm -rf docs/#{tag}`
    puts `git mv html docs/#{tag}`
    puts `git commit -am "Update documentation for #{tag}"`
  end

  gem "rdoc"
  require "rdoc/task"
  RDoc::Task.new do |rdoc|
    require_relative "../lib/gcloud/version"
    require_relative "../rdoc/generator/gcloud"

    rdoc.generator = "gcloud"
    rdoc.title = "gcloud #{Gcloud::VERSION} Documentation"
    rdoc.main = "README.md"
    rdoc.rdoc_files.include "README.md",
                            "CONTRIBUTING.md",
                            "CHANGELOG.md",
                            "LICENSE",
                            "lib/"
    rdoc.options = ["--exclude", "Manifest.txt",
                    "--exclude", "lib/gcloud/proto",
                    "--exclude", "lib/rdoc"]
  end
end
