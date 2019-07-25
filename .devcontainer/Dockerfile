FROM ruby:2.6.3-stretch

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y zsh less

RUN gem install bundler

RUN useradd --create-home --user-group --uid 1000 app
RUN mkdir -p /app /original $BUNDLE_PATH
RUN chown -R app /app /original $BUNDLE_PATH

WORKDIR /app

USER app

ENV SHELL=/bin/zsh BUNDLE_PATH=/app/vendor/bundle BUNDLE_JOB=4 HOME=/home/app
