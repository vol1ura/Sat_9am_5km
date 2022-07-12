FROM ruby:3.1.0-alpine

RUN apk add --update \
  build-base \
  postgresql-dev \
  tzdata git vim openssh \
  && rm -rf /var/cache/apk/*

# Russian locale settings
# ENV LANG ru_RU.UTF-8
# ENV LANGUAGE ru_RU.UTF-8
# ENV LC_ALL ru_RU.UTF-8

WORKDIR /tmp
COPY Gemfile* ./
RUN bundle install

WORKDIR /usr/src
COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
