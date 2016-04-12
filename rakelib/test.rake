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
    Dir.glob("test/gcloud/datastore/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs storage tests."
  task :storage do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/gcloud/storage/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs pubsub tests."
  task :pubsub do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/gcloud/pubsub/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs bigquery tests."
  task :bigquery do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/gcloud/bigquery/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs dns tests."
  task :dns do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/gcloud/dns/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs resource_manager tests."
  task :resource_manager do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/gcloud/resource_manager/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs search tests."
  task :search do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/gcloud/search/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs logging tests."
  task :logging do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/gcloud/logging/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs translate tests."
  task :translate do
    $LOAD_PATH.unshift "lib", "test"
    Dir.glob("test/gcloud/translate/**/*_test.rb").each { |file| require_relative "../#{file}"}
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
    ENV["SEARCH_PROJECT"] = project
    ENV["SEARCH_KEYFILE"] = keyfile
    ENV["LOGGING_PROJECT"] = project
    ENV["LOGGING_KEYFILE"] = keyfile

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
    ENV["SEARCH_PROJECT"] = project
    ENV["SEARCH_KEYFILE"] = keyfile
    ENV["LOGGING_PROJECT"] = project
    ENV["LOGGING_KEYFILE"] = keyfile

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
    ENV["SEARCH_PROJECT"] = project
    ENV["SEARCH_KEYFILE"] = keyfile
    ENV["LOGGING_PROJECT"] = project
    ENV["LOGGING_KEYFILE"] = keyfile

    $LOAD_PATH.unshift "lib", "test", "acceptance"
    Dir.glob("acceptance/**/*_test.rb").each { |file| require_relative "../#{file}"}
  end

  namespace :acceptance do

    desc "Runs the datastore acceptance tests."
    task :datastore, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["DATASTORE_TEST_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["DATASTORE_TEST_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:acceptance:datastore[test123, /path/to/keyfile.json] or DATASTORE_TEST_PROJECT=test123 DATASTORE_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:datastore"
      end
      # always overwrite when running tests
      ENV["DATASTORE_PROJECT"] = project
      ENV["DATASTORE_KEYFILE"] = keyfile

      $LOAD_PATH.unshift "lib", "test", "acceptance"
      Dir.glob("acceptance/datastore/**/*_test.rb").each { |file| require_relative "../#{file}"}
    end

    desc "Runs the storage acceptance tests."
    task :storage, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["STORAGE_TEST_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["STORAGE_TEST_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:acceptance:storage[test123, /path/to/keyfile.json] or STORAGE_TEST_PROJECT=test123 STORAGE_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:storage"
      end
      # always overwrite when running tests
      ENV["STORAGE_PROJECT"] = project
      ENV["STORAGE_KEYFILE"] = keyfile

      $LOAD_PATH.unshift "lib", "test", "acceptance"
      Dir.glob("acceptance/storage/**/*_test.rb").each { |file| require_relative "../#{file}"}
    end

    namespace :storage do
      desc "Removes *ALL* buckets and files. Use with caution."
      task :cleanup do |t, args|
        project = args[:project]
        project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["STORAGE_TEST_PROJECT"]
        keyfile = args[:keyfile]
        keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["STORAGE_TEST_KEYFILE"]
        if project.nil? || keyfile.nil?
          fail "You must provide a project and keyfile. e.g. rake test:acceptance:storage:cleanup[test123, /path/to/keyfile.json] or STORAGE_TEST_PROJECT=test123 STORAGE_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:storage:cleanup"
        end
        # always overwrite when running tests
        ENV["STORAGE_PROJECT"] = project
        ENV["STORAGE_KEYFILE"] = keyfile

        $LOAD_PATH.unshift "lib"
        require "gcloud/storage"
        puts "Cleaning up Storage buckets and files"
        Gcloud.storage.buckets.each { |b| b.files.map(&:delete); b.delete }
      end
    end

    desc "Runs the pubsub acceptance tests."
    task :pubsub, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["PUBSUB_TEST_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["PUBSUB_TEST_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:acceptance:pubsub[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:pubsub"
      end
      # always overwrite when running tests
      ENV["PUBSUB_PROJECT"] = project
      ENV["PUBSUB_KEYFILE"] = keyfile

      $LOAD_PATH.unshift "lib", "test", "acceptance"
      Dir.glob("acceptance/pubsub/**/*_test.rb").each { |file| require_relative "../#{file}"}
    end

    namespace :pubsub do
      desc "Removes *ALL* topics and subscriptions. Use with caution."
      task :cleanup do |t, args|
        project = args[:project]
        project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["PUBSUB_TEST_PROJECT"]
        keyfile = args[:keyfile]
        keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["PUBSUB_TEST_PROJECT"]
        if project.nil? || keyfile.nil?
          fail "You must provide a project and keyfile. e.g. rake test:acceptance:pubsub:cleanup[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:pubsub:cleanup"
        end
        # always overwrite when running tests
        ENV["PUBSUB_PROJECT"] = project
        ENV["PUBSUB_KEYFILE"] = keyfile

        $LOAD_PATH.unshift "lib"
        require "gcloud/pubsub"
        puts "Cleaning up Pub/Sub topics and subscriptions"
        Gcloud.pubsub.topics.map &:delete
        Gcloud.pubsub.subscriptions.map &:delete
      end
    end

    desc "Runs the bigquery acceptance tests."
    task :bigquery, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["BIGQUERY_TEST_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["BIGQUERY_TEST_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:acceptance:bigquery[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:bigquery"
      end
      # always overwrite when running tests
      ENV["BIGQUERY_PROJECT"] = project
      ENV["BIGQUERY_KEYFILE"] = keyfile

      $LOAD_PATH.unshift "lib", "test", "acceptance"
      Dir.glob("acceptance/bigquery/**/*_test.rb").each { |file| require_relative "../#{file}"}
    end

    namespace :bigquery do
      desc "Removes *ALL* BigQuery datasets and tables. Use with caution."
      task :cleanup do |t, args|
        project = args[:project]
        project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["BIGQUERY_TEST_PROJECT"]
        keyfile = args[:keyfile]
        keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["BIGQUERY_TEST_KEYFILE"]
        if project.nil? || keyfile.nil?
          fail "You must provide a project and keyfile. e.g. rake test:acceptance:bigquery:cleanup[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:bigquery:cleanup"
        end
        # always overwrite when running tests
        ENV["BIGQUERY_PROJECT"] = project
        ENV["BIGQUERY_KEYFILE"] = keyfile

        $LOAD_PATH.unshift "lib"
        require "gcloud/bigquery"
        puts "Cleaning up BigQuery datasets and tables"
        Gcloud.bigquery.datasets.each do |ds|
          begin
            ds.tables.map &:delete
            ds.delete
          rescue Gcloud::Bigquery::ApiError => e
            puts e.message
          end
        end
      end
    end

    desc "Runs the dns acceptance tests."
    task :dns, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["DNS_TEST_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["DNS_TEST_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:acceptance:dns[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:dns"
      end
      # always overwrite when running tests
      ENV["DNS_PROJECT"] = project
      ENV["DNS_KEYFILE"] = keyfile

      $LOAD_PATH.unshift "lib", "test", "acceptance"
      Dir.glob("acceptance/dns/**/*_test.rb").each { |file| require_relative "../#{file}"}
    end

    namespace :dns do
      desc "Removes *ALL* DNS zones and records. Use with caution."
      task :cleanup do |t, args|
        project = args[:project]
        project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["DNS_TEST_PROJECT"]
        keyfile = args[:keyfile]
        keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["DNS_TEST_KEYFILE"]
        if project.nil? || keyfile.nil?
          fail "You must provide a project and keyfile. e.g. rake test:acceptance:dns:cleanup[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:dns:cleanup"
        end
        # always overwrite when running tests
        ENV["DNS_PROJECT"] = project
        ENV["DNS_KEYFILE"] = keyfile

        $LOAD_PATH.unshift "lib"
        require "gcloud/dns"
        puts "Cleaning up DNS zones and records"
        Gcloud.dns.zones.each do |zone|
          begin
            zone.delete force: true
          rescue Gcloud::Dns::ApiError => e
            puts e.message
          end
        end
      end
    end

    desc "Runs the search acceptance tests."
    task :search, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["SEARCH_TEST_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["SEARCH_TEST_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:acceptance:search[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:search"
      end
      # always overwrite when running tests
      ENV["SEARCH_PROJECT"] = project
      ENV["SEARCH_KEYFILE"] = keyfile

      $LOAD_PATH.unshift "lib", "test", "acceptance"
      Dir.glob("acceptance/search/**/*_test.rb").each { |file| require_relative "../#{file}"}
    end

    namespace :search do
      desc "Removes *ALL* SEARCH zones and records. Use with caution."
      task :cleanup do |t, args|
        project = args[:project]
        project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["SEARCH_TEST_PROJECT"]
        keyfile = args[:keyfile]
        keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["SEARCH_TEST_KEYFILE"]
        if project.nil? || keyfile.nil?
          fail "You must provide a project and keyfile. e.g. rake test:acceptance:search:cleanup[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:search:cleanup"
        end
        # always overwrite when running tests
        ENV["SEARCH_PROJECT"] = project
        ENV["SEARCH_KEYFILE"] = keyfile

        $LOAD_PATH.unshift "lib"
        require "gcloud/search"
        puts "Cleaning up SEARCH indexes and documents"
        Gcloud.search.indexes.each do |index|
          begin
            index.delete force: true
          rescue Gcloud::Search::ApiError => e
            puts e.message
          end
        end
      end
    end

    desc "Runs the logging acceptance tests."
    task :logging, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["LOGGING_TEST_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["LOGGING_TEST_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:acceptance:logging[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:logging"
      end
      # always overwrite when running tests
      ENV["LOGGING_PROJECT"] = project
      ENV["LOGGING_KEYFILE"] = keyfile

      $LOAD_PATH.unshift "lib", "test", "acceptance"
      Dir.glob("acceptance/logging/**/*_test.rb").each { |file| require_relative "../#{file}"}
    end

    namespace :logging do
      desc "Removes *ALL* LOGGING sinks and metrics. Use with caution."
      task :cleanup do |t, args|
        project = args[:project]
        project ||= ENV["GCLOUD_TEST_PROJECT"] || ENV["LOGGING_TEST_PROJECT"]
        keyfile = args[:keyfile]
        keyfile ||= ENV["GCLOUD_TEST_KEYFILE"] || ENV["LOGGING_TEST_KEYFILE"]
        if project.nil? || keyfile.nil?
          fail "You must provide a project and keyfile. e.g. rake test:acceptance:logging:cleanup[test123, /path/to/keyfile.json] or PUBSUB_TEST_PROJECT=test123 PUBSUB_TEST_KEYFILE=/path/to/keyfile.json rake test:acceptance:logging:cleanup"
        end
        # always overwrite when running tests
        ENV["LOGGING_PROJECT"] = project
        ENV["LOGGING_KEYFILE"] = keyfile

        $LOAD_PATH.unshift "lib"
        require "gcloud/logging"
        puts "Cleaning up LOGGING sinks and metrics"
        begin
          # Gcloud.logging.sinks.each.map &:delete
          Gcloud.logging.metrics.each.map &:delete
        rescue Gcloud::Error => e
          puts e.message
        end
      end
    end

    desc "Runs the translate acceptance tests."
    task :translate do |t, args|
      $LOAD_PATH.unshift "lib", "test", "acceptance"
      Dir.glob("acceptance/translate/**/*_test.rb").each { |file| require_relative "../#{file}"}
    end

    desc "Removes *ALL* acceptance test data. Use with caution."
    task :cleanup do
      Rake::Task["test:acceptance:bigquery:cleanup"].invoke
      Rake::Task["test:acceptance:dns:cleanup"].invoke
      Rake::Task["test:acceptance:logging:cleanup"].invoke
      Rake::Task["test:acceptance:pubsub:cleanup"].invoke
      # Rake::Task["test:acceptance:search:cleanup"].invoke
      Rake::Task["test:acceptance:storage:cleanup"].invoke
    end
  end

end
