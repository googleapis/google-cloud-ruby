#!/bin/bash

set -eo pipefail

# TODO: Remove these when the docker image sets them.
export OLDEST_RUBY_VERSION=2.5.8
export NEWEST_RUBY_VERSION=3.0.0
export RBENV_ROOT=/root/.rbenv
export PYENV_ROOT=/root/.pyenv
export NODENV_ROOT=/root/.nodenv

# Get requested ruby versions. Use the default if not given.
ruby_versions=($RUBY_VERSIONS)
if [ "${#ruby_versions[@]}" = "0" ]; then
  ruby_versions=(DEFAULT)
fi

# Run tests against all requested ruby versions.
for ruby_version in "${ruby_versions[@]}"; do
  # Interpret special symbolic version names.
  if [ "$ruby_version" = "OLDEST" ]; then
    ruby_version=$OLDEST_RUBY_VERSION
  elif [ "$ruby_version" = "NEWEST" ]; then
    ruby_version=$NEWEST_RUBY_VERSION
  elif [ "$ruby_version" = "DEFAULT" ]; then
    ruby_version=
  fi
  if [ -n "$ruby_version" ]; then
    echo "**** USING RUBY $ruby_version ****"
    rbenv local "$ruby_version"
  else
    echo "**** USING DEFAULT RUBY ****"
  fi

  # Install gems in the user directory because the default install directory
  # is in a read-only location.
  export GEM_HOME=$HOME/.gem
  export PATH=$GEM_HOME/bin:$PATH

  gem install --no-document toys

  toys ci -v --load-kokoro-context $EXTRA_CI_ARGS < /dev/null
done
