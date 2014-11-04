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

  desc "Runs the regression tests against a hosted datastore."
  task :regression, :project, :keyfile do |t, args|
    project = args[:project]
    project ||= ENV["DATASTORE_PROJECT"]
    keyfile = args[:keyfile]
    keyfile ||= ENV["DATASTORE_KEYFILE"]
    if project.nil? || keyfile.nil?
      fail "You must provide a project and keyfile. e.g. rake test:regression[test123, /path/to/keyfile.json] or DATASTORE_PROJECT=test123 DATASTORE_KEYFILE=/path/to/keyfile.json rake test:regression"
    end
    ENV["DATASTORE_PROJECT"] = project # always overwrite from command line
    ENV["DATASTORE_KEYFILE"] = keyfile # always overwrite from command line

    $LOAD_PATH.unshift "lib", "test", "regression"
    Dir.glob("regression/**/test*.rb").each { |file| require_relative "../#{file}"}
  end

  desc "Runs the regression tests against a locally runnning devserver."
  task :devserver, :project do |t, args|
    project = args[:project]
    project ||= ENV["DEVSERVER_PROJECT"]
    if project.nil?
      fail "You must provide a project. e.g. rake test:devserver[test123] or DEVSERVER_PROJECT=test123 rake test:devserver"
    end
    ENV["DEVSERVER_PROJECT"] = project # always overwrite from command line

    $LOAD_PATH.unshift "lib", "test", "regression"
    Dir.glob("regression/**/test*.rb").each { |file| require_relative "../#{file}"}
  end

end
