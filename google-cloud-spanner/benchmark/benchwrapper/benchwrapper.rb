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
require 'grpc'
require 'spanner_services_pb'
require "google/cloud/spanner"

include SpannerBench

# ServerImpl provides an implementation of the SpannerBenchWrapper service.
class ServerImpl < SpannerBench::SpannerBenchWrapper::Service
  def initialize()    
    @spanner = Google::Cloud::Spanner.new project: "someproject"
    @client = @spanner.client "someinstance", "somedatabase"
  end

  def read(read_query, _call)
    @client.execute(read_query.query).rows.each do |row|
      # Just iterate over all rows.
    end
    EmptyResponse.new
  end

  def insert(insert_query, _call)
    rows = insert_query.singers.map do |singer| 
      {
        SingerId: singer.id,
        FirstName: singer.first_name,
        LastName: singer.last_name
      }
    end
    
    @client.commit do |c|
      c.insert "Singers", rows 
    end
    EmptyResponse.new
  end

  def update(update_query, _call)
    row_counts = nil
    @client.transaction do |transaction|
      row_counts = transaction.batch_update do |b|
        update_query.queries.each do |query|
          b.batch_update query
        end
      end
    end
    statement_count = row_counts.count
    EmptyResponse.new
  end
end

def main
  port = nil
  OptionParser.new do |opts|
    opts.banner = "Usage: benchwrapper.rb [options]"
    opts.on('-p', '--port PORT', "Specify the port") do |v| 
      port = v
    end
  end.parse!

  if ENV["SPANNER_EMULATOR_HOST"].nil?
    fail "This benchmarking server only works when connected to an emulator. Please set SPANNER_EMULATOR_HOST."
  end

  if port.nil? || port.to_i.to_s != port
    fail "Please specify a valid port, e.g., -p 5000 or --port 5000."
  end

  addr = "0.0.0.0:#{port}"
  s = GRPC::RpcServer.new
  s.add_http2_port(addr, :this_port_is_insecure)
  puts "starting benchwrapper for Spanner on localhost:#{addr}"
  s.handle(ServerImpl.new)
  # Runs the server with SIGHUP, SIGINT and SIGQUIT signal handlers to 
  #   gracefully shutdown.
  # User could also choose to run server via call to run_till_terminated
  s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
end

main