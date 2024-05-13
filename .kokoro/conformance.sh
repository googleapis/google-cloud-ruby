set -x
set -eo pipefail

ruby -v
go version

export PORT=9999

# Start the test proxy

pushd google-cloud-bigtable/test/test_proxy
bundle install
bundle exec ruby test_proxy.rb &
PROXY_PID=$!
echo "Proxy PID: $PROXY_PID"
popd

# Run tests

# Known failures should be listed in this file, one per line, ex:
# TestCheckAndMutateRow_Generic_CloseClient
# TestCheckAndMutateRow_Generic_DeadlineExceeded
# TestMutateRow_Generic_DeadlineExceeded
# TestMutateRow_Generic_CloseClient
# This shell command concatenates all the lines of the file with a pipe as a
# delimiter, to build a regex in the form "test1|test2|test3" for the -skip option
KNOWN_FAILURES=`cat google-cloud-bigtable/test/test_proxy/known_failures.txt | paste -sd '|'`
pushd cloud-bigtable-clients-test/tests
go test -v -proxy_addr=:$PORT -skip=$KNOWN_FAILURES
STATUS=$?
popd

# Shut down the proxy

kill $PROXY_PID

exit ${STATUS}
