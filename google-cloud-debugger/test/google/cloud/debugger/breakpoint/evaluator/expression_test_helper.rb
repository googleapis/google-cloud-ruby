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

def expression_must_equal expression, expected, binding = binding()
  result = evaluator.readonly_eval_expression binding, expression
  result.must_equal expected
end

def expression_must_be_kind_of expression, expected, binding = binding()
  result = evaluator.readonly_eval_expression binding, expression
  result.must_be_kind_of expected
end

def expression_not_allowed expression, binding = binding()
  result = evaluator.readonly_eval_expression binding, expression
  result.must_match "Invalid operation detected"
end
