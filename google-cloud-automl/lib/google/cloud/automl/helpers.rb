# frozen_string_literal: true

# Copyright 2023 Google LLC
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


module Google
  module Cloud
    module AutoML
      class << self
        # Backwards-compatibility hack: Define "auto_ml" as an alternative name
        # for the "automl" method. The generator changed this name due to
        # https://github.com/googleapis/gapic-generator-ruby/pull/935.
        if public_method_defined?(:automl) && !public_method_defined?(:auto_ml)
          alias auto_ml automl
        end
      end
    end
  end
end
