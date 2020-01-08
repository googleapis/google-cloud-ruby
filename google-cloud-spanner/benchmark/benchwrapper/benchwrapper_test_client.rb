#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

this_dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(this_dir) unless $LOAD_PATH.include?(this_dir)

require 'optparse'
require "spanner_services_pb"

include SpannerBench

def main
  port = nil
  OptionParser.new do |opts|
    opts.banner = "Usage: benchwrapper.rb [options]"
    opts.on('-p', '--port PORT', "Specify the port") do |v| 
      port = v
    end
  end.parse!
  
  if port.nil? || port.to_i.to_s != port
    fail "Please specify a valid port, e.g., -p 5000 or --port 5000."
  end

  puts "connecting to localhost:#{port}"

  stub = SpannerBench::SpannerBenchWrapper::Stub.new("localhost:#{port}", :this_channel_is_insecure)

  stub.read(ReadQuery.new(Query: "SELECT 1 AS COL1 UNION ALL SELECT 2 AS COL1"))

  stub.insert(InsertQuery.new(users: [
    User.new(name: "foo", age: 50),
    User.new(name: "bar", age: 40),
  ]))

  resp = stub.update(UpdateQuery.new(Queries: [
    "UPDATE sometable SET foo=1 WHERE bar=2",
    "UPDATE sometable SET foo=2 WHERE bar=1",
  ]))
end

main