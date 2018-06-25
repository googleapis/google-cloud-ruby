import synthtool as s
import synthtool.gcp as gcp
import logging


logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1_library = gapic.ruby_library(
    'tasks', 'v2beta2', artman_output_name='google-cloud-ruby/google-cloud-tasks',
    config_path='artman_cloudtasks.yaml'
)

s.copy(v1_library)

# https://github.com/googleapis/gapic-generator/issues/2080
s.replace(
    "test/google/cloud/tasks/v2beta2/cloud_tasks_client_test.rb",
    "assert_not_nil",
    "refute_nil")

s.replace(
	'google-cloud-tasks.gemspec',
	'gem.add_dependency "google-gax", "~> 1.0"',
	('gem.add_dependency "google-gax", "~> 1.0"' + "\n" + '  gem.add_dependency "grpc-google-iam-v1", "~> 0.6.9"')
)

# Move credentials class under the v2beta2 module