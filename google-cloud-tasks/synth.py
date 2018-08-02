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

def merge_gemspec(src, dest, path):
    version_re = re.compile(r'^\s+gem.version\s*=\s*"[\d\.]+"$', flags=re.MULTILINE)
    match = version_re.search(dest)
    if match:
        return version_re.sub(match.group(0), src, count=1)
    else:
        return src

s.copy(v2beta2_library / 'google-cloud-tasks.gemspec', merge=merge_gemspec)
