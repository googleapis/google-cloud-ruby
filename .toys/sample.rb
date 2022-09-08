# frozen_string_literal: true

# Copyright 2022 Google LLC
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

require_relative ".lib/sample_loader"

desc "Samples runnable from this directory"

SampleLoader.list.each do |filename|
  sample = SampleLoader.load filename

  if sample.well_formed?
    tool_name = sample.name_segments.map { |seg| seg.tr "_", "-" }
    tool tool_name do
      desc "Run the \"#{sample.file_name}\" sample"

      sample.param_names.each do |param|
        accepted_type =
          case sample.param_type(param)
          when "Integer"
            Integer
          when "Array<String>"
            Array
          else
            String
          end
        flag param, accept: accepted_type, desc: sample.param_desc(param)
      end

      to_run do
        params = sample.param_names.to_h { |param| [param, get(param)] }
        sample.run(**params)
      end
    end
  end
end
