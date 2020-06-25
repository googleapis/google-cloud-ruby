#!/bin/bash

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License..

# Fail on any error
set -e

# Display commands being run
set -x

set +e # Run all tests, don't stop after the first failure.
exit_code=0

# Run tests.
for i in `find . -name Gemfile`; do
  pushd `dirname $i`;
    # Run integration tests against an emulator.
    if [ -f "emulator_test.sh" ]; then
      ./emulator_test.sh
    fi
    # Add the exit codes together so we exit non-zero if any module fails.
    exit_code=$(($exit_code + $?))
  popd;
done

exit $exit_code
