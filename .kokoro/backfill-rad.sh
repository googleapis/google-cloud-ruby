#!/bin/bash

set -eo pipefail

# Install gems in the user directory because the default install directory
# is in a read-only location.
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH

gem install --no-document toys -v '~> 0.22.0'
toys release perform -v --reporter-org=googleapis --gems=$LIBRARIES_VERSIONS --enable-rad --force-republish < /dev/null
