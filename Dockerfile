FROM ruby:3.2.2-alpine

RUN apk add --update \
  build-base postgresql-dev nodejs yarn \
  tzdata git vim openssh memcached \
  && rm -rf /var/cache/apk/*

# Russian locale settings
ENV LANG ru_RU.UTF-8
# ENV LANGUAGE ru_RU.UTF-8
# ENV LC_ALL ru_RU.UTF-8

RUN gem install bundler --version=2.3.7 --no-doc \
  && bundle config set force_ruby_platform true
WORKDIR /tmp
COPY Gemfile* ./
RUN bundle install

WORKDIR /usr/src
COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
