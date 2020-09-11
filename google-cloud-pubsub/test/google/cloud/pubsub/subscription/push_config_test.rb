# Copyright 2017 Google LLC
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

require "helper"

describe Google::Cloud::PubSub::Subscription::PushConfig do
  let(:endpoint)      { "https://pub-sub.test.com/pubsub" }
  let(:auth_email)     { "service-account@example.net" }
  let(:auth_audience) { "audience-header-value" }

  it "constructor arguments appropriately constructs PushConfig" do

    push_config = Google::Cloud::PubSub::Subscription::PushConfig.new endpoint: endpoint, auth_email: auth_email, auth_audience: auth_audience

    _(push_config.endpoint).must_equal endpoint
    _(push_config.authentication).must_be_kind_of Google::Cloud::PubSub::Subscription::PushConfig::OidcToken
  end

  it "does not accept audeince without an auth_email" do
    assert_raises ArgumentError do
      Google::Cloud::PubSub::Subscription::PushConfig.new endpoint: endpoint, auth_email: nil, auth_audience: auth_audience
    end
  end

end
