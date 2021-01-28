# Copyright 2020 Google LLC
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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/hooks/default"
require "google/cloud/datastore"
require "securerandom"

module Acceptance
  ##
  # This class can be used with the spec DSL.
  # To do so, add :datastore to describe:
  #
  #   describe "My Datastore Test", :datastore do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class DatastoreTest < Minitest::Test
    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :datastore is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :datastore
    end

    def self.run_one_method klass, method_name, reporter
      result = nil
      reporter.prerecord klass, method_name
      (1..3).each do |try|
        result = Minitest.run_one_method(klass, method_name)
        break if (result.passed? || result.skipped?)
        puts "Retrying #{klass}##{method_name} (#{try})"
      end
      reporter.record result
    end
  end
end

def time_plus_random
  "#{Time.now.to_i}_#{SecureRandom.hex 4}"
end

def task_entity key
  datastore.entity key do |t|
    t["category"] = "Personal"
    t["created"] = Time.utc 1999, 12, rand(1..31)
    t["done"] = false
    t["priority"] = 4
    t["percent_complete"] = 10.0
    t["description"] = "A task description."
    t["tag"] = ["fun", "programming"]
  end
end

def find_or_save_task_list task_list_key
  tl = datastore.find task_list_key
  if tl.nil?
    wait_until description: "find task_list #{task_list_key.name}" do
      tl = datastore.entity task_list_key
      datastore.save tl
      sleep 1
      tl = datastore.find task_list_key
    end
  end
  tl
end

def find_or_save_task task_key
  t = datastore.find task_key
  if t.nil?
    wait_until description: "find task #{task_key.name}" do
      t = task_entity task_key
      datastore.save t
      sleep 1
      t = datastore.find task_key
    end
  end
  t
end

# Keep trying a block of code until the code of block yield a true statement or
# raise error after timeout
def wait_until timeout: 60, description: "execute block"
  t_begin = Time.now
  delay = 1
  loop do
    break if yield
    sleep delay
    raise "Timeout attempting to #{description} after #{timeout}s" if (Time.now - t_begin) > timeout
    delay += 1
  end
end
