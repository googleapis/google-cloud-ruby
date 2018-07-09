import synthtool as s
import synthtool.gcp as gcp
import logging


logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1_library = gapic.ruby_library(
    'kms', 'v1', artman_output_name='google-cloud-ruby/google-cloud-kms',
    config_path='artman_cloudkms.yaml'
)

s.copy(v1_library / 'lib')
s.copy(v1_library / 'test')