# Copyright 2017 Google Inc. All rights reserved.
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


require "google/cloud/debugger/tracer/tracer_scenarios_test"

##
# Helper method to test tracer
def tracer_test_func
  true
end

##
# Helper method to test tracer
def tracer_test_func2
  yield
end

##
# Helper method to test tracer
def tracer_test_func3
  tracer_test_func2 do
    true
  end
end

##
# Helper method to test tracer
def tracer_test_func4
  tracer_distraction_method1
end

##
# Helper method to test tracer
def tracer_test_func5
  true
end

##
# Helper lambda to test tracer
def tracer_test_lambda
  ->() {
    true
  }
end

##
# Helper proc to test tracer
def tracer_test_proc
  Proc.new do
    true
  end
end

##
# Helper filber to test tracer
def tracer_test_fiber
  Fiber.new do
    result = 1
    Fiber.yield result
    result = 2
    result
  end
end

##
# Helper method to test tracer
def tracer_test_func6
  tracer_distraction_method2
  var = nil
  var
end

##
# Helper method to test tracer
def tracer_test_func7
  tracer_distraction_method3
  true
end

def dynamic_define_method
  eval "def foo1; 6 * 7; end"
  eval "def foo2; foo1; end"

  result = foo2
  result
end
