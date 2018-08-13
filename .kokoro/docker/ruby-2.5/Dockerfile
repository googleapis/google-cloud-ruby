FROM ruby:2.5-stretch

ENTRYPOINT /bin/bash

RUN apt-get update && apt-get upgrade -y

# Set the locale
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y locales

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN dpkg-reconfigure --frontend=noninteractive locales
RUN update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8 