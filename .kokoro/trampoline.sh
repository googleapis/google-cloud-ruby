#!/bin/bash
# Copyright 2017 Google Inc.
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
# limitations under the License.
set -eo pipefail
# Always run the cleanup script, regardless of the success of bouncing into
# the container.
function cleanup() {
    if [[ $OS = "linux" ]]; then
        chmod +x ${KOKORO_GFILE_DIR}/trampoline_cleanup.sh
        ${KOKORO_GFILE_DIR}/trampoline_cleanup.sh
        echo "cleanup"
    fi
}

cd $REPO_DIR

versions=(2.4.10 2.5.8 2.6.6 2.7.2)

STARTTIME=$(date +%s)

if [[ $JOB_TYPE = "presubmit" ]]; then
    COMMIT_MESSAGE=$(git log --format=%B -n 1 $KOKORO_GIT_COMMIT)
    if [[ $COMMIT_MESSAGE = *"[ci skip]"* || $COMMIT_MESSAGE = *"[skip ci]"* ]]; then
        echo "[ci skip] found. Exiting"
    elif [[ $OS = "windows" ]]; then
        python "${KOKORO_GFILE_DIR}/${TRAMPOLINE_SCRIPT}"
    else
        python3 "${KOKORO_GFILE_DIR}/${TRAMPOLINE_SCRIPT}" $version
    fi
else
    if [[ $OS = "windows" ]]; then
        python "${KOKORO_GFILE_DIR}/${TRAMPOLINE_SCRIPT}"
    else
        python3 "${KOKORO_GFILE_DIR}/${TRAMPOLINE_SCRIPT}"
    fi
fi

ENDTIME=$(date +%s)
echo "Tests took a total of $(($ENDTIME - $STARTTIME)) seconds"
