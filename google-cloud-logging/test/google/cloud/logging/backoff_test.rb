# Copyright 2016 Google Inc. All rights reserved.
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

require "helper"

describe "Google Cloud Logging Backoff", :mock_logging do
  it "retries when the session times out" do
    metric_name = "session-timed-out-metric"

    stub = Object.new
    def stub.get_log_metric *args
      @tries ||= 0
      @tries += 1
      raise GRPC::BadStatus.new 14, "goaway" if @tries < 3
      return Google::Logging::V2::LogMetric.decode_json(
        "{\"name\":\"session-timed-out-metric\",\"description\":\"The servere errors metric\",\"filter\":\"logName:syslog AND severity>=ERROR\"}"
      )
    end
    logging.service.mocked_metrics = stub

    metric = nil
    assert_backoff_sleep 1, 2 do
      metric = logging.metric metric_name
    end

    metric.must_be_kind_of Google::Cloud::Logging::Metric
    metric.name.must_equal metric_name
  end

  it "raises after enough retries" do
    metric_name = "session-timed-out-metric"

    stub = Object.new
    def stub.get_log_metric *args
      raise GRPC::BadStatus.new 14, "goaway"
    end
    logging.service.mocked_metrics = stub

    assert_backoff_sleep 1, 2, 3, 4, 5 do
      expect { logging.metric metric_name }.must_raise Google::Cloud::UnavailableError
    end
  end

  def assert_backoff_sleep *args
    mock = Minitest::Mock.new
    args.each { |intv| mock.expect :sleep, nil, [intv] }
    callback = ->(retries) { mock.sleep retries }
    backoff = Google::Cloud::Core::Backoff.new retries: 5, backoff: callback

    Google::Cloud::Core::Backoff.stub :new, backoff do
      yield
    end

    mock.verify
  end
end
