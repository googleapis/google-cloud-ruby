import synthtool as s
import synthtool.gcp as gcp
import logging
import re


logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v2beta2_library = gapic.ruby_library(
    'tasks', 'v2beta2', artman_output_name='google-cloud-ruby/google-cloud-tasks',
    config_path='artman_cloudtasks.yaml'
)

# Copy everything but Gemfile, .gemspec, and Changelog.md
s.copy(v2beta2_library / 'lib')
s.copy(v2beta2_library / 'test')
s.copy(v2beta2_library / 'Rakefile')
s.copy(v2beta2_library / 'README.md')
s.copy(v2beta2_library / 'LICENSE')
s.copy(v2beta2_library / '.gitignore')
s.copy(v2beta2_library / '.rubocop.yml')
s.copy(v2beta2_library / '.yardopts')

# https://github.com/googleapis/gapic-generator/issues/2174
s.replace(
    'lib/google/cloud/tasks.rb',
    'File\.join\(dir, "\.rb"\)',
    'dir + ".rb"')

# https://github.com/googleapis/gapic-generator/issues/2182
s.replace(
    'lib/google/cloud/tasks/v2beta2/credentials.rb',
    'TASKS_KEYFILE\\n(\s+)TASKS_CREDENTIALS\n',
    'TASKS_CREDENTIALS\\n\\1TASKS_KEYFILE\n')
s.replace(
    'lib/google/cloud/tasks/v2beta2/credentials.rb',
    'TASKS_KEYFILE_JSON\\n(\s+)TASKS_CREDENTIALS_JSON\n',
    'TASKS_CREDENTIALS_JSON\\n\\1TASKS_KEYFILE_JSON\n')

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

s.copy(v2beta2_library / 'google-cloud-tasks.gemspec', merge=merge_gemspec)

# https://github.com/googleapis/gapic-generator/issues/2180
s.replace(
    'google-cloud-tasks.gemspec',
    '(gem\.add_dependency\s+"google-gax",\s+"[^"]+")',
    '\\1\n  gem.add_dependency "grpc-google-iam-v1", "~> 0.6.9"')
