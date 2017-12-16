# Copyright 2016 Google LLC
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

describe Google::Cloud::Trace::TimeSampler do
  let(:start_time) { ::Time.at(12345678) }
  let(:env) { {} }

  def sampler
    ::Time.stub :now, start_time do
      Google::Cloud::Trace::TimeSampler.new
    end
  end

  describe ".call" do
    it "samples the first time called" do
      sam = Google::Cloud::Trace::TimeSampler.new
      sam.call(env).must_equal true
    end

    it "omits the default blacklisted path" do
      sam = Google::Cloud::Trace::TimeSampler.new
      blacklisted_env = { "PATH_INFO" => "/_ah/health" }
      sam.call(blacklisted_env).must_equal false
    end

    it "doesn't sample when called too soon" do
      sam = sampler
      ::Time.stub :now, start_time - 1 do
        sam.call(env).must_equal false
      end
    end

    it "samples when called after a suitable delay" do
      sam = sampler
      ::Time.stub :now, start_time + 1 do
        sam.call(env).must_equal true
      end
    end

    it "advances last sampling time" do
      sam = sampler
      ::Time.stub :now, start_time + 3 do
        sam.call(env).must_equal true
      end
      ::Time.stub :now, start_time + 9 do
        sam.call(env).must_equal false
      end
      ::Time.stub :now, start_time + 11 do
        sam.call(env).must_equal true
      end
    end

    it "advances last sampling time after a large gap" do
      sam = sampler
      ::Time.stub :now, start_time + 30 do
        sam.call(env).must_equal true
      end
      ::Time.stub :now, start_time + 31 do
        sam.call(env).must_equal true
      end
      ::Time.stub :now, start_time + 32 do
        sam.call(env).must_equal false
      end
    end
  end
end
