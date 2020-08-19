FROM gcr.io/cloud-devrel-kokoro-resources/yoshi-ruby/multi as ruby_base

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update && apt-get -y upgrade && apt-get --no-install-recommends install -y nodejs
