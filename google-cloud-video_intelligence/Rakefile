# Copyright 2017, Google Inc. All rights reserved.
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

require "bundler/setup"
require "bundler/gem_tasks"

require "rubocop/rake_task"
RuboCop::RakeTask.new

desc "Run tests."
task :test do
  $LOAD_PATH.unshift "lib", "test"
  Dir.glob("test/**/*test.rb")
    .reject { |file| file.include? "smoke_test" }
    .each { |file| require_relative file }
end

namespace :test do
  desc "Runs tests with coverage."
  task :coverage do
    require "simplecov"
    SimpleCov.start do
      command_name "google-cloud-video_intelligence"
      track_files "lib/**/*.rb"
      add_filter "test/"
    end

    Rake::Task["test"].invoke
  end
end

desc "Run the CI build"
task :ci do
  header "BUILDING google-cloud-video_intelligence"
  header "google-cloud-video_intelligence rubocop", "*"
  sh "bundle exec rake rubocop"
  header "google-cloud-video_intelligence test", "*"
  sh "bundle exec rake test"
end

namespace :ci do
  desc "Run the CI build, with smoke_tests."
  task :smoke_test do
    Rake::Task["ci"].invoke
    header "google-cloud-video_intelligence smoke_test", "*"
    sh "bundle exec rake smoke_test -v"
  end
  task :a do
    # This is a handy shortcut to save typing
    Rake::Task["ci:smoke_test"].invoke
  end
end

task :default => :test

def header str, token = "#"
  line_length = str.length + 8
  puts ""
  puts token * line_length
  puts "#{token * 3} #{str} #{token * 3}"
  puts token * line_length
  puts ""
end