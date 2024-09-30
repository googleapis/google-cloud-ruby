#!/bin/bash

set -eo pipefail

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

  # Universe Domain Test project Credentials
  export TEST_UNIVERSE_DOMAIN_CREDENTIAL=$(realpath ${KOKORO_GFILE_DIR}/secret_manager/client-library-test-universe-domain-credential)
  export TEST_UNIVERSE_DOMAIN=$(gcloud secrets versions access latest --project cloud-devrel-kokoro-resources --secret=client-library-test-universe-domain)
  export TEST_UNIVERSE_PROJECT_ID=$(gcloud secrets versions access latest --project cloud-devrel-kokoro-resources --secret=client-library-test-universe-project-id)
  export TEST_UNIVERSE_LOCATION=$(gcloud secrets versions access latest --project cloud-devrel-kokoro-resources --secret=client-library-test-universe-storage-location)


  gem install --no-document toys

  toys ci -v --load-kokoro-context $EXTRA_CI_ARGS < /dev/null
done
