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

require_relative "helper"
require "securerandom"

describe "Google Cloud Security Center Notifications Sample" do
  parallelize_me!

  before do
    @client = Google::Cloud::SecurityCenter.security_center
    @pubsub_topic = "projects/project-a-id/topics/notifications-sample-topic"
    @config_id = "config-#{SecureRandom.hex 8}"
    @org_id = "1081635000895"
    @config_path = @client.notification_config_path organization:        @org_id,
                                                    notification_config: @config_id
    cleanup!
  end

  after do
    cleanup!
  end

  def cleanup!
    @client.delete_notification_config name: @config_path
  rescue Google::Cloud::NotFoundError
    puts "Config #{@config_path} already deleted"
  end

  def create_fixture!
    last_error = nil
    3.times do
      create_notification_config org_id:       @org_id,
                                 config_id:    @config_id,
                                 pubsub_topic: @pubsub_topic
      return
    rescue Google::Cloud::FailedPreconditionError => e
      # Creating this fixture occasionally raises a precondition error.
      # I'm not certain why, but because we can have tests running
      # concurrently, I suspect it happens when multiple fixtures are being
      # created simultaneously. Retry with a random delay if this happens.
      puts "Got precondition error when creating fixture #{@config_id}"
      sleep rand(2.0..7.0)
      last_error = e
    end
    raise last_error
  end

  it "creates notification config" do
    assert_output(/Created notification config #{@config_id}/) do
      create_notification_config org_id:       @org_id,
                                 config_id:    @config_id,
                                 pubsub_topic: @pubsub_topic
    end

    config = @client.get_notification_config name: @config_path
    assert_equal @config_path, config.name
  end

  it "updates notification config" do
    create_fixture!

    assert_output(/Updated description/) do
      update_notification_config org_id:      @org_id,
                                 config_id:   @config_id,
                                 description: "Updated description"
    end
  end

  it "deletes notification config" do
    create_fixture!

    assert_output(/Deleted notification config #{@config_id}/) do
      delete_notification_config org_id:    @org_id,
                                 config_id: @config_id
    end
  end

  it "gets notification config" do
    create_fixture!

    assert_output(/#{@config_path}/) do
      get_notification_config org_id:    @org_id,
                              config_id: @config_id
    end
  end

  it "lists notification configs" do
    create_fixture!

    assert_output(/#{@config_path}/) do
      list_notification_configs org_id: @org_id
    end
  end
end
