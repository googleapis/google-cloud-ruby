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

gem "rdoc"
require "rdoc/task"
require "fileutils"
require "pathname"

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

    tmp   = Pathname.new(Dir.home) + "tmp"
    docs  = tmp + "docs"
    pages = tmp + "pages"
    FileUtils.remove_dir docs if Dir.exists? docs
    FileUtils.remove_dir pages if Dir.exists? pages
    FileUtils.mkdir_p docs
    FileUtils.mkdir_p pages

    Rake::Task["pages:rdoc"].invoke

    puts `cp -R html/* #{docs}`
    # checkout the gh-pages branch
    puts `git clone --quiet --branch=gh-pages git@github.com:GoogleCloudPlatform/gcloud-ruby.git #{pages} > /dev/null`
    # Change to gh-pages
    Dir.chdir pages do
      # sync the docs
      puts `rsync -r #{docs}/ docs/master/`
      # commit changes
      puts `git add .`
      if ENV["GH_OAUTH_TOKEN"]
        push_url = "https://#{ENV["GH_OAUTH_TOKEN"]}@github.com/#{ENV["GH_OWNER"]}/#{ENV["GH_PROJECT_NAME"]}"
        puts `git config --global user.email "travis@travis-ci.org"`
        puts `git config --global user.name "travis-ci"`
        puts `git commit -m "Update documentation for #{commit_hash}"`
        puts `git push #{push_url} gh-pages:gh-pages`
      else
        puts `git commit -m "Update documentation for #{commit_hash}"`
        puts `git push origin gh-pages`
      end
    end
  end

  desc "Installs the latest gcloud-rdoc gem"
  task :install_gcloud_rdoc do
    tmp = Pathname.new(Dir.home) + "tmp"
    rdocgem = tmp + "gcloud-rdoc"
    FileUtils.remove_dir rdocgem if Dir.exists? rdocgem
    FileUtils.mkdir_p rdocgem

    puts `git clone --quiet --branch=gcloud-rdoc git@github.com:GoogleCloudPlatform/gcloud-ruby.git #{rdocgem}`
    Dir.chdir rdocgem do
      puts `rake gem`
      puts `gem install pkg/gcloud-rdoc-*.gem`
    end
  end

  RDoc::Task.new do |rdoc|
    begin; require "gcloud-rdoc"; rescue LoadError; end
    require_relative "../lib/gcloud/version"

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
