# Setup universe domain testing needed environment variables.
export TEST_UNIVERSE_DOMAIN_CREDENTIAL=$(realpath ${KOKORO_GFILE_DIR}/secret_manager/client-library-test-universe-domain-credential)
export TEST_UNIVERSE_DOMAIN=$(gcloud secrets versions access latest --project cloud-devrel-kokoro-resources --secret=client-library-test-universe-domain)
export TEST_UNIVERSE_PROJECT_ID=$(gcloud secrets versions access latest --project cloud-devrel-kokoro-resources --secret=client-library-test-universe-project-id)
export TEST_UNIVERSE_LOCATION=$(gcloud secrets versions access latest --project cloud-devrel-kokoro-resources --secret=client-library-test-universe-storage-location)