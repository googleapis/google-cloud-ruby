import synthtool as s
import synthtool.gcp as gcp
import logging
import re


logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1beta1_library = gapic.ruby_library(
    'redis', 'v1beta1',
    config_path='artman_redis_v1beta1.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-redis'
)

# Copy everything but Gemfile, .gemspec, and Changelog.md
s.copy(v1beta1_library / 'lib')
s.copy(v1beta1_library / 'test')
s.copy(v1beta1_library / 'Rakefile')
s.copy(v1beta1_library / 'README.md')
s.copy(v1beta1_library / 'LICENSE')
s.copy(v1beta1_library / '.gitignore')
s.copy(v1beta1_library / '.rubocop.yml')
s.copy(v1beta1_library / '.yardopts')

# https://github.com/googleapis/gapic-generator/issues/2174
s.replace(
    'lib/google/cloud/redis.rb',
    'File\.join\(dir, "\.rb"\)',
    'dir + ".rb"')

# https://github.com/googleapis/gapic-generator/issues/2182
s.replace(
    'lib/google/cloud/redis/v1beta1/credentials.rb',
    'REDIS_KEYFILE\\n(\s+)REDIS_CREDENTIALS\n',
    'REDIS_CREDENTIALS\\n\\1REDIS_KEYFILE\n')
s.replace(
    'lib/google/cloud/redis/v1beta1/credentials.rb',
    'REDIS_KEYFILE_JSON\\n(\s+)REDIS_CREDENTIALS_JSON\n',
    'REDIS_CREDENTIALS_JSON\\n\\1REDIS_KEYFILE_JSON\n')

# https://github.com/googleapis/gapic-generator/issues/2195
s.replace(
    'README.md',
    '\\(https://console\\.cloud\\.google\\.com/apis/api/redis\\)',
    '(https://console.cloud.google.com/apis/library/redis.googleapis.com)')

# https://github.com/googleapis/gapic-generator/issues/2196
s.replace(
    'README.md',
    '\\[Product Documentation\\]: https://cloud\\.google\\.com/redis\n',
    '[Product Documentation]: https://cloud.google.com/memorystore\n')

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

s.copy(v1beta1_library / 'google-cloud-redis.gemspec', merge=merge_gemspec)
