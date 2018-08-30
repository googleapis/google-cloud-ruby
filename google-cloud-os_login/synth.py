import synthtool as s
import synthtool.gcp as gcp
import logging
import re


logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

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

v1_library = gapic.ruby_library(
    'oslogin', 'v1',
    config_path='/google/cloud/oslogin/artman_oslogin_v1.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-os_login'
)
s.copy(v1_library / 'lib/google/cloud/os_login.rb')
s.copy(v1_library / 'lib/google/cloud/os_login/v1')
s.copy(v1_library / 'lib/google/cloud/os_login/v1.rb')
s.copy(v1_library / 'lib/google/cloud/oslogin/v1')
s.copy(v1_library / 'lib/google/cloud/oslogin/common')
s.copy(v1_library / 'test/google/cloud/os_login/v1')
s.copy(v1_library / 'README.md')
s.copy(v1_library / 'LICENSE')
s.copy(v1_library / '.gitignore')
s.copy(v1_library / '.rubocop.yml')
s.copy(v1_library / '.yardopts')
s.copy(v1_library / 'google-cloud-os_login.gemspec', merge=merge_gemspec)

v1beta_library = gapic.ruby_library(
    'oslogin', 'v1beta',
    config_path='/google/cloud/oslogin/artman_oslogin_v1beta.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-os_login'
)
s.copy(v1beta_library / 'lib/google/cloud/os_login/v1beta')
s.copy(v1beta_library / 'lib/google/cloud/os_login/v1beta.rb')
s.copy(v1beta_library / 'lib/google/cloud/oslogin/v1beta')
s.copy(v1beta_library / 'test/google/cloud/os_login/v1beta')

# PERMANENT: API name for oslogin
s.replace(
    [
      'README.md',
      'lib/google/cloud/os_login.rb',
      'lib/google/cloud/os_login/v1.rb',
      'lib/google/cloud/os_login/v1beta.rb'
    ],
    '/os-login\\.googleapis\\.com', '/oslogin.googleapis.com')

# https://github.com/googleapis/gapic-generator/issues/2196
s.replace(
    [
      'README.md',
      'lib/google/cloud/os_login.rb',
      'lib/google/cloud/os_login/v1.rb',
      'lib/google/cloud/os_login/v1beta.rb'
    ],
    '\\[Product Documentation\\]: https://cloud\\.google\\.com/os-login\n',
    '[Product Documentation]: https://cloud.google.com/compute/docs/oslogin/rest/\n')

# https://github.com/googleapis/gapic-generator/issues/2242
def escape_braces(match):
    expr = re.compile('([^#\\$\\\\])\\{([\\w,]+)\\}')
    content = match.group(0)
    while True:
        content, count = expr.subn('\\1\\\\\\\\{\\2}', content)
        if count == 0:
            return content
s.replace(
    'lib/google/cloud/**/*.rb',
    '\n(\\s+)#[^\n]*[^\n#\\$\\\\]\\{[\\w,]+\\}',
    escape_braces)

# https://github.com/googleapis/gapic-generator/issues/2243
s.replace(
    'lib/google/cloud/os_login/*/*_client.rb',
    '(\n\\s+class \\w+Client\n)(\\s+)(attr_reader :\\w+_stub)',
    '\\1\\2# @private\n\\2\\3')
