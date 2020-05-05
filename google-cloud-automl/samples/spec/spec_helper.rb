# Copyright 2019 Google LLC
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

require "dotenv/load"
require "rspec"

module UtilHelpers
  # Capture and return STDOUT output by block
  def capture
    real_stdout = $stdout
    $stdout     = StringIO.new
    yield
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end
  attr_reader :captured_output

  def ensure_import_file! bucket, import_file, source = nil
    source ||= "resources/#{import_file}"
    f = bucket.file(import_file) || bucket.create_file(source, import_file)
    f.to_gs_url
  end

  def cleanup_bucket_prefix! bucket, export_path
    b = storage.bucket bucket
    b.files(prefix: export_path).all(&:delete)
  end
end

RSpec.configure do |c|
  # declare an exclusion filter
  c.filter_run_excluding :slow

  c.run_all_when_everything_filtered = true

  # include common spec methods
  c.include UtilHelpers

  # Use color in STDOUT
  c.color = true

  # Use color not only in STDOUT but also in pagers and files
  c.tty = true

  # Use the specified formatter
  c.formatter = :documentation
end
