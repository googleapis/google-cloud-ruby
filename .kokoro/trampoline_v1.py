#!/usr/env/bin python3

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


"""Trampoline handles launching into a docker container for running tests."""

import os
import shutil
import subprocess
import sys
import tempfile
from subprocess import Popen, PIPE


ENV_BLACKLIST = [
    'TMP', 'rvm_version', 'HOME', 'SSH_CONNECTION', 'LANG', 'SHELL',
    'PYENV_SHELL', 'PYENV_VERSION', 'JAVA_HOME', 'XDG_RUNTIME_DIR',
    'rvm_prefix', 'J2SDKDIR', '_system_type', 'ANDROID_HOME', 'XDG_SESSION_ID',
    '_system_arch', 'GRADLE_USER_HOME', '_system_version', 'MAIL', 'GOPATH',
    'GOROOT', 'rvm_path', 'PYENV_DIR', 'SSH_CLIENT', 'LOGNAME', 'USER', 'PATH',
    'PYENV_VIRTUALENV_INIT', 'TEMP', 'SHLVL', 'QT_QPA_PLATFORMTHEME',
    '_system_name', 'rvm_bin_path', 'TMPDIR', 'XDG_SESSION_COOKIE',
    'DERBY_HOME', 'J2REDIR', 'PYENV_HOOK_PATH', 'PYENV_ROOT', 'PWD',
    'CLOUDSDK_CONFIG', 'CLOUD_SDK_VERSION']


def setup_isolated_gcloud_config(tmpdir):
    os.environ['CLOUDSDK_CONFIG'] = os.path.join(tmpdir, 'cloudsdk')


def setup_gcloud_auth(service_account_key_file):
    subprocess.check_output([
        'gcloud', 'auth', 'activate-service-account',
        '--key-file', service_account_key_file], shell=True)
    try:
        # Attempt to the use the GA command, fall back to beta if Cloud SDK
        # is too old.
        subprocess.check_call([
            'gcloud', 'auth', 'configure-docker', '--quiet'], shell=True)
    except subprocess.CalledProcessError:
        subprocess.check_call([
            'gcloud', 'beta', 'auth', 'configure-docker', '--quiet'], shell=True)


def pull_docker_image(image):
    # Retry pulling the image up to three time.
    for n in range(3):
        try:
            subprocess.check_call(['docker', 'pull', image], shell=True)
            return
        except subprocess.CalledProcessError:
            print(
                "Failed to pull docker image, attempt {} out of 3.".format(n))
    raise RuntimeError("Failed to pull image {}.".format(image))


def create_docker_envfile(tmpdir):
    exported_env_keys = (
        key for key in os.environ.keys() if key not in ENV_BLACKLIST)

    env_file_name = os.path.join(tmpdir, 'envfile')
    with open(env_file_name, 'w') as env_file:
        for key in exported_env_keys:
            os.environ[key] = os.environ[key].replace('T:', 'C:').replace('t:', 'c:')
            env_file.write('{}\n'.format(key))
    return env_file_name


def run_docker(image, env_file, kokoro_root, kokoro_artifacts_dir, build_file):
    docker_args = [
        'docker',
        'run',
        '--rm',  # Remove the container when it exits.
        '--interactive',  # Attach stdin.
        '--volume="T:\src:C:\src"',
        # Set the working directory to the workspace.
        '--workdir={}'.format(kokoro_artifacts_dir),
        # Run the test script.
        '--entrypoint="C:\src\{}"'.format(build_file),
        '--env-file={}'.format(env_file)
    ]

    exec_args = docker_args + [image]

    print('Executing: {}'.format(' '.join(exec_args)))
    sys.stdout.flush()
    sys.stderr.flush()

    p = Popen(" ".join(exec_args), shell=True, stdout=PIPE, encoding="utf-8", stderr=PIPE)
    output, err = p.communicate()
    if err:
        print(output)
        print(err)
        raise RuntimeError(err)
    else:
        print(output)


def main():
    kokoro_root = os.environ['KOKORO_ROOT']
    kokoro_artifacts_dir = os.environ['KOKORO_ARTIFACTS_DIR']
    kokoro_artifacts_dir = kokoro_artifacts_dir.replace("T:\\", "C:\\").replace("t:\\", "C:\\")
    kokoro_gfile_dir = os.environ['KOKORO_GFILE_DIR']
    service_account_key_file = os.path.join(
        kokoro_gfile_dir, 'kokoro-trampoline.service-account.json')
    image = os.environ['TRAMPOLINE_IMAGE']
    build_file = os.environ['TRAMPOLINE_BUILD_FILE']

    tmpdir = tempfile.mkdtemp()
    setup_isolated_gcloud_config(tmpdir)
    
    setup_gcloud_auth(service_account_key_file)
    pull_docker_image(image)
    env_file = create_docker_envfile(tmpdir)
    run_docker(image, env_file, kokoro_root, kokoro_artifacts_dir, build_file)


if __name__ == '__main__':
    main()
