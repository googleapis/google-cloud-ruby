import synthtool as s
import synthtool.gcp as gcp
import logging
import re


logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1_library = gapic.ruby_library(
    'oslogin', 'v1',
    config_path='/google/cloud/oslogin/artman_oslogin_v1.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-os_login'
)

s.copy(v1_library / 'lib/google/cloud/os_login/v1')
s.copy(v1_library / 'lib/google/cloud/os_login/v1.rb')
s.copy(v1_library / 'lib/google/cloud/oslogin/v1')

# https://github.com/googleapis/gapic-generator/issues/2182
s.replace(
    'lib/google/cloud/os_login/v1/credentials.rb',
    'OS_LOGIN_KEYFILE\\n(\s+)OS_LOGIN_CREDENTIALS\n',
    'OS_LOGIN_CREDENTIALS\\n\\1OS_LOGIN_KEYFILE\n')
s.replace(
    'lib/google/cloud/os_login/v1/credentials.rb',
    'OS_LOGIN_KEYFILE_JSON\\n(\s+)OS_LOGIN_CREDENTIALS_JSON\n',
    'OS_LOGIN_CREDENTIALS_JSON\\n\\1OS_LOGIN_KEYFILE_JSON\n')

s.copy(v1_library / 'test/google/cloud/os_login/v1')

# https://github.com/googleapis/gapic-generator/issues/2117
s.replace(
    'test/google/cloud/os_login/v1/os_login_service_client_test.rb',
    'CustomTestError', 'CustomTestError_v1')
s.replace(
    'test/google/cloud/os_login/v1/os_login_service_client_test.rb',
    'MockGrpcClientStub', 'MockGrpcClientStub_v1')
s.replace(
    'test/google/cloud/os_login/v1/os_login_service_client_test.rb',
    'MockOsLoginServiceCredentials',
    'MockOsLoginServiceCredentials_v1')

# Copy base module from the v1 library so v1 is the default
s.copy(v1_library / 'lib/google/cloud/os_login.rb')

# https://github.com/googleapis/gapic-generator/issues/2174
s.replace(
    'lib/google/cloud/os_login.rb',
    'File\.join\(dir, "\.rb"\)',
    'dir + ".rb"')

# Copy common pbs from the v1 library
s.copy(v1_library / 'lib/google/cloud/oslogin/common')

# Copy other base files from v1
s.copy(v1_library / 'README.md')
s.copy(v1_library / 'LICENSE')
s.copy(v1_library / '.gitignore')
s.copy(v1_library / '.rubocop.yml')
s.copy(v1_library / '.yardopts')

# Temporary until we get Ruby-specific tools into synthtool
def merge_gemspec(src, dest, path):
    regex = re.compile(r'^\s+gem.version\s*=\s*"[\d\.]+"$', flags=re.MULTILINE)
    match = regex.search(dest)
    if match:
        src = regex.sub(match.group(0), src, count=1)
    regex = re.compile(r'^\s+gem.homepage\s*=\s*"[^"]+"$', flags=re.MULTILINE)
    match = regex.search(dest)
    if match:
        src = regex.sub(match.group(0), src, count=1)
    return src

s.copy(v1_library / 'google-cloud-os_login.gemspec', merge=merge_gemspec)


v1beta_library = gapic.ruby_library(
    'oslogin', 'v1beta',
    config_path='/google/cloud/oslogin/artman_oslogin_v1beta.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-os_login'
)

s.copy(v1beta_library / 'lib/google/cloud/os_login/v1beta')
s.copy(v1beta_library / 'lib/google/cloud/os_login/v1beta.rb')
s.copy(v1beta_library / 'lib/google/cloud/oslogin/v1beta')

# https://github.com/googleapis/gapic-generator/issues/2182
s.replace(
    'lib/google/cloud/os_login/v1beta/credentials.rb',
    'OS_LOGIN_KEYFILE\\n(\s+)OS_LOGIN_CREDENTIALS\n',
    'OS_LOGIN_CREDENTIALS\\n\\1OS_LOGIN_KEYFILE\n')
s.replace(
    'lib/google/cloud/os_login/v1beta/credentials.rb',
    'OS_LOGIN_KEYFILE_JSON\\n(\s+)OS_LOGIN_CREDENTIALS_JSON\n',
    'OS_LOGIN_CREDENTIALS_JSON\\n\\1OS_LOGIN_KEYFILE_JSON\n')

s.copy(v1beta_library / 'test/google/cloud/os_login/v1beta')

# https://github.com/googleapis/gapic-generator/issues/2117
s.replace(
    'test/google/cloud/os_login/v1beta/os_login_service_client_test.rb',
    'CustomTestError', 'CustomTestError_v1beta')
s.replace(
    'test/google/cloud/os_login/v1beta/os_login_service_client_test.rb',
    'MockGrpcClientStub', 'MockGrpcClientStub_v1beta')
s.replace(
    'test/google/cloud/os_login/v1beta/os_login_service_client_test.rb',
    'MockOsLoginServiceCredentials',
    'MockOsLoginServiceCredentials_v1beta')
