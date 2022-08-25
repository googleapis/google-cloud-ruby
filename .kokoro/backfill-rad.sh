#!/bin/bash

set -eo pipefail

# Install gems in the user directory because the default install directory
# is in a read-only location.
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH

python3 -m pip install --require-hashes -r .kokoro/releases-requirements.txt
gem install --no-document toys

toys rad backfill -v $LIBRARIES_VERSIONS < /dev/null
