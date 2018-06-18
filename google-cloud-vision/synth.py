import synthtool as s
import synthtool.gcp as gcp
import logging
from pathlib import Path
import subprocess
import os


logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

# tasks has two product names, and a poorly named artman yaml
v1_library = gapic.ruby_library(
    'vision', 'v1', artman_output_name='google-cloud-ruby/google-cloud-vision'
)

# Copy all files except for 'README.md'
# s.copy(v1_library, os.getcwd())
s.copy(v1_library)

s.replace(
    "test/google/cloud/vision/v1/image_annotator_client_test.rb",
    "assert_not_nil",
    "refute_nil")

s.replace(
    "lib/google/cloud/vision/v1/image_annotator_client.rb",
    "google/cloud/vision/credentials",
    "google/cloud/vision/v1/credentials")

s.replace(
    "Rakefile",
    "google/cloud/vision/credentials",
    "google/cloud/vision/v1/credentials")