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

require "minitest/autorun"
require "minitest/focus"
require "google/cloud/datastore"
require "securerandom"

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

def find_or_save_task task_key
  t = datastore.find task_key
  if t.nil?
    t = task_entity task_key
    datastore.save t
    wait_until do
      t = datastore.find task_key
    end
  end
  t
end

# Keep trying a block of code until the code of block yield a true statement or
# raise error after timeout
def wait_until timeout: 30
  t_begin = Time.now
  delay = 1
  loop do
    if yield
      break
    elsif (Time.now - t_begin) > timeout
      fail "Timeout after trying for #{timeout} seconds"
    else
      puts "sleep for #{delay}"
      sleep delay
    end
    delay += 1
  end
end
