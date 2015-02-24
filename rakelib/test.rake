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

require "rake/testtask"

namespace :test do

  desc "Runs datastore tests."
  task :datastore do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/gcloud/datastore/**/test*.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs storage tests."
  task :storage do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/gcloud/storage/**/test*.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs pubsub tests."
  task :pubsub do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/gcloud/pubsub/**/test*.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs tests with coverage."
  task :coverage, :project, :keyfile do |t, args|
    project = args[:project]
    project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["DATASTORE_TEST_PROJECT"]
    keyfile = args[:keyfile]
    keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["DATASTORE_TEST_KEYFILE"]
    if project.nil? || keyfile.nil?
      fail "You must provide a project and keyfile. e.g. rake test:regression[test123, /path/to/keyfile.json] or GCLOUD_TEST_PROJECT=test123 GCLOUD_TEST_KEYFILE=/path/to/keyfile.json rake test:regression"
    end
    # always overwrite when running tests
    ENV["DATASTORE_PROJECT"] = project
    ENV["DATASTORE_KEYFILE"] = keyfile
    ENV["STORAGE_PROJECT"] = project
    ENV["STORAGE_KEYFILE"] = keyfile
    ENV["PUBSUB_PROJECT"] = project
    ENV["PUBSUB_KEYFILE"] = keyfile

    require "simplecov"
    SimpleCov.start("test_frameworks") { command_name "Minitest" }

    # Rake::Task["test"].execute
    $LOAD_PATH.unshift "lib", "test", "regression"
    Dir.glob("{test,regression}/**/test*.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs tests with coveralls."
  task :coveralls, :project, :keyfile do |t, args|
    project = args[:project]
    project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["DATASTORE_TEST_PROJECT"]
    keyfile = args[:keyfile]
    keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["DATASTORE_TEST_KEYFILE"]
    if project.nil? || keyfile.nil?
      fail "You must provide a project and keyfile. e.g. rake test:regression[test123, /path/to/keyfile.json] or GCLOUD_TEST_PROJECT=test123 GCLOUD_TEST_KEYFILE=/path/to/keyfile.json rake test:regression"
    end
    # always overwrite when running tests
    ENV["DATASTORE_PROJECT"] = project
    ENV["DATASTORE_KEYFILE"] = keyfile
    ENV["STORAGE_PROJECT"] = project
    ENV["STORAGE_KEYFILE"] = keyfile
    ENV["PUBSUB_PROJECT"] = project
    ENV["PUBSUB_KEYFILE"] = keyfile

    require "simplecov"
    require "coveralls"
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
    SimpleCov.start("test_frameworks") { command_name "Minitest" }

    $LOAD_PATH.unshift "lib", "test", "regression"
    Dir.glob("{test,regression}/**/test*.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs the regression tests."
  task :regression, :project, :keyfile do |t, args|
    project = args[:project]
    project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["DATASTORE_TEST_PROJECT"]
    keyfile = args[:keyfile]
    keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["DATASTORE_TEST_KEYFILE"]
    if project.nil? || keyfile.nil?
      fail "You must provide a project and keyfile. e.g. rake test:regression[test123, /path/to/keyfile.json] or GCLOUD_TEST_PROJECT=test123 GCLOUD_TEST_KEYFILE=/path/to/keyfile.json rake test:regression"
    end
    # always overwrite when running tests
    ENV["DATASTORE_PROJECT"] = project
    ENV["DATASTORE_KEYFILE"] = keyfile
    ENV["STORAGE_PROJECT"] = project
    ENV["STORAGE_KEYFILE"] = keyfile
    ENV["PUBSUB_PROJECT"] = project
    ENV["PUBSUB_KEYFILE"] = keyfile

    $LOAD_PATH.unshift "lib", "test", "regression"
    Dir.glob("regression/**/test*.rb").each { |file| require_relative "../#{file}"}
  end

  namespace :regression do

    desc "Runs the datastore regression tests."
    task :datastore, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["DATASTORE_TEST_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["DATASTORE_TEST_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:regression:datastore[test123, /path/to/keyfile.json] or DATASTORE_TEST_PROJECT=test123 DATASTORE_TEST_KEYFILE=/path/to/keyfile.json rake test:regression:datastore"
      end
      # always overwrite when running tests
      ENV["DATASTORE_PROJECT"] = project
      ENV["DATASTORE_KEYFILE"] = keyfile

      $LOAD_PATH.unshift "lib", "test", "regression"
      Dir.glob("regression/datastore/**/test*.rb").each { |file| require_relative "../#{file}"}
    end

    desc "Runs the storage regression tests."
    task :storage, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["STORAGE_TEST_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["STORAGE_TEST_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:regression:storage[test123, /path/to/keyfile.json] or STORAGE_TEST_PROJECT=test123 STORAGE_TEST_KEYFILE=/path/to/keyfile.json rake test:regression:storage"
      end
      # always overwrite when running tests
      ENV["STORAGE_PROJECT"] = project
      ENV["STORAGE_KEYFILE"] = keyfile

      $LOAD_PATH.unshift "lib", "test", "regression"
      Dir.glob("regression/storage/**/test*.rb").each { |file| require_relative "../#{file}"}
    end

    namespace :storage do
      desc "Removes *ALL* buckets and files. Use with caution."
      task :cleanup do |t, args|
        project = args[:project]
        project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["STORAGE_TEST_PROJECT"]
        keyfile = args[:keyfile]
        keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["STORAGE_TEST_KEYFILE"]
        if project.nil? || keyfile.nil?
          fail "You must provide a project and keyfile. e.g. rake test:regression:storage:cleanup[test123, /path/to/keyfile.json] or STORAGE_TEST_PROJECT=test123 STORAGE_TEST_KEYFILE=/path/to/keyfile.json rake test:regression:storage:cleanup"
        end
        # always overwrite when running tests
        ENV["STORAGE_PROJECT"] = project
        ENV["STORAGE_KEYFILE"] = keyfile

        $LOAD_PATH.unshift "lib"
        require "gcloud/storage"
        puts "Cleaning up existing buckets and files"
        Gcloud.storage.buckets.each { |b| b.files.map(&:delete); b.delete }
      end
    end

    desc "Runs the pubsub regression tests."
    task :pubsub, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["PUBSUB_TEST_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["PUBSUB_TEST_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:regression:pubsub[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:regression:storage"
      end
      # always overwrite when running tests
      ENV["PUBSUB_PROJECT"] = project
      ENV["PUBSUB_KEYFILE"] = keyfile

      $LOAD_PATH.unshift "lib", "test", "regression"
      Dir.glob("regression/pubsub/**/test*.rb").each { |file| require_relative "../#{file}"}
    end

    namespace :pubsub do
      desc "Removes *ALL* topics and subscriptions. Use with caution."
      task :cleanup do |t, args|
        project = args[:project]
        project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["STORAGE_TEST_PROJECT"]
        keyfile = args[:keyfile]
        keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["STORAGE_TEST_KEYFILE"]
        if project.nil? || keyfile.nil?
          fail "You must provide a project and keyfile. e.g. rake test:regression:pubsub:cleanup[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:regression:pubsub:cleanup"
        end
        # always overwrite when running tests
        ENV["PUBSUB_PROJECT"] = project
        ENV["PUBSUB_KEYFILE"] = keyfile

        $LOAD_PATH.unshift "lib"
        require "gcloud/pubsub"
        puts "Cleaning up existing topics and subscriptions"
        Gcloud.pubsub.topics.map &:delete
        Gcloud.pubsub.subscriptions.map &:delete
      end
    end

  end

end
