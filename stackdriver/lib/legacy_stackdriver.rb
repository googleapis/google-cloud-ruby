# Copyright (c) 2013 Grant T. Olson
# All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#   * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided
#       with the distribution.
#
#     * Neither the name of the Grant T. Olson nor the names of
#       additional contributors may be used to endorse or promote
#       products derived from this software without specific prior
#       written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#
# This file provides backward compatibility with legacy stackdriver v0.2.2 gem.
# Original code can be found at https://github.com/sammarx/stackdriver-ruby
#
require 'multi_json'

module StackDriver
  POST_URI = "https://custom-gateway.stackdriver.com/v1/custom"
  DELETE_URI = "https://custom-gateway.stackdriver.com/v1/delete_custom"

  def self.init *args
    # Deprecation message
    puts "This usage is specific to the legacy Stackdriver service. It is " \
      "deprecated and will be removed at some point in the future. Please " \
      "migrate to the Google Stackdriver API documented at " \
      "https://googlecloudplatform.github.io/google-cloud-ruby/"

    if args.count > 1
      puts "Customer ID is no longer needed, and will be deprecated"
      args.shift
    end
    @api_key = args[0]
  end

  def self.send_metric name, value, time, instance=''
    msg = build_message name, value, time, instance
    post MultiJson.dump(msg), StackDriver::POST_URI
  end

  def self.send_multi_metrics data
    msg = build_multi_message data
    post MultiJson.dump(msg), StackDriver::POST_URI
  end

  def self.delete_metric name, time
    msg = build_message name, nil, time
    post MultiJson.dump(msg), StackDriver::DELETE_URI
  end

  private

  def self.post msg, uri
    headers = {'content-type' => 'application/json',
               'x-stackdriver-apikey' => @api_key}

    uri = URI(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    http.start do |http|
      response = http.post(uri.path, msg, headers)
      if response.code != "201"
        raise RuntimeError, "#{response.code} - #{response.body}"
      end
    end
  end

  def self.build_message name, value, time, instance=''
    data_point = {'name' => name, 'value' => value, 'collected_at' => time}
    data_point.merge!('value' => value) unless value.nil?
    data_point.merge!('instance' => instance) unless instance.empty?
    {'timestamp' => Time.now.to_i, 'proto_version' => '1', 'data' => data_point}
  end

  def self.build_multi_message data
    data_point = data
    {
      'timestamp' => Time.now.to_i,
      'proto_version' => '1',
      'data' => data_point
    }
  end
end