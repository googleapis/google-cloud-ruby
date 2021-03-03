# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0  the "License";
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
require "google/cloud/errors"

describe Google::Cloud::Error, :cause do
  def wrapped_std_error msg
    begin
      raise msg
    rescue => std_err
      raise Google::Cloud::Error.from_error std_err
    end
  rescue => gcoud_err
    return gcoud_err
  end

  # These tests show Google::Cloud::Error#cause is available, even on ruby 2.0

  it "always has a cause" do
    error = wrapped_std_error "yo"

    _(error).must_be_kind_of Google::Cloud::Error
    _(error.message).must_equal "yo"

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?

    _(error.cause).wont_be :nil?
    _(error.cause).must_be_kind_of StandardError
    _(error.cause.message).must_equal "yo"
  end

  it "can have a nil cause" do
    error = Google::Cloud::Error.new "sup"

    _(error).must_be_kind_of Google::Cloud::Error
    _(error.message).must_equal "sup"

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?

    _(error.cause).must_be :nil?

    _(error.instance_variable_get(:@cause)).must_be :nil?
  end
end
