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

# Adds grpc-google-iam-v1 to gemspec
s.replace(
	'google-cloud-tasks.gemspec',
	'gem.add_dependency "google-gax", "~> 1.0"',
	('gem.add_dependency "google-gax", "~> 1.0"' + "\n" + '  gem.add_dependency "grpc-google-iam-v1", "~> 0.6.9"')
)



# Manual steps: 
#     1) lib/google/cloud/tasks/ Move Credentials class under the V2beta2 module
#     2) Add """
# 			if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.1")
# 			  # WORKAROUND: builds are failing on Ruby 2.0.
# 			  # We think this is because of a bug in Bundler 1.6.
# 			  # Specify a viable version to allow the build to succeed.
# 			  gem "jwt", "~> 1.5"
# 			  gem "kramdown", "< 1.17.0" # Error in yard with 1.17.0
# 			end
# 			""" to gemfile