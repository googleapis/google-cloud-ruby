import synthtool as s
import synthtool.gcp as gcp
import logging


logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v2_library = gapic.ruby_library(
    'tasks', 'v2beta2', artman_output_name='google-cloud-ruby/google-cloud-tasks',
    config_path='artman_cloudtasks.yaml'
)

# Copy everything but Gemfile, .gemspec, and Changelog.md
s.copy(v2_library / 'lib')
s.copy(v2_library / 'test')
s.copy(v2_library / 'Rakefile')
s.copy(v2_library / 'README.md')
s.copy(v2_library / 'LICENSE')
s.copy(v2_library / '.gitignore')
s.copy(v2_library / '.rubocop.yml')
s.copy(v2_library / '.yardopts')