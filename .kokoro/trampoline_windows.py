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

import errno
import os
import shutil
import subprocess
import sys
import tempfile
from subprocess import Popen, PIPE


ENV_BLACKLIST = ["ALIASES", "ALLUSERSPROFILE", "ANDROID_HOME", "ANSICON",
                 "ANSICON_DEF", "ANT_HOME", "APPDATA", "ARCHITECTURE", "ARCHITECTURE_BITS", "CCALL",
                 "CEXEC", "CHOCOLATEYINSTALL", "CHOCOLATEYLASTPATHUPDATE", "CHOCOLATEYTOOLSLOCATION",
                 "CLASSPATH", "CLIENTNAME", "CLOUDSDK_CONFIG", "CLOUD_SDK_VERSION", "CMDER_ALIASES",
                 "CMDER_CLINK", "CMDER_CONFIGURED", "CMDER_INIT_END", "CMDER_INIT_START", "CMDER_ROOT",
                 "CMDER_SHELL", "CMDER_USER_FLAGS", "COMPUTERNAME", "CONEMUANSI", "CONEMUARGS", "CONEMUBACKHWND",
                 "CONEMUBASEDIR", "CONEMUBASEDIRSHORT", "CONEMUBUILD", "CONEMUCFGDIR", "CONEMUDIR", "CONEMUDRAWHWND",
                 "CONEMUDRIVE", "CONEMUHOOKS", "CONEMUHWND", "CONEMUPALETTE", "CONEMUPID", "CONEMUSERVERPID",
                 "CONEMUTASK", "CONEMUWORKDIR", "CONEMUWORKDRIVE", "CUDA_PATH", "CUDA_PATH_V9_0", "CUDA_PATH_V9_1",
                 "ComSpec", "CommonProgramFiles", "CommonProgramFiles(x86)", "CommonProgramW6432", "DEBUG_OUTPUT",
                 "DERBY_HOME", "FAST_INIT", "FEFLAGNAME", "FSHARPINSTALLDIR", "GIT_INSTALL_ROOT", "GOOGETROOT",
                 "GOPATH", "GOROOT", "GRADLE_HOME", "GRADLE_USER_HOME", "HOME", "HOMEDRIVE", "HOMEPATH", "J2REDIR",
                 "J2SDKDIR", "JAVA_HOME", "LANG", "LIB_BASE", "LIB_CONSOLE",
                 "LIB_GIT", "LIB_PATH", "LIB_PROFILE", "LOCALAPPDATA", "LOGNAME", "LOGONSERVER", "M2", "M2_HOME",
                 "M2_REPO", "MAIL", "MAVEN_OPTS", "MAX_DEPTH", "MSMPI_BIN", "NIX_TOOLS", "NUMBER_OF_PROCESSORS",
                 "NVCUDASAMPLES9_0_ROOT", "NVCUDASAMPLES9_1_ROOT", "NVCUDASAMPLES_ROOT", "OS", "PATH",
                 "PATHEXT", "PLINK_PROTOCOL", "PROCESSOR_ARCHITECTURE", "PROCESSOR_IDENTIFIER", "PROCESSOR_LEVEL",
                 "PROCESSOR_REVISION", "PROMPT", "PSModulePath", "PUBLIC", "PWD", "PYENV_DIR", "PYENV_HOOK_PATH",
                 "PYENV_ROOT", "PYENV_SHELL", "PYENV_VERSION", "PYENV_VIRTUALENV_INIT", "Path", "ProgramData",
                 "ProgramFiles", "ProgramFiles(x86)", "ProgramW6432", "QT_QPA_PLATFORMTHEME",
                 "SESSIONNAME", "SHELL", "SHLVL", "SSH_CLIENT", "SSH_CONNECTION", "SVN_SSH", "SystemDrive",
                 "SystemRoot", "TEMP", "TERM", "TIME_INIT", "TMP", "TMPDIR", "TRAMPOLINE_BUILD_FILE",
                 "TRAMPOLINE_IMAGE", "USER", "USERDOMAIN", "USERDOMAIN_ROAMINGPROFILE", "USERNAME", "USERPROFILE",
                 "USER_ALIASES", "VERBOSE_OUTPUT", "VS110COMNTOOLS", "VS120COMNTOOLS", "VS140COMNTOOLS",
                 "VSSDK140INSTALL", "XDG_RUNTIME_DIR", "XDG_SESSION_COOKIE", "XDG_SESSION_ID", "_system_arch"
                 "_system_name", "_system_type", "_system_version", "rvm_bin_path", "rvm_path", "rvm_prefix",
                 "rvm_version", "windir"]


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
            os.environ[key] = os.environ[key].replace(
                'T:', 'C:').replace('t:', 'c:')
            env_file.write('{}\n'.format(key))
    return env_file_name


 
def copy(src, dest):
    delete(dest)
    try:
        shutil.copytree(src, dest, symlinks=True)
    except OSError as e:
        # If the error was caused because the source wasn't a directory
        if e.errno == errno.ENOTDIR:
            shutil.copy(src, dest)
        else:
            print('Directory not copied. Error: %s' % e)

def delete(src):
    try:
        shutil.rmtree(src)
    except:
        e = sys.exc_info()[0]
        print('Error while deleting {}: {}'.format(src, e))



def run_docker(image, env_file, kokoro_artifacts_dir, build_file):
    docker_args = [
        'docker',
        'run',
        '--rm',
        '--interactive',  # Attach stdin.
        '--volume="C:\\src:C:\\src"',
        # Set the working directory to the workspace.
        '--workdir={}'.format(kokoro_artifacts_dir),
        # Run the test script.
        '--entrypoint="C:\\src\\{}"'.format(build_file),
        '--env-file={}'.format(env_file)
    ]

    # exec_args = ['"{}"'.format(shutil.which('docker'))] + docker_args + [image]
    exec_args = docker_args + ['{}:latest'.format(image)]

    print('Executing: {}'.format(' '.join(exec_args)))
    sys.stdout.flush()
    sys.stderr.flush()
    p = Popen(" ".join(exec_args), stdout=PIPE, encoding="utf-8", stderr=PIPE)
    output, err = p.communicate()
    print(output)
    if p.returncode != 0:
        print(err)
        raise RuntimeError(err)


def main():
     # Windows docker containers do not like non-C:\\ drives
    old_kokoro_artifacts_dir = os.environ['KOKORO_ARTIFACTS_DIR']
    kokoro_artifacts_dir = old_kokoro_artifacts_dir.replace(
        "T:\\", "C:\\").replace("t:\\", "C:\\")
    copy(old_kokoro_artifacts_dir, kokoro_artifacts_dir)

    old_kokoro_gfile_dir = os.environ['KOKORO_GFILE_DIR']
    kokoro_gfile_dir =  old_kokoro_gfile_dir.replace(
        "T:\\", "C:\\").replace("t:\\", "C:\\")
    copy(old_kokoro_gfile_dir, kokoro_gfile_dir)

    service_account_key_file = os.path.join(
        kokoro_gfile_dir, 'kokoro-trampoline.service-account.json')
    image = os.environ['TRAMPOLINE_IMAGE']
    build_file = os.environ['TRAMPOLINE_BUILD_FILE']

    tmpdir = tempfile.mkdtemp()
    setup_isolated_gcloud_config(tmpdir)

    setup_gcloud_auth(service_account_key_file)
    pull_docker_image(image)
    env_file = create_docker_envfile(tmpdir)
    run_docker(image, env_file, kokoro_artifacts_dir, build_file)


if __name__ == '__main__':
    main()
