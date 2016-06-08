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

require "helper"
require "json"
require "uri"

describe "Gcloud Translate Backoff", :mock_translate do

  it "translates a single input with backoff" do
    2.times do
      mock_connection.get "/language/translate/v2" do |env|
        env.params["key"].must_equal key
        env.params["q"].must_equal   "Hello"
        env.params["target"].must_equal "es"
        [500, { "Content-Type" => "application/json" }, nil]
      end
    end
    mock_connection.get "/language/translate/v2" do |env|
      env.params["key"].must_equal key
      env.params["q"].must_equal   "Hello"
      env.params["target"].must_equal "es"
      [200, { "Content-Type" => "application/json" },
       translate_json("Hola", "en")]
    end

    assert_backoff_sleep 1, 2 do
      translation = translate.translate "Hello", to: "es"
      translation.text.must_equal "Hola"
      translation.source.must_equal "en"
    end
  end

  def assert_backoff_sleep *args
    mock = Minitest::Mock.new
    args.each { |intv| mock.expect :sleep, nil, [intv] }
    callback = ->(retries) { mock.sleep retries }
    backoff = Gcloud::Backoff.new backoff: callback

    Gcloud::Backoff.stub :new, backoff do
      yield
    end

    mock.verify
  end
end
