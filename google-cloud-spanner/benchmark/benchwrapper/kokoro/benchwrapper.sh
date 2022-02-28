#!/bin/bash

# Fail on any error.
set -e

# Display commands being run.
set -x

# Install gems in the user directory because the default install directory
# is in a read-only location.
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH

# install bundler using gem so an up-to-date version is available.
gem install --no-document bundler

export SPANNER_EMULATOR_HOST=localhost:9010
cd $PROJECT_ROOT/google-cloud-spanner/benchmark/benchwrapper
bundle install
bundle exec benchwrapper.rb --port=8081 &
docker pull gcr.io/cloud-spanner-emulator/emulator
docker run -p 9010:9010 -p 9020:9020 gcr.io/cloud-spanner-emulator/emulator &
