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

  desc "Runs the regression tests."
  task :regression, :project, :keyfile do |t, args|
    project = args[:project]
    project ||= ENV["GCLOUD_PROJECT"] || ENV["DATASTORE_PROJECT"]
    keyfile = args[:keyfile]
    keyfile ||= ENV["GCLOUD_KEYFILE"] || ENV["DATASTORE_KEYFILE"]
    if project.nil? || keyfile.nil?
      fail "You must provide a project and keyfile. e.g. rake test:regression[test123, /path/to/keyfile.json] or GCLOUD_PROJECT=test123 GCLOUD_KEYFILE=/path/to/keyfile.json rake test:regression"
    end
    ENV["DEVSERVER_PROJECT"] = nil # clear in case it is also set
    ENV["DATASTORE_PROJECT"] = project # always overwrite from command line
    ENV["DATASTORE_KEYFILE"] = keyfile # always overwrite from command line
    ENV["STORAGE_PROJECT"] = project # always overwrite from command line
    ENV["STORAGE_KEYFILE"] = keyfile # always overwrite from command line

    $LOAD_PATH.unshift "lib", "test", "regression"
    Dir.glob("regression/**/test*.rb").each { |file| require_relative "../#{file}"}
  end

  namespace :regression do

    desc "Runs the datastore regression tests."
    task :datastore, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_PROJECT"] || ENV["DATASTORE_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_KEYFILE"] || ENV["DATASTORE_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:regression:datastore[test123, /path/to/keyfile.json] or DATASTORE_PROJECT=test123 DATASTORE_KEYFILE=/path/to/keyfile.json rake test:regression:datastore"
      end
      ENV["DEVSERVER_PROJECT"] = nil # clear in case it is also set
      ENV["DATASTORE_PROJECT"] = project # always overwrite from command line
      ENV["DATASTORE_KEYFILE"] = keyfile # always overwrite from command line

      $LOAD_PATH.unshift "lib", "test", "regression"
      Dir.glob("regression/datastore/**/test*.rb").each { |file| require_relative "../#{file}"}
    end

    desc "Runs the datastore regression tests against a locally runnning devserver."
    task :devserver, :project, :host do |t, args|
      project = args[:project]
      project ||= ENV["DEVSERVER_PROJECT"]
      host = args[:host]
      host ||= ENV["DEVSERVER_HOST"]
      host ||= "http://localhost:8080"
      if project.nil?
        fail "You must provide a project. e.g. rake test:regression:devserver[test123] or DEVSERVER_PROJECT=test123 rake test:regression:devserver"
      end
      ENV["DEVSERVER_PROJECT"] = project # always overwrite from command line
      ENV["DEVSERVER_HOST"]    = host    # always overwrite from command line

      $LOAD_PATH.unshift "lib", "test", "regression"
      Dir.glob("regression/datastore/**/test*.rb").each { |file| require_relative "../#{file}"}
    end

    desc "Runs the storage regression tests."
    task :storage, :project, :keyfile do |t, args|
      project = args[:project]
      project ||= ENV["GCLOUD_PROJECT"] || ENV["STORAGE_PROJECT"]
      keyfile = args[:keyfile]
      keyfile ||= ENV["GCLOUD_KEYFILE"] || ENV["STORAGE_KEYFILE"]
      if project.nil? || keyfile.nil?
        fail "You must provide a project and keyfile. e.g. rake test:regression:storage[test123, /path/to/keyfile.json] or STORAGE_PROJECT=test123 STORAGE_KEYFILE=/path/to/keyfile.json rake test:regression:storage"
      end
      ENV["STORAGE_PROJECT"] = project # always overwrite from command line
      ENV["STORAGE_KEYFILE"] = keyfile # always overwrite from command line

      $LOAD_PATH.unshift "lib", "test", "regression"
      Dir.glob("regression/storage/**/test*.rb").each { |file| require_relative "../#{file}"}
    end

  end

end
