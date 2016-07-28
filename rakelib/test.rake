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

  desc "Runs resource_manager tests."
  task :resource_manager do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/google/cloud/resource_manager/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs translate tests."
  task :translate do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/google/cloud/translate/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

    desc "Runs vision tests."
    task :vision do
      $LOAD_PATH.unshift "lib", "test"
      Dir.glob("test/google/cloud/vision/**/*_test.rb").each { |file| require_relative "../#{file}"}
    end

  desc "Runs tests with coverage."
  task :coverage, :project, :keyfile do |t, args|
    project = args[:project]
    project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["DATASTORE_TEST_PROJECT"]
    keyfile = args[:keyfile]
    keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["DATASTORE_TEST_KEYFILE"]
    if project.nil? || keyfile.nil?
      fail "You must provide a project and keyfile. e.g. rake test:coverage[test123, /path/to/keyfile.json] or GCLOUD_TEST_PROJECT=test123 GCLOUD_TEST_KEYFILE=/path/to/keyfile.json rake test:coverage"
    end
    # always overwrite when running tests
    ENV["DATASTORE_PROJECT"] = project
    ENV["DATASTORE_KEYFILE"] = keyfile
    ENV["STORAGE_PROJECT"] = project
    ENV["STORAGE_KEYFILE"] = keyfile
    ENV["PUBSUB_PROJECT"] = project
    ENV["PUBSUB_KEYFILE"] = keyfile
    ENV["BIGQUERY_PROJECT"] = project
    ENV["BIGQUERY_KEYFILE"] = keyfile
    ENV["DNS_PROJECT"] = project
    ENV["DNS_KEYFILE"] = keyfile
    ENV["LOGGING_PROJECT"] = project
    ENV["LOGGING_KEYFILE"] = keyfile
    ENV["VISION_PROJECT"] = project
    ENV["VISION_KEYFILE"] = keyfile

    require "simplecov"
    SimpleCov.start("test_frameworks") { command_name "Minitest" }

    # Rake::Task["test"].execute
    $LOAD_PATH.unshift "lib", "test", "acceptance"
    Dir.glob("{test,acceptance}/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs tests with coveralls."
  task :coveralls, :project, :keyfile do |t, args|
    project = args[:project]
    project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["DATASTORE_TEST_PROJECT"]
    keyfile = args[:keyfile]
    keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["DATASTORE_TEST_KEYFILE"]
    if project.nil? || keyfile.nil?
      fail "You must provide a project and keyfile. e.g. rake test:coveralls[test123, /path/to/keyfile.json] or GCLOUD_TEST_PROJECT=test123 GCLOUD_TEST_KEYFILE=/path/to/keyfile.json rake test:coveralls"
    end
    # always overwrite when running tests
    ENV["DATASTORE_PROJECT"] = project
    ENV["DATASTORE_KEYFILE"] = keyfile
    ENV["STORAGE_PROJECT"] = project
    ENV["STORAGE_KEYFILE"] = keyfile
    ENV["PUBSUB_PROJECT"] = project
    ENV["PUBSUB_KEYFILE"] = keyfile
    ENV["BIGQUERY_PROJECT"] = project
    ENV["BIGQUERY_KEYFILE"] = keyfile
    ENV["DNS_PROJECT"] = project
    ENV["DNS_KEYFILE"] = keyfile
    ENV["LOGGING_PROJECT"] = project
    ENV["LOGGING_KEYFILE"] = keyfile
    ENV["VISION_PROJECT"] = project
    ENV["VISION_KEYFILE"] = keyfile

    require "simplecov"
    require "coveralls"
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
    SimpleCov.start("test_frameworks") { command_name "Minitest" }

    $LOAD_PATH.unshift "lib", "test", "acceptance"
    Dir.glob("{test,acceptance}/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs the acceptance tests."
  task :acceptance, :project, :keyfile do |t, args|
    project = args[:project]
    project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["DATASTORE_TEST_PROJECT"]
    keyfile = args[:keyfile]
    keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["DATASTORE_TEST_KEYFILE"]
    if project.nil? || keyfile.nil?
      fail "You must provide a project and keyfile. e.g. rake test:acceptance[test123, /path/to/keyfile.json] or GCLOUD_TEST_PROJECT=test123 GCLOUD_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance"
    end
    # always overwrite when running tests
    ENV["DATASTORE_PROJECT"] = project
    ENV["DATASTORE_KEYFILE"] = keyfile
    ENV["STORAGE_PROJECT"] = project
    ENV["STORAGE_KEYFILE"] = keyfile
    ENV["PUBSUB_PROJECT"] = project
    ENV["PUBSUB_KEYFILE"] = keyfile
    ENV["BIGQUERY_PROJECT"] = project
    ENV["BIGQUERY_KEYFILE"] = keyfile
    ENV["DNS_PROJECT"] = project
    ENV["DNS_KEYFILE"] = keyfile
    ENV["LOGGING_PROJECT"] = project
    ENV["LOGGING_KEYFILE"] = keyfile
    ENV["VISION_PROJECT"] = project
    ENV["VISION_KEYFILE"] = keyfile

    $LOAD_PATH.unshift "lib", "test", "acceptance"
    Dir.glob("acceptance/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  namespace :acceptance do

    desc "Runs acceptance tests with coverage."
    task :coverage, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["DATASTORE_TEST_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["DATASTORE_TEST_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:coverage[test123, /path/to/keyfile.json] or GCLOUD_TEST_PROJECT=test123 GCLOUD_TEST_KEYFILE=/path/to/keyfile.json rake test:coverage"
      end
      # always overwrite when running tests
      ENV["DATASTORE_PROJECT"] = project
      ENV["DATASTORE_KEYFILE"] = keyfile
      ENV["STORAGE_PROJECT"] = project
      ENV["STORAGE_KEYFILE"] = keyfile
      ENV["PUBSUB_PROJECT"] = project
      ENV["PUBSUB_KEYFILE"] = keyfile
      ENV["BIGQUERY_PROJECT"] = project
      ENV["BIGQUERY_KEYFILE"] = keyfile
      ENV["DNS_PROJECT"] = project
      ENV["DNS_KEYFILE"] = keyfile
      ENV["LOGGING_PROJECT"] = project
      ENV["LOGGING_KEYFILE"] = keyfile
      ENV["VISION_PROJECT"] = project
      ENV["VISION_KEYFILE"] = keyfile

      require "simplecov"
      SimpleCov.start("test_frameworks") { command_name "Minitest" }

      # Rake::Task["test"].execute
      $LOAD_PATH.unshift "lib", "test", "acceptance"
      Dir.glob("acceptance/**/*_test.rb").each { |file| require_relative "../#{file}"}
    end

    desc "Runs the translate acceptance tests."
    task :translate do |t, args|
      $LOAD_PATH.unshift "lib", "test", "acceptance"
      Dir.glob("acceptance/translate/**/*_test.rb").each { |file| require_relative "../#{file}"}
    end

    desc "Runs the vision acceptance tests."
    task :vision, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["VISION_TEST_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["VISION_TEST_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:acceptance:vision[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:vision"
      end
      # always overwrite when running tests
      ENV["VISION_PROJECT"] = project
      ENV["VISION_KEYFILE"] = keyfile

      $LOAD_PATH.unshift "lib", "test", "acceptance"
      Dir.glob("acceptance/vision/**/*_test.rb").each { |file| require_relative "../#{file}"}
    end

    desc "Removes *ALL* acceptance test data. Use with caution."
    task :cleanup do
      Rake::Task["test:acceptance:bigquery:cleanup"].invoke
      Rake::Task["test:acceptance:dns:cleanup"].invoke
      Rake::Task["test:acceptance:logging:cleanup"].invoke
      Rake::Task["test:acceptance:pubsub:cleanup"].invoke
      Rake::Task["test:acceptance:storage:cleanup"].invoke
    end
  end

end
