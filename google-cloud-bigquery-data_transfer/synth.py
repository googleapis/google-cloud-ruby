import synthtool as s
import synthtool.gcp as gcp
import logging


logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1_library = gapic.ruby_library(
    'bigquery/datatransfer', 'v1', artman_output_name='google-cloud-ruby/google-cloud-bigquerydatatransfer',
    config_path='artman_bigquerydatatransfer.yaml'
)

# Copy everything but Gemfile, .gemspec, and Changelog.md
s.copy(v1_library / 'lib')
s.copy(v1_library / 'test')
s.copy(v1_library / 'Rakefile')
s.copy(v1_library / 'README.md')
s.copy(v1_library / 'LICENSE')
s.copy(v1_library / '.gitignore')
s.copy(v1_library / '.rubocop.yml')
s.copy(v1_library / '.yardopts')