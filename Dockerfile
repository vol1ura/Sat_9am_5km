FROM ruby:3.2.2-alpine

RUN apk --no-cache add \
    build-base postgresql-dev nodejs yarn \
    tzdata vim openssh vips-dev

# Russian locale settings
ENV LANG ru_RU.UTF-8
# ENV LANGUAGE ru_RU.UTF-8
# ENV LC_ALL ru_RU.UTF-8

WORKDIR /tmp
RUN gem install bundler --version=2.4.10 --no-doc && \
    bundle config set force_ruby_platform true
COPY Gemfile* .
RUN bundle install

WORKDIR /usr/src
COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
